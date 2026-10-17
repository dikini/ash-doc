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
