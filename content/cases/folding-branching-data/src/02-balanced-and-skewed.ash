import trees as Trees

main : Unit -> ((Int, Trees.Natural), (Int, Trees.Natural))
main () = {
    let balanced = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        2,
        Trees.Node(Trees.Empty, 3, Trees.Empty)
    )
    let skewed = Trees.Node(
        Trees.Empty,
        1,
        Trees.Node(
            Trees.Empty,
            2,
            Trees.Node(Trees.Empty, 3, Trees.Empty)
        )
    )
    (
        Trees.nodes_and_height balanced,
        Trees.nodes_and_height skewed
    )
}
