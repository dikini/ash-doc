import lists as Lists

main : Unit -> Lists.List<Int>
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    Lists.fold_left Lists.prepend (Lists.More(99, Lists.Empty)) numbers
}
