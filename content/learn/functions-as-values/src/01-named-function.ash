increment : Int -> Int
increment number = number + 1

apply_twice : (Int -> Int) -> Int -> Int
apply_twice transform number = transform (transform number)

main : Unit -> Int
main () = apply_twice increment 40
