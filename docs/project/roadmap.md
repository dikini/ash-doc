# Roadmap

The roadmap names ash-doc's next complete increment and records verified
increments. It is a planning view, not a curriculum, publication promise, or
source of Ash semantics.

## Current migration target

- Ash milestone: `lib-ash`
- Resolved commit: `d1e323d23390cdad03202ee3df76cd9100556e1d`
- Repository state: unpublished forward migration with the complete verified
  Learn path and a verified six-Case recursive-algorithm prefix active
- Published `lib-ash` documentation tag: none
- Immutable predecessor: `modular-ash` at Ash commit
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`

Active teaching and verification use the [pinned Lib Ash evaluation
behavior](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md).
The first six Cases records below describe active work at the Lib Ash target.
The later records describe historical work at the predecessor and link its
immutable `recursive-1` snapshot; they do not make those later Cases active.
The roadmap states mean:

- **next** identifies the one increment ready to enter the execution workflow:
  approve its bounded design, activate its temporary plan, then implement it;
- **provisional** orders downstream increments without authorizing their case
  implementation, content directories, source, or tooling; and
- **verified** identifies completed content whose prose, programs, and checks
  pass together.

Promotion to **next** authorizes the design-and-plan work, not a content change
that bypasses those gates.

## Next: migrate Cases to `lib-ash`

**Question:** How can the existing recursive-algorithm Cases preserve their
problems, invariants, derivations, and source-level cost accounts at the exact
`lib-ash` target?

The approved
[Lib Ash documentation milestone design](../plans/2026-08-31-lib-ash-documentation-milestone-design.md)
selects a staged forward migration ending in an immutable ash-doc `lib-ash`
tag. The target is the annotated `ash-lang` tag `lib-ash`, resolved to exact
commit `d1e323d23390cdad03202ee3df76cd9100556e1d`.

The next bounded outcome migrates the twelve historical Cases in reading
order. Each Case must first regain its existing promise at the new pin, then
receive a separate assessment of whether a Lib Ash feature clarifies the same
algorithmic question or strengthens its evidence. The active
[Cases migration implementation plan](../plans/2026-08-31-migrate-cases-to-lib-ash.md)
selects the longest verified sequential prefix, exact per-Case comparison,
explicit implementation-selection migrations, the upstream failure gate, and
partial-prefix integration without claiming Outcome 2 complete. This plan is
approved under the standing Lib Ash milestone authorization and the roadmap's
promotion of Cases to **next**; it authorizes no library-family content.

## Provisional `lib-ash` outcomes

After Cases migration closes, review both migrated paths before promoting the
new **Design library abstractions in Ash** family. Its proposed five-lesson
sequence covers explicit implementation selection, public capability facades,
explicit kinds and higher-kinded parameters, method-local type parameters, and
relational determination. Provisional status authorizes no new content
directory, canonical source, verifier, or shared tooling.

## Verified increments

The active [beginning learning path](beginning-learning-path.md) contains all
eleven lessons and 43 canonical sources verified at exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Lessons 1 through 10 retained
their predecessor source, prose, verifier, and observations; their migration
needed only target and active-navigation administration. Explicit
implementation selection, kinds, method-local type parameters, and relational
interfaces would not simplify or strengthen those lessons' established
questions, so none received a feature retrofit.

Lesson 11 retained all five canonical sources and accepted observations. Its
specified rejection now explains that `List` has kind `Type -> Type`, while an
ordinary function domain requires kind `Type`; the shared rejection helper now
retains the expected and found kinds along with the causal source evidence.
That explicit kind boundary improves the existing lesson without introducing a
separate higher-kinded abstraction.

The migration also retained three unexpected imported-summary compiler
failures as permanent executable
[upstream evidence](../../lab/lib-ash-migration/body-free-summary-authentication/README.md).
The lab records exact observations across both Ash pins and does not propose an
Ash fix.

The active [recursive-algorithm Cases](../../content/cases/README.md) path now
contains six verified Cases and 28 canonical sources at the Lib Ash commit.
Cases 7 through 12 below remain historical material verified at the
Modular Ash predecessor. Their immutable prose, programs, and checks remain
available in
the
[`recursive-1` snapshot](https://github.com/dikini/ash-doc/tree/fa870a280c76278361db658ff3952cf18f2b7833).

[recursive-cases]: https://github.com/dikini/ash-doc/blob/fa870a280c76278361db658ff3952cf18f2b7833/content/cases/README.md

### 1. Folding recursive lists

**Question:** How can one recursive traversal define many list
algorithms?

The active [first Cases chapter](../../content/cases/folding-recursive-lists/README.md)
defines a strict right `fold` over `List<A>` and derives `sum`, `length`, `map`,
and `filter` from it. Its counted first-element program observes that returning
the first value does not let an eager right fold avoid traversing the rest.

Five canonical sources and their displayed blocks pass together at exact Lib
Ash commit `d1e323d23390cdad03202ee3df76cd9100556e1d`. The checks assert three
successful values and types, the complete
`type.argument` rejection and its causal base argument, and the source
relationships that make the four operations uses of `fold`. The chapter
separates combiner calls, recursive dependency depth, and constructed `More`
nodes from host stack optimization and heap byte counts. The approved
[recursive-algorithms design](../plans/2026-08-29-recursive-algorithms-design.md)
continues to govern the path.

The migration changed only target links and active navigation. Explicit
implementation selection, method-local type parameters, and relational
interfaces do not improve this concrete traversal question; a higher-kinded
fold would ask a different abstraction question, so this Case received no
feature retrofit.

### 2. Building finite lists with `unfold`

**Question:** How can changing finite state produce recursive data?

The active [second Cases chapter](../../content/cases/building-finite-lists/README.md)
defines
`Step<S, A> = Stop | Emit(A, S)` and
`unfold : (S -> Step<S, A>) -> S -> List<A>`. A unary `Natural` seed makes the
concrete producer's structural termination measure visible. The chapter
separates that argument from generic `unfold`, which does not establish that an
arbitrary transition reaches `Stop`.

Five canonical sources and their displayed blocks pass together at exact Lib
Ash commit `d1e323d23390cdad03202ee3df76cd9100556e1d`. The checks assert three
successful values and types, the complete `type.argument` rejection and its
causal Boolean seed, and the source relationships for one transition per
recursive call, eager recursive-rest binding, structural decrease, and the
additional list built by a following `map`. For a seed with `n` `Next` forms,
the terminating producer reports `n + 1` transition applications and
constructs `n` `More` values before `map` constructs another `n`.

The Case introduces no generic termination guarantee, lazy or infinite data,
or fold/build fusion API. It retains elapsed time, exact heap bytes, host stack
behavior, and compiler optimization outside its source-level claims.

The migration changed only target links and active navigation. Explicit
implementation selection, method-local type parameters, and relational
interfaces do not improve this concrete transition question. Explicit kinds
would add syntax without strengthening finite production, so this Case received
no feature retrofit.

### 3. Accumulating list results

**Question:** When should recursion retain knowledge from earlier elements?

The active
[third Cases chapter](../../content/cases/accumulating-list-results/README.md)
compares reverse through
repeated append with accumulator reverse. Five canonical sources and their
displayed blocks pass at exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Four exact accepted observations
establish the same reverse results, six previously built left-node revisits
versus four original input visits, an invariant midpoint, and an accepted wrong
initial accumulator.

The source equations derive quadratic append revisits and constructor
applications versus linear accumulator visits and constructions. Tail position
names only the recursive application's source placement. The case excludes
elapsed time, exact heap bytes, host-stack behavior and tail-call optimization,
compiler optimization, mutation, and a type-level proof of the invariant.

The migration changed only target links and active navigation. Explicit
implementation selection, explicit kinds, method-local type parameters, and
relational interfaces do not strengthen the concrete append-versus-accumulator
comparison or its retained-state account, so this Case received no feature
retrofit.

### 4. A dictionary encoded as a list

**Question:** What does lookup cost when a dictionary is a recursive list?

The active
[fourth Cases chapter](../../content/cases/dictionary-as-list/README.md)
represents each
dictionary as a newest-to-oldest recursive list of entries. Explicit equality
lets selective lookup return at the first match, so prepending an equal key
shadows the older entry without removing it.

Five canonical sources and their displayed blocks pass at exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Four exact accepted observations
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

The migration changed only target links and active navigation. Explicit
equality remains because replacing it with an `Equal` interface would
introduce implementation selection before the later ordering-abstraction
Case. Explicit kinds, method-local type parameters, and relational interfaces
do not strengthen this list-dictionary cost question, so this Case received no
feature retrofit.

### 5. Folding branching data

**Question:** How does the data-directed method extend from lists to trees?

The active
[fifth Cases chapter](../../content/cases/folding-branching-data/README.md)
extends the
data-directed fold from one list tail to the two branches of
`Tree<A> = Empty | Node(Tree<A>, A, Tree<A>)`. Four canonical sources and their
displayed blocks pass at exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Three exact accepted outputs
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

The migration changed only target links and active navigation. Explicit
implementation selection, explicit kinds, method-local type parameters, and
relational interfaces do not strengthen this tree-specific fold and search
contrast. A generic fold abstraction would change the question's altitude, so
this Case received no feature retrofit.

### 6. Searching an ordered tree

**Question:** How can an invariant let lookup ignore most of a tree?

The active
[sixth Cases chapter](../../content/cases/searching-ordered-tree/README.md)
passes an explicit comparator to lookup and persistent insertion over a
transparent ordered tree.
Four canonical sources and their displayed blocks pass at exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Three byte-identical accepted
outputs retain the predecessor observations. A manually valid balanced tree
gives a successful path and a missing path that each visit
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

The migration changed only target links and active navigation. Explicit
comparator passing remains because it is the deliberate baseline that the
next Case abstracts through `Order`. Explicit kinds, method-local type
parameters, and relational interfaces do not strengthen this Case's ordered
lookup invariant, comparator-work account, or unbalanced-height boundary, so
it received no feature retrofit.

### 7. Abstracting key order

**Question:** How can modules reuse an ordering capability without passing it
manually?

The seventh [historical Cases][recursive-cases] chapter replaces explicit
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

### 8. Protecting the dictionary invariant

**Question:** How can clients use a dictionary without constructing invalid
trees?

The eighth [historical Cases][recursive-cases] chapter places the ordered
tree behind `pub opaque type Dictionary<K, V>`. Importers can name and pass the
public nominal type, but only the defining module can use `Empty` and `Node` as
values or patterns. Its public API supplies `empty`, `insert`, `build`,
`lookup`, and `invariant_holds`; opacity controls constructor access rather
than proving that the operations preserve their invariant or that the
representation is secret.

Six canonical sources and their displayed blocks pass together at Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. The defining module and three
importing clients complete with empty standard error and status `0`: its
private `main` observes a deeper malformed tree as `false`, public insertion
of keys three, one, two, and four observes a valid dictionary with four hits
and one absence, strict list-consuming `build` replaces the earlier value `20`
with the later equal value `99`, and a client observes the public empty value
structurally as `Empty : Dictionary<Natural, Int>`. Separate value and pattern
attempts to use `Dictionaries.Empty` complete with empty standard output,
status `1`, and first standard-error line `resolve.opaque-constructor`. Each
primary label covers the client `Empty` member token, and each related label
covers the withheld declaration token. Remaining diagnostic prose and byte
offsets are not contracts.

The public construction argument fixes an `Order<K>` implementation whose
required comparisons return and satisfy the stated equivalence, reversal,
transitivity, and substitution premises. Validity is global: both subtrees are
valid, every left descendant is `Less`, and every right descendant is
`Greater`. Under those premises, completed `insert` preserves a finite valid
dictionary, retains the stored representative key on equality, and replaces
only its value. The private counterexample places key three in the left
subtree of key two while retaining correct immediate parent-child order, so it
distinguishes descendant bounds from a local-child check. The defining module
can still construct malformed values or export a bad operation; opacity is the
client boundary, not a type-level invariant proof.

The private strict left fold calls its combiner and therefore `insert` exactly
`n` times for a finite `n`-entry list. If insertion `j` enters `m_j` existing
nodes and `C_j(i)` counts all comparison-method applications caused at its
`i`th visited key, exact comparison sub-work is the double sum of `C_j(i)`,
with surrounding source work `O(n + sum m_j)`. Unbalanced input can make that
work quadratic. For completed validation of a finite `n`-node dictionary, let
`B` count validator-initiated comparisons. `B = 0` for zero or one node; for
`n > 1`, `n - 1 <= B <= 2n - 2`. If `C_r` counts all method applications in
validator comparison `r`, exact comparison sub-work is `sum C_r`. Only when
every `C_r <= Cmax`, with `Cmax >= 1`, may this be summarized as
`O(B * Cmax)` and therefore `O(n * Cmax)`; surrounding traversal work is
`O(n)`.

The finite-return claims apply to finite acyclic dictionary spines produced by
the selected operations from finite prior values and inputs, when their
required calls return. Defining-module code can create a dictionary-spine
cycle; generic key or value payloads can cycle independently. Whole-tree
validation enters both branches, lookup and insertion enter only their
selected path, a nonreturning comparison can prevent an operation from
returning, and lookup can return a cyclic value payload without traversing it.
Final structural observation traverses a returned payload and renders an
active-path revisit as `<cycle>`. The chapter establishes no runtime pointer
identity, physical sharing, heap, garbage-collection, native-stack, tail-call,
or compiler representation claim.

The accepted body tuple match in the private `insert_entry` works around an
exact-pin `internal.resource.coverage` failure minimized from an equivalent
tuple-equation form. That failure remains an Ash regression candidate outside
lesson prose; it does not define language behavior. The case introduces no
balancing, deletion, mutation, iteration, generic dictionary infrastructure,
lazy or infinite data, rank-2 fold/build fusion, representation secrecy, or
ordering-law enforcement.

### 9. Guaranteeing logarithmic retrieval

**Question:** How can the representation prevent a search tree from
degenerating?

The ninth [historical Cases][recursive-cases] chapter retains the public
`Ordering`, `Natural`, `Option`, `List`, `Order`, `empty`, `lookup`, `insert`,
`build`, and `invariant_holds` API while replacing the hidden representation
with `pub opaque type Dictionary<K, V>` nodes that carry a private `Color`.
The defining module alone can construct or inspect those nodes. Its operations
maintain global key order, prohibit a red node from having a red child, give
both branches of every node equal black-height, and blacken every nonempty
public root. Opacity prevents client construction; the operation proofs, not
the nominal type alone, establish preservation.

Three canonical sources and their displayed blocks pass together at Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. The complete dictionary source
observes its valid private fixture as `true` and its deep ordering, red-root,
red-child, and unequal-black-height fixtures as four `false` values. The prefix
matrix checks the empty state and every insertion prefix of ascending,
descending, left-left, left-right, right-left, and right-right sequences; every
invariant, new association, retained association, fixed absence, and final
association observation is `true`. The persistence source observes the exact
old, replaced, extended, and independently built structures, four `true`
invariants, and lookups `(Some(20), Some(99), Some(99), None, Some(30),
Some(30))`. These finite executions exercise each repair orientation and the
public boundary; they do not prove the general invariant or height arguments.

Absent insertion first constructs one red leaf. On the path back, four
left/right configurations normalize two consecutive red links into one red
middle node with two black children, retaining all three ordered key-value
associations and the four surrounding subtrees. The reconstruction preserves
their common black-height; final root blackening establishes the separate
public-root condition. Equal insertion retains the stored representative key
and both branches while replacing only its value. `build` uses a strict left
fold, so later equal entries replace earlier values. Older dictionary values
remain separately observable after replacement and extension.

If a finite valid dictionary has `n` nodes, height `h`, and root-to-empty
black-height `q`, the color conditions give `h <= 2(q - 1)` and the minimum-node
argument gives `n >= 2^(q - 1) - 1`; therefore
`h <= 2 log2(n + 1)`. A completed lookup visits at most `h` nodes. If its
visited comparisons make a total of `C` completed `compare` method
applications, its surrounding source work is `O(h)` and its exact comparison
sub-work is `C`. Only when every visited comparison is bounded by `Cmax`, with
`Cmax >= 1`, may the combined account be summarized as
`O(log(n + 1) * Cmax)`.

For an absent insertion that enters `m` existing nodes, performs `r` repairs,
and blackens a red root when `b = 1`, the source constructs
`m + 1 + 2r + b <= 3m + 2` new `Node` forms. Equal replacement at depth `m`
constructs exactly `m` nodes. These are persistent source-construction counts:
unentered subtrees are reused as source values, but the chapter claims no
runtime pointer identity or physical sharing. `invariant_holds` performs one
ordering pass and one color/black-height pass. Each pass visits every node
once and performs a bounded number of named source operations per node; the
second pass returns either `Invalid` or a black-height summary. This
source-linear account excludes the bit cost of arbitrary-precision `Int`
equality and addition.

The ordering proof fixes one selected `Order<K>` implementation whose required
comparisons return and satisfy the stated equivalence, reversal, transitivity,
and substitution premises; the interface itself does not encode those laws.
Return claims require finite entered structure and returning required calls.
Whole-tree validation enters both branches, lookup and insertion enter only a
selected path, a reachable constructor-guarded cycle may prevent return, and a
cyclic value payload may be returned without traversal. Final structural
observation can render an active-path revisit as `<cycle>`, but it establishes
no pointer or heap property.

The reviewed [persistent red-black insertion source
record](../../research/persistent-red-black-insertion.md) selects Chris
Okasaki's four-configuration functional insertion as conceptual inspiration,
with the MIT-licensed Software Foundations presentation as corroborating
evidence. The Ash programs, names, prose, derivations, diagrams, and exercises
are original rather than direct adaptations. This research tradition cannot
define Ash behavior.

The exact-pin equation-level tuple-pattern `internal.resource.coverage`
failure inherited from case 8 remains an Ash regression candidate; the source
retains its accepted body match without teaching the workaround. A separate
exact-pin client-owned implementation of an imported public interface fails
with `evidence.validation.unknown-identity`; the completed case uses the
module-owned `Order<Natural>` fact and does not present the failure as language
behavior.

The case establishes no elapsed-time, machine-instruction, native-stack,
tail-call, exact-heap-byte, garbage-collection, mutation, pointer-identity,
physical-sharing, compiler-representation, compiler-optimization, universal
optimality, deletion, lazy or infinite-data, or arbitrary-precision integer
bit-cost result. It introduces no generic dictionary infrastructure or
ordering-law enforcement.

### 10. Resuming tree traversal

**Question:** How can traversal pause and resume without laziness?

The tenth [historical Cases][recursive-cases] chapter extends the opaque
persistent red-black dictionary with a private `FrameStack<K, V>` and a public
opaque `Iterator<K, V>`. Its public API is
`iterator : Dictionary<K, V> -> Iterator<K, V>` and
`next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>`. Importers can name,
retain, and pass iterator values, while only the defining module can construct
or inspect the `Iterator`, `NoFrame`, and `MoreFrame` representation.

Five canonical sources and their displayed blocks pass together at Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`: `dictionaries.ash`,
`01-sequence.ash`, `02-retained-state.ash`, `03-opaque-pattern.ash`, and
`04-opaque-construction.ash`. The two accepted entries complete with empty
standard error and status `0`, producing these exact observations:

