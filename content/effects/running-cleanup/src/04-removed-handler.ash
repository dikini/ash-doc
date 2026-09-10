effect Stop {
    now : Unit -> Unit
}

effect Report {
    closed : Int -> Unit
}

report_close : Unit -> Unit ! {Report}
report_close ignored = perform Report.closed 1

main : Unit -> Int
main () = handle {
    let ignored = perform Report.closed 0
    handle {
        handle (cleanup report_close {
            let ignored = perform Stop.now ()
            42
        }) with Report {
            closed value => resume ()
        }
    } with Stop {
        now ignored => {
            let ignored = discard
            7
        }
    }
} with Report {
    closed value => resume ()
}
