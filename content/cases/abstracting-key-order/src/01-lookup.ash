import ordered_trees as Trees

main : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let valid = Trees.Node(
        Trees.Node(Trees.Empty, one, 10, Trees.Empty),
        two,
        20,
        Trees.Node(Trees.Empty, three, 30, Trees.Empty)
    )
    (
        Trees.lookup_counted three valid,
        Trees.lookup_counted Trees.Zero valid
    )
}
