import @builtin.cell as Cell

pub type Scores = End
    | Item(Int, Scores)
pub type Outcome = Finished(Int)
    | Stopped(Int)

pub effect Bonus {
    amount : Unit -> Int
}
effect Visit {
    item : Unit -> Unit
}
effect Stop {
    at_zero : Int -> Unit
}

sum_scores : (Scores, Int) -> Int ! {Bonus, Stop, Visit}
sum_scores (End, total) = total
sum_scores (Item(value, rest), total) = {
    let ignored = perform Visit.item ()
    let ignored = match value == 0 {
        true => perform Stop.at_zero total
        false => ()
    }
    let bonus = perform Bonus.amount ()
    sum_scores (rest, total + value + bonus)
}

pub run : Scores -> (Outcome, Int, Int) ! {Bonus}
run values = resource cell<V> visited = 0 {
    resource cell<C> closed = 0 {
        let on_close : Unit -> Unit ! {Cell.Ops<C>} = fn(ignored) {
            Cell.write (closed, (Cell.read closed) + 1)
        }
        let outcome = handle (cleanup on_close {
            handle (Finished (sum_scores (values, 0))) with Visit {
                item ignored => {
                    let ignored = Cell.write (visited, (Cell.read visited) + 1)
                    resume ()
                }
            }
        }) with Stop {
            at_zero partial => {
                let ignored = discard
                Stopped partial
            }
        }
        (outcome, Cell.read visited, Cell.read closed)
    }
}
