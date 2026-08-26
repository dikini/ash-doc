type IntList =
    Empty
    | More(Int, IntList)

main : Unit -> IntList
main () = More(20, More(22, Empty))
