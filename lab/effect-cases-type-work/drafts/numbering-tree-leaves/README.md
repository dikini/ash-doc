# Number a tree’s leaves

Draft blocked by the [upstream case](../../README.md); this is not an active
lesson. The intended output below is derived, not an observed transcript.

Number the leaves from left to right. The pure version returns both the
rebuilt tree and the next unused number, passing the left result's counter
into the right traversal. The effectful version requests each number through
`Fresh.next`; its handler owns a scoped counter.

The intended comparison is the same tree labeled from zero by both versions,
then a fresh run starting at ten. Explicit left and right bindings preserve the
visit order. The counter and its handle stay within `number`; the rebuilt tree
contains only copied integers. Follow-up: change the traversal order and predict
which leaves receive each number.

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

Expected after an upstream repair:

<!-- markdownlint-disable MD013 -->
```text
(Fork(Leaf(0), Fork(Leaf(1), Leaf(2))), Fork(Leaf(0), Fork(Leaf(1), Leaf(2))), Fork(Leaf(10), Fork(Leaf(11), Leaf(12)))) : (Tree, Tree, Tree)
```
<!-- markdownlint-enable MD013 -->
