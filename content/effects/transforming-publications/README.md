# Transforming publications

A score may pass through several adjustments: add one point, then double the
result. We could compose two functions directly. A hook gives surrounding
scopes a way to register those transformations while the calculation publishes
an ordinary typed value.

A hook API is an effect with exactly one operation named `publish`, whose
input and result types are structurally equal under the declaration's own
parameters, before substituting arguments at a use. `hook` establishes a root
with an identity transformation. Each `register` adds a transformer for its
body's scope.

## Transform in registration order

In `01-transform-order.ash`, the outer registration increments and the inner
registration doubles:

<!-- source: src/01-transform-order.ash -->
```ash
effect Adjust {
    publish : Int -> Int
}

increment : Int -> Int
increment value = value + 1

double : Int -> Int
double value = value * 2

main : Unit -> Int
main () = hook Adjust {
    register Adjust increment {
        register Adjust double {
            perform Adjust.publish 3
        }
    }
}
```

Publication uses ordinary `perform` syntax. It applies the outer
transformation first, then the inner one. Predict the two intermediate values
for payload `3` before running from this lesson's `src` directory:

```text
$ ash 01-transform-order.ash
8 : Int
```

Increment changes `3` to `4`; double changes `4` to `8`. The
[hook evaluation rules][execution] describe this outer-to-inner chain.
Each transformer is an ordinary `Int -> Int` function. Registration evaluates
the transformer expression once and retains the resulting function for that
scope. It does not call the transformer until a publication reaches it.

## A nested root starts a separate chain

`02-nested-root.ash` publishes before, inside, and after a nested root for the
same exact effect instance:

<!-- source: src/02-nested-root.ash -->
```ash
effect Adjust {
    publish : Int -> Int
}

increment : Int -> Int
increment value = value + 1

double : Int -> Int
double value = value * 2

main : Unit -> (Int, Int, Int)
main () = hook Adjust {
    register Adjust increment {
        let before = perform Adjust.publish 3
        let inside = hook Adjust {
            perform Adjust.publish 3
        }
        (before, inside, perform Adjust.publish 3)
    }
}
```

The nested root starts a fresh identity chain for this exact instance.
For each publication, locate its nearest root and the registrations inside
that root. Predict the three fields before running:

```text
$ ash 02-nested-root.ash
(4, 3, 4) : (Int, Int, Int)
```

The first publication uses increment and returns `4`. Inside the nested root
there is no registration, so publication returns `3`. After it closes, the
outer registration is still active and produces `4` again.
A root does not accumulate every registration in the program. Its exact
instance and lexical nesting determine the chain used by a publication.

## Callbacks use the context around registration

A transformer can itself request an effect. In `03-callback-context.ash`,
`adjust` asks for a bonus. Callbacks run through a generated handler clause
outside handlers placed only around publication. The
[handler-selection lesson](../choosing-a-handler/README.md) distinguished
body requests from clause requests; use that distinction to locate the
context surrounding registration:

<!-- source: src/03-callback-context.ash -->
```ash
effect Adjust {
    publish : Int -> Int
}

effect Bonus {
    amount : Unit -> Int
}

adjust : Int -> Int ! {Bonus}
adjust value = value + (perform Bonus.amount ())

main : Unit -> Int
main () = hook Adjust {
    handle (register Adjust adjust {
        handle {
            let ignored = perform Bonus.amount ()
            perform Adjust.publish 3
        } with Bonus {
            amount ignored => resume 100
        }
    }) with Bonus {
        amount ignored => resume 2
    }
}
```

Trace the direct bonus request and the request made by `adjust` separately.
Which handler answers each, and which answer contributes to the published
result?

```text
$ ash 03-callback-context.ash
5 : Int
```

The direct request receives `100`, which its binding ignores. The callback's
request receives `2` from the handler surrounding registration, so
`adjust` computes `3 + 2`. The callback runs through the registration's
generated clause, outside the handler installed only around publication.
An ordinary closure keeps lexical values; creating it under a handler does
not store that handler. Here the registration's clause determines the
callback's handler context.

Callback effects remain requirements of the registration even when one input
never publishes. A hook root handles its own target, not every effect used by
subscribers. The [hook rules][hooks] define these contexts and outward rows.

## Qualify the API before specializing it

`04-invalid-api.ash` declares a conversion with different input and result
parameters:

<!-- source: src/04-invalid-api.ash -->
```ash
effect Convert<A, B> {
    publish : A -> B
}

main : Unit -> Int
main () = hook Convert<Int, Int> {
    perform Convert<Int, Int>.publish 3
}
```

Compare `A` and `B` in the declaration before substituting `Int`. Does this
API meet the hook requirement, regardless of this particular use?

