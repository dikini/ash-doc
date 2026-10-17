# Preserving outcomes through cleanup

A batch can finish its calculation and still have something to report while
closing. Adding `2` and `3` produces `5`; an audit that follows may fail.
Rejecting a command is different again: the batch has a primary failure before
the audit starts. A caller needs both accounts to decide what to do next.

In [running cleanup](../../effects/running-cleanup/README.md), an action returns
unit while its scope retains the body's value. Build on that separation here.
Put the body value and an ordered list of completion errors in one report.
Returning only one error would discard useful information: replacing a command
failure loses the primary cause, while retaining only that cause loses later
completion errors.

The closing actions in this chapter model an audit and a summary. Their
results are deterministic source values. They do not perform external I/O.
Continue from cleanup and
[stopping a calculation](../../effects/stopping-a-calculation/README.md).
Run the commands below from `content/cases/`.

## Retain a value and a separate error list

The report representation must distinguish three things. A close attempt can
return `Closed` or `CloseFailed(error)`. An emitted error belongs in an ordered
`Failures<E>` list. A `Report<A, E>` retains both its value of type `A` and that
list. `NoFailures` ends the list; `FailureItem(error, later)` puts one error
before the later errors. The type permits any such list; the collector must
maintain its emission order.

Use a sum for the two completion categories. `AuditFailed(22)` names an audit
failure with code `22`; `SummaryFailed(11)` names a summary failure with code
`11`. Their distinct constructors keep the categories visible even if their
integer codes later coincide. This is the explicit error domain chosen by this
application.

Two operations connect an attempt to a report. `report_close` examines one
`CloseResult<E>` and requests `CleanupFailure<E>.report` only for a failure.
The request returns unit, so the action can finish. `collect` accepts a
calculation and returns `Report<A, E>`. Its row removes that reporting effect
and leaves the calculation's other effects in `R`; later examples use that
space for a scoped observation cell. These are ordinary
[effect and row rules][effects], and the
[typed reporting rule][typed-reporting] explains how they apply to cleanup.

Before reading the clause, consider two reports emitted in order: `22`, then
`11`. When the clause for `22` resumes, the rest of the calculation can emit
`11` and finish. The returned list already contains `11`. Placing `22` in front
therefore retains the original order. Placing each new error in front *before*
running the rest would require a different calculation and ordering argument.

Here is `src/reporting.ash`:

<!-- source: src/reporting.ash -->
```ash
pub type CompletionError =
    AuditFailed(Int)
    | SummaryFailed(Int)

pub type CloseResult<E> =
    Closed
    | CloseFailed(E)

pub type Failures<E> =
    NoFailures
    | FailureItem(E, Failures<E>)

pub type Report<A, E> = Report(A, Failures<E>)

pub effect CleanupFailure<E> {
    report : E -> Unit
}

pub report_close<E> : CloseResult<E> -> Unit ! {CleanupFailure<E>}
report_close result = match result {
    Closed => ()
    CloseFailed(error) => perform CleanupFailure<E>.report error
}

pub collect<A, E, R : EffectRow> : (
    Unit -> A ! {CleanupFailure<E> | R}
) -> Report<A, E> ! {| R}
collect calculation = handle {
    let value = calculation(())
    Report(value, NoFailures)
} with CleanupFailure<E> {
    report error => match (resume ()) {
        Report(value, errors) => Report(value, FailureItem(error, errors))
    }
}
```

Normal completion constructs `Report(value, NoFailures)`. Each clause resumes
with `()`, receives the later report, and adds exactly its own error in front.
Following the requests in their emission order explains why the value is
unchanged and why every reported error is retained. It also explains the cost:
for `m` emitted reports, the collector constructs `m` list items. This counts
source constructions, without asserting native stack use or allocator behavior.

## Separate the batch outcome from caller policy

Represent a finite command list with `End` and `Next`. `Add(amount)` adds an
integer to the running total. `Reject(code)` ends the batch with
`RejectedCommand(code)`. The outcome is either `Success(total)` or
`Failed(primary_error)`. A separate `CancelledBatch` primary error will describe
the caller's cancellation policy later.

The batch operation has type `Commands -> Execution`. An `Execution` pairs its
outcome with the exact command prefix it executed, including a rejecting
command. For `Add(2), Reject(7), Add(3)`, the required prefix ends at
`Reject(7)`. Checking only the final failure would miss an implementation that
also ran the final addition.

Derive `run_from` from that contract. With no commands, the current total is the
answer and the executed prefix is empty. For an addition, increase the total,
calculate the smaller remaining list, and place this addition before its
executed prefix. For a rejection, construct the failure and its one-command
prefix directly. That branch does not recurse into `later`.

