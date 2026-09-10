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
