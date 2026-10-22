# Rolling back a cancellable journal

Suppose a calculation starts with a balance of `10` and stages an addition of
`5`. A caller then cancels it. Stopping the remaining work answers a control
question: which expressions will run? Restoring the balance answers a state
question: which earlier writes should remain? The first answer does not supply
the second.

The [cell lesson](../../effects/counting-with-a-cell/README.md) established that
reads copy integers and writes change a live cell. The
[discard lesson](../../effects/stopping-a-calculation/README.md) stopped waiting
work, and [cleanup](../../effects/running-cleanup/README.md) attached an action
to its closing. Combine those ideas into a small journal: remember an entry
snapshot, stage writes in one balance cell, and restore the snapshot when an
uncommitted scope closes.

A copied snapshot is an ordinary integer. It remains `10` after the cell changes
to `15`. Each journal also owns a commit flag, initially `0`. Committing writes
`1`; its closing action restores the snapshot only when the flag is still `0`.
This is the application protocol we will calculate and test.

## Separate the outcome from the state

The public answer has two alternatives. `Committed(value)` says the scope chose
to keep its staged balance. `Cancelled(Requested)` says its handler chose to
abandon the waiting work. These constructors are [ordinary data][constructors];
they perform no restoration themselves.

The shared module supplies those types and the cancellation request.
`stage_add` reads a balance, writes its sum with the supplied
amount, and returns the new integer. `commit` writes the flag and constructs
the committed outcome from a supplied balance. Each operation requires the
provider and operation row for the cell it uses; neither owns release.

A `Cancel<Scope>` request names an [exact effect instance][effects] to
distinguish the scope being cancelled. Later, the outer and inner journals
will use their respective flag identities so
that an inner calculation can explicitly request cancellation of the outer
one. `Closing` will let a final example ask a surrounding handler to record
a close.

<!-- source: src/journal.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell

pub type CancelReason = Requested

pub type JournalOutcome = Committed(Int)
    | Cancelled(CancelReason)

pub type Observation = Observation(JournalOutcome, Int, Int, Int, Int)

pub effect Cancel<Scope> {
    cancel : CancelReason -> Unit
}

pub effect Closing {
    closed : Int -> Unit
}

pub stage_add : (Cell.Handle<State>, Int) -> Int ! {Cell.Ops<State>} where Cell.Provider<State>
stage_add (state, amount) = {
    let staged = (Cell.read state) + amount
    let ignored = Cell.write (state, staged)
    staged
}

pub commit : (Cell.Handle<Flag>, Int) -> JournalOutcome ! {Cell.Ops<Flag>} where Cell.Provider<Flag>
commit (committed, value) = {
    let ignored = Cell.write (committed, 1)
    Committed value
}

pub report_close : Unit -> Unit ! {Closing}
report_close ignored = perform Closing.closed 1
```
<!-- markdownlint-enable MD013 -->

`Observation` groups five copied fields, in order:

1. the explicit journal outcome;
2. the balance after closing;
3. the closing order, with outer owner `1` and inner owner `2`;
4. the balances read immediately after each closing action's state decision;
5. a counter for suffixes that cancellation should abandon.

For order, each action appends its owner digit. For balances, it appends a
base-100 field: closing at `15` and then `10` records `15 * 100 + 10 = 1510`.
These encodings are measurements for these small examples, whose balances stay
below `100`. They let us distinguish one close from repeated closes and see
intermediate restoration. A suffix probe adds a positive amount if reached;
zero means none ran.

## Stop the suffix without restoring a write

First give cleanup only a recording action. There is no snapshot or commit
flag in this comparison. The state and measurement cells surround the handler,
so they remain live while it discards. The local `Bare` type supplies an exact
cancellation instance without claiming a cell identity.

<!-- source: src/01-bare-cancellation.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

type Bare = Bare

main : Unit -> Observation
main () = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                let close_journal = fn(ignored) {
                    let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 1)
                    Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                }
                let outcome = handle (cleanup close_journal {
                    let staged = Journal.stage_add (state, 5)
                    let ignored = perform Journal.Cancel<Bare>.cancel Journal.Requested
                    let ignored = Cell.write (suffixes, (Cell.read suffixes) + 1)
                    Journal.Committed staged
                }) with Journal.Cancel<Bare> {
                    cancel reason => {
                        let ignored = discard
                        Journal.Cancelled reason
                    }
                }
                Journal.Observation(outcome, Cell.read state, Cell.read closing_order,
                    Cell.read closing_states, Cell.read suffixes)
            }
        }
    }
}
```
<!-- markdownlint-enable MD013 -->

