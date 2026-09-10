effect Stop {
    now : Unit -> Unit
}

stop_while_closing : Unit -> Unit ! {Stop}
stop_while_closing ignored = perform Stop.now ()

main : Unit -> Int
main () = handle (cleanup stop_while_closing {
    42
}) with Stop {
    now ignored => {
        let ignored = discard
        7
    }
}
