type IntList =
    Empty
    | More(Int, IntList)

sum : IntList -> Int
sum More(first, rest) = first + sum rest

main : Unit -> Int
main () = sum Empty