<!-- markdownlint-disable MD013 -->
```text
(true, More((Next(Zero), 10), More((Next(Next(Zero)), 20), More((Next(Next(Next(Zero))), 30), End)))) : (Bool, List<(Natural, Int)>)
Replay(Iterator(MoreFrame(Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty), NoFrame)), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame))), Some((Next(Next(Zero)), 20), Iterator(MoreFrame(Next(Next(Next(Zero))), 30, Empty, NoFrame)))) : ReplayObservation
```
<!-- markdownlint-enable MD013 -->

The first output establishes the immediate empty state and the complete
increasing sequence `one`, `two`, `three`, followed by exhaustion. The second
retains the state after `one` and calls `next` from it twice; both replays
produce `two` and independently prepare an equivalent state for `three`.
Structural observation renders the private `Iterator`, `MoreFrame`, and `Node`
forms, but those spellings provide no source constructor binding or access.
The pattern and value entries each write empty standard output, exit with
status `1`, and begin standard error with `resolve.opaque-constructor`. Their
primary labels cover, respectively, the client `Dictionaries.Iterator` member
in a pattern and the distinct member in a local value initializer; each related
label covers the withheld declaration. Offsets and remaining diagnostic prose
are not contracts.

`iterator` runs `push_left` from the root with `NoFrame`, eagerly saving only
the initial left spine. Every `MoreFrame` retains the next key and value, its
unentered right subtree, and the remaining ancestor frames. A successful
`next` pops that frame, produces the association, and runs `push_left` over the
saved right subtree to prepare the returned iterator. An exhausted `next`
selects `NoFrame` and returns `None`. Neither operation requires `Order<K>` or
calls `compare`. Under the inherited valid dictionary invariant, this
structural in-order traversal produces increasing keys; it neither validates
nor sorts, so a malformed defining-module value can produce an out-of-order
sequence.

