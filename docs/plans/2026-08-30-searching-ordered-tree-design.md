# Searching an ordered tree design

Status: approved on 2026-08-30 after independent specification and quality review

## Reader and maintainer problem

The branching-fold case ended with a direct search that may avoid a branch,
but its predicate had no fact about which branch could contain a match. An
ordered tree adds that fact as a program invariant: every key below the left
field is smaller than the node key, and every key below the right field is
greater.

The reader asks how a valid global binary-search-tree invariant permits
one-branch lookup. The observable boundary crosses from local comparison to
the placement of every descendant: a transparent malformed tree can hide an
existing key in the branch that comparison skips. A successful lookup alone
cannot establish the invariant, and the nominal `Tree<K, V>` type does not
enforce it.

The case must make successful and missing lookup, duplicate replacement,
malformation, and degenerate height observable without claiming logarithmic
search from an unbalanced representation. It must also separate the number of
tree nodes visited from the recursive work performed inside comparison.

## Authority and version boundary

Every executable observation targets Modular Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Language behavior comes from the
[specification at that commit](https://github.com/dikini/ash-lang/tree/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec).
Commands, values, types, output channels, and statuses come from the
[pinned tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
and executable.

The published ash-doc `modular-ash` tag remains immutable. This proposed case
is unpublished work for `main`; it neither changes the edition target nor
imports language behavior from current `ash-lang/main`.

Verification must receive a clean Ash checkout whose `HEAD` is the exact
commit above. It builds from inside that checkout with locked dependencies and
invokes that checkout's executable on each entry:

```text
cd <clean-pinned-ash-lang>
cargo build --locked
<clean-pinned-ash-lang>/target/debug/ash <case-entry.ash>
```

The shared verifier may isolate Cargo's target directory, but it must not use
an unrelated `ash` from `PATH`. Cargo and the pinned toolchain establish how
the executable is built; they add no language semantics.

The governing pinned sections are:

- the [syntax grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  and [global function
  presentations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#global-function-presentations)
  for parameterized data, constructor patterns, curried explicit-comparator
  functions, blocks, and matches;
- [imports and
  namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces),
  [type and constructor
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#type-and-constructor-scope),
  and [global
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#global-scope)
  for the shared module, transparent constructors, and recursive globals;
- [tuples and
  constructors](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors),
  [functions and
  application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application),
  [patterns, matches, and
  coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage),
  [blocks](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks),
  [recursive block
  groups](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups),
  [primitive
  operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#primitive-operations),
  and [globals and
  modules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  for the public API, exhaustive comparison branches, recursive definitions,
  guarded recursive data, typed integer count additions, and complete entry
  modules;
- dynamic [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [recursive
  bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#recursive-bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  [tuples, constructors, and
  matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches),
  and [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
  for strict comparison applications, the selected `Ordering` arm, retained
  older values, and structural output; and
- the tool guide's [successful-output
  contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  for exact standard output, empty standard error, and status `0`.

Ash specifies how these complete programs check, evaluate, and render. The
ordered-tree invariant, comparator laws, correctness argument, and cost model
below are properties of the selected programs; they are not additional Ash
semantics.

## Reader model and prerequisites

The reader has completed the five earlier Cases chapters. They know
transparent parameterized data, structural recursion, unary `Natural`, direct
selective tree search, height as the greatest root-to-`Empty` node count, and
source-operation counts.

This case changes why a search can choose a branch. At
`Node(left, key, value, right)`, `compare query key` returns `Less`, `Equal`, or
`Greater`. Under the global ordering invariant, `Less` rules out `right` and
`Greater` rules out `left`; `Equal` returns the current value. Without that
invariant, the same control flow still runs but need not find a key that occurs
elsewhere in the transparent structure.

## Approaches considered

### Build every observed tree through insertion

One approach would expose `insert`, build every tree through it, and show
lookup only on the resulting values. That demonstrates invariant-preserving
construction under suitable comparator premises. It does not expose why the
invariant is necessary: every example would begin valid, while transparency
would still let a client construct an invalid tree that the chapter never
examines.

### Hide the tree behind an opaque dictionary

A second approach would make construction and matching unavailable to clients
and teach only `empty`, `insert`, and `lookup`. That gives a stronger client
boundary, but it combines the ordering argument with the later question of
how module opacity protects a representation. It would prevent the smallest
accepted malformed value from showing the consequence of violating the
invariant.

### Return comparison work from the comparator

A third approach would change the callback to
`K -> K -> (Ordering, Int)` and make lookup accumulate both visited nodes and
recursive comparator calls. That makes one cost sum executable, but it changes
the ordinary ordering capability into measurement instrumentation. The next
case needs an `Order<A>` method that returns `Ordering`, so this shape would
either interrupt continuity or require a second lookup API.

### Keep the transparent tree and an ordinary explicit comparator

The selected design uses a public transparent tree and passes
`K -> K -> Ordering` explicitly to lookup and insertion. One entry manually
constructs a valid tree, one contrasts insertion with an accepted malformed
tree, and one observes ascending insertion. `lookup_counted` reports top-level
comparison applications, while the recursive work of `compare_natural` is
derived separately from its equations.

This is the smallest replaceable choice that makes both the invariant and its
violation observable while preparing the explicit capability for abstraction
in case 7. Deferring the choice would leave the promoted outcome without its
negative boundary and without a precise distinction between node visits and
comparison work. The case remains lesson-local and needs no new harness,
manifest, renderer, shared tree library, or research record.

## Lesson-local representation and API

Create `content/cases/searching-ordered-tree/` only after this design receives
independent approval and a temporary implementation plan becomes active. The
case will contain `src/ordered_trees.ash` and three complete entry modules:

- `src/01-lookup.ash`;
- `src/02-replace-and-malformed.ash`; and
- `src/03-ascending.ash`.

The shared module exports these transparent types and functions:

```text
Ordering = Less | Equal | Greater
Natural = Zero | Next(Natural)
Option<A> = None | Some(A)
Tree<K, V> = Empty | Node(Tree<K, V>, K, V, Tree<K, V>)

compare_natural : Natural -> Natural -> Ordering
lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>
insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>
lookup_counted :
    (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)
height : Tree<K, V> -> Natural
```

The wrapped `lookup_counted` signature is design notation. Its canonical Ash
signature will remain on one physical line. `maximum` is a private helper for
`height`; no reader-facing operation needs to choose between two natural
numbers independently.

The four equations of `compare_natural` compare the outside constructors
first. `Zero` against `Zero` returns `Equal`; `Zero` against `Next(right)`
returns `Less`; `Next(left)` against `Zero` returns `Greater`; and
`Next(left)` against `Next(right)` recursively compares `left` with `right`.
The [constructor-match
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches)
select one equation. The coherent total-order interpretation of those results
is the program invariant used by the algorithm, not a property Ash assigns to
every function of this type.

`lookup` returns `None` at `Empty`. At a node it applies the comparator once to
`query` and `key`, recurses only into `left` for `Less`, returns `Some(value)`
for `Equal`, and recurses only into `right` for `Greater`. Pinned Ash evaluates
the complete comparator application before selecting the first matching arm
under its [strict application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application)
and [match](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches)
rules. Only the selected arm body evaluates.

`insert` constructs a one-node tree at `Empty`. At a node, `Less` inserts into
`left` while retaining the current key, value, and `right`; `Greater` does the
mirror operation. `Equal` constructs
`Node(left, current_key, value, right)`: the new value replaces the old value,
but the stored representative key and both branches remain. This matters for a
generic comparator whose equality class may contain distinguishable key
values.

`lookup_counted` preserves the three lookup branches. It returns `(None, 0)`
at `Empty`, `(Some(value), 1)` at `Equal`, and adds one current-node comparison
to the recursive count after either `Less` or `Greater`. That addition is
well-typed by the pinned static [primitive-operation
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#primitive-operations).
The count is therefore the number of visited `Node` forms and top-level
comparator applications. It does not count recursive calls made inside
`compare_natural`.

`height` returns `Zero` for `Empty` and
`Next(maximum (height left) (height right))` at a node. `maximum` has its three
structural equations for zero-left, zero-right, and two `Next` values. Its
unary recursion is separate work from lookup and from the comparator.

## Invariant and return premises

Fix one comparator and a key equivalence represented by its `Equal` result.
When the case states tree validity or invariant preservation, it assumes the
comparator returns for every key pair whose ordering that statement uses and
that its results form one coherent total order:

- `Equal` is the chosen key equivalence;
- reversing a `Less` comparison gives `Greater`, and conversely;
- strict comparison is transitive; and
- equivalent keys have the same ordering relationship to every other key.

For that comparator, `Empty` is valid. A finite
`Node(left, key, value, right)` is valid when both branches are valid, every
key anywhere in `left` compares with `key` as `Less`, and every key anywhere
in `right` compares with `key` as `Greater`. This is a global descendant
condition, not merely a condition on the two child nodes.

Under those premises, a comparison at a valid node rules out one complete
branch. Lookup returns the current value on `Equal`, and otherwise preserves
the possibility of a match only in the selected branch. Insertion into a valid
finite tree preserves the invariant: `Less` and `Greater` place a new key in
the selected branch, while `Equal` changes only the stored value and retains
the representative key. These are program proofs over the stated invariant;
the pinned specification guarantees the evaluation steps but does not certify
the ordering laws or tree validity.

For a finite tree and returning comparisons along the entered path, lookup
terminates because each recursive call receives one structural branch. If a
required comparison does not return, lookup need not return. Transparency also
permits finite malformed trees. Ash's pinned static [recursive block-group
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups)
and dynamic [recursive binding
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#recursive-bindings)
admit constructor-guarded cycles, so the nominal type supplies neither the
ordering invariant nor finiteness.

## Complete observations

The proposed exact-pin case has four canonical sources.

1. `src/ordered_trees.ash` contains the shared types and functions described
   above.

2. `src/01-lookup.ash` binds unary keys `one`, `two`, and `three`, then manually
   constructs this valid balanced tree:

   ```text
             two:20
             /    \
       one:10    three:30
   ```

   It asks for `three` and then for `Zero` with the same comparator and tree.
   The exact output is:

   ```text
   ((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))
   ```

   Both results report two visited nodes and two top-level comparator
   applications. The successful path compares `three` with `two`, then with
   `three`. The missing path compares `Zero` with `two`, then with `one`, and
   reaches `Empty` without incrementing the count.

3. `src/02-replace-and-malformed.ash` defines `one` and `two`. Its nested
   insertion order is exact: first insert `two -> 20` into `Empty`, then insert
   `one -> 10` into that tree. The retained `original` is therefore
   `Node(Node(Empty, one, 10, Empty), two, 20, Empty)`. Inserting
   `one -> 99` into `original` creates `replaced`; its equal-key node retains
   the stored `one` and both branches while changing only `10` to `99`.

   The accepted malformed value is exactly
   `Node(Node(Empty, two, 20, Empty), one, 10, Empty)`. It places `two` in the
   left branch of `one`. Looking up `two` compares `Greater` at the root and
   follows the empty right branch, so the structurally present key is hidden.
   The entry observes the older value, replacement, and malformed miss:

   ```text
   (Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)
   ```

4. `src/03-ascending.ash` inserts `one -> 10`, then `two -> 20`, then
   `three -> 30` into successive retained tree values. It observes the final
   tree, its unary height, and a counted lookup for `three`:

   <!-- markdownlint-disable MD013 -->
   ```text
   (Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : (Tree<Natural, Int>, Natural, (Option<Int>, Int))
   ```
   <!-- markdownlint-enable MD013 -->

All three entries must exit with status `0`, write exactly their one expected
line to standard output, and leave standard error empty under the pinned
[successful-output
contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output).
The case needs no source rejection. Its negative boundary is an accepted
transparent value whose shape violates the program invariant and therefore
causes ordinary lookup to return `None` for a key that is present elsewhere in
the structure.

## Comparison work and height

Let `|Zero| = 0` and `|Next(n)| = |n| + 1`. For completed
`compare_natural q k`, let `C(q, k)` count all applications in its recursive
comparison chain, including the terminal equation. Its four equations give

```text
C(q, k) = min(|q|, |k|) + 1
```

The successful lookup in the balanced tree performs
`C(three, two) + C(three, three) = 3 + 4 = 7` recursive Natural comparison
applications. The miss performs
`C(Zero, two) + C(Zero, one) = 1 + 1 = 2`. Both paths still report `2` through
`lookup_counted`, because that function counts visited nodes and top-level
comparator applications rather than the work internal to the comparator.

For a completed lookup visiting keys `k_1` through `k_m`, its exact comparison
sub-work is

```text
sum from i = 1 to m of C(query, k_i)
```

Its surrounding branch selection, result construction, recursive lookup, and
count bookkeeping contribute `O(m)` named source operations. If `h` is the
greatest number of `Node` forms on a root-to-`Empty` path, a one-branch lookup
has `m <= h`. Only with an explicit bound
`C(query, k_i) <= Cmax` for every visited key and `Cmax >= 1` may the combined
account be summarized as `O(h * Cmax)`. Without that bound, counting each
node comparison as constant work would erase the recursive key cost.

Pinned Ash integers are mathematical, arbitrary-precision values under the
[primitive-operation
rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#primitive-operations).
The count's primitive additions remain named source operations; the case makes
no arbitrary-precision bit-cost claim.

The manually balanced three-node tree has height `2`, but the case does not
infer a general logarithmic bound from that shape. Inserting `one`, `two`, and
`three` in ascending order constructs a right chain with `n = 3`, height
`h = 3`, and three visited nodes for the last-key lookup. More generally, this
unbalanced insertion method can produce `h = n`; the representation gives no
logarithmic guarantee.

Computing the displayed height recursively traverses both branches and invokes
private `maximum` on unary results. That helper's recursion and constructed
`Next` results are separate from lookup's visited-node count and comparator
sub-work. The chapter must not use the height observation as evidence about
elapsed time, native stack frames, or runtime storage.

## Verification and mutation boundary

The local verifier will reuse `content/checks/lib.sh`. It will check all four
canonical source blocks, the three exact accepted observations, and each
complete transcript line exactly once. Causal source assertions will
establish:

- the exact public `Ordering`, `Natural`, `Option<A>`, and `Tree<K, V>` forms;
- the four `compare_natural` equations, including structural decrease from two
  `Next` values to their payloads;
- `lookup`'s exact `None` base, one `compare query key`, `Less`-left,
  `Equal`-current, and `Greater`-right relationships;
- `insert`'s one-node base, selected recursive branch, preservation of the
  unselected branch, and equal replacement of only the value while retaining
  `current_key`;
- `lookup_counted`'s zero base, one current top-level comparison, exact equal
  count, selected recursive branch, and one increment on both recursive paths;
- the three private `maximum` equations and exact `height` base and recursive
  expression;
- the precise valid balanced shape and the same tree and comparator passed to
  the successful and missing counted lookups;
- the exact nested insertion order, retained `original`, derived `replaced`,
  malformed left placement, and three corresponding lookup calls;
- the successive ascending insertions and the same `after_three` value passed
  to structural observation, `height`, and counted lookup; and
- the absence of an implementation interface, opaque dictionary, balancing
  helper, shared manifest, or new harness in this case.

Before closure, the mutation audit must change canonical source and its
displayed block together, prove each mutation makes the verifier fail, then
restore both. It must include at least these independent guards:

1. make `compare_natural Zero Next(right)` return `Greater`;
2. stop the `Next(left)`/`Next(right)` equation without its recursive payload
   comparison;
3. send `lookup`'s `Less` arm to `right`;
4. send `lookup`'s `Greater` arm to `left`;
5. change `lookup_counted Empty` from `(None, 0)`;
6. remove the current-node increment from its `Less` recursive result;
7. remove the current-node increment from its `Greater` recursive result;
8. send `insert`'s `Less` arm into `right` or its `Greater` arm into `left`;
9. replace `current_key` with the incoming `key` in the `Equal` result;
10. change either retained branch or preserve `current_value` instead of the
    new `value` in that `Equal` result;
11. move `two` out of the malformed tree's left branch while updating its
    displayed source block;
12. change the malformed lookup query away from `two`;
13. reverse one pair in the ascending insertion sequence; and
14. replace `maximum` in the `height` equation with one selected branch.

These guards cover causal relationships that the exact outputs alone do not
all isolate, especially representative-key retention and both counted
recursive arms.

Completion requires the case verifier and both content-family aggregators to
pass against a clean checkout at the exact pin. Every displayed `ash` block
must agree exactly with its canonical source. Markdown, spelling, shell, and
relative-link checks must pass. Navigation must list the verified case, the
roadmap must move it under verified increments and promote case 7, and an
independent review must cover language authority, the invariant, comparator
premises, replacement, malformation, cost, height, attribution, continuity,
and exclusions. `git diff --check` and `git status --short` must show only the
intended repository changes before integration.

After those reviews, this bounded design and its temporary implementation plan
leave the live tree; Git history retains them. Reconsider the lesson-local API
or verifier only when a later complete case exposes a concrete shared need.

## Attribution, exclusions, and continuity

The existing [*How to Design Programs* research
record](../../research/how-to-design-programs-recursive-algorithms.md) supplies
inspiration for deriving functions from self-referential data and counting
named source operations before summarizing growth. The ordered-tree invariant
and its correctness and cost derivations are original program reasoning for
this case. HtDP's CC BY-NC-ND boundary remains in that record. The case will
use original Ash prose, programs, tree shapes, calculations, and exercises; it
will not translate the book's examples, follow its chapter sequence, or import
its teaching-language behavior. No new source record is required.

The case introduces no interface or evidence selection, which belong to case
7, and no opacity, which belongs to case 8. It also excludes balancing,
deletion, mutation, iteration, generic tree infrastructure, a new harness,
manifest, renderer, and research record. It makes no claims about elapsed time,
machine instructions, runtime or host stack behavior, tail-call optimization,
heap layout or bytes, garbage collection, pointer identity, physical sharing,
compiler representation or optimization, or arbitrary-precision integer bit
cost.

Practice will ask the reader to state whether a supplied tree satisfies the
global invariant before predicting a lookup path, then repair one misplaced
key. A second exercise will compare the reported node visits and derived
Natural comparison work for another query without changing the comparator's
return type.

The ending leads directly to case 7: explicit `compare` parameters repeat an
ordering capability at every dictionary operation. How can an `Order<A>`
interface let checking select that evidence while preserving the same tree
behavior and cost model?
