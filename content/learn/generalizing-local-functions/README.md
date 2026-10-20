# When can a local function work at several types?

The previous chapter gave a global identity function the signature `A -> A`.
Each use chose its own type for `A`. A block can also name a function whose
work does not depend on one particular input type. We need to distinguish
that reusable definition from a binding that holds one already chosen
function value.

The distinction concerns how the local binding is written and checked. Two
functions that return their inputs can have different reuse contracts.

## Give each use its own type choice

In `01-local-identity.ash`, the initializer is an anonymous function and the
binding has no annotation:

<!-- source: src/01-local-identity.ash -->
```ash
main : Unit -> (Int, Bool)
main () = {
    let identity = fn(value) {
        value
    }
    (identity 42, identity true)
}
```

Ash infers that the input and result must have the same type. Nothing fixes
that type to `Int` or `Bool`, and it does not belong to an enclosing binding.
The compiler leaves it open for each use of `identity`. This is called
*local generalization*.

Predict the function type needed by each use and the resulting pair's type.
From this lesson's `src` directory, run:

```text
$ ash 01-local-identity.ash
(42, true) : (Int, Bool)
```

At the first occurrence, `identity` has the chosen type `Int -> Int`. At the
second, it has `Bool -> Bool`. Both choices come from the same definition.

This rule applies when an unannotated `let` binds one name and its initializer
is syntactically an anonymous function. It generalizes only still-open type
choices that do not come from the surrounding environment. It does not make
every local binding polymorphic.

## An annotation chooses one contract

`02-annotated-identity.ash` supplies an ordinary function type explicitly:

<!-- source: src/02-annotated-identity.ash -->
```ash
main : Unit -> (Int, Bool)
main () = {
    let identity : Int -> Int = fn(value) {
        value
    }
    (identity 42, identity true)
}
```

Compare the annotation's input with each supplied argument. Can both uses
meet that one contract? Keep this lesson's `src` directory as the working
directory for its diagnostic commands:

<!-- diagnostic: src/02-annotated-identity.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-annotated-identity.ash
This function argument must have type `Int`, but has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/02-annotated-identity.ash:6:28
6 |     (identity 42, identity true)
  |                            ^ This has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/02-annotated-identity.ash:6:19
6 |     (identity 42, identity true)
  |                   ^ This function requires an argument of type `Int`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/02-annotated-identity.ash:6:19
6 |     (identity 42, identity true)
  |                   ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The labels connect `true` to the integer argument required by `identity`.
The annotation checks one type; it introduces no new type parameters. Remove
it to recover the first program's eligible binding, or keep the annotation and
use the function only with integers.

A global signature can introduce parameters. A local annotation does not
have that role, even if an enclosing definition already has a parameter whose
name can appear in the annotation.

## A call produces one function value

The initializer in `03-returned-function.ash` is a call:

<!-- source: src/03-returned-function.ash -->
```ash
make_identity : Unit -> A -> A
make_identity () = fn(value) {
    value
}

main : Unit -> (Int, Bool)
main () = {
    let identity = make_identity ()
    (identity 42, identity true)
}
```

`make_identity` itself is polymorphic. Each occurrence chooses one type for
`A`, but its returned function is bound by a call initializer, not by the
eligible anonymous-function syntax. That binding keeps one shared choice.
Which use fixes the function's input, and can the other use keep that choice?

<!-- diagnostic: src/03-returned-function.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 03-returned-function.ash
This function argument must have type `Int`, but has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/03-returned-function.ash:9:28
9 |     (identity 42, identity true)
  |                            ^ This has type `Bool`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/03-returned-function.ash:9:19
9 |     (identity 42, identity true)
  |                   ^ This function requires an argument of type `Int`.
  --> /path/to/ash-doc/content/learn/generalizing-local-functions/src/03-returned-function.ash:9:19
9 |     (identity 42, identity true)
  |                   ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The diagnostic again marks a Boolean supplied to an integer function. The
cause is now the shared inferred type of the returned function, rather than
an explicit annotation. Ash does not inspect the factory's body and treat its
result as though the local initializer had been an anonymous function.

If we need two separately chosen function values, call the factory twice:

<!-- source: src/04-separate-creations.ash -->
```ash
make_identity : Unit -> A -> A
make_identity () = fn(value) {
    value
}

main : Unit -> (Int, Bool)
main () = {
    let integer_identity = make_identity ()
    let boolean_identity = make_identity ()
    (integer_identity 42, boolean_identity true)
}
```

There are now two factory occurrences. Predict whether their type choices
must agree, and whether the pair can satisfy `main`'s result type:

```text
$ ash 04-separate-creations.ash
(42, true) : (Int, Bool)
```

Each occurrence of `make_identity` supplies its own choice. Alternatively,
write the local anonymous function directly when one generalized definition
expresses the intended reuse.