Let `d` be the number of nodes on one left-spine descent. A completed
`push_left` performs exactly `d + 1` helper applications, including the
terminal `Empty`, and constructs exactly `d` frames. With dictionary height
`h`, initialization has `d <= h`, constructs at most `h` frames and one
iterator wrapper, and uses `O(h)` explicit frame work and state. A successful
`next` performs one pop and `d_i` pushes for its saved right subtree, so its
exact frame work is `1 + d_i <= h`; it also constructs one new iterator
wrapper and one `Some`. One call therefore has worst-case `O(h)` frame work,
while exhausted `next` constructs `None` without a frame push or pop.

Across one complete linear traversal of a finite `n`-node dictionary, every
node enters one frame and leaves one frame: exactly `n` pushes, `n` pops, and
`2n` frame operations including initialization. For `n = 0`, the traversal and
final `None` move no frame. For `n > 0`, distributing `2n` frame operations
over `n` produced associations gives amortized constant frame work, while one
step retains its `O(h)` worst case. The complete sequence is within
`O(n + h)`. This account applies to one linear history of returned states;
retaining an older iterator and resuming it again can repeat a right-subtree
left descent, as the replay does, so no amortized bound covers an arbitrary
branching history.

Case 9 established `h <= 2 log2(n + 1)` for a finite valid red-black
dictionary under its ordering and balance premises. With those premises,
initialization and one worst-case `next` use `O(log(n + 1))` explicit frame
work; a complete traversal still produces all `n` associations and remains
linear. The `O(h)` state claim counts only the iterator's own frames. Each
frame retains existing keys, values, subtrees, and remaining stack values, so
much or all of the original dictionary may remain transitively reachable; the
claim is not a bound on all reachable source data or runtime bytes.

