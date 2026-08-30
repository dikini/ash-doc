import ordered_trees as Trees

main : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let with_two = Trees.insert two 20 Trees.Empty
    let original = Trees.insert one 10 with_two
    let replaced = Trees.insert one 99 original
    let malformed = Trees.Node(
        Trees.Node(Trees.Empty, two, 20, Trees.Empty),
        one,
        10,
        Trees.Empty
    )
    (
        Trees.lookup one original,
        Trees.lookup one replaced,
        Trees.lookup two malformed
    )
}
