# Measuring tree-search comparisons

An ordered lookup needs comparisons. After [ordered tree search](../searching-ordered-tree/README.md)
and [scoped cells](../../effects/counting-with-a-cell/README.md),
you can count them by handling `Compare.keys` with the same pure ordering and
a counter increment. The lookup algorithm
carries only its comparison requirement; the handler owns the measurement.

The balanced tree and chain contain the same three keys and values. Searching
for `High` should find 30 after two and three comparisons respectively. An
empty tree needs no comparisons. These counts measure this program's comparison
requests, not elapsed time or a general complexity guarantee.

<!-- source: src/main.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

Run the program from the Cases directory:

```text
ash measuring-tree-search/src/main.ash
```

The result is:

<!-- markdownlint-disable MD013 -->
```text
((Found(30), 2), (Found(30), 3), (Missing, 0)) : ((Result, Int), (Result, Int), (Result, Int))
```
<!-- markdownlint-enable MD013 -->

The balanced tree visits `Middle`, then `High`; the chain visits `Low`,
`Middle`, then `High`. Each visited node makes one comparison request. The
empty tree returns `Missing` before any request, so its counter stays at zero.

Change the query to `Low` and predict how the two shapes change the count.
The handler supplies a fixed ordering while measuring its use. In the next
Case, changing the supplied responses changes the calculation's result.
