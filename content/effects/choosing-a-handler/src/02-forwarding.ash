effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle {
    handle (perform Bonus.amount ()) with Bonus {
        amount ignored => {
            let base = perform Bonus.amount ()
            resume (base + 2)
        }
    }
} with Bonus {
    amount ignored => resume 10
}
