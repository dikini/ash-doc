import trees as Trees

increment : Int -> Int
increment value = value + 1

main : Unit -> (Int, Trees.Tree<Int>)
main () = {
    let tree = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        2,
        Trees.Node(Trees.Empty, 3, Trees.Empty)
    )
    (Trees.size tree, Trees.map_tree increment tree)
}
