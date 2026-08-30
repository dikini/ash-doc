# How can modules reuse an ordering capability without passing it manually?

The preceding entries supply `Trees.compare_natural` to each tree operation
they call. Each operation receives it as `compare` and passes that parameter
through recursion. This value tells `lookup`, `insert`, and `lookup_counted`
how to compare keys, but repeating it also makes every caller carry knowledge
that all three operations already require.

An Ash interface can move that requirement out of the source argument list.
The operation declares `where Order<K>`, and checking must find evidence for
that obligation at each use. The algorithm still calls the same comparison
equations and enters the same tree branch. What changes is the boundary:
comparison arrives through evidence selected during checking instead of
through a value argument written by the caller.

## Name the ordering capability

The shared module begins with the same transparent tree, ordering, option, and
unary-natural representations as the preceding case. It then declares the
one-method interface `Order<A>` and an implementation for `Natural`.

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

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(left, key, value, right) = match compare query key {
    Less => lookup query left
    Equal => Some(value)
    Greater => lookup query right
}

pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>
insert key value Empty = Node(Empty, key, value, Empty)
insert key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert key value right)
}

pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>
lookup_counted query Empty = (None, 0)
lookup_counted query Node(left, key, value, right) = match compare query key {
    Less => {
        let (found, later_comparisons) = lookup_counted query left
        (found, later_comparisons + 1)
    }
    Equal => (Some(value), 1)
    Greater => {
        let (found, later_comparisons) = lookup_counted query right
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

This module has no entry contract of its own. Each of the four entry commands
below imports it, so every run loads and checks this complete source before it
checks the entry.

The pinned [interface
grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
makes `Order<A>` a method-only declaration. Its parameter occurs in
`compare : A -> A -> Ordering`, and the method's outer type constructor is a
function arrow, as required by the static [interface
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#interfaces-and-constrained-schemes).
An interface is not an ordinary value type. It names a checking requirement
whose evidence supplies the method when a constrained occurrence is used.

The four implementation equations preserve the previous Natural comparison:
`Zero` precedes every `Next` value, every `Next` value follows `Zero`, and two
`Next` values compare their payloads. The implementation must be `pub` because
the entry modules are direct dependents. Under the pinned [public declaration
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations),
a private implementation remains available only in its defining module, while
a public anonymous implementation fact is available to direct dependents.
There is no implementation name for an importer to call.

Each tree signature states its requirement after the complete value type:

```text
lookup : K -> Tree<K, V> -> Option<V> where Order<K>
insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>
lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>
```

The `where` clause is not another function argument and is not part of the
result type. Ash keeps requirements explicit on global signatures instead of
inferring them from bodies, as specified by [interfaces and constrained
schemes](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#interfaces-and-constrained-schemes).
Inside each `Node` equation, `compare` creates an `Order<K>` obligation.
The recursive `lookup`, `insert`, or `lookup_counted` occurrence creates the
same obligation.

While checking one of these constrained globals, its declared requirement is
available as abstract evidence. Abstract evidence is considered before a
concrete implementation, so both the method occurrence and the recursive
global occurrence reuse the same declared `Order<K>` evidence. The pinned
[global rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
keep recursive self-occurrences at the same rigid type arguments, and the
[selection order](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
accounts for that abstract reuse.

The final Natural implementation equation is recursive for a different
reason. While checking `compare Next(left) Next(right)`, its `compare left
right` occurrence uses exact current-implementation evidence for
`Order<Natural>`. It does not start a new search for a concrete implementation.
That current-evidence rule belongs to implementation-method checking and the
same ordered [evidence
selection](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence).

## Select Natural order at an imported call

The first entry constructs the same valid three-node tree as before, but its
two calls no longer mention `Trees.compare_natural`.

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
        Trees.lookup_counted three valid,
        Trees.lookup_counted Trees.Zero valid
    )
}
```

Follow the first call through checking. Ordinary typing determines both its
query key and its tree key as `Trees.Natural`. Instantiating the imported
constrained global therefore creates an `Order<Trees.Natural>` obligation.
The complete import establishes a direct dependency, and that dependency's
public Natural implementation is the unique matching concrete candidate. The
pinned [import
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces)
make the public anonymous fact available, while the static [constraint
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
select only after ordinary typing has fixed the obligation's type argument.

Predict the paths. Query `three` compares `Greater` at root `two` and `Equal`
at the right child. Query `Zero` compares `Less` at root `two` and `Less` at
the left child before reaching `Empty`. Both paths visit two nodes.

Run the entry from `content/cases`:

```text
ash abstracting-key-order/src/01-lookup.ash
```

```text
((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))
```

The accepted line is byte-for-byte the preceding case's result. The first pair
contains the found value `Some(30)` and two visited `Node` forms; the second
contains `None` and the same visit count. At each visited node,
`lookup_counted` makes one top-level `compare` method application. Its count
does not include recursive applications inside the Natural implementation.

For finite unary values, let `|Zero| = 0` and
`|Next(n)| = |n| + 1`. A completed Natural comparison has
`C(q, k) = min(|q|, |k|) + 1` method applications, including its terminal
equation. The successful path therefore performs
`C(three, two) + C(three, three) = 3 + 4 = 7` internal comparison
applications. The miss performs
`C(Zero, two) + C(Zero, one) = 1 + 1 = 2`. Selected evidence changes how the
method arrives, not which equations these finite inputs enter.

The exact structural result and type follow the pinned [observation
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation).
The tool's [successful-output
contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
gives one standard-output line, empty standard error, and status `0`.

## Preserve replacement and expose malformed data

The next entry also removes only the explicit comparator arguments. Its
sequential bindings retain the original tree, derive a replacement, and then
construct a malformed tree directly.

<!-- source: src/02-replace-and-malformed.ash -->
```ash
import ordered_trees as Trees

main : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let with_two = Trees.insert two 20 Trees.Empty
    let original = Trees.insert one 10 with_two
    let replaced = Trees.insert one 99 original
    let malformed = Trees.Node(
        Trees.Node(Trees.Empty, two, 20, Trees.Empty),
        one,
        10,
        Trees.Empty
    )
    (
        Trees.lookup one original,
        Trees.lookup one replaced,
        Trees.lookup two malformed
    )
}
```

Predict `Some(10)` from `original` and `Some(99)` from `replaced`. On an
`Equal` insertion, the library retains the stored representative key and both
branches while changing only the value. The older binding still denotes the
earlier value.

The malformed tree places `two` in the left branch of `one`. Lookup compares
`two` as `Greater` than the root and enters the empty right branch, so predict
`None` even though the key occurs structurally.

Run the entry:

```text
ash abstracting-key-order/src/02-replace-and-malformed.ash
```

```text
(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)
```

The three observations confirm replacement, retention of the older tree, and
the malformed miss. `Tree<K, V>` remains a public transparent type, so an
importer may use `Trees.Node` directly under the pinned [public, private, and
opaque declaration
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations).
Neither the nominal type nor `Order<K>` certifies descendant placement.

## Observe the same unbalanced insertion

Ascending keys still make every insertion choose the right branch.

<!-- source: src/03-ascending.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import ordered_trees as Trees

main : Unit -> (Trees.Tree<Trees.Natural, Int>, Trees.Natural, (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let after_one = Trees.insert one 10 Trees.Empty
    let after_two = Trees.insert two 20 after_one
    let after_three = Trees.insert three 30 after_two
    (
        after_three,
        Trees.height after_three,
        Trees.lookup_counted three after_three
    )
}
```
<!-- markdownlint-enable MD013 -->

Predict a three-node right chain, unary height `3`, and a lookup that visits
all three nodes.

```text
ash abstracting-key-order/src/03-ascending.ash
```

<!-- markdownlint-disable MD013 -->
```text
(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : (Tree<Natural, Int>, Natural, (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

The tree, height, value, and visit count are again unchanged. For this input,
`n = 3` and `h = 3`. In general, ascending insertion can produce a right chain
with `h = n`. An interface requirement supplies comparison evidence; it adds
no balancing rule or logarithmic-height guarantee.

`height` does not require `Order<K>` because it never compares keys. At each
node it evaluates both recursive heights and then invokes the private
`maximum` helper on the unary results. Those helper calls and constructed
`Next` forms remain separate source work from lookup's visited-node count and
Natural comparison work.

## Separate output from evidence lowering

These three runs establish that each complete program checks, evaluates, and
produces the displayed value and type. They do not expose the chosen
implementation identity, distinguish abstract from concrete selection, or
show the generated Core program. Those conclusions come from the pinned
specification and retained implementation tests, not from successful CLI
output.

After linked evidence validation, a constrained global lowers to an ordinary
Core function with type parameters first, then one function binder for each
flattened evidence method, then the source value function. At a constrained
call, type application comes first, evidence applications follow, and source
value applications come last. Abstract selections lower to evidence
parameters; concrete selections lower to occurrences of the selected
implementation-method binders. These are the pinned
[interface-evidence lowering
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/elaboration.md#interface-evidence-lowering).

Three exact retained tests exercise or inspect compiler stages that a CLI
result cannot reveal:

- [`cross_module_constraint_lowers_to_method_evidence`](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/tests/interfaces.rs#L252)
  inspects the evidence binder and concrete method application before the
  source argument;
- [`recursive_constrained_global_reuses_its_declared_abstract_evidence`](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/tests/interface_selection.rs#L682)
  inspects the abstract selections on a method and recursive global
  occurrence; and
- [`generic_exact_current_self_carries_abstract_prerequisite_evidence`](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/tests/interfaces.rs#L658)
  exercises recursive exact-current evidence in an implementation method.

The tests support the specified checking and lowering account. They do not add
language behavior or make Core structure observable to an Ash program.

Once the selected relationships have lowered, their interface,
implementation, and requirement identities erase. The evaluator receives
ordinary functions, binder lookups, and applications under the pinned
[generated-evidence
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#generated-interface-evidence).
There is no runtime interface value, implementation registry, registration
step, implementation lookup, or interface-specific dispatch.

Generated evidence functions and applications can still perform ordinary Core
work. They are outside the program's named counts for visited nodes,
top-level `compare` calls at nodes, and recursive Natural `compare` calls.
The observations therefore establish no zero-overhead result, identical Core,
elapsed-time comparison, or machine-cost comparison with explicit parameter
passing.

## Observe a missing implementation

Now change the key representation instead of the calling syntax. This complete
entry constructs one `Int`-key node and calls the same constrained global.

<!-- source: src/04-missing-order.ash -->
```ash
import ordered_trees as Trees

main : Unit -> Trees.Option<Int>
main () = {
    let tree = Trees.Node(Trees.Empty, 1, 10, Trees.Empty)
    Trees.lookup 1 tree
}
```

Ordinary typing determines `K = Int`, so the call creates an `Order<Int>`
obligation. `main` declares no abstract requirement, it is not an
implementation method with exact current evidence, and the direct dependency
provides only `Order<Natural>`. Predict rejection before evaluation.

Run the entry:

```text
ash abstracting-key-order/src/04-missing-order.ash
```

<!-- markdownlint-disable MD013 -->
```text
constraint.unsatisfied
primary: source 0 139..151: no available implementation satisfies this interface obligation
related: source 1 478..484: this declaration introduced the interface obligation
related: source 0 0..29: this import made the declaration available
related: source 1 224..283: this interface declaration participates in the failing selection
```
<!-- markdownlint-enable MD013 -->

The `Order<Int>` obligation belongs to the `Trees.lookup` occurrence.

That causal location matters more than the rendered offsets or prose. The
stable observation is empty standard output, status `1`, first standard-error
line `constraint.unsatisfied`, and a primary label covering the constrained
`Trees.lookup` occurrence. Related labels connect the failure to the imported
declaration and `Order` interface. The pinned [selection
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
assign an unsatisfied obligation to its constrained occurrence, while the
tool's [failure
contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#failures)
defines the channels and status. Colors, gutters, byte offsets, and the
remaining diagnostic presentation are not contracts. Because checking rejects
the program, evaluation never attempts to find an implementation.

## Retain the algorithm's premises

Moving comparison into selected evidence does not make its laws part of
`Order<A>`. Fix one implementation whose comparisons required by an argument
return and whose results satisfy these premises:

- `Equal` is the chosen equivalence between keys;
- reversing a strict comparison reverses `Less` and `Greater`;
- strict comparison is transitive; and
- equivalent keys have the same ordering relationship to every other key.

For that implementation, `Empty` is valid. A finite
`Node(left, key, value, right)` is valid when both subtrees are valid, every
key anywhere in `left` compares with `key` as `Less`, and every key anywhere in
`right` compares with `key` as `Greater`. The interface checks none of these
global descendant properties.

For a finite valid input tree, when every comparison on the entered insertion
path returns, a completed insertion preserves the invariant under those
premises. `Less` and `Greater` rebuild the node around the one recursively
changed branch. `Equal` retains the stored representative key and both
branches. This is a proof obligation about this program, not a property that
Ash derives from `where Order<K>`.

For a completed lookup on a finite tree whose query and visited keys
`k_1` through `k_m` are finite unary Naturals, let `C(query, k_i)` count
completed `compare` method applications for that pair, including the terminal
equation. Let `h` be the greatest number of `Node` forms on a
root-to-`Empty` path. The exact comparison sub-work is:

```text
sum from i = 1 to m of C(query, k_i)
```

The surrounding branch selection, result construction, recursive lookup, and
count bookkeeping contribute `O(m)` named source operations. One-branch
lookup has `m <= h`. Only when every visited comparison satisfies
`C(query, k_i) <= Cmax`, with `Cmax >= 1`, may the combined account be
summarized as `O(h * Cmax)`. Generated evidence applications remain ordinary
work outside these named counts. None of these source counts establishes
elapsed time, machine instructions, arbitrary-precision integer bit cost,
heap bytes, or native stack behavior.

A completed return claim also needs the finite entered path and returning
comparisons on that path. A required nonreturning comparison can prevent
lookup from returning. The nominal type does not prove finiteness: Ash permits
constructor-guarded cyclic values under its static [recursive block-group
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups)
and dynamic [recursive binding
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#recursive-bindings).
A reachable cycle along the selected path may prevent return, while a cycle in
an unentered branch need not affect that lookup.

This case adds no opacity, invariant enforcement, balance, deletion, mutation,
iteration, or generic tree infrastructure. It also introduces no associated
declarations, default methods, named implementations, inferred global
requirements, runtime registries, or dynamic dispatch. The source and output
make no claims about physical sharing, pointer identity, garbage collection,
compiler optimization, or storage strategy.

## Practice and continue

1. At `Trees.insert two 20 Trees.Empty`, identify the key type that ordinary
   typing determines and name the resulting interface obligation. Then state
   which direct dependency can supply its evidence.
2. Suppose the Natural implementation loses `pub` while the entry remains a
   direct dependent. Predict whether `Trees.lookup_counted three valid` can
   select that implementation, and identify the source occurrence that owns
   the resulting obligation.
3. In a copy of the first entry, replace the Natural query and tree keys with
   `Int` values while retaining the constrained lookup. Predict the output
   channel, first reason, and status before running it.

Selected evidence removes the repeated comparator argument, but the
transparent tree still lets a client construct a value that violates the
ordering invariant. How can an opaque dictionary expose insertion and lookup
while preventing clients from constructing that malformed representation?
