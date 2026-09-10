effect Bonus {
    amount : Unit -> Int
}

prepare_score : Int -> (Unit -> Int) ! {Bonus}
prepare_score points = {
    let bonus = perform Bonus.amount ()
    fn(ignored) {
        points + bonus
    }
}

main : Unit -> Int
main () = {
    let calculate = handle (prepare_score 40) with Bonus {
        amount ignored => resume 2
    }
    calculate ()
}
