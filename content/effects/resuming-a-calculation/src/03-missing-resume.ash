effect Bonus {
    amount : Unit -> Int
}

main : Unit -> Int
main () = handle (perform Bonus.amount ()) with Bonus {
    amount ignored => 2
}
