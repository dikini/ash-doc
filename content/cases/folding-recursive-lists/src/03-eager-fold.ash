import lists as Lists

main : Unit -> (Lists.Option<Int>, Int)
main () = Lists.first_and_visits(
    Lists.More(42, Lists.More(43, Lists.More(44, Lists.Empty)))
)
