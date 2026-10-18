import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

main : Unit -> Observation
main () = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                resource cell<OuterFlag> outer_committed = 0 {
                    let outer_snapshot = Cell.read state
                    let close_outer = fn(ignored) {
                        let ignored = match (Cell.read outer_committed) == 0 {
                            true => Cell.write (state, outer_snapshot)
                            false => ()
                        }
                        let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 1)
                        Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                    }
                    let outcome = handle (cleanup close_outer {
                        let staged = Journal.stage_add (state, 5)
                        let inner_outcome = resource cell<InnerFlag> inner_committed = 0 {
                            let inner_snapshot = Cell.read state
                            let close_inner = fn(ignored) {
                                let ignored = match (Cell.read inner_committed) == 0 {
                                    true => Cell.write (state, inner_snapshot)
                                    false => ()
                                }
                                let ignored = Cell.write (closing_order, (Cell.read closing_order) * 10 + 2)
                                Cell.write (closing_states, (Cell.read closing_states) * 100 + Cell.read state)
                            }
                            cleanup close_inner {
                                let staged = Journal.stage_add (state, 2)
                                let ignored = perform Journal.Cancel<OuterFlag>.cancel Journal.Requested
                                let ignored = Cell.write (suffixes, (Cell.read suffixes) + 1)
                                Journal.commit (inner_committed, staged)
                            }
                        }
                        let ignored = Cell.write (suffixes, (Cell.read suffixes) + 10)
                        Journal.commit (outer_committed, Cell.read state)
                    }) with Journal.Cancel<OuterFlag> {
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