The addition happens before the request. Discard skips the suffix probe and
the pending construction of `Committed`, invokes the recording action, and
then lets the clause construct `Cancelled`. Predict the balance at closing.
Run this and the following commands from `content/cases/`:

<!-- result: src/01-bare-cancellation.ash -->
```text
$ ash rolling-back-a-cancellable-journal/src/01-bare-cancellation.ash
Observation(Cancelled(Requested), 15, 1, 15, 0) : Observation
```

The balance is `15`, the recording action ran once, and the suffix counter
is zero. The [discard transition][discard] closes owned work without resuming
its abandoned expressions. It does not reverse the earlier `Cell.write`.

## Give closing an explicit compensation

Add the snapshot and flag. The flag's resource scope must surround both the
cleanup and the cancellation handler. The action needs that flag during
closing, including when discard runs in the handler clause. The balance and
measurement owners surround them all.

The action first tests the flag, restores the snapshot for `0`, then records
the close and the resulting balance. A normal commit sets the flag to `1`
before returning. Keeping these steps separate makes their order visible. A
closing action that undoes a scope's staged effect when the scope did not
commit is *compensation*; restoring one saved snapshot is *rollback*.

<!-- source: src/02-compensated-cancellation.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

main : Unit -> Observation
main () = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                resource cell<Flag> committed = 0 {
                    let snapshot = Cell.read state
                    let close_journal = fn(ignored) {
                        let ignored = match (Cell.read committed) == 0 {
                            true => Cell.write (state, snapshot)
                            false => ()
                        }
                        let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 1)
                        Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                    }
                    let outcome = handle (cleanup close_journal {
                        let staged = Journal.stage_add (state, 5)
                        let ignored = perform Journal.Cancel<Flag>.cancel Journal.Requested
                        let ignored = Cell.write (suffixes, (Cell.read suffixes) + 1)
                        Journal.commit (committed, staged)
                    }) with Journal.Cancel<Flag> {
                        cancel reason => {
                            let ignored = discard
                            Journal.Cancelled reason
                        }
                    }
                    Journal.Observation(outcome, Cell.read state, Cell.read closing_order,
                        Cell.read closing_states, Cell.read suffixes)
                }
            }
        }
    }
}
```
<!-- markdownlint-enable MD013 -->

At the request, the balance is `15` and the flag is still `0`. Discard owns
the cleanup but leaves its surrounding flag and balance owners available.
The action reads `0`, writes the saved `10`, and records `10`. Only then does
the cancellation clause return its outcome:

<!-- result: src/02-compensated-cancellation.ash -->
```text
$ ash rolling-back-a-cancellable-journal/src/02-compensated-cancellation.ash
Observation(Cancelled(Requested), 10, 1, 10, 0) : Observation
```

The changed field is explained by the action's assignment, rather than by
`Cancelled` or discard alone. The [cell rules][cells] permit an action to use
enclosing live cells and permit copied integers to leave them. Here the action
captures handles, but stays inside every owner it depends on. The final
`Observation` contains only data and copied integers, so no handle escapes.

For this protocol, the entry snapshot remains fixed throughout the scope.
Before commit the flag remains `0`, so any checked cancellation reaches an
armed action that assigns that snapshot. After commit the flag is `1`, so
closing leaves the staged balance alone. This argument relies on the body
using `commit` only to finish its journal and not writing the flag itself.
The integer cell type alone does not impose those conventions.

Normal completion takes the second path. `03-commit.ash` stages the same
addition and then commits; it needs no cancellation handler because it makes
no cancellation request.

<!-- source: src/03-commit.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

main : Unit -> Observation
main () = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                resource cell<Flag> committed = 0 {
                    let snapshot = Cell.read state
                    let close_journal = fn(ignored) {
                        let ignored = match (Cell.read committed) == 0 {
                            true => Cell.write (state, snapshot)
                            false => ()
                        }
                        let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 1)
                        Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                    }
                    let outcome = cleanup close_journal {
                        let staged = Journal.stage_add (state, 5)
                        Journal.commit (committed, staged)
                    }
                    Journal.Observation(outcome, Cell.read state, Cell.read closing_order,
                        Cell.read closing_states, Cell.read suffixes)
                }
            }
        }
    }
}
```
<!-- markdownlint-enable MD013 -->

