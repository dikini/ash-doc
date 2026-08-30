# Roadmap

The roadmap names ash-doc's next complete increment and keeps later cases in a
provisional order. It is a planning view, not a curriculum, publication
promise, or source of Ash semantics.

## Current edition

- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Repository state: the first repository-source edition is published; the
  seven verified recursive-algorithm cases remain unpublished on `main`
- Published documentation tag: immutable `modular-ash`

The current `ash-lang/main` compatibility canary is deferred until an explicit
forward migration. Every increment below continues to use the exact published
target.

Every case uses the [pinned eager evaluation
behavior](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md)
and lands its prose, complete canonical programs, and checks together. The
roadmap states mean:

- **next** identifies the one increment ready to enter the execution workflow:
  approve its bounded design, activate its temporary plan, then implement it;
- **provisional** orders downstream increments without authorizing their case
  implementation, content directories, source, or tooling; and
- **verified** identifies completed content whose prose, programs, and checks
  pass together.

Promotion to **next** authorizes the design-and-plan work, not a content change
that bypasses those gates.

## Verified increments

The complete eleven-lesson [beginning learning path](beginning-learning-path.md)
is verified at the resolved commit. Its immutable publication snapshot remains
available at the repository-local `modular-ash` tag.

### 1. Folding recursive lists

**Question:** How can one recursive traversal define many list
algorithms?

The first [Cases](../../content/cases/README.md) chapter defines a strict right
`fold` over `List<A>` and derives `sum`, `length`, `map`, and `filter` from it.
Its counted first-element program observes that returning the first value does
not let an eager right fold avoid traversing the rest.

Five canonical sources and their displayed blocks pass together at the exact
pin. The checks assert three successful values and types, the complete
`type.argument` rejection and its causal base argument, and the source
relationships that make the four operations uses of `fold`. The chapter
separates combiner calls, recursive dependency depth, and constructed `More`
nodes from host stack optimization and heap byte counts. The approved
[recursive-algorithms design](../plans/2026-08-29-recursive-algorithms-design.md)
continues to govern the path.

### 2. Building finite lists with `unfold`

**Question:** How can changing finite state produce recursive data?

The second [Cases](../../content/cases/README.md) chapter defines
`Step<S, A> = Stop | Emit(A, S)` and
`unfold : (S -> Step<S, A>) -> S -> List<A>`. A unary `Natural` seed makes the
concrete producer's structural termination measure visible. The chapter
separates that argument from generic `unfold`, which does not establish that an
arbitrary transition reaches `Stop`.

