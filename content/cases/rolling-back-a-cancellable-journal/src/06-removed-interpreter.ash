import journal as Journal
import journal (JournalOutcome)

type Attempt = Attempt

main : Unit -> JournalOutcome
main () = handle {
    let ignored = perform Journal.Closing.closed 0
    handle {
        handle (cleanup Journal.report_close {
            let ignored = perform Journal.Cancel<Attempt>.cancel Journal.Requested
            Journal.Committed 15
        }) with Journal.Closing {
            closed owner => resume ()
        }
    } with Journal.Cancel<Attempt> {
        cancel reason => {
            let ignored = discard
            Journal.Cancelled reason
        }
    }
} with Journal.Closing {
    closed owner => resume ()
}