Return claims apply to finite acyclic dictionary spines reached through
completed public operations and to iterators produced from them. An initial
left-edge cycle can prevent `iterator` from returning; a cycle in a saved right
subtree can permit earlier results before the `next` that enters it fails to
return. Cyclic key or value payloads can be returned without traversal, and a
later structural observation may render an active-path revisit as `<cycle>`.
The counts cover named source applications, frame pushes and pops, and
constructor applications; they do not establish elapsed time, machine
instructions, native-stack behavior, tail-call optimization, runtime storage
or bytes, heap layout, pointer identity, physical sharing, garbage collection,
or compiler representation and optimization. The case introduces no laziness,
infinite traversal, hidden mutation, generator, coroutine, stream, reverse
step, cursor update, deletion, generic zipper, new ordering or balance proof,
or ordering-law enforcement.

The frame stack and account are an original local derivation from the case-9
tree equations and the path's existing eager recursive-algorithm method. The
case selects no new external source and makes no new adaptation; the existing
recursive-algorithm, strictness, and persistent red-black insertion records
retain their prior scope and classifications. These observations remain
ash-doc evidence and do not define Ash semantics.

### 11. Implementing a persistent FIFO frontier

**Question:** How can two lists preserve queue order while avoiding a full
rebuild on every operation?

