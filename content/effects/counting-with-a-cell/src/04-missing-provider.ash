import @builtin.cell as Cell

read_count : Cell.Handle<R> -> Int ! {Cell.Ops<R>}
read_count counter = Cell.read counter

main : Unit -> Int
main () = resource cell<R> counter = 0 {
    read_count counter
}
