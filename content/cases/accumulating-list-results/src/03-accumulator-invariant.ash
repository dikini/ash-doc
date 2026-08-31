import lists as Lists

main : Unit -> (Lists.List<Int>, Lists.List<Int>, Lists.List<Int>)
main () = {
    let processed = Lists.More(1, Lists.More(2, Lists.Empty))
    let remaining = Lists.More(3, Lists.More(4, Lists.Empty))
    let accumulated = Lists.fold_left Lists.prepend Lists.Empty processed
    let complete = Lists.fold_left Lists.prepend accumulated remaining
    (processed, accumulated, complete)
}