The similar function bodies have different places for choosing types:

| Binding | Where the type is chosen |
| --- | --- |
| Direct unannotated anonymous function (`01`) | At each use |
| Annotated function (`02`) | In the one declared local type |
| One factory result (`03`) | Shared by uses of that returned value |
| Separate factory results (`04`) | Independently at each factory call |

## Keep captured types fixed

A local function can capture an enclosing value while leaving its own input
open. `05-captured-input.ash` pairs each input with a saved value:

<!-- source: src/05-captured-input.ash -->
```ash
pair_with : A -> ((A, Int), (A, Bool))
pair_with saved = {
    let pair = fn(value) {
        (saved, value)
    }
    (pair 42, pair true)
}

main : Unit -> ((Bool, Int), (Bool, Bool))
main () = pair_with false
```

Within `pair_with`, the type of `saved` is the enclosing parameter `A`.
The local definition cannot choose a different type for that captured value.
It can generalize its new input type, which is independent of `saved`.
Predict the type of both fields in each pair before running:

```text
$ ash 05-captured-input.ash
((false, 42), (false, true)) : ((Bool, Int), (Bool, Bool))
```

Both pairs retain the same Boolean in their first field. Their second fields
have different types. Generalization preserves connections to enclosing
values rather than inventing a new type for each capture.

## Passing a function chooses an ordinary function type

A generalized name can be used as an argument too:

<!-- source: src/06-function-arguments.ash -->
```ash
apply_twice : (A -> A, A) -> A
apply_twice (transform, value) = transform (transform value)

main : Unit -> (Int, Bool)
main () = {
    let identity = fn(value) {
        value
    }
    (apply_twice (identity, 42), apply_twice (identity, true))
}
```

Each `apply_twice` call chooses one `A`. Its `transform` parameter is one
ordinary `A -> A` function for that call; it is not a parameter that may be
called at unrelated types within the body. The two occurrences of `identity`
are instantiated separately before they meet those parameter contracts.
Predict the two results and identify which one function type each
`transform` parameter uses throughout its call:

```text
$ ash 06-function-arguments.ash
(42, true) : (Int, Bool)
```

This is the rank-1 boundary: general type choices belong to global signatures
and eligible local definitions. Ordinary function parameters and results do
not contain another layer of polymorphic contract. A tuple or an application
initializer likewise does not acquire generalization merely by storing a
function.

The [block rules][blocks] specify eligible bindings, and the
[inference rules][inference] specify which variables remain fixed. Every
inference choice must eventually be solved or generalized; an unused name
does not excuse an unresolved type.

## Optional connection: preserving callback effects

You can continue directly to the next Learn chapter. Return to this example
after [the effects lesson on callback rows](../../effects/preserving-callback-effects/README.md),
where requests, handlers, and effect rows have been introduced.

<!-- source: src/07-local-effect-row.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

request_bonus : Unit -> Int ! {Bonus}
request_bonus ignored = perform Bonus.amount ()

main : Unit -> (Int, Int)
main () = {
    let apply = fn((function, value)) {
        function value
    }
    let constant = fn(ignored) {
        40
    }
    let first = apply (constant, ())
    let second = handle (apply (request_bonus, ())) with Bonus {
        amount ignored => resume 2
    }
    (first, second)
}
```

The direct anonymous initializer lets `apply` generalize its callback's input,
result, and effect row. Identify the callback requirement at each call, then
predict both integers. The second call places a handler around the callback's
request:

```text
$ ash 07-local-effect-row.ash
(40, 2) : (Int, Int)
```

The pure callback returns `40`; the effectful callback receives `2` from
its handler. The row choice follows each callback, just as the input type
follows each argument. Generalization preserves the row's constraints and
retains its effects. It introduces no interface requirements; those come from
the contracts and evidence taught in the library path.

## Exercise: locate the type choice

For each task, make a fresh copy of its named source in a scratch directory
outside this lesson's `src` tree. Predict the observation, then run that copy
from its directory.

1. Change `01-local-identity.ash` to return three uses, with integer, Boolean,
   and unit inputs. Update the entry result type before running it.
2. In `04-separate-creations.ash`, give both functions integer inputs. Explain
   why two separately chosen types may still turn out to be equal.
3. Change `pair_with false` to `pair_with 7` in `05-captured-input.ash` and
   update `main`'s result type. Predict which fields change type.
4. In `06-function-arguments.ash`, replace one identity argument with a function
   that adds one. Trace the two calls inside `apply_twice`.

A local function's reuse comes from its binding and its connections to the
enclosing environment. We can now distinguish a generalized definition from
one stored function value. The next chapter asks how local definitions can
refer to themselves and to one another while being initialized safely.

[blocks]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#blocks
[inference]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#inference-and-rank-1-restrictions
