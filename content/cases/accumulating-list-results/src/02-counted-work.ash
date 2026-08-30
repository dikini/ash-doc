import lists as Lists

main : Unit -> ((Lists.List<Int>, Int), (Lists.List<Int>, Int))
main () = {
    let numbers = Lists.More(1, Lists.More(2, Lists.More(3, Lists.More(4, Lists.Empty))))
    (
        Lists.reverse_through_append_with_revisits numbers,
        Lists.reverse_with_accumulator_and_visits numbers
    )
}
