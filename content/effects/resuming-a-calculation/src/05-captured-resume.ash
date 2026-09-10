effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle (perform Bonus.amount ()) with Bonus {
    amount ignored => {
        let later : Unit -> Int = fn(ignored) {
            resume 2
        }
        later ()
    }
}
