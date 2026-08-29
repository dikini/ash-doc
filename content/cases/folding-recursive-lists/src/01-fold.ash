import lists as Lists

main : Unit -> (Int, Int)
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.Empty)))
    (Lists.sum numbers, Lists.length numbers)
}
