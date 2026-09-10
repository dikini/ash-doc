effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

apply_twice<A : Type, R : EffectRow> : (A -> A ! {| R}, A) -> A ! {| R}
apply_twice (function, value) = function (function value)

increment : Int -> Int
increment value = value + 1

main : Unit -> (Int, Int)
main () = {
    let pure_score = apply_twice (increment, 40)
    let bonus_score = handle (apply_twice (score, 40)) with Bonus {
        amount ignored => resume 2
    }
    (pure_score, bonus_score)
}
