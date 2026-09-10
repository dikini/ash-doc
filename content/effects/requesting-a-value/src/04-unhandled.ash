effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

main : Unit -> Int ! {Bonus}
main () = score 40
