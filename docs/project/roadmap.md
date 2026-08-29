# Roadmap

The roadmap names ash-doc's next complete increment and keeps later cases in a
provisional order. It is a planning view, not a curriculum, publication
promise, or source of Ash semantics.

## Current edition

- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Repository state: the first repository-source edition is published; new
  recursive-algorithm work remains unpublished on `main`
- Published documentation tag: immutable `modular-ash`

The current `ash-lang/main` compatibility canary is deferred until an explicit
forward migration. Every increment below continues to use the exact published
target.

## Verified

The complete eleven-lesson [beginning learning path](beginning-learning-path.md)
is verified at the resolved commit. Its immutable publication snapshot remains
available at the repository-local `modular-ash` tag.

## Next: folding recursive lists

**Reader question:** How can one recursive traversal define many list
algorithms?

Create the Cases family after the complete Learn Ash path. Introduce a strict
right `fold` over `List<A>` and define `sum`, `length`, `map`, and `filter`
through it. A counted first-element calculation must show that returning the
first value does not let an eager right fold avoid traversing the rest.

The case must establish source-level combiner calls, recursive dependency
depth, and constructed `More` nodes without claiming host stack optimization or
heap byte counts. Successful programs and one complete `type.argument`
rejection must run at the exact pin. See the approved
[design](../plans/2026-08-29-recursive-algorithms-design.md) and active
[implementation plan](../plans/2026-08-29-folding-recursive-lists.md).

## Provisional cases

The following order expresses current dependencies. These entries authorize no
content directories, source files, or tooling. Promote only one after the
preceding case verifies and its evidence has been reviewed.

### 2. Building finite lists with `unfold`

**Question:** How can changing finite state produce recursive data?

Introduce `Step<S, A> = Stop | Emit(A, S)` and
`unfold : (S -> Step<S, A>) -> S -> List<A>`. Use a unary `Natural` seed so
every executable producer has a structural termination measure. Demonstrate
exact output, counted steps, eager construction of the complete result, the
additional list constructed by a following `map`, and a complete type
rejection. Do not introduce lazy or infinite data, a hanging example, or a
generic fold/build fusion API.

### 3. Accumulating list results

**Question:** When should recursion retain knowledge from earlier elements?

Compare `fold_left`, reverse through repeated append, and accumulator reverse.
Instrumentation over four elements must report six previously built nodes
revisited by the append-based algorithm and four input nodes visited by the
accumulator algorithm. Explain the accumulator invariant, quadratic versus
linear work, retained logical state, and tail position without promising
implementation-level constant stack use.

### 4. A dictionary encoded as a list

**Question:** What does lookup cost when a dictionary is a recursive list?

Introduce an association-list `Entry<K, V>` and `Dictionary<K, V>` with
explicit equality, `empty`, `insert`, `lookup`, and `lookup_counted`. Prepending
must shadow an older equal key. The case must observe one comparison for the
newest duplicate key and three comparisons for a missing key after three
insertions. Contrast selective recursive lookup with an eager whole-list fold,
and explain linear retrieval, equality cost, persistent sharing, and retained
old versions.

### 5. Folding branching data

**Question:** How does the data-directed method extend from lists to trees?

Introduce `Tree<A> = Empty | Node(Tree<A>, A, Tree<A>)`, `fold_tree`, `size`,
and `map_tree`. Compare balanced and skewed trees with the same node count.
Establish one visit per node and recursive dependency depth proportional to
height, and show why a general eager fold cannot implement selective search
without visiting both branches.

### 6. Searching an ordered tree

**Question:** How can an invariant let lookup ignore most of a tree?

Introduce an explicit `Ordering`, comparison function, and counted `lookup` and
`insert`. Use recursive natural-number keys and state lookup work as
`O(C(k) * h)`. Cover successful and missing lookup, duplicate replacement, a
manually valid tree, a malformed transparent tree, and ascending insertion that
produces degenerate height.

### 7. Abstracting key order

**Question:** How can modules reuse an ordering capability without passing it
manually?

Replace explicit comparison parameters with a public `Order<A>` interface, a
constrained dictionary API, and a public implementation for the example key
type. Preserve the preceding behavior and cost model. Demonstrate checking-time
evidence selection, lowering to ordinary calls, and a complete
`constraint.unsatisfied` rejection.

### 8. Protecting the dictionary invariant

**Question:** How can clients use a dictionary without constructing invalid
trees?

Move the tree behind `pub opaque type Dictionary<K, V>` and expose `empty`,
`insert`, `lookup`, concrete list-consuming `build`, and `invariant_holds`.
Reject client construction and matching with `resolve.opaque-constructor`.
`build` is an invariant-preserving dictionary operation, not a rank-2 producer
from lazy fold/build fusion.

### 9. Guaranteeing logarithmic retrieval

**Question:** How can the representation prevent a search tree from
degenerating?

First add a source record for the selected persistent red-black-tree tradition
and its license. Replace the opaque representation without changing the normal
client API. Explain ordering, root-black, red-parent, and equal-black-height
invariants; the four insertion balance configurations; root blackening;
persistent path copying; and `O(C(k) log n)` lookup and insertion. Test every
prefix of ascending, descending, and rotation-triggering sequences for behavior
and invariants.

### 10. Resuming tree traversal

**Question:** How can traversal pause and resume without laziness?

Expose an opaque eager `Iterator<K, V>` with `iterator` and
`next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>`. Repeated calls over
three entries must end with `None`. Explain `O(h)` initialization and state,
worst-case `O(h)` `next`, and amortized constant work over a complete traversal.
Do not use thunks, lazy lists, hidden mutation, or infinite-data claims.

### 11. Choosing a search frontier

**Question:** How does frontier representation change a search algorithm?

Build deterministic depth-first and breadth-first search over one finite cyclic
graph. Use a list stack for DFS, a two-list amortized queue for BFS, the
dictionary as a visited set, and explicit counted search state. Both traversals
must find the target; BFS must return the shortest unweighted path; visited
tracking must prevent repeated expansion. Compare depth memory with width
memory and classify any library, tooling, diagnostic, or performance pressure.

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
   successor, and reassess the remaining provisional order.

Final verification for each increment uses a clean Ash checkout at the exact
resolved commit:

```text
bash -n <changed verification scripts>
bash content/learn/checks/verify.sh <clean pinned ash-lang checkout>
bash content/cases/checks/verify.sh <clean pinned ash-lang checkout>
git diff --check
git status --short
```