<!-- diagnostic: src/04-invalid-api.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-invalid-api.ash
An API used by `hook` or `register` must declare exactly one operation, `publish`, whose parameter and result types are equal before type arguments are substituted.
  --> /path/to/ash-doc/content/effects/transforming-publications/src/04-invalid-api.ash:6:16
6 | main () = hook Convert<Int, Int> {
  |                ^ An API used by `hook` or `register` must declare exactly one operation, `publish`, whose parameter and result types are equal before type arguments are substituted.
reason: type.hook-api
```
<!-- markdownlint-enable MD013 -->

Even though this use supplies `Int` for both parameters, the declaration does
not promise one unchanged payload type. Its domain is `A` and its result is
`B`. Qualification happens before use-site substitution. Use a declaration
such as `Adjust`, whose `publish : Int -> Int` has equal input and result
types, or a one-parameter API with `publish : A -> A`.

The diagnostic points at the target that fails qualification. Changing only
the callback or publication value would not repair the API declaration.

## Abandon a registration without calling its transformer

A registration has a lifetime as well as a transformation. In
`05-discard-registration.ash`, a cell counts actual callback invocations:

<!-- source: src/05-discard-registration.ash -->
```ash
import @builtin.cell as Cell

effect Adjust {
    publish : Int -> Int
}

effect Stop {
    now : Unit -> Unit
}

main : Unit -> (Int, Int, Int)
main () = resource cell<R> calls = 0 {
    let change : Int -> Int ! {Cell.Ops<R>} = fn(value) {
        let ignored = Cell.write (calls, (Cell.read calls) + 1)
        value + 1
    }
    hook Adjust {
        let result = handle (register Adjust change {
            let ignored = perform Stop.now ()
            perform Adjust.publish 3
        }) with Stop {
            now ignored => {
                let ignored = discard
                7
            }
        }
        let later = perform Adjust.publish 5
        (result, later, Cell.read calls)
    }
}
```

Discard can close an owned registration without invoking its transformer.
The stop request arrives before publication. Predict the three fields:
the clause's result, the later publication after closing, and the number of
actual calls to `change`:

```text
$ ash 05-discard-registration.ash
(7, 5, 0) : (Int, Int, Int)
```

The remaining publication is skipped and the clause returns `7`. The
registration is gone before the later publication, which returns the root's
unchanged `5`. No callback ran, so the count is `0`.
The callback captures cell access, but its owner surrounds the whole hook and
all callback uses. The dependency rules from the
[resource-scope lesson](../keeping-access-in-scope/README.md) still apply.
Registration is not permission to return access beyond the cell's lifetime.

## Resume with the registration still owned

`06-resume-registration.ash` instead resumes the stopped work:

<!-- source: src/06-resume-registration.ash -->
```ash
import @builtin.cell as Cell

effect Adjust {
    publish : Int -> Int
}

effect Stop {
    now : Unit -> Unit
}

main : Unit -> (Int, Int, Int)
main () = resource cell<R> calls = 0 {
    let change : Int -> Int ! {Cell.Ops<R>} = fn(value) {
        let ignored = Cell.write (calls, (Cell.read calls) + 1)
        value + 1
    }
    hook Adjust {
        let result = handle (register Adjust change {
            let ignored = perform Stop.now ()
            perform Adjust.publish 3
        }) with Stop {
            now ignored => {
                resume ()
            }
        }
        let later = perform Adjust.publish 5
        (result, later, Cell.read calls)
    }
}
```

Resumption preserves the waiting registration and continues after the stop
request. Predict the callback count and both publication results, accounting
for where normal completion removes the registration:

```text
$ ash 06-resume-registration.ash
(4, 5, 1) : (Int, Int, Int)
```

The resumed publication invokes `change` once and produces `4`. Its scope
then closes normally; the later publication returns `5` from the identity
root. The counter records that one invocation.
Removing a registration does not run its transformer as a destructor. Cleanup
actions are a separate feature. As with other completion owners, discard may
close a registration inside its owned abandoned segment; it cannot skip a
required owner outside that segment. Hooks introduce no escaping registration
token or arbitrary removal operation.

## Practice: trace the value and the lifetime

Start each task with a fresh copy of its named program in a scratch directory
outside this lesson's `src` tree. Run the copy from that directory.

Reverse the two registrations in `01-transform-order.ash`. Apply the
functions in their new order to predict the result.

Put a registration inside the nested root of `02-nested-root.ash`. Which
tuple field changes?

In `03-callback-context.ash`, change only the publication-body bonus handler.
Which request uses it? Answer before predicting the final result.

Move the stop request after publication in `05-discard-registration.ash`.
What is the callback count, and which later work is abandoned?

Hook roots and registrations organize ordinary typed transformations within
scopes. Their order, callback context, and completion obligations determine
what a publication does. Next we will use the same resource-lifetime model
with a provider whose acquisition can fail before its body begins.

[hooks]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#synchronous-typed-hooks
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#synchronous-hook-execution
