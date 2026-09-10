effect Bonus {
    amount : Unit -> Int
}

score : Int -> Int ! {Bonus}
score points = points + (perform Bonus.amount ())

apply_twice : (Int -> Int, Int) -> Int
apply_twice (function, value) = function (function value)

main : Unit -> Int
main () = handle (apply_twice (score, 40)) with Bonus {
    amount ignored => resume 2
}
