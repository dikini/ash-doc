# How do these boundaries fit together?

We can now give the list calculation one complete contract. Each nonzero item
earns its points plus a requested bonus. Zero stops processing. The result
reports the completed or partial score, the number of items visited, and how
many times the processing scope closed.

The calculation uses features already introduced separately: a policy effect,
a scoped counter, a stopping handler, and a cleanup action. We will derive
its responsibilities from the earlier pure calculation, then trace a normal
run and an early stop through the same code.

## Keep the scoring rule visible

The pure comparison in `00-pure-calculation.ash` passes the bonus directly.
It uses the data declarations from the sibling `scoring.ash` shown next:

<!-- source: src/00-pure-calculation.ash -->
```ash
import scoring as Scoring

sum_scores : (Scoring.Scores, Int, Int) -> Scoring.Outcome
sum_scores (Scoring.End, total, bonus) = Scoring.Finished total
sum_scores (Scoring.Item(value, rest), total, bonus) = match value == 0 {
    true => Scoring.Stopped total
    false => sum_scores (rest, total + value + bonus, bonus)
}

main : Unit -> Scoring.Outcome
main () = sum_scores (Scoring.Item(20, Scoring.Item(22, Scoring.End)), 0, 2)
```

For each nonzero item, add its value and the bonus to the accumulator. At zero,
return `Stopped total`; at `End`, return `Finished total`. With values `20, 22`
and bonus `2`, the completed score is `46`.

The effectful version keeps that arithmetic and stopping point. It changes how
the bonus is obtained, makes visits observable, and gives scope completion its
own action.

## Separate the traversal from its interpretations

`scoring.ash` contains the shared calculation used by all the entry programs:

<!-- source: src/scoring.ash -->
```ash
import @builtin.cell as Cell

pub type Scores = End
    | Item(Int, Scores)
pub type Outcome = Finished(Int)
    | Stopped(Int)

pub effect Bonus {
    amount : Unit -> Int
}
effect Visit {
    item : Unit -> Unit
}
effect Stop {
    at_zero : Int -> Unit
}

sum_scores : (Scores, Int) -> Int ! {Bonus, Stop, Visit}
sum_scores (End, total) = total
sum_scores (Item(value, rest), total) = {
    let ignored = perform Visit.item ()
    let ignored = match value == 0 {
        true => perform Stop.at_zero total
        false => ()
    }
    let bonus = perform Bonus.amount ()
    sum_scores (rest, total + value + bonus)
}

pub run : Scores -> (Outcome, Int, Int) ! {Bonus}
run values = resource cell<V> visited = 0 {
    resource cell<C> closed = 0 {
        let on_close : Unit -> Unit ! {Cell.Ops<C>} = fn(ignored) {
            Cell.write (closed, (Cell.read closed) + 1)
        }
        let outcome = handle (cleanup on_close {
            handle (Finished (sum_scores (values, 0))) with Visit {
                item ignored => {
                    let ignored = Cell.write (visited, (Cell.read visited) + 1)
                    resume ()
                }
            }
        }) with Stop {
            at_zero partial => {
                let ignored = discard
                Stopped partial
            }
        }
        (outcome, Cell.read visited, Cell.read closed)
    }
}
```

Follow `sum_scores` before studying `run`. It requests a visit at the start of
each item. If the value is zero, it requests a stop with the current total.
Otherwise it requests the bonus and makes the recursive call with the updated
total. It receives no cell handle: a visit is a request, while counting visits
is the surrounding handler's responsibility.

`run` acquires two distinct cells. `visited` counts processed items, including
a zero marker. `closed` records how many times the cleanup action runs. The
local `Visit` handler increments the first cell and resumes with `Unit`. The
`Stop` handler discards the remaining traversal and returns `Stopped partial`.
Normal traversal returns `Finished` instead.

The cleanup action increments `closed` once. Its owner surrounds the traversal
and the visit handler. Both cell owners surround the stop handler, so their
access remains live when discard invokes the action. The returned tuple
contains an ordinary outcome and two copied integers; it exports no handles.

Read the outward contracts from the inside out:

| Boundary | Requirements still needed outside it |
| --- | --- |
| `sum_scores` | `Bonus`, `Stop`, and `Visit` |
| The visit handler | `Bonus`, `Stop`, and access to `visited` |
| The cleanup and stop handler | `Bonus` and access to the two live cells |
| The two resource scopes | `Bonus` |
| The entry's bonus handler | None |

Cleanup's cell access contributes to the effects of closing, including when
closing happens during discard. The resource scopes supply those exact cell
interpreters. `Bonus` remains public because the entry chooses its policy;
`Stop` and `Visit` remain private implementation choices.

## Run the completed calculation

Save `01-finished.ash` beside the module. It supplies a bonus of two:

<!-- source: src/01-finished.ash -->
```ash
import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int)
main () = {
    let values = Scoring.Item(20, Scoring.Item(22, Scoring.End))
    handle (Scoring.run values) with Scoring.Bonus {
        amount ignored => resume 2
    }
}
```

