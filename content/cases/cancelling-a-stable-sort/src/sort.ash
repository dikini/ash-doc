import @builtin.cell as Cell

pub type Priority = Low
    | Normal
    | High
pub type Record = Record(Priority, Int)
pub type Records = End
    | More(Record, Records)
pub type Ordering = Before
    | Same
    | After
pub type Result = Sorted(Records)
    | Cancelled
pub type Comparisons = Done
    | Comparison(Int, Int, Ordering, Comparisons)

pub effect Compare {
    allow : Unit -> Unit
}

pub effect Trace {
    compared : (Int, Int, Ordering) -> Unit
}

order : (Priority, Priority) -> Ordering
order (Low, Low) = Same
order (Low, Normal) = Before
order (Low, High) = Before
order (Normal, Low) = After
order (Normal, Normal) = Same
order (Normal, High) = Before
order (High, Low) = After
order (High, Normal) = After
order (High, High) = Same

pub compare : (Record, Record) -> Ordering ! {Trace}
compare (Record(left, left_id), Record(right, right_id)) = {
    let ordering = order (left, right)
    let ignored = perform Trace.compared (left_id, right_id, ordering)
    ordering
}

pub insert : (Record, Records) -> Records ! {Compare, Trace}
insert (record, End) = More(record, End)
insert (record, More(current, rest)) = {
    let ignored = perform Compare.allow ()
    match compare (record, current) {
        Before => More(record, More(current, rest))
        Same => More(record, More(current, rest))
        After => More(current, insert (record, rest))
    }
}

pub stable_sort : Records -> Records ! {Compare, Trace}
stable_sort End = End
stable_sort (More(record, rest)) = {
    let ordered_tail = stable_sort rest
    insert (record, ordered_tail)
}

pub sample : Unit -> Records
sample () = More (
    Record(Normal, 1), More (
        Record(Low, 2), More (
            Record(Normal, 3), More (
                Record(High, 4), More(Record(Low, 5), End)
            )
        )
    )
)

pub equals : Unit -> Records
equals () = More (
    Record(Normal, 11), More (
        Record(Normal, 12), More(Record(Normal, 13), End)
    )
)

pub run : (Records, Int) -> (Result, Int, Comparisons)
run (records, budget) = resource cell<R> used = 0 {
    handle {
        let result = handle (Sorted (stable_sort records)) with Compare {
            allow () => match Cell.read used == budget {
                true => {
                    let ignored = discard
                    Cancelled
                }
                false => {
                    let count = Cell.read used
                    let ignored = Cell.write (used, count + 1)
                    resume ()
                }
            }
        }
        (result, Cell.read used, Done)
    } with Trace {
        compared (left_id, right_id, ordering) => {
            let (result, count, later) = resume ()
            (result, count, Comparison(left_id, right_id, ordering, later))
        }
    }
}
