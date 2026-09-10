import @builtin.cell as Cell

effect Stop {
    now : Unit -> Unit
}

effect Report {
    closed : Int -> Unit
}

report_close : Unit -> Unit ! {Report}
report_close ignored = perform Report.closed 1

main : Unit -> (Int, Int)
main () = resource cell<R> log = 0 {
    let result = handle {
        handle (cleanup report_close {
            let ignored = perform Stop.now ()
            42
        }) with Stop {
            now ignored => {
                let ignored = discard
                7
            }
        }
    } with Report {
        closed value => {
            let ignored = Cell.write (log, value)
            resume ()
        }
    }
    (result, Cell.read log)
}