The eleventh [historical Cases][recursive-cases] chapter crosses from an
explicit LIFO iterator stack to a persistent FIFO frontier. Instead of
appending through one growing forward list, it represents logical queue order
as `front ++ reverse(rear)`, where `front` is already in removal order and
`rear` is in reverse insertion order.

Three canonical sources and their displayed blocks pass together at exact Ash
commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`: `queues.ash`,
`01-sequence.ash`, and `02-retained-state.ash`. Both entries complete with
empty standard error and status `0`, producing these exact observations:

<!-- markdownlint-disable MD013 -->
```text
(None, Queue(End, More(3, More(2, More(1, End)))), 1, Queue(More(2, More(3, End)), End), More(2, More(3, End))) : (Option<(Int, Queue<Int>)>, Queue<Int>, Int, Queue<Int>, List<Int>)
(Some(1, Queue(More(2, More(3, End)), End)), Some(1, Queue(More(2, More(3, End)), End))) : (Option<(Int, Queue<Int>)>, Option<(Int, Queue<Int>)>)
```
<!-- markdownlint-enable MD013 -->

The first output establishes empty removal, the retained pre-transfer state,
the oldest value, the returned successor, and the remaining FIFO sequence.
The second calls `dequeue` twice from the same retained `ready` state and
establishes two equivalent structural results, each reached through its own
complete rear transfer. Structural rendering does not establish pointer
identity, physical sharing, allocation behavior, or memoization.

`empty` constructs `Queue(End, End)`. `enqueue` prepends one `More` to the
rear. `dequeue` returns `None` from an empty pair, removes the first front node
when one exists, and otherwise eagerly reverses the complete rear, clears it,
and removes from the new front. Every finite front-and-rear pair has a logical
meaning under the representation relationship. This selected variant does not
maintain a stronger nonempty-front invariant: the front may be empty while the
rear is nonempty.

One list-node unit is one selected or constructed `More`. Reversing a rear of
length `m > 0` applies `reverse_into` `m + 1` times, selects `m` rear nodes,
constructs `m` front nodes, and then selects the first new front node. The
transfer therefore costs `2m + 1` list-node units and gives one `dequeue` a
linear worst case. Along one finite linear successor history that starts from
`empty`, with `e` enqueues and `d` successful dequeues, each rear node
transfers at most once, so total list-node work is at most `3e + d`. This
supports amortized constant list-node work per operation only on that one
history; it does not make an individual eager transfer constant.

Starting at `empty` ensures that the counted `e` includes every enqueue that
constructed a transferable rear node. Restarting the counters at the populated
`ready` state would report `e = 0` and `d = 1` while still performing the
three-node transfer's `7` units. That suffix omits its enqueue prefix and is
not a history to which the stated bound applies.

Retaining the older empty-front `ready` state changes the account. Each future
started from that state still sees the complete rear and repeats its reversal.
The linear-history account cannot pay for arbitrary branches through a
persistent version graph.

Public histories that start with `empty` and use finite sequences of
`enqueue` and returned successors build finite acyclic queue-list spines. A
cyclic payload can pass through the queue because its equations need not enter
the payload. Opacity prevents clients from constructing or matching the queue
representation, but the defining module could construct a cyclic front that
yields indefinitely or a cyclic rear whose reversal does not return. The
source-level reuse and list-node counts do not establish elapsed time, machine
instructions, host-stack behavior, runtime storage or bytes, allocation
count, heap layout, pointer identity, physical sharing, garbage collection,
or compiler representation and optimization.

The permanent [source
record](../../research/persistent-paired-list-queue.md) retains the source
selection and adaptation classification. The case selects Okasaki's 1995
transfer-on-dequeue paired-list queue and its recorded lineage as conceptual
inspiration. Its Ash code, examples, derivations, prose, and exercises are
original rather than adapted expression.

The local, Learn, and Cases verifiers pass at the exact pin, as do five focused
pinned tests for strict constructor-tuple entry, defining-module access to an
opaque constructor, an imported transparent parameterized constructor,
rank-one polymorphism, and its exact CLI observation. The repository contains
`11 Learn / 11 Cases / 50 Case sources`. These observations remain ash-doc
evidence and do not define Ash semantics.

### 12. Choosing a search frontier

**Question:** How does frontier representation change a search algorithm?

The twelfth [historical Cases][recursive-cases] chapter holds one search
transition fixed while ordinary add and remove functions select a LIFO list
stack or FIFO paired-list queue. Three canonical sources pass together at
exact Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`:
`searches.ash`, `01-found-paths.ash`, and `02-unreachable-cycle.ash`.

