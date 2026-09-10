effect Bonus {
    amount : Unit -> Int
}

add_bonus<R : EffectRow> : (Int -> Int ! {| R}, Int) -> Int ! {Bonus | R}
add_bonus (function, value) = (function value) + (perform Bonus.amount ())

increment : Int -> Int
increment value = value + 1

main : Unit -> Int
main () = handle (add_bonus (increment, 40)) with Bonus {
    amount ignored => resume 2
}
