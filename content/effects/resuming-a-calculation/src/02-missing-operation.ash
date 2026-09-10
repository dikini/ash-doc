effect Round {
    bonus : Unit -> Int
    enabled : Unit -> Bool
}

main : Unit -> Int
main () = handle (perform Round.bonus ()) with Round {
    bonus ignored => resume 2
}
