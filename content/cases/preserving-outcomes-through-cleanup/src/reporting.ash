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
