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
