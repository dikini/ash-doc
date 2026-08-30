import ordered_trees as Trees

main : Unit -> (Trees.Tree<Trees.Natural, Int>, Trees.Natural, (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let after_one = Trees.insert Trees.compare_natural one 10 Trees.Empty
    let after_two = Trees.insert Trees.compare_natural two 20 after_one
    let after_three = Trees.insert Trees.compare_natural three 30 after_two
    (
        after_three,
        Trees.height after_three,
        Trees.lookup_counted Trees.compare_natural three after_three
    )
}
