effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

round_score : Int -> Int ! {Bonus}
round_score points = score points

total : Int -> Int ! {Bonus}
total points = round_score points

main : Unit -> Int
main () = handle (total 40) with Bonus {
    amount ignored => resume 2
}
