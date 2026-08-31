type IntList =
    Empty
    | More(Int, IntList)

sum : IntList -> Int
sum Empty = 0
sum More(first, rest) = first + sum rest

main : Unit -> Int
main () = sum (More(20, More(22, Empty)))
