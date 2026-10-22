import @builtin.cell as Cell

main : Unit -> Int
main () = resource cell<R> tally = 0 {
    let ignored = Cell.write (tally, 7)
    Cell.read tally
}
