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
