import ordered_trees as Trees
import ordered_trees (impl Order)

main : Unit -> Trees.Option<Int>
main () = {
    let tree = Trees.Node(Trees.Empty, 1, 10, Trees.Empty)
    Trees.lookup 1 tree
}
