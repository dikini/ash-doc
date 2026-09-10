import @builtin.cell as Cell

effect Stop {
    now : Unit -> Unit
}

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let append_one : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 1)
    }
    let append_two : Unit -> Unit ! {Cell.Ops<R>} = fn(ignored) {
        Cell.write (log, (Cell.read log) * 10 + 2)
    }
    let result = handle (cleanup append_one {
        cleanup append_two {
            let ignored = perform Stop.now ()
            let ignored = Cell.write (log, 999)
            42
        }
    }) with Stop {
        now ignored => {
            let ignored = discard
            7
        }
    }
    (result, Cell.read log)
}