Caller policy takes a complete report. `decide` gives an existing primary
failure precedence. A successful calculation with no completion errors is
`Accepted(total)`. With completion errors, the first emitted error supplies
`CompletionFailed(first)`. Keep the report beside this decision: the decision
alone cannot retain the successful total and every completion error.

Here is `src/batch.ash`:

<!-- source: src/batch.ash -->
```ash
import reporting as Reporting

pub type Command =
    Add(Int)
    | Reject(Int)

pub type Commands =
    End
    | Next(Command, Commands)

pub type PrimaryError =
    RejectedCommand(Int)
    | CancelledBatch

pub type Outcome =
    Success(Int)
    | Failed(PrimaryError)

pub type Execution = Execution(Outcome, Commands)

run_from : (Int, Commands) -> Execution
run_from (total, End) = Execution(Success(total), End)
run_from (total, Next(Add(amount), later)) = {
    match run_from(total + amount, later) {
        Execution(outcome, executed) => Execution(
            outcome, Next(Add(amount), executed)
        )
    }
}
run_from (total, Next(Reject(code), later)) = {
    Execution(Failed(RejectedCommand(code)), Next(Reject(code), End))
}

pub run : Commands -> Execution
run commands = run_from(0, commands)

pub type Decision =
    Accepted(Int)
    | PrimaryFailed(PrimaryError)
    | CompletionFailed(Reporting.CompletionError)

pub decide : Reporting.Report<Execution, Reporting.CompletionError> -> Decision
decide report = {
    let Reporting.Report(Execution(outcome, executed), errors) = report
    match outcome {
        Failed(error) => PrimaryFailed(error)
        Success(total) => match errors {
            Reporting.NoFailures => Accepted(total)
            Reporting.FailureItem(first, later) => CompletionFailed(first)
        }
    }
}
```

For any finite input, each recursive call consumes one addition and its tail
is smaller. The first rejection ends recursion. Reading those cases gives the
prefix property for every finite list; the examples below test distinguishing
instances of it. With `n` visited commands, this calculation performs linear
source work and constructs `n` prefix items. Integer addition has its own cost,
which depends on the integers' sizes.

Start with a close attempt that succeeds. Predict both the nonempty batch's
total and the empty batch's total before running `01-success.ash`:

<!-- source: src/01-success.ash -->
```ash
import batch as Batch
import reporting as Reporting

finish : Unit -> Unit ! {Reporting.CleanupFailure<Reporting.CompletionError>}
finish ignored = {
    let result : Reporting.CloseResult<Reporting.CompletionError> = Reporting.Closed
    Reporting.report_close(result)
}

observe : Batch.Commands -> (
    Reporting.Report<Batch.Execution, Reporting.CompletionError>, Batch.Decision
)
observe commands = {
    let report = Reporting.collect(fn(ignored) {
        cleanup finish {
            Batch.run(commands)
        }
    })
    (report, Batch.decide(report))
}

main : Unit -> (
    (Reporting.Report<Batch.Execution, Reporting.CompletionError>, Batch.Decision),
    (Reporting.Report<Batch.Execution, Reporting.CompletionError>, Batch.Decision)
)
main () = (
    observe(Batch.Next(Batch.Add(2), Batch.Next(Batch.Add(3), Batch.End))),
    observe(Batch.End)
)
```

```text
ash preserving-outcomes-through-cleanup/src/01-success.ash
```

The result is a pair of observations. Its first report contains
`Success(5)`, the prefix `Next(Add(2), Next(Add(3), End))`, and `NoFailures`;
its decision is `Accepted(5)`. The second report contains `Success(0)`,
`End`, and `NoFailures`, with decision `Accepted(0)`. Both reports have type
`Report<Execution, CompletionError>`. These are components of the one returned
value. The annotation on `result` fixes the error type even though `Closed`
carries no error.

Now place a rejection between the two additions:

<!-- source: src/02-primary-failure.ash -->
```ash
import batch as Batch
import reporting as Reporting

main : Unit -> (
    Reporting.Report<Batch.Execution, Reporting.CompletionError>, Batch.Decision
)
main () = {
    let commands = Batch.Next(
        Batch.Add(2),
        Batch.Next(Batch.Reject(7), Batch.Next(Batch.Add(3), Batch.End))
    )
    let calculation : (
        Unit -> Batch.Execution ! {Reporting.CleanupFailure<Reporting.CompletionError>}
    ) = fn(ignored) {
        Batch.run(commands)
    }
    let report = Reporting.collect(calculation)
    (report, Batch.decide(report))
}
```

