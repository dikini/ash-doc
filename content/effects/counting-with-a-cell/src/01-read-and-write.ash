import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> counter = 0 {
    let before = Cell.read counter
    let alias = counter
    let ignored = Cell.write (alias, before + 1)
    (before, Cell.read counter)
}