Predict the flag when `close_journal` runs and whether recording still
happens. Cleanup preserves the body's outcome after the action returns:

<!-- result: src/03-commit.ash -->
```text
$ ash rolling-back-a-cancellable-journal/src/03-commit.ash
Observation(Committed(15), 15, 1, 15, 0) : Observation
```

The balance stays `15`, but order `1` and closing balance `15` still record
one invocation. The [cleanup execution rules][closing] distinguish invocation
from its effect on state: the obligation exists even when restoration is
unnecessary.

## Commit inside a larger uncommitted journal

Now let the outer journal stage `+5`, then let an inner journal stage `+2`.
Both use the same balance cell. Their snapshots differ: the outer records
`10`, while the inner enters at `15`. Each owns a separate flag and closing
action. An inner commit therefore keeps `17` relative to its own entry; it
cannot change the snapshot already retained by the outer scope.

`nested` takes two cancellation choices, inner first and outer second. It
returns the inner outcome alongside the outer observation. There is one extra
measurement cell, `recorded_inner`, outside the outer handler. After the inner
handler returns, a match records its actual outcome: its positive committed
balance, or `0` for the sole cancellation reason `Requested`. The committed
balances in these fixed cases are positive, so `0` cannot be confused with
one of them. The final match copies the recorded outcome back into data.
This lets us inspect the inner answer even if the outer request later abandons
the local binding that held it. The recording happens before that outer
request; it is not inferred from the final balance or from a flag.

The inner suffix probe adds `1` if reached after an inner cancellation request;
the outer probe adds `10` after an outer request. Both should remain absent.
Follow the two snapshots and flags before reading the complete program.

<!-- source: src/04-nested-completion.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

nested : (Bool, Bool) -> (JournalOutcome, Observation)
nested (cancel_inner, cancel_outer) = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                resource cell<Recorded> recorded_inner = 0 {
                    resource cell<OuterFlag> outer_committed = 0 {
                        let outer_snapshot = Cell.read state
                        let close_outer = fn(ignored) {
                            let ignored = match (Cell.read outer_committed) == 0 {
                                true => Cell.write (state, outer_snapshot)
                                false => ()
                            }
                            let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 1)
                            Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                        }
                        let outer_outcome = handle (cleanup close_outer {
                            let staged = Journal.stage_add (state, 5)
                            let inner_outcome = resource cell<InnerFlag> inner_committed = 0 {
                                let inner_snapshot = Cell.read state
                                let close_inner = fn(ignored) {
                                    let ignored = match (Cell.read inner_committed) == 0 {
                                        true => Cell.write (state, inner_snapshot)
                                        false => ()
                                    }
                                    let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 2)
                                    Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                                }
                                handle (cleanup close_inner {
                                    let staged = Journal.stage_add (state, 2)
                                    let ignored = match cancel_inner {
                                        true => {
                                            let ignored = perform Journal.Cancel<InnerFlag>.cancel Journal.Requested
                                            Cell.write (suffixes, (Cell.read suffixes) + 1)
                                        }
                                        false => ()
                                    }
                                    Journal.commit (inner_committed, staged)
                                }) with Journal.Cancel<InnerFlag> {
                                    cancel reason => {
                                        let ignored = discard
                                        Journal.Cancelled reason
                                    }
                                }
                            }
                            let ignored = match inner_outcome {
                                Journal.Committed(value) => Cell.write (recorded_inner, value)
                                Journal.Cancelled(reason) => Cell.write (recorded_inner, 0)
                            }
                            let ignored = match cancel_outer {
                                true => {
                                    let ignored = perform Journal.Cancel<OuterFlag>.cancel Journal.Requested
                                    Cell.write (suffixes, (Cell.read suffixes) + 10)
                                }
                                false => ()
                            }
                            Journal.commit (outer_committed, Cell.read state)
                        }) with Journal.Cancel<OuterFlag> {
                            cancel reason => {
                                let ignored = discard
                                Journal.Cancelled reason
                            }
                        }
                        let recorded = Cell.read recorded_inner
                        let inner_outcome = match recorded == 0 {
                            true => Journal.Cancelled Journal.Requested
                            false => Journal.Committed recorded
                        }
                        (inner_outcome, Journal.Observation(outer_outcome, Cell.read state,
                            Cell.read closing_order, Cell.read closing_states, Cell.read suffixes))
                    }
                }
            }
        }
    }
}