```text
ash preserving-outcomes-through-cleanup/src/02-primary-failure.ash
```

The report contains `Failed(RejectedCommand(7))` and the executed prefix
`Next(Add(2), Next(Reject(7), End))`. The final `Add(3)` is absent.
`NoFailures` records the lack of completion reports; the decision is
`PrimaryFailed(RejectedCommand(7))`. The callback annotation supplies the
closed reporting row expected by `collect`, although this particular
calculation makes no reporting request. An
[allowed effect row][rows] does not require an operation to be performed.

## Let every closing action finish

Nest an audit inside a summary. The
[cleanup execution rules][cleanup-execution] run the inner action first on
normal completion, then the outer action, while retaining the body's value.
Have the audit report `AuditFailed(22)` and the summary report
`SummaryFailed(11)`. Predict the list order for both the successful batch and
the rejected batch.

Each action also records its invocation in `action_trace`. Starting at zero,
append digit `2` for the audit and digit `1` for the summary. Thus `21` means
audit then summary, each once in this two-action example. Repetition would
leave another digit; missing an action would leave one digit. The final
integer is copied out of the cell after the actions finish.

<!-- source: src/03-nested-reports.ash -->
```ash
import @builtin.cell as Cell
import batch as Batch
import reporting as Reporting
import reporting (Report, CompletionError)

observe : Batch.Commands -> (
    Report<Batch.Execution, CompletionError>, Batch.Decision, Int
)
observe commands = resource cell<R> action_trace = 0 {
    let summary = fn(ignored) {
        let _ = Cell.write(action_trace, (Cell.read action_trace) * 10 + 1)
        Reporting.report_close(
            Reporting.CloseFailed(Reporting.SummaryFailed(11))
        )
    }
    let audit = fn(ignored) {
        let _ = Cell.write(action_trace, (Cell.read action_trace) * 10 + 2)
        Reporting.report_close(Reporting.CloseFailed(Reporting.AuditFailed(22)))
    }
    let report = Reporting.collect(fn(ignored) {
        cleanup summary {
            cleanup audit {
                Batch.run(commands)
            }
        }
    })
    (report, Batch.decide(report), Cell.read action_trace)
}

main : Unit -> (
    (Report<Batch.Execution, CompletionError>, Batch.Decision, Int),
    (Report<Batch.Execution, CompletionError>, Batch.Decision, Int)
)
main () = (
    observe(Batch.Next(Batch.Add(2), Batch.Next(Batch.Add(3), Batch.End))),
    observe(Batch.Next(
        Batch.Add(2),
        Batch.Next(Batch.Reject(7), Batch.Next(Batch.Add(3), Batch.End))
    ))
)
```

```text
ash preserving-outcomes-through-cleanup/src/03-nested-reports.ash
```

Both reports retain this complete error list:

```text
FailureItem(AuditFailed(22), FailureItem(SummaryFailed(11), NoFailures))
```

This list is a component of each returned observation. The first body remains
`Success(5)` with both additions in its prefix, and its decision is
`CompletionFailed(AuditFailed(22))`. The second remains
`Failed(RejectedCommand(7))` with a prefix ending at the rejection; its decision
is `PrimaryFailed(RejectedCommand(7))`. Each observation ends in action trace
`21`. The primary rejection changes caller policy without removing either
completion error. Resuming a failure report lets the running action return;
it does not retry that action.

## Replace an abandoned result explicitly

Cancellation needs a different account of the body. A discarded continuation
does not finish its calculation and cannot supply its unfinished result.
[Discard][discard] closes the scopes it owns, then returns unit to its clause.
The clause must choose the handler's result explicitly.

Here the body finishes a one-command prefix, copies that prefix into a
`Cancel.now` request, and leaves another command calculation after the request.
Immediately after the request, it writes sentinel `9` into `action_trace`.
That write would reveal that the unfinished body suffix was reached, even if
the clause later replaced its value. The actions still append `2` and `1`.
The clause discards the unfinished work, waits for closing to complete, then
returns `Execution(Failed(CancelledBatch), prefix)`. The copied prefix came in
the request payload. The failure is a replacement chosen by the clause.

The reporting collector surrounds the call to `calculation`, so it also
surrounds the cancellation handler inside that callback. It survives discard.
The observation cell surrounds both and remains live while the actions run.
This arrangement respects the
[cleanup interpreter and completion checks][cleanup-checking].

Predict the primary error, error order, action trace, and executed prefix:

<!-- source: src/04-cancellation.ash -->
```ash
import @builtin.cell as Cell
import batch as Batch
import reporting as Reporting
import reporting (Report, CompletionError, CleanupFailure)

effect Cancel {
    now : Batch.Commands -> Unit
}

main : Unit -> (
    Report<Batch.Execution, CompletionError>, Batch.Decision, Int
)
main () = resource cell<R> action_trace = 0 {
    let summary = fn(ignored) {
        let _ = Cell.write(action_trace, (Cell.read action_trace) * 10 + 1)
        Reporting.report_close(
            Reporting.CloseFailed(Reporting.SummaryFailed(11))
        )
    }
    let audit = fn(ignored) {
        let _ = Cell.write(action_trace, (Cell.read action_trace) * 10 + 2)
        Reporting.report_close(Reporting.CloseFailed(Reporting.AuditFailed(22)))
    }
    let calculation : (
        Unit -> Batch.Execution ! {CleanupFailure<CompletionError>, Cell.Ops<R>}
    ) = fn(ignored) {
        handle (cleanup summary {
            cleanup audit {
                let Batch.Execution(outcome, prefix) = Batch.run(
                    Batch.Next(Batch.Add(2), Batch.End)
                )
                let cancelled = perform Cancel.now prefix
                let suffix_reached = Cell.write(action_trace, 9)
                Batch.run(Batch.Next(Batch.Add(3), Batch.End))
            }
        }) with Cancel {
            now prefix => {
                let closed = discard
                Batch.Execution(Batch.Failed(Batch.CancelledBatch), prefix)
            }
        }
    }
    let report = Reporting.collect(calculation)
    (report, Batch.decide(report), Cell.read action_trace)
}
```

```text
ash preserving-outcomes-through-cleanup/src/04-cancellation.ash
```

The report contains `Failed(CancelledBatch)` with prefix
`Next(Add(2), End)`, both completion errors in audit-then-summary order,
decision `PrimaryFailed(CancelledBatch)`, and action trace `21`. The later
sentinel write and calculation containing `Add(3)` never run. Both actions
finish while discard closes the abandoned scopes, before the clause supplies
its replacement.
This establishes the selected cancellation policy for this finite program;
it does not recover a discarded body's result or promise asynchronous
cancellation.

## A failure value does not report itself

A plausible mistake is to construct the right failure and forget the adapter.
`forget_summary` below creates `CloseFailed(SummaryFailed(11))` and returns
unit. Compare the emitted report with the independently stated expected list.
Predict whether the compiler has any type error to reject.

<!-- source: src/05-unreported-close.ash -->
```ash
import batch as Batch
import reporting as Reporting

forget_summary : Unit -> Unit
forget_summary ignored = {
    let result = Reporting.CloseFailed(Reporting.SummaryFailed(11))
    ()
}

main : Unit -> (
    Reporting.Report<Batch.Execution, Reporting.CompletionError>,
    Batch.Decision,
    Reporting.Failures<Reporting.CompletionError>
)
main () = {
    let calculation : (
        Unit -> Batch.Execution ! {Reporting.CleanupFailure<Reporting.CompletionError>}
    ) = fn(ignored) {
        cleanup forget_summary {
            Batch.run(Batch.Next(Batch.Add(2), Batch.Next(Batch.Add(3), Batch.End)))
        }
    }
    let report = Reporting.collect(calculation)
    let expected_errors = Reporting.FailureItem(Reporting.SummaryFailed(11), Reporting.NoFailures)
    (report, Batch.decide(report), expected_errors)
}
```

```text
ash preserving-outcomes-through-cleanup/src/05-unreported-close.ash
```

The program is accepted. Its report contains `Success(5)` and `NoFailures`,
and its decision is `Accepted(5)`. The third component is the application's
expected `FailureItem(SummaryFailed(11), NoFailures)`. These disagree.
The application invariant says every modeled failed attempt must be reported,
but `forget_summary` never requests the reporting effect. Under
[typed failure reporting][typed-reporting], constructors carry no automatic
failure meaning. Repair this action by passing its `result` to `report_close`;
the collector cannot collect a request that was never made.

## Repair a collector that abandons cleanup

Another plausible attempt is to stop on the first completion error. The
following collector discards when the audit reports and substitutes a report
containing `0`. At that moment the audit has started and has not returned.
The discard would skip required completion.

<!-- source: src/06-abortive-collector.ash -->
```ash
import reporting as Reporting

audit : Unit -> Unit ! {Reporting.CleanupFailure<Reporting.CompletionError>}
audit ignored = Reporting.report_close(Reporting.CloseFailed(Reporting.AuditFailed(22)))

main : Unit -> Reporting.Report<Int, Reporting.CompletionError>
main () = handle {
    let value = cleanup audit {
        42
    }
    Reporting.Report(value, Reporting.NoFailures)
} with Reporting.CleanupFailure<Reporting.CompletionError> {
    report error => {
        let abandoned = discard
        Reporting.Report(0, Reporting.FailureItem(error, Reporting.NoFailures))
    }
}
```