Five canonical sources and their displayed blocks pass together at the exact Ash
commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`. The checks assert three
successful values and types, the complete `type.argument` rejection and its
causal Boolean seed, and the source relationships for one transition per
recursive call, eager recursive-rest binding, structural decrease, and the
additional list built by a following `map`. For a seed with `n` `Next` forms,
the terminating producer reports `n + 1` transition applications and
constructs `n` `More` values before `map` constructs another `n`.

The case introduces no generic termination guarantee, lazy or infinite data,
or fold/build fusion API. It retains elapsed time, exact heap bytes, host stack
behavior, and compiler optimization outside its source-level claims.

### 3. Accumulating list results

**Question:** When should recursion retain knowledge from earlier elements?

The third [Cases](../../content/cases/README.md) chapter compares reverse through
repeated append with accumulator reverse. Five canonical sources and their
displayed blocks pass at the exact Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Four exact accepted observations
establish the same reverse results, six previously built left-node revisits
versus four original input visits, an invariant midpoint, and an accepted wrong
initial accumulator.

The source equations derive quadratic append revisits and constructor
applications versus linear accumulator visits and constructions. Tail position
names only the recursive application's source placement. The case excludes
elapsed time, exact heap bytes, host-stack behavior and tail-call optimization,
compiler optimization, mutation, and a type-level proof of the invariant.

### 4. A dictionary encoded as a list

**Question:** What does lookup cost when a dictionary is a recursive list?

The fourth [Cases](../../content/cases/README.md) chapter represents each
dictionary as a newest-to-oldest recursive list of entries. Explicit equality
lets selective lookup return at the first match, so prepending an equal key
shadows the older entry without removing it.

Five canonical sources and their displayed blocks pass at the exact Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Four exact accepted observations
establish ordinary hit and absence, one comparison for a front hit versus
three for a complete miss, one selective comparison versus three strict-fold
comparisons for the same hit, and lookup through retained older and newer
dictionary versions.

For a fixed query `q`, assume the dictionary is finite and every equality
application required by the chosen algorithm returns. Under those conditions,
let `m` be the number of entries direct lookup visits through its first match,
or the full dictionary length on a miss. If `E_q(k_i)` names the source work of
equality at visited key `k_i`, direct lookup's account is
`O(m + sum E_q(k_i))`. Only when `E_q(k_i) <= Emax` for every visited key may
this be summarized as `O(m * (1 + Emax))`. The strict fold visits every entry
under the same conditions because it obtains the complete folded tail before
combining the current entry. Each insertion constructs one `Entry` and one
front `More`, with the previous dictionary as the tail. Retaining both
dictionary values leaves the older entries reachable through both version
chains.

These are source-level work, construction, and reachability claims. The case
does not establish elapsed time, machine instructions, host-stack behavior,
tail-call optimization, exact heap bytes, garbage collection, pointer identity,
mutation, or compiler representation and optimization. It introduces no
equality interface or law enforcement, evidence selection, ordering, tree,
balancing, opacity, deletion, in-place update, or lazy, infinite, or cyclic
data.

### 5. Folding branching data

**Question:** How does the data-directed method extend from lists to trees?

The fifth [Cases](../../content/cases/README.md) chapter extends the
data-directed fold from one list tail to the two branches of
`Tree<A> = Empty | Node(Tree<A>, A, Tree<A>)`. Four canonical sources and their
displayed blocks pass at the exact Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Three exact accepted outputs
establish size and shape-preserving map behavior, equal three-node counts with
balanced height `2` and skewed height `3`, and one predicate application for a
direct root hit versus three applications through the strict whole-tree fold.
These are one visited node for selective direct search and three visited nodes
for strict folded search.

For a finite structural expansion with `n` `Node` encounters, a completed
`fold_tree` whose required combiner applications return completes exactly `n`
`Node` combiners. If `h` is the greatest number of `Node` forms on a path from
the root to `Empty`, the longest source dependency has `h` pending `Node`
results; counting the active terminal `Empty` call gives `h + 1` simultaneous
source `fold_tree` calls. These counts do not describe native stack frames.
`size` performs two primitive integer additions per node. If the transform
returns for every encountered value, `map_tree` applies it `n` times,
constructs `n` output `Node` forms, and preserves branch shape. The separate
unary `maximum` recursion and height construction inside `nodes_and_height`
are not included in the fold's `n` combiner or `h` pending-result counts.

Direct pre-order search completes when every predicate application at each
node it enters returns; it imposes no predicate-return condition on unentered
branches. The completed folded search requires a returning predicate at every
node in the finite expansion because both branch folds finish before the
current combiner runs. When a traversal enters both branch fields, as the
completed strict fold does, a shared acyclic subtree placed in both fields is
followed and counted through both structural occurrences. A cyclic `Tree`
value may prevent these functions from returning; the nominal type does not
establish finiteness.

The case intentionally excludes ordering, ordered insertion and lookup,
duplicate-key policy, balancing, opacity, mutation, laziness, infinite-tree
claims, and generic tree infrastructure. Its source counts do not establish
elapsed time, machine instructions, native stack size, tail-call optimization,
exact heap bytes, garbage collection, pointer identity, physical sharing,
arbitrary-precision integer bit cost, or compiler representation and
optimization.

### 6. Searching an ordered tree

**Question:** How can an invariant let lookup ignore most of a tree?

The sixth [Cases](../../content/cases/README.md) chapter passes an explicit
comparator to lookup and persistent insertion over a transparent ordered tree.
Four canonical sources and their displayed blocks produce three exact accepted
outputs at Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`. A manually
valid balanced tree gives a successful path and a missing path that each visit
two nodes and make two top-level comparisons. The recursive Natural comparator
performs `7` internal applications for the hit and `2` for the miss.