The first visit increments the count before the first bonus request. Resuming
that request continues the suspended work; it does not repeat the visit. The
same happens for the second item. At `End`, the score is `46` and the count is
two. Normal cleanup increments `closed` once. From this lesson's `src` directory:

```text
$ ash 00-pure-calculation.ash
Finished(46) : Outcome
```

```text
$ ash 01-finished.ash
(Finished(46), 2, 1) : (Outcome, Int, Int)
```

The score agrees with the pure version. The other two fields expose the visit
and completion behavior we added. Importing the module does not initialize
those cells; each call to `run` executes its own acquisitions.

## Stop before applying another bonus

`02-stopped.ash` changes only the input list:

<!-- source: src/02-stopped.ash -->
```ash
import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int)
main () = {
    let values = Scoring.Item(20, Scoring.Item(0, Scoring.Item(99, Scoring.End)))
    handle (Scoring.run values) with Scoring.Bonus {
        amount ignored => resume 2
    }
}
```

The first item contributes `20 + 2`, giving total `22`. The zero marker counts
as the second visit, then requests a stop before requesting its bonus. The
stop clause abandons the remaining traversal, including the item `99` and the
pending `Finished` construction. Closing invokes the cleanup action once,
then the clause supplies `Stopped(22)`:

```text
$ ash 02-stopped.ash
(Stopped(22), 2, 1) : (Outcome, Int, Int)
```

The cleanup requires only the still-live `closed` cell. It does not need to
restore the captured visit handler or continue the abandoned traversal.
The [effect][effects], [resource][cells], and [cleanup][cleanup] rules govern
these separate obligations.

## Change policy without changing scope ownership

`03-different-policy.ash` uses the original input and supplies a bonus of five:

<!-- source: src/03-different-policy.ash -->
```ash
import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int)
main () = {
    let values = Scoring.Item(20, Scoring.Item(22, Scoring.End))
    handle (Scoring.run values) with Scoring.Bonus {
        amount ignored => resume 5
    }
}
```

```text
$ ash 03-different-policy.ash
(Finished(52), 2, 1) : (Outcome, Int, Int)
```

Only the policy answer changed. The score becomes `25 + 27`, while the visit
and cleanup counts retain their meanings.

`05-empty-input.ash` checks another boundary: there is no item to visit and no
policy request to make, but the processing scope still completes:

<!-- source: src/05-empty-input.ash -->
```ash
import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int)
main () = {
    let values = Scoring.End
    handle (Scoring.run values) with Scoring.Bonus {
        amount ignored => resume 2
    }
}
```

```text
$ ash 05-empty-input.ash
(Finished(0), 0, 1) : (Outcome, Int, Int)
```

The cleanup obligation belongs to entering its scope, not to whether one
particular execution makes an effect request.

## The entry must still supply the public policy

The private handlers and resources do not answer `Bonus`.
`04-unhandled-policy.ash` records the remaining requirement on `main` instead
of handling it:

<!-- source: src/04-unhandled-policy.ash -->
```ash
import scoring as Scoring

main : Unit -> (Scoring.Outcome, Int, Int) ! {Scoring.Bonus}
main () = {
    let values = Scoring.Item(20, Scoring.Item(22, Scoring.End))
    Scoring.run values
}
```
<!-- diagnostic: src/04-unhandled-policy.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-unhandled-policy.ash
Calling `main` must require no effects from its caller.
  --> /path/to/ash-doc/content/effects/combining-effects-and-scopes/src/04-unhandled-policy.ash:3:1
3 | main : Unit -> (Scoring.Outcome, Int, Int) ! {Scoring.Bonus}
  | ^ This is the local `main` declaration.
reason: entry.main-effects
```
<!-- markdownlint-enable MD013 -->

The label points at the entry declaration whose row remains nonempty. Restore
the bonus handler from `01-finished.ash`. Neither the module boundary nor the
private resource scopes turn an unhandled policy request into a pure entry.

## Practice: account for every field

1. Change the values and bonus in `01-finished.ash`. Predict the score, visit
   count, and cleanup count separately.
2. Move the zero marker in `02-stopped.ash`. Explain whether it contributes a
   bonus, whether it contributes a visit, and which suffix is abandoned.
3. Call `Scoring.run` twice under a bonus handler and return both reports.
   Predict whether the second run starts with fresh counts.
4. Move the visit request below the zero check in `scoring.ash`. Predict how
   this changes the stopped report while retaining the scoring rule.

A complete explanation identifies where each request is answered, which work
resumes or stops, and which owners remain responsible for completion. The
result types and rows describe the outward contracts; the scope structure
explains how the program satisfies them. Hooks and buffers can serve other
problems without being added to this calculation merely to use every feature.

[effects]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#effects
[cells]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[cleanup]: https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#scoped-cleanup-actions
