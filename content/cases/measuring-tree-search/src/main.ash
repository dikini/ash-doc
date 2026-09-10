import @builtin.cell as Cell

type Key = Low
    | Middle
    | High

type Ordering = Before
    | Same
    | After

type Tree = Empty
    | Node(Tree, Key, Int, Tree)

type Result = Missing
    | Found(Int)

effect Compare {
    keys : (Key, Key) -> Ordering
}

order : (Key, Key) -> Ordering
order (Low, Low) = Same
order (Low, Middle) = Before
order (Low, High) = Before
order (Middle, Low) = After
order (Middle, Middle) = Same
order (Middle, High) = Before
order (High, Low) = After
order (High, Middle) = After
order (High, High) = Same

lookup : (Tree, Key) -> Result ! {Compare}
lookup (Empty, query) = Missing
lookup (Node(left, key, value, right), query) = match perform Compare.keys (query, key) {
        Before => lookup (left, query)
        Same => Found(value)
        After => lookup (right, query)
    }

measure : (Tree, Key) -> (Result, Int)
measure (tree, query) = resource cell<R> comparisons = 0 {
    let result = handle (lookup (tree, query)) with Compare {
        keys pair => {
            let count = Cell.read comparisons
            let ignored = Cell.write (comparisons, count + 1)
            resume (order pair)
        }
    }
    (result, Cell.read comparisons)
}

main : Unit -> ((Result, Int), (Result, Int), (Result, Int))
main () = {
    let balanced = Node(Node(Empty, Low, 10, Empty), Middle, 20,
        Node(Empty, High, 30, Empty))
    let chain = Node(Empty, Low, 10,
        Node(Empty, Middle, 20, Node(Empty, High, 30, Empty)))
    (measure (balanced, High), measure (chain, High), measure (Empty, High))
}
