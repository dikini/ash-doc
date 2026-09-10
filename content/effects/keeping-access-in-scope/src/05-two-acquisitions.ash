import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> outer = 1 {
    let copied = resource cell<S> inner = 2 {
        let handles = (outer, inner)
        let (first, second) = handles
        let ignored = Cell.write (first, 10)
        Cell.read second
    }
    (Cell.read outer, copied)
}
