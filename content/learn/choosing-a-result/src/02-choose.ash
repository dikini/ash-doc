choose : Bool -> Int -> Int -> Int
choose condition when_true when_false = match condition {
    true => when_true
    false => when_false
}

main : Unit -> Int
main () = choose true 42 0
