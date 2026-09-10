effect Bonus {
    amount : Unit -> Int
}

add_bonus<R : EffectRow> : (Int -> Int ! {| R}, Int) -> Int ! {Bonus | R}
add_bonus (function, value) = (function value) + (perform Bonus.amount ())

increment : Int -> Int
increment value = value + 1

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

main : Unit -> Int
main () = handle (add_bonus (score, 40)) with Bonus {
    amount ignored => resume 2
}
