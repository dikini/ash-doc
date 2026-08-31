import lists as Lists

increment : Int -> Int
increment number = number + 1

is_42 : Int -> Bool
is_42 number = number == 42

main : Unit -> (Lists.List<Int>, Lists.List<Int>)
main () = {
    let numbers = Lists.More(41, Lists.More(42, Lists.More(43, Lists.Empty)))
    (Lists.map increment numbers, Lists.filter is_42 numbers)
}
