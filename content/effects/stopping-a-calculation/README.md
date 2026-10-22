# Stopping a calculation

A list of scores can contain a marker meaning that processing should stop.
Use zero as that marker. We want the total before the marker, and we want to
leave later items unprocessed.

A pure function can express that decision by returning an outcome. An effect
lets the calculation request the decision from a handler. We will compare the
two approaches before using `discard` to stop the waiting work.

## Return an outcome directly

`01-pure-outcome.ash` uses the finite recursive data and accumulated total
introduced in Learn and the list Cases:

<!-- source: src/01-pure-outcome.ash -->
```ash
type Scores = End
    | Item(Int, Scores)
type Outcome = Finished(Int)
    | Stopped(Int)

sum_scores : (Scores, Int) -> Outcome
sum_scores (End, total) = Finished total
sum_scores (Item(value, rest), total) = match value == 0 {
    true => Stopped total
    false => sum_scores (rest, total + value)
}

main : Unit -> Outcome
main () = sum_scores (Item(20, Item(0, Item(99, End))), 0)
```

`End` completes the calculation. An `Item` with value zero returns `Stopped`
immediately. Every other item adds to the total and continues with its tail.
Trace the list `20, 0, 99`: which items contribute to the accumulated total,
and which tail is left untouched? Predict the outcome before running the
file from this lesson's `src` directory:

```text
$ ash 01-pure-outcome.ash
Stopped(20) : Outcome
```

The first item adds `20`; the next item selects `Stopped` with that total.
The call never recurses into the tail containing `99`. The constructors make
the result meaningful to this program. Their names do
not give them any special failure or control behavior in Ash.

## Ask the handler whether to continue

`02-stop-at-zero.ash` makes reaching zero an operation request instead:

<!-- source: src/02-stop-at-zero.ash -->
```ash
type Scores = End
    | Item(Int, Scores)
type Outcome = Finished(Int)
    | Stopped(Int)

effect Stop {
    at_zero : Int -> Unit
}

sum_scores : (Scores, Int) -> Int ! {Stop}
sum_scores (End, total) = total
sum_scores (Item(value, rest), total) = {
    let ignored = match value == 0 {
        true => perform Stop.at_zero total
        false => ()
    }
    sum_scores (rest, total + value)
}

main : Unit -> Outcome
main () = {
    let values = Item(20, Item(0, Item(99, End)))
    handle (Finished (sum_scores (values, 0))) with Stop {
        at_zero partial => {
            let ignored = discard
            Stopped partial
        }
    }
}
```

The operation carries the partial total and expects a `Unit` answer. If it
receives that answer, the calculation can continue to its recursive call.
The surrounding handler instead executes `discard`, consuming the continuation
without running the waiting remainder. The clause then returns `Stopped partial`.
`discard` itself returns `Unit`, which the `ignored` binding sets aside.

At the zero request, identify the accumulated prefix and all the waiting
work. Follow the call back to `main` as well: what must happen before
`Finished` can be constructed? Predict the clause's outcome after discard:

```text
$ ash 02-stop-at-zero.ash
Stopped(20) : Outcome
```

The request carries `20`. Discard abandons the recursive call that would visit
`99` and the pending outer construction of `Finished`. The clause instead
constructs `Stopped(20)`, producing the same outcome as the pure version.
The difference is
where the stopping choice lives. The pure function chooses in its match. The
effectful function requests a decision; its handler chooses how to consume
the waiting continuation.

## Choose to continue instead

In `03-continue-at-zero.ash`, the calculation and input are unchanged. The
clause supplies the operation's `Unit` answer through `resume ()`:

<!-- source: src/03-continue-at-zero.ash -->
```ash
type Scores = End
    | Item(Int, Scores)
type Outcome = Finished(Int)
    | Stopped(Int)

effect Stop {
    at_zero : Int -> Unit
}

sum_scores : (Scores, Int) -> Int ! {Stop}
sum_scores (End, total) = total
sum_scores (Item(value, rest), total) = {
    let ignored = match value == 0 {
        true => perform Stop.at_zero total
        false => ()
    }
    sum_scores (rest, total + value)
}

main : Unit -> Outcome
main () = {
    let values = Item(20, Item(0, Item(99, End)))
    handle (Finished (sum_scores (values, 0))) with Stop {
        at_zero partial => {
            resume ()
        }
    }
}
```

Resume continues after the zero request. Predict the total when the remaining
recursive calls finish, and which constructor `main` will then use:

