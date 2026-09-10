effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle {
    let local_bonus = handle (perform Bonus.amount ()) with Bonus {
        amount ignored => resume 2
    }
    local_bonus + (perform Bonus.amount ())
} with Bonus {
    amount ignored => resume 10
}
