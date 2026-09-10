import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let append_one : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 1)
    }
    let result = cleanup append_one {
        let ignored = Cell.write (log, 9)
        42
    }
    (result, Cell.read log)
}
