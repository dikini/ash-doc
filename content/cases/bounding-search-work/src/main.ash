import @builtin.cell as Cell

type Tree = Empty
    | Node(Int, Tree, Tree)

type Frontier = End
    | Pending(Tree, Frontier)

type Result = Found(Int)
    | Missing
    | Exhausted

effect Work {
    expand : Unit -> Unit
}

search : (Frontier, Int) -> Result ! {Work}
search (End, query) = Missing
search (Pending(Empty, rest), query) = search (rest, query)
search (Pending(Node(value, left, right), rest), query) = {
    let ignored = perform Work.expand ()
    match value == query {
        true => Found(value)
        false => search (Pending(left, Pending(right, rest)), query)
    }
}

run : (Tree, Int, Int) -> (Result, Int)
run (tree, query, budget) = resource cell<R> used = 0 {
    let result = handle (search (Pending(tree, End), query)) with Work {
        expand () => match Cell.read used == budget {
            true => {
                let ignored = discard
                Exhausted
            }
            false => {
                let count = Cell.read used
                let ignored = Cell.write (used, count + 1)
                resume ()
            }
        }
    }
    (result, Cell.read used)
}

main : Unit -> ((Result, Int), (Result, Int), (Result, Int), (Result, Int))
main () = {
    let tree = Node(10, Node(20, Empty, Empty), Node(30, Empty, Empty))
    (run (tree, 30, 0), run (tree, 30, 2),
        run (tree, 30, 3), run (tree, 99, 3))
}
