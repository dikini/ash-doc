# Following effect contracts

In the previous lesson, `score` requested a bonus and `main` supplied a handler.
A larger calculation may reach `score` through other functions. Each caller
must account for the request, even when its own body contains no `perform`.

There is another distinction to make when a function returns a function. Does
the request happen while making that function, or when calling it later? The
position of the effect row in the signature tells us which call needs a
handler.

## Follow the request through calls

`01-call-chain.ash` adds two calls around the familiar score calculation:

<!-- source: src/01-call-chain.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

round_score : Int -> Int ! {Bonus}
round_score points = score points

total : Int -> Int ! {Bonus}
total points = round_score points

main : Unit -> Int
main () = handle (total 40) with Bonus {
    amount ignored => resume 2
}
```

Start at `main` and follow `total 40`, then `round_score 40`, then `score 40`.
Only `score` contains a request, but each call needs that request answered
before it can return. This is why all three signatures contain `! {Bonus}`.
An effect row describes the requirements of calling the function, including
work done through other calls.

Trace the answer back from the handler through the addition and the two
callers. Predict the result, then run the file from this lesson's `src`
directory:

```text
$ ash 01-call-chain.ash
42 : Int
```

The handler around `total 40` supplies `2` when the calculation reaches the
request. The addition produces `42`, and the two callers return that same
value. Neither caller writes `perform`; each still requires that request
to be answered.

None of these functions needs a separate handler merely because it calls an
effectful function. It may pass the requirement outward through its contract.
Here `main` handles it, leaving the entry computation with an empty row.

## A pure contract cannot hide a request

In `04-missing-row.ash`, only the signature of `total` changes. It now promises
a pure call:

<!-- source: src/04-missing-row.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

round_score : Int -> Int ! {Bonus}
round_score points = score points

total : Int -> Int
total points = round_score points

main : Unit -> Int
main () = handle (total 40) with Bonus {
    amount ignored => resume 2
}
```

Compare `total`'s new signature with the contract of the function it calls.
Can that body meet the promise of a pure call? Keep the handler in `main`
in view while you run the file and inspect where Ash reports the mismatch:

<!-- diagnostic: src/04-missing-row.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-missing-row.ash
This function body requests effects outside its declared effect row.
  --> /path/to/ash-doc/content/effects/following-effect-contracts/src/04-missing-row.ash:12:16
12 | total points = round_score points
   |                ^ This function body requests effects outside its declared effect row.
reason: effect.row-union-ambiguous
```
<!-- markdownlint-enable MD013 -->

The label points at `round_score points`, the call that brings the requirement
into `total`. The words of the message explain the mismatch: the body requests
an effect outside the declared row. Ash checks `total` against its own
signature. The handler in `main` can answer the eventual request, but it does
not repair that definition's incorrect promise. Restore `! {Bonus}` on
`total`, as in `01-call-chain.ash`, and the contract again describes what the
body does.

This diagnostic uses `effect.row-union-ambiguous`. Here the source contains
only closed rows; the message identifies a body that exceeds its declared
row. Read the explanation and source label rather than assuming that the
reason code alone describes the particular mistake.

## Make a function that requests the bonus later

Suppose we want to remember the points now and calculate the score later.
`02-request-later.ash` returns a function that keeps those points:

<!-- source: src/02-request-later.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

make_score : Int -> Unit -> Int ! {Bonus}
make_score points = fn(ignored) {
    points + (perform Bonus.amount ())
}

main : Unit -> Int
main () = {
    let calculate = make_score 40
    handle (calculate ()) with Bonus {
        amount ignored => resume 2
    }
}
```

`make_score 40` and `calculate ()` are separate calls. Follow the body of
`make_score`: it returns an anonymous function. Which call reaches the
`perform` expression? Trace the request from that point to its handler,
then predict the score:

```text
$ ash 02-request-later.ash
42 : Int
```

Calling `make_score 40` creates a function that keeps the points. It does not
run the anonymous function's body, so it does not request a bonus yet. The
local name `calculate` holds that returned function. Calling `calculate ()`
runs the body and makes the request; that is the call enclosed by the handler.
The clause supplies `2` for the bonus, so the addition produces `42`.

Read `Int -> Unit -> Int ! {Bonus}` from the outside inward. The first call
takes an `Int` and purely returns a function. That function takes `Unit`,
returns an `Int`, and may request `Bonus`. The effect is *latent*: it belongs
to a future call of the returned function.

The function value has a type describing that later call. The computation that
creates the value has its own effects—in this case, none. Creating an anonymous
function is pure even when its body contains a request.

The row's placement explains why `make_score 40` can appear before the handler.
Moving the request into a function body changes when the request happens.

## Request the bonus before returning a function

In `03-request-now.ash`, we instead obtain the bonus while preparing the score.
The returned function remembers both ordinary integers:

<!-- source: src/03-request-now.ash -->
```ash
effect Bonus {
    amount : Unit -> Int
}

prepare_score : Int -> (Unit -> Int) ! {Bonus}
prepare_score points = {
    let bonus = perform Bonus.amount ()
    fn(ignored) {
        points + bonus
    }
}

main : Unit -> Int
main () = {
    let calculate = handle (prepare_score 40) with Bonus {
        amount ignored => resume 2
    }
    calculate ()
}
```

Follow the initializer of `calculate` before moving to the final call.
Does the request happen before or after `prepare_score 40` returns its
function? Trace where the bonus is supplied and what the returned function
keeps, then predict the result:

```text
$ ash 03-request-now.ash
42 : Int
```

The block first requests the bonus and binds its answer to `bonus`. Only then
does it create the anonymous function. The handler therefore surrounds
`prepare_score 40`. Once that call returns, `calculate ()` adds the captured
integers without making another request. It produces the same `42` as the
preceding program, through a different sequence of work.

Compare the two signatures:

| Signature | First call | Returned function's call |
| --- | --- | --- |
| `Int -> Unit -> Int ! {Bonus}` | Pure | May request `Bonus` |
| `Int -> (Unit -> Int) ! {Bonus}` | May request `Bonus` | Pure |

Arrows associate to the right. Without the parentheses, the row attaches to
the innermost result computation. With them, the result of the first call is
the whole pure function type `Unit -> Int`, and `! {Bonus}` describes producing
that result. The matching scores do not make the contracts interchangeable:
one handler surrounds the call that constructs the function, and the other
surrounds the later call of the returned function.

The [computation-type rules][rows] explain how rows attach to arrows. The
[function rules][functions] distinguish creating a function from applying it.
The [application rules][application] describe when its stored body runs.
When checking a call, Ash accounts for evaluating the function expression,
evaluating its argument, and running the function body. Putting an effectful
calculation in an argument does not hide its requirement either.

## Practice: place the handler around the work

Start each task from a fresh copy of its named program in this lesson's `src`
directory.

Add another function between `total` and `round_score` in
`01-call-chain.ash`, writing its signature before its body. Does the new
function need an effect row? Run it to confirm your answer.

In `02-request-later.ash`, change the remembered points and the handler's
answer. Predict the result and identify which call makes the request.

In `03-request-now.ash`, call `calculate ()` twice and return both results as
a tuple. Do those later calls request another bonus? Run the program and
explain the result from the saved values.

An effectful contract follows the work that can make the request. Ordinary
callers carry the requirement outward until a handler answers it. A returned
function carries its later requirements in its own function type.

We can now describe a particular effectful function accurately. The next
question is how a reusable helper can call functions with different effects
without fixing its contract to `Bonus`.

[rows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#computation-types-and-effect-rows
[functions]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#functions-and-application
[application]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#application