```text
$ ash 03-continue-at-zero.ash
Finished(119) : Outcome
```

The zero adds nothing, but the later `99` adds to the existing `20`.
Normal completion supplies `119` to the waiting `Finished` construction.
`resume` and `discard` consume the same clause capability. One continues the
waiting work; the other abandons it. Neither is an ordinary stored function.

## Discard does not supply the clause's result

In `04-discard-result.ash`, the clause stops the continuation and returns only
the value of `discard`:

<!-- source: src/04-discard-result.ash -->
```ash
type Scores = End
    | Item(Int, Scores)
type Outcome = Finished(Int)
    | Stopped(Int)

effect Stop {
    at_zero : Int -> Unit
}

sum_scores : (Scores, Int) -> Int ! {Stop}
sum_scores (End, total) = total
sum_scores (Item(value, rest), total) = {
    let ignored = match value == 0 {
        true => perform Stop.at_zero total
        false => ()
    }
    sum_scores (rest, total + value)
}

main : Unit -> Outcome
main () = {
    let values = Item(20, Item(0, Item(99, End)))
    handle (Finished (sum_scores (values, 0))) with Stop {
        at_zero partial => {
            discard
        }
    }
}
```

Compare that value's type with the handler's `Outcome` result requirement.
Which step from the stopping version is missing?

<!-- diagnostic: src/04-discard-result.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-discard-result.ash
This expression must have type `Outcome`, but it has type `Unit`.
  --> /path/to/ash-doc/content/effects/stopping-a-calculation/src/04-discard-result.ash:25:13
25 |             discard
   |             ^ This has type `Unit`.
reason: type.mismatch
```
<!-- markdownlint-enable MD013 -->

`discard` produces `Unit`. The handler's body and clauses must produce
`Outcome`, so returning that `Unit` fails. The label points at `discard`, where
the wrong result is supplied. Restore the following `Stopped partial` expression
from `02-stop-at-zero.ash`. The `let ignored` binding lets discard finish before
that result is constructed.

Stopping work and choosing a result are separate steps. This distinction will
matter again when abandonment must also close owned scopes.

## Finish without selecting a clause

`05-no-stop.ash` uses a list with no zero marker:

<!-- source: src/05-no-stop.ash -->
```ash
type Scores = End
    | Item(Int, Scores)
type Outcome = Finished(Int)
    | Stopped(Int)

effect Stop {
    at_zero : Int -> Unit
}

sum_scores : (Scores, Int) -> Int ! {Stop}
sum_scores (End, total) = total
sum_scores (Item(value, rest), total) = {
    let ignored = match value == 0 {
        true => perform Stop.at_zero total
        false => ()
    }
    sum_scores (rest, total + value)
}

main : Unit -> Outcome
main () = {
    let values = Item(20, Item(22, End))
    handle (Finished (sum_scores (values, 0))) with Stop {
        at_zero partial => {
            let ignored = discard
            Stopped partial
        }
    }
}
```

Trace the two items. Will either select `at_zero`, and if no clause runs,
where does the handler's result come from?

```text
$ ash 05-no-stop.ash
Finished(42) : Outcome
```

Both items take the recursive branch, so no request occurs. The body finishes
with `Finished(42)`; the discarding clause never runs. The static `Stop` row
still describes what `sum_scores` may require for other
inputs. The handler supplies that contract even when one execution does not
request it. The [evaluation rules][evaluation] distinguish a handler body's
normal return from a selected clause's consumption of waiting work.

The [effect rules][effects] also check whether abandoned work can be closed
safely. These examples own no resources or cleanup actions. Do not conclude
that every discard is pure or that it can skip any enclosing obligation. We
will return to those questions after introducing scoped state and cleanup.

## Practice: compare the two choices

For each task, start with fresh copies of `01-pure-outcome.ash`,
`02-stop-at-zero.ash`, and `03-continue-at-zero.ash` in a scratch directory
outside this lesson's `src` tree. Make the same input change in the copies you
compare, then run them from that directory.

Move the zero marker to the beginning of the list. Predict the pure outcome
and the discarding handler's outcome before running either.

Put zero at the end of the list instead. What total has accumulated at the
request?

Change the values that come after zero. Which result — the stopping
handler's or the continuing handler's — can depend on those later values?

We can now trace a request, continue its waiting work, or stop that work and
return a chosen outcome. The next question is how a calculation can keep
mutable state whose access and release belong to one scope.

[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[evaluation]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
