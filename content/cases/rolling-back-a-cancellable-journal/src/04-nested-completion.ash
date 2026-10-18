import @builtin.cell as Cell
import journal as Journal
import journal (JournalOutcome, Observation)

nested : (Bool, Bool) -> (JournalOutcome, Observation)
nested (cancel_inner, cancel_outer) = resource cell<State> state = 10 {
    resource cell<Order> closing_order = 0 {
        resource cell<States> closing_states = 0 {
            resource cell<Suffix> suffixes = 0 {
                resource cell<Recorded> recorded_inner = 0 {
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
                        let outer_outcome = handle (cleanup close_outer {
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
                                handle (cleanup close_inner {
                                    let staged = Journal.stage_add (state, 2)
                                    let ignored = match cancel_inner {
                                        true => {
                                            let ignored = perform Journal.Cancel<InnerFlag>.cancel Journal.Requested
                                            Cell.write (suffixes, (Cell.read suffixes) + 1)
                                        }
                                        false => ()
                                    }
                                    Journal.commit (inner_committed, staged)
                                }) with Journal.Cancel<InnerFlag> {
                                    cancel reason => {
                                        let ignored = discard
                                        Journal.Cancelled reason
                                    }
                                }
                            }
                            let ignored = match inner_outcome {
                                Journal.Committed(value) => Cell.write (recorded_inner, value)
                                Journal.Cancelled(reason) => Cell.write (recorded_inner, 0)
                            }
                            let ignored = match cancel_outer {
                                true => {
                                    let ignored = perform Journal.Cancel<OuterFlag>.cancel Journal.Requested
                                    Cell.write (suffixes, (Cell.read suffixes) + 10)
                                }
                                false => ()
                            }
                            Journal.commit (outer_committed, Cell.read state)
                        }) with Journal.Cancel<OuterFlag> {
                            cancel reason => {
                                let ignored = discard
                                Journal.Cancelled reason
                            }
                        }
                        let recorded = Cell.read recorded_inner
                        let inner_outcome = match recorded == 0 {
                            true => Journal.Cancelled Journal.Requested
                            false => Journal.Committed recorded
                        }
                        (inner_outcome, Journal.Observation(outer_outcome, Cell.read state,
                            Cell.read closing_order, Cell.read closing_states, Cell.read suffixes))
                    }
                }
            }
        }
    }
}

main : Unit -> ((JournalOutcome, Observation), (JournalOutcome, Observation), (JournalOutcome, Observation))
main () = (nested (false, false), nested (true, false), nested (false, true))
