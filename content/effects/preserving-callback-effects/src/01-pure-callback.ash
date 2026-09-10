apply_twice : (Int -> Int, Int) -> Int
apply_twice (function, value) = function (function value)

increment : Int -> Int
increment value = value + 1

main : Unit -> Int
main () = apply_twice (increment, 40)