main : Unit -> ((JournalOutcome, Observation), (JournalOutcome, Observation), (JournalOutcome, Observation))
main () = (nested (false, false), nested (true, false), nested (false, true))
```
<!-- markdownlint-enable MD013 -->

Run the entry once:

```text
ash rolling-back-a-cancellable-journal/src/04-nested-completion.ash
```

It returns one tuple containing three scenario results, in the order listed
below. Each block selects one complete scenario component from that single
captured result; the surrounding tuple and type annotation are omitted. Each
component pairs the inner outcome with the outer journal's `Observation`.

<!-- nested-observations: src/04-nested-completion.ash -->
Both commit:

```text
(Committed(17), Observation(Committed(17), 17, 21, 1717, 0))
```

Inner cancels:

```text
(Cancelled(Requested), Observation(Committed(15), 15, 21, 1515, 0))
```

Outer cancels:

```text
(Committed(17), Observation(Cancelled(Requested), 10, 21, 1710, 0))
```

When both commit, inner closing keeps `17`, then outer closing keeps `17`.
When the inner cancels, its action restores `15`; the outer then commits that
balance. When only the outer cancels, the inner has already returned
`Committed(17)` and closed at `17`, yet the outer action still restores `10`.
The captured snapshots, rather than the names of the outcomes, determine
which assignment each uncommitted close makes.

Order `21` also tells us each action ran once. A repeated inner close would
append another `2`; a repeated outer close would append another `1`. The
closing balances distinguish keeping `17` at inner completion from restoring
`10` at outer cancellation. Looking only at the final `10` would hide that
boundary.

## Cancel the outer journal while the inner is live

The preceding inner scopes had already finished before an outer cancellation.
What changes when the request happens inside the inner body? Keep both flags
at `0` and request `Cancel<OuterFlag>` immediately after staging `+2`.
There is no inner cancellation handler here: the request deliberately names
the outer journal. The inner cleanup and its flag owner are still part of
the waiting work captured by that outer handler.

<!-- source: src/05-live-inner-cancellation.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

main : Unit -> Observation
main () = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                resource cell<OuterFlag> outer_committed = 0 {
                    let outer_snapshot = Cell.read state
                    let close_outer = fn(ignored) {
                        let ignored = match (Cell.read outer_committed) == 0 {
                            true => Cell.write (state, outer_snapshot)
                            false => ()
                        }
                        let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 1)
                        Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                    }
                    let outcome = handle (cleanup close_outer {
                        let staged = Journal.stage_add (state, 5)
                        let inner_outcome = resource cell<InnerFlag> inner_committed = 0 {
                            let inner_snapshot = Cell.read state
                            let close_inner = fn(ignored) {
                                let ignored = match (Cell.read inner_committed) == 0 {
                                    true => Cell.write (state, inner_snapshot)
                                    false => ()
                                }
                                let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 2)
                                Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                            }
                            cleanup close_inner {
                                let staged = Journal.stage_add (state, 2)
                                let ignored = perform Journal.Cancel<OuterFlag>.cancel Journal.Requested
                                let ignored = Cell.write (suffixes, (Cell.read suffixes) + 1)
                                Journal.commit (inner_committed, staged)
                            }
                        }
                        let ignored = Cell.write (suffixes, (Cell.read suffixes) + 10)
                        Journal.commit (outer_committed, Cell.read state)
                    }) with Journal.Cancel<OuterFlag> {
                        cancel reason => {
                            let ignored = discard
                            Journal.Cancelled reason
                        }
                    }
                    Journal.Observation(outcome, Cell.read state, Cell.read closing_order,
                        Cell.read closing_states, Cell.read suffixes)
                }
            }
        }
    }
}
```
<!-- markdownlint-enable MD013 -->

