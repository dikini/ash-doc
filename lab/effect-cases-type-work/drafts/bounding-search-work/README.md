# Bound search work

Draft blocked by the [upstream case](../../README.md); this is not an active
lesson. The intended output below is derived, not an observed transcript.

A search can ask permission before expanding each nonempty node. `search`
keeps a depth-first frontier; `Work.expand` separates that traversal from the
policy deciding whether another expansion is allowed. Empty trees are skipped
without consuming the budget.

The handler counts admitted expansions in its own cell. At the limit it
consumes the continuation with `discard` and returns `Exhausted`. The earlier
writes remain visible, so the result includes work already admitted. Exhaustion
means the search was stopped; `Missing` means the frontier was fully examined.
The finite acyclic tree needs no visited set. Follow-up: change the budget or
child order and predict whether the target is reached before exhaustion.

<!-- source: src/main.ash -->
```ash
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
```

Expected after an upstream repair:

<!-- markdownlint-disable MD013 -->
```text
((Exhausted, 0), (Exhausted, 2), (Found(30), 3), (Missing, 3)) : ((Result, Int), (Result, Int), (Result, Int), (Result, Int))
```
<!-- markdownlint-enable MD013 -->
