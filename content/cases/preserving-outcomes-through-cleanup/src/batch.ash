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