The outer discard owns both cleanup obligations. The [closing order][discard]
is structural: the inner action runs while its own flag and the balance are
live, before the inner flag releases; then the outer action runs. Predict
both saved balances as well as the final result:

<!-- result: src/05-live-inner-cancellation.ash -->
```text
$ ash rolling-back-a-cancellable-journal/src/05-live-inner-cancellation.ash
Observation(Cancelled(Requested), 10, 21, 1510, 0) : Observation
```

The inner action first restores its snapshot `15`. The outer action then
restores its snapshot `10`. Order `21` records each once, and `1510` records
those two assignments separately. Neither the inner suffix nor the outer
suffix runs, so neither reaches its subsequent commit. No inner outcome is
returned in this example; the pending `inner_outcome` binding is abandoned.

## Keep the action's interpreter alive

Cell access is only one requirement of a closing action. The shared
`report_close` operation performs `Closing.closed 1`. Suppose a nearer source
handler interprets that operation inside the work a cancellation will abandon.
An outer handler for the same `Closing` instance also exists. Can closing use
that outer one instead?

The following reduced program retains just that question. Its initial report
of `0` uses the outer handler, so both handlers have a real role. Locate the
nearest handler surrounding the cleanup before running it.

<!-- source: src/06-removed-interpreter.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import journal as Journal
import journal (JournalOutcome)

type Attempt = Attempt

main : Unit -> JournalOutcome
main () = handle {
    let ignored = perform Journal.Closing.closed 0
    handle {
        handle (cleanup Journal.report_close {
            let ignored = perform Journal.Cancel<Attempt>.cancel Journal.Requested
            Journal.Committed 15
        }) with Journal.Closing {
            closed owner => resume ()
        }
    } with Journal.Cancel<Attempt> {
        cancel reason => {
            let ignored = discard
            Journal.Cancelled reason
        }
    }
} with Journal.Closing {
    closed owner => resume ()
}
```
<!-- markdownlint-enable MD013 -->

Run from `content/cases/` with English human diagnostics selected explicitly.
Only the checkout prefix in the following capture is normalized, as described
in the repository setup.

<!-- diagnostic: src/06-removed-interpreter.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en rolling-back-a-cancellable-journal/src/06-removed-interpreter.ash
Discard would remove a handler that this cleanup action still needs.
  --> /path/to/ash-doc/content/cases/rolling-back-a-cancellable-journal/src/06-removed-interpreter.ash:18:27
18 |             let ignored = discard
   |                           ^ Discard would remove a handler that this cleanup action still needs.
  --> /path/to/ash-doc/content/cases/rolling-back-a-cancellable-journal/src/06-removed-interpreter.ash:10:16
10 |         handle (cleanup Journal.report_close {
   |                ^ This cleanup action requires the handler.
11 |             let ignored = perform Journal.Cancel<Attempt>.cancel Journal.Requested
   | ^ This cleanup action requires the handler.
12 |             Journal.Committed 15
   | ^ This cleanup action requires the handler.
13 |         }) with Journal.Closing {
   | ^ This cleanup action requires the handler.
  --> /path/to/ash-doc/content/cases/rolling-back-a-cancellable-journal/src/06-removed-interpreter.ash:10:9
10 |         handle (cleanup Journal.report_close {
   |         ^ Discard would abandon this handler.
11 |             let ignored = perform Journal.Cancel<Attempt>.cancel Journal.Requested
   | ^ Discard would abandon this handler.
12 |             Journal.Committed 15
   | ^ Discard would abandon this handler.
13 |         }) with Journal.Closing {
   | ^ Discard would abandon this handler.
14 |             closed owner => resume ()
   | ^ Discard would abandon this handler.
15 |         }
   | ^ Discard would abandon this handler.
reason: effect.cleanup-context
```
<!-- markdownlint-enable MD013 -->

The primary label identifies discard. The action label points to the cleanup
whose retained callback requests `Closing`; the handler label identifies the
nearer interpreter inside the abandoned work. The [cleanup rules][cleanup]
check that nearest candidate at the action's closing position. A surviving
outer handler for the same instance cannot replace the removed candidate.
Cleanup does not restore captured source handlers to interpret an abandoned
action.

