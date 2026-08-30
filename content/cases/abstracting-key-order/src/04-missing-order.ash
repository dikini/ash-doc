import ordered_trees as Trees

main : Unit -> Trees.Option<Int>
main () = {
    let tree = Trees.Node(Trees.Empty, 1, 10, Trees.Empty)
    Trees.lookup 1 tree
}
