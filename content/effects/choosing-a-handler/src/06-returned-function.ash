effect Bonus {
    amount : Unit -> Int
}

make_request : Unit -> Unit -> Int ! {Bonus}
make_request ignored = handle {
    let initial = perform Bonus.amount ()
    let request : Unit -> Int ! {Bonus} = fn(ignored) {
        initial + (perform Bonus.amount ())
    }
    request
} with Bonus {
    amount ignored => resume 2
}

main : Unit -> Int
main () = {
    let request = make_request ()
    handle (request ()) with Bonus {
        amount ignored => resume 9
    }
}
