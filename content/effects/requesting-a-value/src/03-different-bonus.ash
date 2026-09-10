effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

main : Unit -> Int
main () = handle (score 40) with Bonus {
    amount ignored => resume 5
}
