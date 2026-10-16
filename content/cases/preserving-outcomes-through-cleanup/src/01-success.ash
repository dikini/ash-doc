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
