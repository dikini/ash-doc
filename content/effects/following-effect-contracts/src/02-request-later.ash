effect Bonus {
    amount : Unit -> Int
}

make_score : Int -> Unit -> Int ! {Bonus}
make_score points = fn(ignored) {
    points + (perform Bonus.amount ())
}

main : Unit -> Int
main () = {
    let calculate = make_score 40
    handle (calculate ()) with Bonus {
        amount ignored => resume 2
    }
}
