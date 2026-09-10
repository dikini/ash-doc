effect Bonus {
    amount : Unit -> Int
}

request_bonus : Unit -> Int ! {Bonus}
request_bonus ignored = perform Bonus.amount ()

main : Unit -> (Int, Int)
main () = {
    let apply = fn((function, value)) {
        function value
    }
    let constant = fn(ignored) {
        40
    }
    let first = apply (constant, ())
    let second = handle (apply (request_bonus, ())) with Bonus {
        amount ignored => resume 2
    }
    (first, second)
}
