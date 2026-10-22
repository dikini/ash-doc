# Searching an ordered tree

The previous chapter's direct search could stop after a match, but a mismatch
gave it no reason to rule out either branch. An ordered tree supplies that
reason through an invariant. At `Node(left, key, value, right)`, one comparison
chooses the left branch, the current value, or the right branch. That choice
finds every stored key only when the comparison behaves consistently and every
descendant occupies the branch promised by its comparison with the node key.

This chapter develops that promise as a property of the program and its data.
Ash checks and evaluates the functions, but the nominal tree type alone does
not prove the ordering invariant. Keeping those boundaries separate will let
us explain both the branch that lookup skips and a malformed tree that hides a
key in that skipped branch.

The derivation follows ideas recorded from HtDP about [designing from
self-referential data and counting named source
operations](../../../research/how-to-design-programs-recursive-algorithms.md).
That source provides inspiration only. The prose, programs, tree shapes,
calculations, and exercises here are original; they do not translate HtDP's
examples, sequence, or teaching-language behavior into Ash.

## Compare at one node

The shared module uses four transparent data types. `Tree<K, V>` stores keys
and values at its nodes. `Ordering` names the three outcomes needed to choose
a branch. `Option<A>` distinguishes a found value from absence, and `Natural`
provides the visible unary keys and heights in the observations. The pinned
[syntax grammar](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#grammar)
provides parameterized declarations, constructor patterns, curried functions,
blocks, and matches. The [type and constructor
scope](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#type-and-constructor-scope)
makes each type visible in its own recursive constructor payload and associates
each constructor with its nominal type.

<!-- source: src/ordered_trees.ash -->
<!-- markdownlint-disable MD013 -->
```ash
pub type Tree<K, V> =
    Empty
    | Node(Tree<K, V>, K, V, Tree<K, V>)

pub type Ordering =
    Less
    | Equal
    | Greater

pub type Option<A> =
    None
    | Some(A)

pub type Natural =
    Zero
    | Next(Natural)

pub compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Zero = Equal
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>
lookup compare query Empty = None
lookup compare query Node(left, key, value, right) = match compare query key {
    Less => lookup compare query left
    Equal => Some(value)
    Greater => lookup compare query right
}

pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>
insert compare key value Empty = Node(Empty, key, value, Empty)
insert compare key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert compare key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert compare key value right)
}

pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)
lookup_counted compare query Empty = (None, 0)
lookup_counted compare query Node(left, key, value, right) = match compare query key {
    Less => {
        let (found, later_comparisons) = lookup_counted compare query left
        (found, later_comparisons + 1)
    }
    Equal => (Some(value), 1)
    Greater => {
        let (found, later_comparisons) = lookup_counted compare query right
        (found, later_comparisons + 1)
    }
}

maximum : Natural -> Natural -> Natural
maximum Zero right = right
maximum left Zero = left
maximum Next(left) Next(right) = Next(maximum left right)

pub height : Tree<K, V> -> Natural
height Empty = Zero
height Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))
```
<!-- markdownlint-enable MD013 -->

The four `compare_natural` equations follow the two forms of `Natural`. Two
`Zero` values are equal. `Zero` precedes every `Next` value, and every `Next`
value follows `Zero`. Comparing two `Next` values removes their outside forms
and compares the two payloads. The pinned [global function
presentation](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#global-function-presentations)
makes the four equations one curried function, while the static [patterns,
matches, and coverage
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#patterns-matches-and-coverage)
check that the equations cover both constructors.

The type `Natural -> Natural -> Ordering` does not make every function of that
type a coherent order. Fix one comparator before stating the invariant. We
assume every comparison required by an argument returns and that its results
form one coherent total order:

- `Equal` names the chosen equivalence between keys;
- reversing a `Less` comparison gives `Greater`, and conversely;
- strict comparison is transitive; and
- equivalent keys have the same ordering relationship to every other key.

For that comparator, `Empty` is valid. A finite
`Node(left, key, value, right)` is valid when both branches are valid, every key
anywhere in `left` compares with `key` as `Less`, and every key anywhere in
`right` compares with `key` as `Greater`. A tree valid under this condition is
called a *binary search tree*. The word *anywhere* matters. Checking only the
two immediate child keys would not constrain a misplaced grandchild.

Now derive `lookup` from the invariant. `Empty` contains no key, so it returns
`None`. At a node, Ash completes the curried application `compare query key`
before choosing an `Ordering` arm under the dynamic [application
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#application)
and [constructor-match
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches).
Only the selected arm body evaluates. Under the invariant, `Less` rules out the
current key and the whole right subtree; `Greater` rules out the current key
and the whole left subtree. `Equal` returns the current value.

The function globals in this module enter its simultaneous [global
scope](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#global-scope).
The nominal types and constructors use the type and constructor scope described
above. The [global and module
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#globals-and-modules)
check the function signatures and bodies. Marking declarations `pub` governs
their availability to importers under the pinned [public, private, and opaque
declaration
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#public-private-and-opaque-declarations),
and the entries use those public names through an [import
namespace](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#imports-and-namespaces).

## Follow a successful and a missing path

The first entry constructs a valid three-node tree:

```text
          two:20
          /    \
     one:10   three:30
```

<!-- source: src/01-lookup.ash -->
```ash
import ordered_trees as Trees

main : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let valid = Trees.Node(
        Trees.Node(Trees.Empty, one, 10, Trees.Empty),
        two,
        20,
        Trees.Node(Trees.Empty, three, 30, Trees.Empty)
    )
    (
        Trees.lookup_counted Trees.compare_natural three valid,
        Trees.lookup_counted Trees.compare_natural Trees.Zero valid
    )
}
```

Work out both paths before running. Query `three` is `Greater` than root key
`two`, then `Equal` to the right child key. Query `Zero` is `Less` than `two`,
then `Less` than `one`, after which lookup reaches the left `Empty`. Each path
therefore visits two `Node` forms.

Run the entry from `content/cases`:

```text
ash searching-ordered-tree/src/01-lookup.ash
```

```text
((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))
```

The first `(Option<Int>, Int)` contains the found value `Some(30)` and visit
count `2`. The second contains `None` and the same count. The complete type is
a pair of those result-and-count pairs. Ash's static [tuple, constructor,
function, and application
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#tuples-and-constructors)
check the constructed tree and result; the function rules continue in the
[functions and application
section](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#functions-and-application).
The pinned [observation
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation)
and tool [successful-output
contract](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#successful-output)
account for the exact structural line, empty standard error, and status `0`.

`lookup_counted` counts visited `Node` forms. At each visited node, it makes one
top-level comparator application; reaching `Empty` adds zero. It does not count
recursive applications made inside `compare_natural`. The additions in its
recursive arms have type `Int` under the pinned static [primitive-operation
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#primitive-operations).

The difference appears when we count the comparator's own source work. For
finite unary values whose `Next` chains end at `Zero`, write `|Zero| = 0` and
`|Next(n)| = |n| + 1`. For a completed comparison of finite `q` and `k`, let
`C(q, k)` count every `compare_natural` application in its recursive chain,
including the terminal equation. The four equations give:

```text
C(q, k) = min(|q|, |k|) + 1
```

For these finite unary keys, the successful path performs
`C(three, two) + C(three, three) = 3 + 4 = 7` internal Natural comparison
applications. The missing path performs
`C(Zero, two) + C(Zero, one) = 1 + 1 = 2`. Both paths still report `2` because
the returned count measures top-level comparisons at tree nodes, not these
recursive Natural comparisons.

## Preserve the invariant while inserting

`insert` also follows one comparison arm. At `Empty`, it constructs one node.
On `Less` or `Greater`, it recursively inserts into the selected branch and
rebuilds the current node with the other branch unchanged. On `Equal`, it
retains `current_key`, `left`, and `right`, replacing only the value. Retaining
the stored representative matters for a generic comparator: two distinguishable
key values may belong to the same equivalence class.

The next entry retains each earlier tree in a separate sequential binding. The
pinned static [block
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#blocks)
check the bindings and result, while the dynamic [binding
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#bindings)
complete each initializer before extending the following scope.

<!-- source: src/02-replace-and-malformed.ash -->
```ash
import ordered_trees as Trees

main : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let with_two = Trees.insert Trees.compare_natural two 20 Trees.Empty
    let original = Trees.insert Trees.compare_natural one 10 with_two
    let replaced = Trees.insert Trees.compare_natural one 99 original
    let malformed = Trees.Node(
        Trees.Node(Trees.Empty, two, 20, Trees.Empty),
        one,
        10,
        Trees.Empty
    )
    (
        Trees.lookup Trees.compare_natural one original,
        Trees.lookup Trees.compare_natural one replaced,
        Trees.lookup Trees.compare_natural two malformed
    )
}
```

Predict the three fields before running. `with_two` contains `two -> 20`.
Inserting `one -> 10` builds `original` with `one` in its left branch, so its
lookup returns `Some(10)`. Inserting the equivalent key `one` with value `99`
builds `replaced`, while the retained `original` still contains `10`. The
manually constructed `malformed` tree is different: it places `two` in the
left branch of root key `one`, contrary to the invariant. Predict `None` for
that final lookup.

Run the entry:

```text
ash searching-ordered-tree/src/02-replace-and-malformed.ash
```

```text
(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)
```

The first two fields confirm that `original` remains observable with `10` and
`replaced` contains `99`. The third confirms the malformed miss. Lookup for
`two` compares `Greater` at root `one`, so it enters the empty right branch.
The structurally present `two` sits in the skipped left branch. A public
transparent `Tree<K, V>` lets an importer construct this value under the pinned
[public, private, and opaque declaration
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#public-private-and-opaque-declarations);
its nominal type does not certify descendant placement. The complete tuple is
rendered by the pinned [observation
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation),
and the tool's [successful-output
contract](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#successful-output)
again gives one standard-output line, empty standard error, and status `0`.

Under the stated comparator premises, insertion preserves the invariant for a
finite valid input tree. A `Less` or `Greater` result puts the new key into the
only admissible branch and retains the other branch. An `Equal` result changes
no key or branch. This is a preservation argument about `insert` and the
stated program invariant, not a guarantee that Ash attaches to `Tree<K, V>`.

## Observe height without assuming balance

The valid tree in the first entry has three nodes and height `2`: its longest
root-to-`Empty` path encounters two `Node` forms. A different insertion order
can produce another valid three-node tree with a greater height.

<!-- source: src/03-ascending.ash -->
<!-- markdownlint-disable MD013 -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

Decide the complete result before running. Inserting `one`, then `two`, then
`three` sends each later key to the right. The final tree is a three-node right
chain. Its unary height is `Next(Next(Next(Zero)))`, and lookup for `three`
visits all three nodes before finding `30`.

Run the ascending entry:

```text
ash searching-ordered-tree/src/03-ascending.ash
```

<!-- markdownlint-disable MD013 -->
```text
(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : (Tree<Natural, Int>, Natural, (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

The first field displays the predicted right chain. The second gives its
height `3`, and the third contains `Some(30)` with three visited nodes. The
dynamic [primitive-operation
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#primitive-operations)
treat the count additions as mathematical integer operations, and structural
[observation](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation)
accounts for the rendered tree and type. The pinned tool's
[successful-output
contract](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#successful-output)
again requires empty standard error and status `0` with that exact line.

For this input, `n = 3` and `h = 3`. More generally, ascending insertion can
produce a right chain with `h = n`. This unbalanced representation therefore
provides no logarithmic height or lookup guarantee. The balanced three-node
example shows only that one particular shape has height `2`.

For a completed lookup on a finite tree, let `h` be the greatest number of
`Node` forms on a root-to-`Empty` path. If the query and visited keys are finite
unary values and the lookup visits `k_1` through `k_m`, its exact comparison
sub-work is:

```text
sum from i = 1 to m of C(query, k_i)
```

The surrounding branch selection, result construction, recursive lookup, and
count bookkeeping contribute `O(m)` named source operations. On that finite
tree, a one-branch lookup has `m <= h`. Only when every visited comparison has
`C(query, k_i) <= Cmax`, with `Cmax >= 1`, may the combined account be
summarized as `O(h * Cmax)`. The count does not include the bit cost of Ash's
arbitrary-precision integer operations.

## Keep the return boundary visible

On a finite tree, lookup returns when every comparison along its entered path
returns: each recursive call receives one branch of the current node. It needs
no return premise for a branch it never enters. A required comparison that
does not return can prevent lookup from returning.

The nominal type also does not establish finiteness. Ash's static [recursive
block-group
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#recursive-block-groups)
and dynamic [recursive binding
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#recursive-bindings)
admit constructor-guarded cyclic values. A reachable cycle along the selected
path may prevent lookup from returning. A cycle in an unentered branch need not
affect that lookup.

`height` has a different traversal boundary. At every node it evaluates both
recursive heights and then invokes private `maximum` on the two unary results.
The helper's recursive applications and constructed `Next` results are
separate work from lookup's visited-node count and its comparator sub-work.
Neither the height value nor these source counts establish elapsed time,
runtime storage, or native stack behavior.

## Keep the representation boundary narrow

This chapter introduces no interface or evidence selection, opaque dictionary,
balancing, deletion, mutation, iteration, or generic tree infrastructure. Its
observations make no claims about elapsed time, machine instructions, runtime
or host stack behavior, tail-call optimization, heap layout or bytes, garbage
collection,
pointer identity, physical sharing, compiler representation or optimization,
or arbitrary-precision integer bit cost.

## Practice and continue

1. Consider
   `Node(Node(Empty, three, 30, Empty), two, 20, Empty)`. State whether it
   satisfies the global invariant for `compare_natural`, then predict the path
   and result of looking up `three`. Repair the tree by moving one keyed value,
   and explain why the repaired placement lets the same comparison choose the
   branch containing `three`.
2. Change the first entry's missing query from `Zero` to `one`. Predict the
   reported visited-node count. Then derive the internal Natural comparison
   work by summing `C(one, two)` and `C(one, one)`. Explain why these two counts
   name different source operations.

The invariant turns one comparison into permission to skip a whole branch,
but every operation still receives the same explicit `compare` parameter. How
can an `Order<A>` interface let checking select that ordering evidence while
preserving the tree behavior and cost model?
