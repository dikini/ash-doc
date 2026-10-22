pick : Bool -> Int -> Int -> Int
pick true when_true when_false = when_true
pick false when_true when_false = when_false

main : Unit -> Int
main () = pick (20 + 22 == 42) 42 0
