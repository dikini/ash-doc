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

The pair supplies both inputs. Follow how matching it binds `points` and
`bonus`, then work out the addition. Predict the value and its type before
running the program from this lesson's `src` directory:

```text
$ ash 01-explicit.ash
42 : Int
```

`main` supplies `40` as the earned points and chooses `2` as the round's
bonus. `score` uses those inputs to calculate `40 + 2`, producing `42`.
The integer result agrees with its declared result type, `Int`.

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

In `score`, `perform Bonus.amount ()` requests the missing bonus. The `()`
supplies the operation's `Unit` input. The addition needs an integer answer
before it can finish. A request uses `perform`; declaring the operation does
not give it an ordinary function body to call.

The signature `score : Int -> Int ! {Bonus}` records both parts of the
calculation's contract. Calling `score` takes an integer and returns an integer,
and it may request operations from `Bonus`. The part after `!` is an *effect
row*. `{Bonus}` is a closed row containing that one effect: it has no variable
standing for further effects. It names the required effect API, not the value
of the bonus or a particular handler.

The row tells a caller what must be accounted for when running the
calculation. It supplies no answer itself. Follow the handler to see where
the bonus comes from.

## Answer the request

The expression `handle (score 40) with Bonus { ... }` evaluates `score 40`
under a handler for `Bonus`. Its `amount` clause answers an `amount` request.
`ignored` binds the operation's `Unit` input; the clause does not use it.

`resume 2` supplies `2` as the operation's answer and continues the calculation
that was waiting for it. The waiting work is the addition in `score`.

Trace the call and predict the resulting score before running it:

1. `score 40` begins evaluating its addition.
2. `perform Bonus.amount ()` requests the missing integer.
3. The handler's `amount` clause answers through `resume 2`.
4. The addition finishes as `40 + 2`.

```text
$ ash 02-handled.ash
42 : Int
```

The handler chooses `2`, and `score` uses it in `40 + 2`. The resumed
calculation produces `42`, which is also this handler's result. The value
matches the argument-based version, but `score` now obtains the bonus through
a request instead of receiving it in its argument.

A handler must supply a clause for every operation in its effect. `Bonus` has
only `amount`, so this handler is complete. The clause also has a responsibility
to consume the suspended continuation exactly once on every normally
completing path. Here it does so with its single `resume`. A continuation is
the work suspended at the request; resuming it supplies the answer that work
needs. We will examine other control choices later.

The handler accounts for the calculation's `Bonus` requirement, and its
clause adds no further effect requirement. That is why `main` can retain the
signature `Unit -> Int`. As with the pure signatures used in Learn, omitting
the row means it is empty: calling the function must leave no effects for
its caller to handle. The row describes requirements, not a second value
returned by the function.

The specification's [effect rules][effects] describe these request, handler,
and resumption boundaries. Its [computation types and effect rows][rows]
describe the signature notation, and its [handler evaluation rules][evaluation]
describe how the answer continues the suspended calculation.

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

Follow the call from `main` to the request in `score`. Which part of this
program could supply the missing integer? Compare the two versions of `main`:
does recording `{Bonus}` supply an answer, or describe a need that remains?
Run the file to inspect what happens at the program's entry:

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

There is no handler here to answer the request. The message points at the
local `main` declaration, whose `! {Bonus}` records the requirement left by
calling `score`. Ash's [entry contract][entry] requires `main` to have an empty
effect row: there is no source caller outside the program's entry to handle
that requirement. The file is rejected before the calculation runs.
`entry.main-effects` identifies this entry-contract rejection.

Restore the handled `main` from `02-handled.ash`, including its `Unit -> Int`
signature, and run the file again. The handler supplies the answer and removes
the outward requirement. Merely erasing `! {Bonus}` would not answer the
request or make the calculation pure.

## Practice: choose a different scoring rule

Start each task from a fresh copy of `02-handled.ash`, so changes from one
task do not affect the next.

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

[effects]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#effects
[rows]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#computation-types-and-effect-rows
[evaluation]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#effect-handlers-and-completion
[entry]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#globals-and-modules
