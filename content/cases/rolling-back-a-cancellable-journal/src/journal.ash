import @builtin.cell as Cell

pub type CancelReason = Requested

pub type JournalOutcome = Committed(Int)
    | Cancelled(CancelReason)

pub type Observation = Observation(JournalOutcome, Int, Int, Int, Int)

pub effect Cancel<Scope> {
    cancel : CancelReason -> Unit
}

pub effect Closing {
    closed : Int -> Unit
}

pub stage_add : (Cell.Handle<State>, Int) -> Int ! {Cell.Ops<State>} where Cell.Provider<State>
stage_add (state, amount) = {
    let staged = (Cell.read state) + amount
    let ignored = Cell.write (state, staged)
    staged
}

pub commit : (Cell.Handle<Flag>, Int) -> JournalOutcome ! {Cell.Ops<Flag>} where Cell.Provider<Flag>
commit (committed, value) = {
    let ignored = Cell.write (committed, 1)
    Committed value
}

pub report_close : Unit -> Unit ! {Closing}
report_close ignored = perform Closing.closed 1
