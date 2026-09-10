# How does the data-directed method extend from lists to trees?

The dictionary offered one possible `rest` after its current entry. A tree
crosses a wider boundary: every `Node` offers both a `left` tree and a `right`
tree. A function derived from that data must decide what each branch
contributes before it can replace the current node.

The working model is still data directed. `Empty` contributes a base result.
`Node(left, value, right)` contributes a result from `left`, the current
`value`, and a result from `right`. This chapter asks what that second recursive
field changes: first for a fold, then for the depth of its source dependencies,
and finally for a search that may not need both branches.

The derivation follows ideas recorded from HtDP about [designing from
self-referential data and naming source
operations](../../../research/how-to-design-programs-recursive-algorithms.md).
Separating the traversal from the operations that replace its data forms comes
from the project record on [recursion
operators](../../../research/functional-programming-with-bananas.md). These are
sources of inspiration only. The prose, programs, tree shapes, calculations,
and exercises here are original; HtDP's teaching-language behavior and the
paper's lazy semantics, notation, fusion results, and examples do not govern
Ash.

## Replace each tree form

The shared module starts with three transparent types. `Tree<A>` and
`Option<A>` are parameterized. `Tree<A>` has an ending form and a form
containing two smaller trees. `Natural` provides visible unary heights later,
and `Option<A>` separates a found value from an absent one. The pinned [syntax
grammar](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/syntax.md#grammar)
provides the declarations and constructor patterns. The [type and constructor
scope](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/name-resolution.md#type-and-constructor-scope)
makes `Tree` visible in its own `Node` payload and associates every constructor
with its nominal type.

<!-- source: src/trees.ash -->
<!-- markdownlint-disable MD013 -->
```ash
pub type Tree<A> =
    Empty
    | Node(Tree<A>, A, Tree<A>)

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B
fold_tree combine base Empty = base
fold_tree combine base Node(left, value, right) = {
    let folded_left = fold_tree combine base left
    let folded_right = fold_tree combine base right
    combine folded_left value folded_right
}

pub size : Tree<A> -> Int
size tree = fold_tree (fn(left_size) {
    fn(ignored) {
        fn(right_size) {
            left_size + right_size + 1
        }
    }
}) 0 tree

pub map_tree : (A -> B) -> Tree<A> -> Tree<B>
map_tree transform tree = fold_tree (fn(mapped_left) {
    fn(value) {
        fn(mapped_right) {
            Node(mapped_left, transform value, mapped_right)
        }
    }
}) Empty tree

maximum : Natural -> Natural -> Natural
maximum Zero right = right
maximum left Zero = left
maximum Next(left) Next(right) = Next(maximum left right)

pub nodes_and_height : Tree<A> -> (Int, Natural)
nodes_and_height tree = fold_tree (fn(left_summary) {
    fn(ignored) {
        fn(right_summary) {
            let (left_nodes, left_height) = left_summary
            let (right_nodes, right_height) = right_summary
            (
                left_nodes + right_nodes + 1,
                Next(maximum left_height right_height)
            )
        }
    }
}) (0, Zero) tree

pub find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_counted matches Empty = (None, 0)
find_counted matches Node(left, value, right) = match matches value {
    true => (Some(value), 1)
    false => {
        let (left_found, left_visits) = find_counted matches left
        match left_found {
            Some(found) => (Some(found), left_visits + 1)
            None => {
                let (right_found, right_visits) = find_counted matches right
                (right_found, left_visits + right_visits + 1)
            }
        }
    }
}

choose_counted : (A -> Bool) -> (Option<A>, Int) -> A -> (Option<A>, Int) -> (Option<A>, Int)
choose_counted matches (left_found, left_visits) value (right_found, right_visits) = {
    let visits = left_visits + right_visits + 1
    match matches value {
        true => (Some(value), visits)
        false => match left_found {
            Some(found) => (Some(found), visits)
            None => (right_found, visits)
        }
    }
}

pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_through_fold_counted matches tree = fold_tree (choose_counted matches) (None, 0) tree
```
<!-- markdownlint-enable MD013 -->

The fold follows the two forms of `Tree`:

```text
Empty                         -> base
Node(left, value, right)      -> combine (fold left) value (fold right)
```

The source writes the second replacement more precisely. The first binding
completes `fold_tree combine base left`. The second then completes
`fold_tree combine base right`. Only after both initializers have returned
does evaluation of the complete curried expression
`combine folded_left value folded_right` begin. Ash's [sequential binding
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#bindings)
and strict [application
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#application)
establish that order.

`fold_tree` is an ordinary rank-1 Ash function, not built-in fold syntax. Its
signature implicitly quantifies `A` and `B`, and its two exhaustive equations
replace the two constructors. The pinned [global function
presentation](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/syntax.md#global-function-presentations),
module-wide [global
scope](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/name-resolution.md#global-scope),
static [function and application
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#functions-and-application)
and [global and module
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#globals-and-modules)
check that definition. Its equations cover `Empty` and `Node` under the static
[pattern and coverage
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#patterns-matches-and-coverage).
The imported entries use the public types, constructors, and functions through
Ash's [import
namespace](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/name-resolution.md#imports-and-namespaces).

Before counting any completed fold, fix its boundary. A tree has a *finite
structural expansion* when following both fields of every encountered `Node`
eventually reaches `Empty` on every path. We also assume that every combiner
application required by the fold returns. The recursive type alone does not
establish either premise.

## Count nodes and preserve shape

The first entry builds a three-node tree. `size` replaces `Empty` with `0` and
each `Node` with its two branch sizes plus one. `map_tree` replaces `Empty` with
`Empty` and each node with one transformed node in the same left and right
positions.

<!-- source: src/01-size-and-map.ash -->
```ash
import trees as Trees

increment : Int -> Int
increment value = value + 1

main : Unit -> (Int, Trees.Tree<Int>)
main () = {
    let tree = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        2,
        Trees.Node(Trees.Empty, 3, Trees.Empty)
    )
    (Trees.size tree, Trees.map_tree increment tree)
}
```

Predict before running. The root and its two children give size `3`.
`increment` changes the left, root, and right values to `2`, `3`, and `4`, but
does not exchange either branch.

Run the entry from `content/cases`:

```text
ash folding-branching-data/src/01-size-and-map.ash
```

```text
(3, Node(Node(Empty, 2, Empty), 3, Node(Empty, 4, Empty))) : (Int, Tree<Int>)
```

The observed pair contains the predicted size and mapped tree. Its type says
that the first field is an `Int` and the second is a `Tree<Int>`. The pinned
[constructor and tuple typing
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#tuples-and-constructors)
check those forms, while structural
[observation](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#observation)
and the tool's [successful-output
contract](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/docs/tools/ash.md#successful-output)
account for the exact line, empty standard error, and status `0`.

For a finite structural expansion with `n` `Node` encounters, `size` performs
two primitive integer additions per node, or `2 * n` additions. This names
source operations; it does not measure the internal bit work of
arbitrary-precision integer addition. The pinned static [primitive operation
typing
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#primitive-operations)
and dynamic [evaluation
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#primitive-operations)
define the additions and the `Int` result.

Assume in addition that `transform` returns at every encountered value.
`map_tree` then applies it exactly `n` times and completes exactly `n` output
`Node` constructor applications. Each output node receives `mapped_left` in
its left field and `mapped_right` in its right field, so mapping preserves the
input's branch shape.

## Separate node count from dependency depth

Two trees can have the same number of nodes but different shapes. Let `n` be
the number of `Node` encounters in a finite structural expansion. Let `h` be
the greatest number of `Node` forms on a path from the root to `Empty`, with
height `0` for `Empty`.

The next entry keeps `n = 3` for both trees. The balanced root has two
one-node branches, so predict height `2`, written `Next(Next(Zero))`. The
right-skewed tree has three nodes on its longest path, so predict height `3`,
written `Next(Next(Next(Zero)))`.

<!-- source: src/02-balanced-and-skewed.ash -->
```ash
import trees as Trees

main : Unit -> ((Int, Trees.Natural), (Int, Trees.Natural))
main () = {
    let balanced = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        2,
        Trees.Node(Trees.Empty, 3, Trees.Empty)
    )
    let skewed = Trees.Node(
        Trees.Empty,
        1,
        Trees.Node(
            Trees.Empty,
            2,
            Trees.Node(Trees.Empty, 3, Trees.Empty)
        )
    )
    (
        Trees.nodes_and_height balanced,
        Trees.nodes_and_height skewed
    )
}
```

Run the shape comparison:

```text
ash folding-branching-data/src/02-balanced-and-skewed.ash
```

<!-- markdownlint-disable MD013 -->
```text
((3, Next(Next(Zero))), (3, Next(Next(Next(Zero))))) : ((Int, Natural), (Int, Natural))
```
<!-- markdownlint-enable MD013 -->

The two `(Int, Natural)` fields confirm equal node counts and different unary
heights. The complete tuple is printed structurally under the same pinned
[observation](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#observation)
and [successful-output
contract](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/docs/tools/ash.md#successful-output).

For a completed `fold_tree` over these premises, the `Node` equation completes
its combiner exactly `n` times. Along a deepest path, `h` `Node` results are
pending while the recursive dependency follows the next branch. At the
terminal step, those results wait while one `Empty` call returns the base.
Counting that active terminal call gives `h + 1` simultaneous `fold_tree`
calls in the source dependency chain. The balanced and skewed trees therefore
complete three node combiners, but have pending-result depths `2` and `3`.
These are source dependencies, not claims about native stack frames or how a
host implementation represents calls.

The executable height justifies a closer look at its extra work.
`nodes_and_height` completes one fold combiner for each node and constructs one
outer `Next` per node. At a node whose branch heights are `l` and `r`, private
`maximum` makes one recursive call and reconstructs one inner `Next` for each
level that is nonzero on both sides: `min(l, r)` of each. The base equation then
returns the remaining unary height. Across the complete tree, this helper work
depends on the branch heights at every node; it is not included in the fold's
`n` combiner count or its `h` pending-result count. The two integer additions
used for each node count also have unmeasured arbitrary-precision internal
work. We therefore do not replace this source account with a single claim that
the complete measurement takes linear work.

Sequential tuple destructuring in the combiner follows the static [block
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#blocks).
The three `maximum` equations cover the two unary constructors under the
static [pattern, match, and coverage
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#patterns-matches-and-coverage).

## Search before folding or after it

A direct search can place its predicate before either recursive call. Here
`find_counted` uses current-left-right pre-order control. It tests the current
value first. A current hit avoids both branches. After a current mismatch, it
searches left; a left hit avoids right, and only left absence enters the right
recursive call. Ash evaluates the match scrutinee once and enters only its
selected arm under the pinned dynamic [match
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#tuples-constructors-and-matches).

Folded search separates evaluation order from result priority.
`choose_counted` prefers a current match, then a found left result, then the
right result. That is the same current-left-right *result priority* as the
direct search. But `fold_tree` has already completed the left fold and then the
right fold before `choose_counted` applies the current predicate. Changing the
combiner's choice cannot make those earlier branch traversals selective.

<!-- source: src/03-selective-and-fold.ash -->
```ash
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
```

The root is `42`. Predict that direct search applies `is_42` once and returns
the root without entering either branch. Folded search returns the same value,
but its strict traversal applies the predicate at both children before the
root, for three applications.

Run both searches over the same tree:

```text
ash folding-branching-data/src/03-selective-and-fold.ash
```

<!-- markdownlint-disable MD013 -->
```text
((Some(42), 1), (Some(42), 3)) : ((Option<Int>, Int), (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

The two `(Option<Int>, Int)` fields confirm equal selected values and different
predicate counts. The pinned static [primitive-operation
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#primitive-operations)
require the two operands of `==` to be `Int` and give the expression type
`Bool`. The dynamic [integer-equality
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#primitive-operations)
produce `true` exactly when the two integer values are equal. The exact
structural line follows the pinned
[successful-output
contract](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/docs/tools/ash.md#successful-output).

For direct search, assume every predicate application required along its chosen
control path returns. Let `m` be the number of nodes visited through and
including the first current-left-right match, or `n` for a complete miss.
Direct search applies the predicate exactly `m` times. Its unentered branches
impose no predicate-return condition. For folded search over a finite
structural expansion, completion requires the predicate application at every
node to return; it applies the predicate exactly `n` times. The root-hit
observation makes the difference visible as `1` and `3`.

## Follow structural occurrences

The finite-expansion premise is about paths through fields, not physical
identity. If the same acyclic subtree value is placed in both fields of a node,
these traversals follow and count it once through each structural occurrence.
Ash's pinned dynamic [structural observation
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#observation)
render shared acyclic data in full at each occurrence; they do not reveal
pointer identity or physical sharing.

Ash can admit constructor-guarded recursive data under its static [recursive
block-group
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#recursive-block-groups)
and dynamic [recursive binding
rules](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/dynamic-semantics.md#recursive-bindings).
A cyclic `Tree` value may prevent these functions from returning. The nominal
`Tree` type therefore does not establish finiteness, and this chapter makes no
claim about infinite-tree traversal.

## Keep the boundary narrow

This case introduces no ordering, ordered insertion or lookup, duplicate-key
policy, balancing, opacity, mutation, laziness, or generic tree
infrastructure. Its operation counts do not measure elapsed time, machine
instructions, native stack size, tail-call optimization, exact heap bytes,
garbage collection, pointer identity, physical sharing, arbitrary-precision
integer bit cost, or compiler representation and optimization.

## Practice and continue

1. Define `sum_tree : Tree<Int> -> Int` through `fold_tree`. Use `0` for
   `Empty`, and add the folded left result, current value, and folded right
   result at `Node`. Apply it to the balanced and skewed shapes from the second
   entry after choosing values that give equal sums. Explain why both folds
   complete three node combiners while their longest pending-result chains
   still have depths `2` and `3`.
2. Move `42` from the root of the search tree into its left child, leaving a
   nonmatching root and right child. Predict the direct and folded results and
   counts before running the entry. Explain from the source why direct search
   avoids the right branch after the left hit, while folded search still
   completes it.

The list method extended by accounting for two recursive results instead of
one. Shape now affects dependency depth, and strict folding cannot express the
branch avoidance of direct search. What if each node also carried an ordering
invariant that could choose one branch before recursion?
