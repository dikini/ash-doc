import lists as Lists

main : Unit -> Lists.List<Int>
main () = Lists.map (fn(number) {
    number + 1
}) (Lists.More(41, Lists.Empty))
