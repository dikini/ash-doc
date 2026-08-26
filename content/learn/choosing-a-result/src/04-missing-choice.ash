choose : Bool -> Int -> Int
choose condition number = match condition {
    true => number
}

main : Unit -> Int
main () = choose false 42
