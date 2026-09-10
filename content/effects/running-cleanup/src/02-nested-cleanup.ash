import @builtin.cell as Cell

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let append_one : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 1)
    }
    let append_two : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 2)
    }
    let result = cleanup append_one {
        cleanup append_two {
            42
        }
    }
    (result, Cell.read log)
}
