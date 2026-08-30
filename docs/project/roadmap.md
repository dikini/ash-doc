# Roadmap

The roadmap names ash-doc's next complete increment and keeps later cases in a
provisional order. It is a planning view, not a curriculum, publication
promise, or source of Ash semantics.

## Current edition

- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Repository state: the first repository-source edition is published; the
  verified recursive-algorithm cases remain unpublished on `main`
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

## Next: accumulating list results

**Question:** When should recursion retain knowledge from earlier elements?

Compare `fold_left`, reverse through repeated append, and accumulator reverse.
Instrumentation over four elements must report six previously built nodes
revisited by the append-based algorithm and four input nodes visited by the
accumulator algorithm. Explain the accumulator invariant, quadratic versus
linear work, retained logical state, and tail position without promising
implementation-level constant stack use.

Acceptance requires both reverse definitions to produce the same list, their
instrumented work to differ by the stated counts, and executable examples that
establish the accumulator invariant. Runtime-memory claims remain outside the
pinned language contract.

Before implementation, approve a bounded design for this question and add its
temporary detailed plan. No content directory or source file is authorized by
promotion alone.

The [accumulating-list-results
design](../plans/2026-08-30-accumulating-list-results-design.md) is approved by
the 2026-08-30 autonomous remaining-cases request. Its temporary execution plan
must remain active until the complete case passes and the roadmap promotes its
successor.

The temporary [implementation
plan](../plans/2026-08-30-accumulating-list-results.md) owns the approved work
through exact-pin verification, independent review, and local integration.

## Provisional cases

The following order expresses current dependencies. These entries authorize no
content directories, source files, or tooling. Promote only one after the
preceding case verifies and its evidence has been reviewed.

### 4. A dictionary encoded as a list

**Question:** What does lookup cost when a dictionary is a recursive list?

Introduce an association-list `Entry<K, V>` and `Dictionary<K, V>` with
explicit equality, `empty`, `insert`, `lookup`, and `lookup_counted`. Prepending
must shadow an older equal key. After inserting `(1, 10)`, `(2, 20)`, and
`(1, 11)`, lookup of `1` must return `Some(11)` after one comparison, while
lookup of `3` must return `None` after three comparisons. Contrast selective
recursive lookup with an eager whole-list fold. Explain linear retrieval,
name the per-key equality cost `E(k)`, and account for one new front node, reuse
of the previous dictionary value, and the entries reachable through retained
dictionary versions. Keep heap bytes and collection outside the contract.

### 5. Folding branching data

**Question:** How does the data-directed method extend from lists to trees?

Introduce `Tree<A> = Empty | Node(Tree<A>, A, Tree<A>)`, `fold_tree`, `size`,
and `map_tree`. Compare balanced and skewed trees with the same node count.
Establish one visit per node and recursive dependency depth proportional to
height. Show why this strict `fold_tree`, whose combiner receives both already
evaluated branch results, cannot implement selective search without visiting
both branches.

### 6. Searching an ordered tree

**Question:** How can an invariant let lookup ignore most of a tree?

Introduce `Ordering = Less | Equal | Greater`, pass
`compare : K -> K -> Ordering` explicitly to `lookup`, `insert`, and
`lookup_counted`, and use recursive natural-number keys. State lookup work as
the sum of `C(query, node_key)` over visited nodes, or as `O(h * Cmax)` only
under an explicit per-comparison bound `Cmax`. Cover successful and missing
lookup, duplicate replacement, a manually valid tree, a malformed transparent
tree whose misplaced key exposes the invariant, and ascending insertion that
produces degenerate height.

### 7. Abstracting key order

**Question:** How can modules reuse an ordering capability without passing it
manually?

Replace explicit comparison parameters with a public `Order<A>` interface, a
constrained `lookup` and `insert` API, and a public implementation for the
example key type. Preserve the preceding behavior and cost model. Demonstrate
successful checking-time evidence selection. Explain the specified lowering to
ordinary calls from the pinned static semantics, elaboration, and retained
tests; CLI output cannot isolate that lowering step. A complete program without
an `Order` implementation must be rejected with `constraint.unsatisfied`.

### 8. Protecting the dictionary invariant

**Question:** How can clients use a dictionary without constructing invalid
trees?

Move the tree behind `pub opaque type Dictionary<K, V>` and expose `empty`,
`insert`, `lookup`, concrete list-consuming `build`, and `invariant_holds`.
Run normal construction and lookup through the public API, then reject separate
client construction and matching attempts with `resolve.opaque-constructor`.
`build` must use strict `fold_left` through `insert` in input order so later
equal keys replace earlier ones. It is an invariant-preserving dictionary
operation, not a rank-2 producer from lazy fold/build fusion.

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
