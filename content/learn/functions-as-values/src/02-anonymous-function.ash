apply_twice : (Int -> Int) -> Int -> Int
apply_twice transform number = transform (transform number)

main : Unit -> Int
main () = apply_twice (fn(number) {
    number + 1
}) 40
