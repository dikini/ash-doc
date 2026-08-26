type Result =
    Found(Int)
    | Missing

value_or_zero : Result -> Int
value_or_zero Found(value) = value

main : Unit -> Int
main () = value_or_zero Missing
