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
        Reporting.report_close(
            Reporting.CloseFailed(Reporting.AuditFailed(22))
        )
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
