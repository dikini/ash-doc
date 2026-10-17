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