The two entries complete with status `0`, empty standard error, and one exact
standard-output line each:

<!-- markdownlint-disable MD013 -->
```text
(Found(More(Start, More(LongOne, More(LongTwo, More(Goal, End)))), 3, Next(Next(Zero))), Found(More(Start, More(Short, More(Goal, End))), 5, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
(Missing(7, Next(Next(Zero))), Missing(7, Next(Next(Next(Next(Zero)))))) : (SearchResult, SearchResult)
```
<!-- markdownlint-enable MD013 -->

The first result records the longer DFS path
`Start -> LongOne -> LongTwo -> Goal`, three completed non-target expansions,
and peak pending count two. BFS returns the shorter
`Start -> Short -> Goal`, after five completed non-target expansions and with
peak pending count four. When `Isolated` is the target, both searches exhaust
the seven reachable vertices and return `Missing(7, ...)`, retaining their
respective peaks of two and four.

Each pending `Work(current, reverse_predecessors)` value retains the path that
led to its vertex. The five-field
`SearchState(frontier, visited, pending, maximum, expanded)` keeps frontier
representation, visited dictionary, logical pending count, greatest pending
count, and completed non-target expansions together. Both wrappers mark the
start before its initial addition. Scheduling an unseen neighbor looks it up
in the current threaded dictionary, inserts it, extends its reverse path, adds
its work, increments the logical count, retains the greater maximum, and
recurses from that complete successor state. Removal decrements the count
before testing the target; a target match constructs the forward path and does
not count the target as expanded.

