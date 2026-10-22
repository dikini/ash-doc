# Numbering a tree's leaves

A tree traversal can number leaves from left to right by carrying the next
unused number. This Case follows [scoped cells](../../effects/counting-with-a-cell/README.md)
and the earlier [tree traversal](../folding-branching-data/README.md).
The pure version returns both the
rebuilt tree and the next unused number, passing the left result's counter
into the right traversal. The effectful version requests each number through
`Fresh.next`; its handler owns a scoped counter.

The comparison is the same tree labeled from zero by both versions,
then a fresh run starting at ten. Explicit left and right bindings preserve the
visit order. The counter and its handle stay within `number`; the rebuilt tree
contains only copied integers.

<!-- source: src/main.ash -->
```ash
import @builtin.cell as Cell

type Tree = Leaf(Int)
    | Fork(Tree, Tree)

effect Fresh {
    next : Unit -> Int
}

thread_labels : (Tree, Int) -> (Tree, Int)
thread_labels (Leaf(value), next) = (Leaf(next), next + 1)
thread_labels (Fork(left, right), next) = {
    let (new_left, after_left) = thread_labels (left, next)
    let (new_right, after_right) = thread_labels (right, after_left)
    (Fork(new_left, new_right), after_right)
}

label : Tree -> Tree ! {Fresh}
label (Leaf(value)) = Leaf(perform Fresh.next ())
label (Fork(left, right)) = {
    let new_left = label left
    let new_right = label right
    Fork(new_left, new_right)
}

number : (Tree, Int) -> Tree
number (tree, start) = resource cell<R> counter = start {
    handle (label tree) with Fresh {
        next () => {
            let value = Cell.read counter
            let ignored = Cell.write (counter, value + 1)
            resume value
        }
    }
}

main : Unit -> (Tree, Tree, Tree)
main () = {
    let tree = Fork(Leaf(99), Fork(Leaf(99), Leaf(99)))
    let (threaded, next) = thread_labels (tree, 0)
    (threaded, number (tree, 0), number (tree, 10))
}
```

Run the program from the Cases directory:

```text
ash numbering-tree-leaves/src/main.ash
```

The result is:

<!-- markdownlint-disable MD013 -->
```text
(Fork(Leaf(0), Fork(Leaf(1), Leaf(2))), Fork(Leaf(0), Fork(Leaf(1), Leaf(2))), Fork(Leaf(10), Fork(Leaf(11), Leaf(12)))) : (Tree, Tree, Tree)
```
<!-- markdownlint-enable MD013 -->

The first two trees agree: each traversal visits three leaves and assigns
`0`, `1`, then `2`. The final tree begins at `10` because each call to `number`
acquires its own counter. The request changes how the next number is supplied;
the explicit left and right bindings still determine traversal order.

Change the traversal to visit the right subtree first and predict which leaf
receives each number. Then restore it. The next Case uses a handler to measure
a traversal while preserving its result.