Validity requires a global descendant invariant: both subtrees are valid,
every left key is `Less` than the current key, and every right key is
`Greater`. The argument fixes a comparator whose required comparisons return,
whose `Equal` result is the chosen key equivalence, whose reversed strict
comparisons reverse `Less` and `Greater`, whose strict order is transitive, and
whose equivalent keys have the same ordering relationship to every other key.
Under those premises and for a finite valid tree, insertion preserves the
invariant. Equal-key insertion replaces only the value while retaining the
stored representative key and both branches; the older `Some(10)` and
replacement `Some(99)` values remain separately observable. The transparent
type also accepts a malformed tree with `two` misplaced left of `one`; lookup
follows the empty right branch and returns `None` for that structurally present
key.

For a completed lookup on a finite tree whose query and visited keys `k_1`
through `k_m` are finite unary Naturals, let `C(query, k_i)` count the
completed `compare_natural` applications for that pair, including the terminal
equation. Let `h` be the greatest number of `Node` forms on a root-to-`Empty`
path. Exact comparison sub-work is the sum from `i = 1` to `m` of
`C(query, k_i)`, surrounding named source work is `O(m)`, and one-branch lookup
has `m <= h`. Only when `C(query, k_i) <= Cmax` for every visited key, with
`Cmax >= 1`, may the combined account be summarized as `O(h * Cmax)`.
Ascending insertion produces the observed three-node right chain, unary height
`3`, and three-node lookup path, and can generally produce `h = n`. This
unbalanced representation provides no logarithmic guarantee. Computing
`height` over both branches and invoking its private unary `maximum` are
separate work from lookup visits and comparator sub-work.

The return claims require a finite entered path and returning comparisons on
that path; a required nonreturning comparison or reachable constructor-guarded
cycle may prevent lookup from returning. The case's source counts do not claim
elapsed time, machine instructions, runtime or native-stack storage, tail-call
optimization, heap layout or bytes, garbage collection, pointer identity,
physical sharing, compiler representation or optimization, or
arbitrary-precision integer bit cost. It introduces no interface, evidence
selection, opacity, balancing, deletion, mutation, iteration, or generic tree
infrastructure.

### 7. Abstracting key order

**Question:** How can modules reuse an ordering capability without passing it
manually?

The seventh [Cases](../../content/cases/README.md) chapter replaces explicit
comparator value arguments with a public one-method `Order<A>` interface, a
public `Order<Natural>` implementation, and explicit `where Order<K>`
requirements on `lookup`, `insert`, and `lookup_counted`; their source value
types contain no comparator argument. Five canonical sources and their
displayed blocks pass together at Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. The three accepted entries retain
the preceding tree constructions and produce these exact outputs with empty
standard error and status `0`:

<!-- markdownlint-disable MD013 -->
```text
((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))
(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)
(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : (Tree<Natural, Int>, Natural, (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

At an imported Natural call, ordinary typing determines `K`. Under the pinned
[public declaration
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations),
the direct dependency's public Natural implementation is available and
supplies the matching concrete evidence. Inside each constrained recursive
global, the declared abstract requirement supplies both the method occurrence
and recursive constrained occurrence. The recursive Natural method uses
exact-current evidence. These selection relationships follow the pinned
[constraint satisfaction and checked-evidence
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence).
CLI output establishes only each complete program's acceptance and result; it
cannot expose the selected identity or generated Core. The specified
[interface-evidence
lowering](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/elaboration.md#interface-evidence-lowering),
supported by three focused retained tests, produces ordinary Core evidence
binders and applications before source value arguments. The identities erase
before evaluation. Under the pinned [generated interface-evidence
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#generated-interface-evidence),
the evaluator uses ordinary functions and applications, so this mechanism
introduces no runtime implementation registry, registration, interface
lookup, or interface-specific dispatch.

A fourth complete entry fixes `K = Int` at `Trees.lookup`, while the direct
dependency provides only `Order<Natural>`. It is rejected during checking with
empty standard output, first standard-error line `constraint.unsatisfied`, and
status `1`; the primary causal label covers the constrained `Trees.lookup`
occurrence. The pinned [failure
contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#failures)
governs those channels and status. Colors, offsets, gutters, and remaining
diagnostic prose are not contracts.

The interface changes how comparison is supplied, not the algorithm's
premises. Its method-only declaration states a comparison type but encodes no
ordering laws under the pinned [interface
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#interfaces-and-constrained-schemes).
Fix one implementation whose required comparisons return, whose
`Equal` result is the chosen key equivalence, whose reversed strict
comparisons reverse `Less` and `Greater`, whose strict order is transitive,
and whose equivalent keys have the same ordering relationship to every other
key. Validity still requires both subtrees to be valid, every left descendant
to compare `Less` than the current key, and every right descendant to compare
`Greater`. For a finite valid tree whose entered-path comparisons return,
completed insertion preserves that global invariant. Equal insertion retains
the stored representative key and both branches while replacing only its
value.

For a completed lookup on a finite tree whose query and visited keys `k_1`
through `k_m` are finite unary Naturals, let `C(query, k_i)` count completed
`compare` method applications for that pair, including the terminal equation.
Let `h` be the greatest number of `Node` forms on a root-to-`Empty` path. Exact
comparison sub-work remains the sum from `i = 1` to `m` of
`C(query, k_i)`, surrounding named source work is `O(m)`, and one-branch
lookup has `m <= h`. Only when `C(query, k_i) <= Cmax` for every visited key,
with `Cmax >= 1`, may the combined account be summarized as
`O(h * Cmax)`. Generated evidence functions and applications are ordinary
Core work outside those named counts.

Under the pinned [public and opaque declaration
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations),
the transparent representation still accepts a malformed tree that contains
the queried key in the wrong branch and returns `None`. Ascending insertion
still produces a right chain with `h = n`, so the interface adds no balancing
or logarithmic guarantee. `height` still enters both branches and performs
separate private unary `maximum` work. A lookup return claim requires a finite
entered path and returning comparisons; a required nonreturning comparison or
a reachable constructor-guarded cycle may prevent return under the pinned
[static recursive block-group
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups)
and dynamic [recursive binding
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#recursive-bindings).

The case establishes no zero-overhead, identical-Core, elapsed-time,
machine-instruction, native-stack, heap-byte, garbage-collection,
pointer-identity, physical-sharing, compiler-optimization, or
arbitrary-precision bit-cost result. It introduces no opacity, invariant
enforcement, balancing, deletion, mutation, iteration, or generic tree
infrastructure.

## Next: protecting the dictionary invariant

**Question:** How can clients use a dictionary without constructing invalid
trees?

Move the tree behind `pub opaque type Dictionary<K, V>` and expose `empty`,
`insert`, `lookup`, concrete list-consuming `build`, and `invariant_holds`.
Run normal construction and lookup through the public API, then reject separate
client construction and matching attempts with `resolve.opaque-constructor`.
`build` must use strict `fold_left` through `insert` in input order so later
equal keys replace earlier ones. It is an invariant-preserving dictionary
operation, not a rank-2 producer from lazy fold/build fusion.

Before creating a content directory or source file, approve a bounded design
for this outcome and link an active temporary implementation plan here. Those
records must name the exact-pin observations, opacity and invariant boundaries,
verification, independent review, and repository closure.

## Provisional cases

The following order expresses current dependencies. These entries authorize no
content directories, source files, or tooling. Promote only one after the
preceding case verifies and its evidence has been reviewed.

### 9. Guaranteeing logarithmic retrieval

**Question:** How can the representation prevent a search tree from
degenerating?

Before promotion, add a source record for the selected persistent
red-black-tree tradition and its license. Replace the opaque representation
without changing the normal client API. Explain ordering, a black root, no red
parent with a red child, and equal black-height invariants; the four insertion
balance configurations; root blackening; persistent path copying and subtree
reuse; and logarithmic tree height. State lookup and insertion as
`O(log n)` comparisons and `O(log n)` newly constructed path nodes. If
comparison cost varies, use `O(log n * Cmax)` under an explicit bound. Describe
this as worst-case logarithmic comparison-based retrieval, not universal
optimality. Test lookup behavior and `invariant_holds` after every insertion
prefix in ascending, descending, and rotation-triggering sequences. Attribute
the guarantee to the opaque API plus invariant-preserving insertion, not to the
nominal representation alone.

### 10. Resuming tree traversal

**Question:** How can traversal pause and resume without laziness?

Expose an opaque eager `Iterator<K, V>` with
`iterator : Dictionary<K, V> -> Iterator<K, V>` and
`next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>`. Repeated calls over
three entries must end with `None`. Explain `O(h)` initialization and state,
worst-case `O(h)` `next`, and `O(n + h)` frame operations over one complete
linear traversal, which gives amortized constant frame work per produced
entry. Do not use thunks, lazy lists, hidden mutation, or infinite-data claims.

### 11. Implementing a persistent FIFO frontier

**Question:** How can two lists preserve queue order while avoiding a full
rebuild on every operation?

Introduce an eager persistent `Queue<A>` with front and rear lists, `empty`,
`enqueue`, and `dequeue`. A deterministic operation sequence must preserve FIFO
order and expose the one rear-list reversal. Count list-node work and explain
amortized constant enqueue/dequeue only over one linear sequence of queue
states; retaining and resuming older versions can repeat reversal work. Use
source-level representation and operation counts, not elapsed-time or runtime
memory claims.

### 12. Choosing a search frontier

**Question:** How does frontier representation change a search algorithm?

Build deterministic depth-first and breadth-first search over one finite cyclic
graph. Use a list stack for DFS, a two-list amortized queue for BFS, the
dictionary as a visited set, explicit search state, and a counted frontier
size represented by a recursive `Natural`. Both traversals must find the
target; FIFO order and marking vertices when enqueued must make BFS return the
shortest unweighted path; visited tracking must prevent repeated expansion.
Measure maximum pending-frontier entries in the example. State general DFS
stack bounds in terms of branching and depth and BFS bounds in terms of
frontier width, while accounting separately for retained paths and the visited
dictionary. Keep runtime-memory claims outside the language contract and
classify any library, tooling, diagnostic, performance, or application
pressure.

## Promotion and verification policy

For every increment:

1. Promote only one provisional increment to **next** and give it an approved
   bounded design before implementation.
2. Add its temporary detailed plan only after promotion.
3. Keep every displayed Ash program complete, canonical, and automatically
   invoked.
4. Assert exact values, types, output, and exit status for successes; assert a
   stable reason and causal source location for intentional rejections.
5. Run all Learn and Cases checks before closure.
6. Review time, comparison, allocation, recursion-depth, and retained-state
   claims as source-level properties unless a separate implementation record
   establishes more.
7. Classify discoveries as ash-doc corrections, Ash regression candidates,
   unspecified design questions, or library, tool, diagnostic, performance, or
   application pressure.
8. Remove the completed temporary plan, mark the case **verified**, promote its
   successor, and reassess the remaining provisional order while preserving
   the final goals of balanced dictionaries, explicit iterators, and search
   frontiers.
9. Add a focused research or laboratory record only when an observed case
   supplies material evidence. Any upstream evidence candidate must reference
   the completed case commit as well as the exact ash-doc and Ash targets.

Final verification for each increment uses a clean Ash checkout at the exact
resolved commit:

```text
bash -n <changed verification scripts>
bash content/learn/checks/verify.sh <clean pinned ash-lang checkout>
bash content/cases/checks/verify.sh <clean pinned ash-lang checkout>
git diff --check
git status --short
```