Those relationships schedule each vertex at most once, so the finite
`LongTwo -> Start` graph cycle cannot repeat expansion. When no earlier target
match returns, including when the target is unreachable, the engine exhausts
the finitely many distinct scheduled vertices. These relationships do not by
themselves establish a shortest path. FIFO removal keeps first-discovery paths
in nondecreasing directed-edge distance, and scheduling extends a retained path
by one edge.
Together with mark-before-add retaining the first discovered path, that layer
order proves that the first target removed by BFS has minimum edge length. The
longer DFS result is the negative case: the same visited timing under LIFO
removal does not prove shortestness.

The reported maximum counts only logical frontier entries. Reverse-path
`More` forms, dictionary `Entry` and list nodes, and equality comparisons have
separate source-work accounts. The paired-list queue retains the preceding
case's list-node bound only for one linear history of returned successors that
starts from empty; retaining and resuming an older state leaves that account.
Constructing and comparing the recursive `Natural` measurements is also
separate source work. For `b >= 1` and DFS discovery-tree edge depth `d`, the
logical stack holds at most `1 + d(b - 1)` pending entries; the `b = 0`
initial state is the separate one-entry case. During BFS layer `i`, pending
entries are at most `L_i + L_(i + 1)`, and therefore at most `2W` when `W` is
the greatest layer size.

