# How can several scopes transform one publication?

A score may pass through several adjustments: add one point, then double the
result. We could compose two functions directly. A hook gives surrounding
scopes a way to register those transformations while the calculation publishes
an ordinary typed value.

A hook API is an effect with exactly one operation named `publish`, whose
input and result types are equal. `hook` establishes a root with an identity
transformation. Each `register` adds a transformer for its body's scope.

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

Publication uses the ordinary `perform` syntax. The value `3` travels through
the outer transformation first, becoming `4`, and the inner transformation
then produces `8`. Run the file from this lesson's `src` directory:

```text
$ ash 01-transform-order.ash
8 : Int
```

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

The first publication uses the increment registration. The nested root starts
an empty identity chain, so its publication returns `3` unchanged. After that
root finishes, the outer registration is still active:

```text
$ ash 02-nested-root.ash
(4, 3, 4) : (Int, Int, Int)
```

A root does not accumulate every registration in the program. Its exact
instance and lexical nesting determine the chain used by a publication.

## Callbacks use the context around registration

A transformer can itself request an effect. In `03-callback-context.ash`,
`adjust` asks for a bonus:

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

The direct bonus request in the publication body receives `100`. That value
is deliberately ignored. When publication invokes `adjust`, its request uses
the handler surrounding the registration and receives `2`, giving:

```text
$ ash 03-callback-context.ash
5 : Int
```

The handler installed only around the publication does not interpret the
callback's bonus request. The callback runs through its registration's handler
clause, outside that publication-only handler. E4's distinction between body
requests and clause requests explains the difference.

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

The stop request arrives before publication. Discard closes the owned
registration without invoking its transformer or the remaining publication.
The clause returns `7`. The later publication occurs after that registration
has closed, so the root returns `5` unchanged and the callback count stays zero:

```text
$ ash 05-discard-registration.ash
(7, 5, 0) : (Int, Int, Int)
```

The callback captures cell access, but its owner surrounds the whole hook and
all callback uses. The dependency rules from E8 still apply. Registration is
not permission to return access beyond the cell's lifetime.

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

The waiting registration is preserved. Its publication invokes `change` once
and produces `4`. Normal completion then removes the registration. The later
publication again returns the root's unchanged `5`:

```text
$ ash 06-resume-registration.ash
(4, 5, 1) : (Int, Int, Int)
```

Removing a registration does not run its transformer as a destructor. Cleanup
actions are a separate feature. As with other completion owners, discard may
close a registration inside its owned abandoned segment; it cannot skip a
required owner outside that segment. Hooks introduce no escaping registration
token or arbitrary removal operation.

## Practice: trace the value and the lifetime

1. Reverse the two registrations in `01-transform-order.ash`. Predict the
   result by applying the functions in their new order.
2. Put a registration inside the nested root of `02-nested-root.ash`.
   Predict which tuple field changes.
3. Change only the publication-body bonus handler in `03-callback-context.ash`.
   Explain which request uses it before predicting the final result.
4. Move the stop request after publication in `05-discard-registration.ash`.
   Predict the callback count and which later work is abandoned.

Hook roots and registrations organize ordinary typed transformations within
scopes. Their order, callback context, and completion obligations determine
what a publication does. Next we will use the same resource-lifetime model
with a provider whose acquisition can fail before its body begins.

[hooks]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#synchronous-typed-hooks
