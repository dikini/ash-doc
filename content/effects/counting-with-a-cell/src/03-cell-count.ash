import @builtin.cell as Cell

type Scores = End
    | Item(Int, Scores)

visit : (Scores, Cell.Handle<R>) -> Unit ! {Cell.Ops<R>} where Cell.Provider<R>
visit (End, counter) = ()
visit (Item(value, rest), counter) = {
    let before = Cell.read counter
    let ignored = Cell.write (counter, before + 1)
    visit (rest, counter)
}

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    let values = Item(20, Item(0, Item(99, End)))
    let ignored = visit (values, counter)
    Cell.read counter
}
