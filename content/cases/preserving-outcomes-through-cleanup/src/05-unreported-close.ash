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
