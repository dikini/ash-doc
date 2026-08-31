type Result =
    Found(Int)
    | Missing

value_or_zero : Result -> Int
value_or_zero Found(value) = value
value_or_zero Missing = 0

main : Unit -> Int
main () = value_or_zero (Found(42))
