type Result =
    Found(Int)
    | Missing

value_or_zero : Result -> Int
value_or_zero result = match result {
    Found(value) => value
    Missing => 0
}

main : Unit -> Int
main () = value_or_zero (Found(42))
