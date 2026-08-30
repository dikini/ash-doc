import trees as Trees

is_42 : Int -> Bool
is_42 value = value == 42

main : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))
main () = {
    let tree = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        42,
        Trees.Node(Trees.Empty, 2, Trees.Empty)
    )
    (
        Trees.find_counted is_42 tree,
        Trees.find_through_fold_counted is_42 tree
    )
}
