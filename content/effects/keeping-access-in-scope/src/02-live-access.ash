import @builtin.cell as Cell

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    let bump : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (counter, (Cell.read counter) + 1)
    }
    let alias = bump
    let ignored = bump ()
    let ignored = alias ()
    Cell.read counter
}
