import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

main : Unit -> Observation
main () = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                resource cell<Flag> committed = 0 {
                    let snapshot = Cell.read state
                    let close_journal = fn(ignored) {
                        let ignored = match (Cell.read committed) == 0 {
                            true => Cell.write (state, snapshot)
                            false => ()
                        }
                        let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 1)
                        Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                    }
                    let outcome = handle (cleanup close_journal {
                        let staged = Journal.stage_add (state, 5)
                        let ignored = perform Journal.Cancel<Flag>.cancel Journal.Requested
                        let ignored = Cell.write (suffixes, (Cell.read suffixes) + 1)
                        Journal.commit (committed, staged)
                    }) with Journal.Cancel<Flag> {
                        cancel reason => {
                            let ignored = discard
                            Journal.Cancelled reason
                        }
                    }
                    Journal.Observation(outcome, Cell.read state, Cell.read closing_order,
                        Cell.read closing_states, Cell.read suffixes)
                }
            }
        }
    }
}
