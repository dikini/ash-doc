# How can a calculation request a value from its caller's context?

A score might combine points earned with a bonus chosen for the round. The
calculation needs that bonus, but it need not decide what the bonus is. So far,
we have supplied values like this through function arguments. An *effect*
gives us another way: the calculation requests a value, and a surrounding
*handler* answers the request.

We will keep the calculation small enough to follow each step. First we will
pass the bonus directly. Then we will request it and see how different handlers
supply different answers.

## Pass the bonus as an argument

Here is the argument-based version in `01-explicit.ash`:

<!-- source: src/01-explicit.ash -->
```ash
score : (Int, Int) -> Int
score (points, bonus) = points + bonus

main : Unit -> Int
main () = score (40, 2)
```

The pair supplies both inputs. Matching it binds `points` to `40` and `bonus`
to `2`, so the result is `42`. Run it from this lesson's `src` directory:

```text
$ ash 01-explicit.ash
42 : Int
```

This version already solves the problem. Keep it in mind as we change how the
calculation obtains the bonus. The addition itself will stay the same.

## Request the bonus

In `02-handled.ash`, `score` receives only the points. It requests the bonus
when it needs to add it:

<!-- source: src/02-handled.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

main : Unit -> Int
main () = handle (score 40) with Bonus {
    amount ignored => resume 2
}
```

The declaration `effect Bonus` names an effect API. Its one operation,
`amount : Unit -> Int`, accepts `()` and produces an integer. The declaration
describes the request; it does not choose the integer that answers it.

`perform Bonus.amount ()` makes that request. The `()` supplies the operation's
`Unit` input. Once the request receives an integer answer, the addition can
finish. A request uses `perform`; declaring the operation does not give it an
ordinary function body to call.

The signature `score : Int -> Int ! {Bonus}` records both parts of the
calculation's contract. Calling `score` takes an integer and returns an integer,
and it may request operations from `Bonus`. The part after `!` is an *effect
row*. `{Bonus}` is a closed row containing that one effect: it has no variable
standing for further effects. It names the required effect API, not the value
of the bonus or a particular handler.

This extends the pure function signatures used in Learn. A result written
without an effect row, as in `Int -> Int`, has an empty row: calling that
function must leave no effects for its caller to handle. The row describes
requirements, not a second value returned by the function.

## Answer the request

The expression `handle (score 40) with Bonus { ... }` evaluates `score 40`
under a handler for `Bonus`. Its `amount` clause answers an `amount` request.
`ignored` binds the operation's `Unit` input; the clause does not use it.

`resume 2` supplies `2` as the operation's answer and continues the calculation
that was waiting for it. In this example, the waiting work is adding that
answer to `40`. The resumed calculation finishes with `42`, which is also the
handler's result.

Trace the whole call before running it:

1. `score 40` begins evaluating its addition.
2. `perform Bonus.amount ()` requests the missing integer.
3. The handler's `amount` clause answers through `resume 2`.
4. The addition finishes as `40 + 2`.

```text
$ ash 02-handled.ash
42 : Int
```

A handler must supply a clause for every operation in its effect. `Bonus` has
only `amount`, so this handler is complete. The clause also has a responsibility
to consume the suspended continuation exactly once on every normally
completing path. Here it does so with its single `resume`. A continuation is
the work suspended at the request; resuming it supplies the answer that work
needs. We will examine other control choices later.

The handler answers the calculation's `Bonus` request, and its clause adds no
further effect requirement. That is why `main` can retain the signature
`Unit -> Int`. The resulting integer is the same as in the explicit-argument
version; the way the calculation obtains the bonus has changed.

The specification's [effect rules][effects] describe these request, handler,
and resumption boundaries. Its [computation types and effect rows][rows]
describe the signature notation.

## Change the answer, keep the calculation

Suppose another round grants a bonus of five points. In
`03-different-bonus.ash`, only the handler's answer changes:

<!-- source: src/03-different-bonus.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

main : Unit -> Int
main () = handle (score 40) with Bonus {
    amount ignored => resume 5
}
```

Compare this file with the preceding one. The effect declaration, `score`
signature, and `score` definition are unchanged. Follow the request with the
new answer and predict the result, then run it:

```text
$ ash 03-different-bonus.ash
45 : Int
```

The calculation still asks for an integer and adds it to the points. The
handler now supplies `5`, so the resumed addition produces `45`. `score` does
not select the handler or contain either bonus value.

## A row records a need; it does not answer it

What if we call `score` without a handler? In `04-unhandled.ash`, the signature
of `main` records the `Bonus` requirement that this call leaves outward:

<!-- source: src/04-unhandled.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

main : Unit -> Int ! {Bonus}
main () = score 40
```

The annotation describes the requirement, but there is no handler to supply
the bonus. Ash's [entry contract][entry] requires `main` to have an empty effect
row.
Running this file therefore produces a rejection before the calculation runs:

<!-- diagnostic: src/04-unhandled.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-unhandled.ash
Calling `main` must require no effects from its caller.
  --> /path/to/ash-doc/content/effects/requesting-a-value/src/04-unhandled.ash:8:1
8 | main : Unit -> Int ! {Bonus}
  | ^ This is the local `main` declaration.
reason: entry.main-effects
```
<!-- markdownlint-enable MD013 -->

The message points at the local `main` declaration. Its `! {Bonus}` records an
effect that would need a caller to handle it, but `main` is the program's entry.
There is no source caller outside that entry to supply the missing handler.
`entry.main-effects` identifies this entry-contract rejection.

Restore the handled `main` from `02-handled.ash`, including its `Unit -> Int`
signature, and run the file again. The handler supplies the answer and removes
the outward requirement. Merely erasing `! {Bonus}` would not answer the
request or make the calculation pure.

## Practice: choose a different scoring rule

Work in a copy of `02-handled.ash`.

1. Change the handler's answer to `7`. Before running the program, trace the
   request and predict the score. Explain which source line supplies the
   bonus and which line uses it.
2. Change `score` so that it doubles the earned points before adding the
   requested bonus. Keep the handler unchanged. Predict, run, and explain the
   new result.
3. Write the equivalent pure version with an explicit bonus argument. Compare
   the two versions: where does each one receive the bonus, and which part
   chooses its value?

You now have two ways to supply the same calculation with a value. An argument
passes it directly. An effectful calculation requests it, records that need in
its row, and continues when a handler resumes it with an answer.

This example puts one call inside one handler. The next question is how the
requirement travels when one function calls another, or returns a function
that will make the request later.

[effects]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#effects
[rows]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#computation-types-and-effect-rows
[entry]: https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#globals-and-modules