Run the explicit English human format from `content/cases/`:

<!-- diagnostic: src/06-abortive-collector.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en preserving-outcomes-through-cleanup/src/06-abortive-collector.ash
This discard would skip a cleanup action that must complete.
  --> /path/to/ash-doc/content/cases/preserving-outcomes-through-cleanup/src/06-abortive-collector.ash:14:25
14 |         let abandoned = discard
   |                         ^ This discard would skip a cleanup action that must complete.
  --> /path/to/ash-doc/content/cases/preserving-outcomes-through-cleanup/src/reporting.ash:22:27
22 |     CloseFailed(error) => perform CleanupFailure<E>.report error
   |                           ^ This request or call can capture the continuation.
  --> /path/to/ash-doc/content/cases/preserving-outcomes-through-cleanup/src/06-abortive-collector.ash:8:17
8 |     let value = cleanup audit {
  |                 ^ This cleanup action must complete.
9 |         42
  | ^ This cleanup action must complete.
10 |     }
   | ^ This cleanup action must complete.
reason: effect.discard-unsafe
```
<!-- markdownlint-enable MD013 -->

The first label identifies the discard that would abandon running cleanup.
The next follows the request into `report_close` in `reporting.ash`; the final
label identifies the cleanup expression whose action must finish. The reason
code `effect.discard-unsafe` classifies that relationship. The
[cleanup checking rules][cleanup-checking] require completion even though this
collector has already received an ordinary error value.

Resume the request with unit, then retain the error in the returned report.
`07-resuming-collector.ash` makes that repair explicit and adds the outer
summary to show that a later report survives too:

<!-- source: src/07-resuming-collector.ash -->
```ash
import reporting as Reporting

summary : Unit -> Unit ! {Reporting.CleanupFailure<Reporting.CompletionError>}
summary ignored = Reporting.report_close(Reporting.CloseFailed(Reporting.SummaryFailed(11)))

audit : Unit -> Unit ! {Reporting.CleanupFailure<Reporting.CompletionError>}
audit ignored = Reporting.report_close(Reporting.CloseFailed(Reporting.AuditFailed(22)))

main : Unit -> Reporting.Report<Int, Reporting.CompletionError>
main () = handle {
    let value = cleanup summary {
        cleanup audit {
            42
        }
    }
    Reporting.Report(value, Reporting.NoFailures)
} with Reporting.CleanupFailure<Reporting.CompletionError> {
    report error => match (resume ()) {
        Reporting.Report(value, errors) => {
            Reporting.Report(value, Reporting.FailureItem(error, errors))
        }
    }
}
```

```text
ash preserving-outcomes-through-cleanup/src/07-resuming-collector.ash
```

It returns
`Report(42, FailureItem(AuditFailed(22), FailureItem(SummaryFailed(11), NoFailures)))`
with type `Report<Int, CompletionError>`. The saved `42` and both errors remain
available. This is the same resume-then-prepend calculation in `collect`.
Reporting a modeled failure neither changes the cleanup ownership rule nor
establishes successful native release. Internal exhaustion and process
termination have no source-cleanup guarantee.

## Practice the policy boundary

1. Copy the nested-report program and make the two error codes equal. Before
   running it, explain how its result can still distinguish audit from summary.
2. Copy the unreported-close program, repair its action with `report_close`,
   and predict both the report and the decision. Run it to compare them with
   your prediction. Then make that attempt `Closed` and predict again.
3. In a copy of the cancellation program, move the reporting handler inside
   the work being discarded. Use the arrangement from
   [running cleanup][removed-handler]
   to decide which handler would be needed when each action closes. Run the
   program and explain any diagnostic through its source labels.

The report preserves the completed body's value independently of completion
errors; cancellation supplies an explicit replacement for unfinished work.
That leaves caller policy visible in `decide`, with the complete report still
available to another consumer. A next application question is what to do with
those retained errors: recording them, choosing a retry policy, and performing
external release each need their own contracts.

[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[rows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#computation-types-and-effect-rows
[typed-reporting]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#typed-failure-reporting
[cleanup-execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#scoped-cleanup-actions
[discard]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
[cleanup-checking]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cleanup-actions
[removed-handler]: ../../effects/running-cleanup/README.md#do-not-restore-a-handler-that-abandonment-removes