The first pinned prototype placed four `match` expressions around an inner
block. At the exact target it returned status `2`, wrote no standard output,
and began standard error with `internal.resource.structural-depth` followed by
limit `128`. A four-match prototype without the inner block passed; restoring
the block reproduced the rejection. Moving the removal result into the
exhaustive `continue_search` helper produced the accepted source without
changing the transition. This remains pinned tool/resource evidence, not Ash
language truth, a runtime-stack claim, or a broader diagnostic-layout
contract.

The permanent [source
record](../../research/graph-search-frontiers.md) identifies Pat Morin's *Open
Data Structures (in pseudocode)*, edition 0.1G beta, section 12.3, under CC BY
2.5 Canada as conceptual inspiration. The Case replaces its indexed adjacency
and mutable discovered array with an equation-defined graph and persistent
list dictionary, retains reverse paths rather than predecessor indices, and
marks DFS on addition rather than removal. Its original graph, Ash code,
observations, derivations, prose, and exercises do not import the source's
`O(V + E)` runtime theorem.

Closure verification with both temporary plans retained reran the lesson-local
verifier and the full 11-Learn and 12-Case aggregators at the exact pin. The
local verifier passed both exact observations and checked displayed-source
agreement plus the causal transition relationships. Shell syntax, ShellCheck,
all 45 current Markdown files, 124 relative links, and the whitespace diff
also passed. A 68-mutation audit made every targeted source or prose change
fail with its intended first verifier message, restored the copied source
between mutations, and ended green.

The Case excludes weighted search, priority frontiers, mutable arrays,
recursive Ash data cycles, nonreturning adjacency or equality, a generic
termination theorem, and claims about elapsed time, machine instructions,
native-stack behavior, runtime storage, allocation, sharing, garbage
collection, or compiler optimization. The structural-depth finding is retained
as tool/resource pressure. The remaining observations are ash-doc learning and
executable evidence subordinate to the pinned specification and tool; they do
not define Ash semantics or accept an Ash mechanism.

The immutable predecessor contains `11 Learn / 12 Cases / 53 Case sources`.
The active migration tree contains
`11 Learn / 6 Cases / 43 Learn sources / 28 Case sources`.
Cases migration remains
the one **next** outcome; its approved plan restores each later historical Case
only after that Case passes its complete evidence at the active target.

## Promotion and verification policy

For a future increment:

1. Select one bounded outcome, promote only that outcome to **next**, and give
   it an approved bounded design before implementation.
2. Add its temporary detailed plan only after promotion.
3. Keep every displayed Ash program complete, canonical, and automatically
   invoked.
4. Assert exact values, types, output, and exit status for successes; assert a
   stable reason and causal source location for intentional rejections.
5. Run every active Learn check before closure. Run the Cases aggregate only
   after Cases have returned to the active tree.
6. Review time, comparison, allocation, recursion-depth, and retained-state
   claims as source-level properties unless a separate implementation record
   establishes more.
7. Classify discoveries as ash-doc corrections, Ash regression candidates,
   unspecified design questions, or library, tool, diagnostic, performance, or
   application pressure.
8. Remove the completed temporary plan, mark the case **verified**, and promote
   a successor only after selecting it as a new bounded outcome. Otherwise
   leave **next** empty.
9. Add a focused research or laboratory record only when an observed case
   supplies material evidence. Any upstream evidence candidate must reference
   the completed case commit as well as the exact ash-doc and Ash targets.

Final verification for each increment uses a clean Ash checkout at the exact
resolved commit:

```text
bash -n <changed verification scripts>
bash content/learn/checks/verify.sh <clean pinned ash-lang checkout>
git diff --check
git status --short
```