In the reduced program, exchange the two inner handler positions: let
`Closing` surround `Cancel<Attempt>` and the cleanup. The same callback can
then request its surviving interpreter during discard.

Apply that placement to the journal too: put the needed interpreter outside
the flag owner and cancellation handler. The repaired program also restores
the journal snapshot, then calls the same `Journal.report_close ()`.
Its handler records owner `1` and the restored
balance, and resumes the running action so closing can finish. The initial
report `0` is deliberately excluded from the closing measurements.

<!-- source: src/07-surviving-interpreter.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

main : Unit -> Observation
main () = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                let outcome = handle {
                    let ignored = perform Journal.Closing.closed 0
                    resource cell<Flag> committed = 0 {
                        let snapshot = Cell.read state
                        let close_journal = fn(ignored) {
                            let ignored = match (Cell.read committed) == 0 {
                                true => Cell.write (state, snapshot)
                                false => ()
                            }
                            Journal.report_close ()
                        }
                        handle (cleanup close_journal {
                            let staged = Journal.stage_add (state, 5)
                            let ignored = perform Journal.Cancel<Flag>.cancel Journal.Requested
                            let ignored = Cell.write (suffixes, (Cell.read suffixes) + 1)
                            Journal.commit (committed, staged)
                        }) with Journal.Cancel<Flag> {
                            cancel reason => {
                                let ignored = discard
                                Journal.Cancelled reason
                            }
                        }
                    }
                } with Journal.Closing {
                    closed owner => {
                        let ignored = match owner == 0 {
                            true => ()
                            false => {
                                let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + owner)
                                Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                            }
                        }
                        resume ()
                    }
                }
                Journal.Observation(outcome, Cell.read state, Cell.read closing_order,
                    Cell.read closing_states, Cell.read suffixes)
            }
        }
    }
}
```
<!-- markdownlint-enable MD013 -->

Now the `Closing` handler survives the cut. The action still makes its actual
request of `1`, and the trace depends on that request reaching the handler:

<!-- result: src/07-surviving-interpreter.ash -->
```text
$ ash rolling-back-a-cancellable-journal/src/07-surviving-interpreter.ash
Observation(Cancelled(Requested), 10, 1, 10, 0) : Observation
```

Restoration finishes before reporting, and the reporting clause resumes the
action before discard returns. The interpreter's placement supplies the missing
closing context without changing the action into a pure no-op.

These examples use one entry copy and one integer flag per journal. Each close
makes at most one restoring write plus its measurements; nesting retains one
such snapshot and flag per live journal. The shared balance is in memory.
The protocol establishes no database isolation, durable storage, or crash
recovery, and it has no way to undo an external effect. The
[cleanup guarantee][closing] concerns invocation ownership on normal completion
and checked abandonment. Internal termination or exhaustion supplies no promise
that compensation succeeds.

## Practice: distinguish keeping from restoring

Copy this lesson's entire `src` directory to a scratch directory and run the
copies there so that the sibling module remains available.

1. In `02-compensated-cancellation.ash`, change the initial balance to `20`
   and the staged addition to `3`. Predict all five observation fields before
   running. Explain which value is a snapshot and which is a later read.
2. In `04-nested-completion.ash`, add the missing `(true, true)` scenario to
   `main` and its result type. Calculate both outcomes, both closing balances,
   and the final balance before running it.
3. In `05-live-inner-cancellation.ash`, replace the cancellation clause with
   `cancel reason => resume ()`. Predict which suffix probes now run and what
   each flag contains at closing. Explain why those probes no longer represent
   abandoned work.
4. In `07-surviving-interpreter.ash`, replace `Journal.report_close ()` with
   `()` in the action while retaining its restoring write. Explain what would be
   lost from the observation even if the final balance still matched.

Cancellation can abandon a suffix while retaining its earlier writes.
An explicit snapshot action can restore those writes when an uncommitted
journal closes, provided its cells and interpreters remain available.
A committed inner answer and a later outer restoration can both be correct:
they answer for different scopes. The next application choice is which state
a caller should observe before deciding that an enclosing journal has finished.

[cells]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[cleanup]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cleanup-actions
[closing]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#scoped-cleanup-actions
[discard]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
[constructors]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches
[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
