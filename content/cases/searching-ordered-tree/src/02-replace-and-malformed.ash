import ordered_trees as Trees

main : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let with_two = Trees.insert Trees.compare_natural two 20 Trees.Empty
    let original = Trees.insert Trees.compare_natural one 10 with_two
    let replaced = Trees.insert Trees.compare_natural one 99 original
    let malformed = Trees.Node(
        Trees.Node(Trees.Empty, two, 20, Trees.Empty),
        one,
        10,
        Trees.Empty
    )
    (
        Trees.lookup Trees.compare_natural one original,
        Trees.lookup Trees.compare_natural one replaced,
        Trees.lookup Trees.compare_natural two malformed
    )
}
