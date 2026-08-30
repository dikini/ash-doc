# Folding branching data design

Status: approved by the 2026-08-30 autonomous remaining-cases request

## Reader and maintainer problem

The dictionary case ended with one recursive `rest` and a lookup that can
decide whether to follow it. A tree changes that data-directed question: every
`Node` contains two smaller trees, so a traversal must account for two
recursive results before it can replace the current form.

The reader asks how the data-directed method extends from lists to trees. The
observable boundary crosses both branch fields of
`Node(Tree<A>, A, Tree<A>)`. The selected strict fold obtains complete left and
right results before its combiner body runs. Tree shape therefore changes the
longest chain of pending recursive results even when two trees contain the same
number of nodes. A direct pre-order search can instead test the current value
and avoid a branch before making its recursive call.

The case must make tree size, mapped shape, height, node visits, and the search
contrast observable without treating a source-level dependency count as a
claim about the host stack. It must also distinguish finite structural
traversal from the recursive nominal type, which by itself does not exclude a
cyclic value.

## Authority and version boundary

Every executable observation targets Modular Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Language claims come from the
[specification at that commit](https://github.com/dikini/ash-lang/tree/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec).
Commands, values, types, output channels, and statuses come from the
[pinned tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
and executable.

The published ash-doc `modular-ash` tag remains immutable. This case is
unpublished work on `main`; it neither changes the edition target nor imports
language behavior from current `ash-lang/main`.

Verification must receive a clean Ash checkout whose `HEAD` is the exact
commit above. It builds that checkout with locked dependencies, then invokes
its own executable on each entry:

```text
cd <clean-pinned-ash-lang>
cargo build --locked
<clean-pinned-ash-lang>/target/debug/ash <case-entry.ash>
```

The shared verifier may isolate Cargo's target directory, but it must not use
an unrelated `ash` from `PATH`. Running Cargo inside the pinned checkout lets
its `rust-toolchain.toml` select the declared Rust version before the manifest
is resolved. Cargo and the Rust toolchain establish how the pinned executable
is built; they do not add language semantics.

The governing pinned sections are:

- [syntax grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  and [global function
  presentations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#global-function-presentations)
  for parameterized data, constructor patterns, and curried equations;
- [imports and
  namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces),
  [type and constructor
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#type-and-constructor-scope),
  and [global
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#global-scope)
  for the shared module, recursive types, and recursive globals;
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
  for the fold type, nested combiners, bindings, arithmetic and equality, cyclic
  value admission, and complete modules;
- dynamic [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [recursive
  bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#recursive-bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  [tuples, constructors, and
  matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches),
  [primitive
  operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#primitive-operations),
  and [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
  for eager branch evaluation, selected match arms, integer counts, and
  structural output; and
- the tool guide's [successful-output
  contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  for exact standard output, empty standard error, and status `0`.

## Reader model and prerequisites

The reader has completed the four earlier Cases chapters. They know transparent
parameterized data, structural recursion, a strict list fold, unary `Natural`,
source-operation counts, accumulator state, and the difference between direct
selective lookup and a whole-list fold.

This case changes only the recursive shape. `Empty` supplies one base result.
`Node(left, value, right)` supplies two smaller trees, so its combiner receives
the folded left result, the current value, and the folded right result. The
chapter will derive that equation before naming height or comparing search.

## Approaches considered

### Use direct recursive functions

One approach would define `size`, `map_tree`, and search with separate
`Empty` and `Node` equations. Those definitions make the two branch fields
visible, but repeat the traversal and do not answer how the earlier fold method
generalizes. They also provide no shared boundary for showing why a strict fold
cannot become selective through a different combiner.

### Keep height as a source-only derivation

A second approach would publish `fold_tree`, derive `size` and `map_tree`, and
use four entries: separate size, map, counted-shape, and search observations.
The prose and exact source shapes could derive height `2` for a balanced
three-node tree and height `3` for a skewed one. This keeps the shared module
smaller, but the central equal-size/different-depth comparison would not place
height in the executable observation. Separate size and map entries would also
split one introductory use of the same tree without creating another boundary.

### Observe size and height together

The selected design publishes the generic fold, `size`, and `map_tree`, then
adds `nodes_and_height`. A public unary `Natural` makes the balanced and skewed
heights exact values. One private `maximum` combines the branch heights. The
reader already used unary naturals in the finite-unfold case, so this does not
introduce another language mechanism.

Three focused entries are enough: size with mapped shape, equal node counts
with different heights, and direct search against strict folded search. The
height helper adds internal recursive work, but the lesson keeps that work out
of its fold-visit and dependency counts. That separation is preferable to
leaving the chapter's defining shape contrast as prose alone.

Deferring the fold or height choice would leave the promoted outcome without
its observable dependency boundary. The selected functions remain local to
one case and create no shared tree library, manifest, renderer, or new harness.

## Lesson-local representation and API

Create `content/cases/folding-branching-data/` only after its temporary
implementation plan is active. The case contains `src/trees.ash` and three
complete entry modules.

The public representation and API are:

```text
Tree<A> = Empty | Node(Tree<A>, A, Tree<A>)
Natural = Zero | Next(Natural)
Option<A> = None | Some(A)

fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B
size : Tree<A> -> Int
map_tree : (A -> B) -> Tree<A> -> Tree<B>
nodes_and_height : Tree<A> -> (Int, Natural)
find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_through_fold_counted :
    (A -> Bool) -> Tree<A> -> (Option<A>, Int)
```

The wrapped final signature is design notation. Its canonical Ash signature
will remain on one physical line.

`fold_tree` mirrors the two forms. `Empty` returns `base`. The `Node` equation
binds `folded_left`, binds `folded_right`, then evaluates the complete
`combine folded_left value folded_right` application. Because each binding
initializer completes before the following block remainder, both
branch results are values before evaluation of that complete curried
application begins. The supplied combiner may itself use either global or
anonymous function presentations.

`size` replaces `Empty` with `0` and each `Node` with the two branch sizes plus
one. `map_tree` replaces `Empty` with `Empty` and each `Node` with one `Node`
whose value has been transformed and whose children are the two mapped branch
results.

`nodes_and_height` replaces `Empty` with `(0, Zero)`. At a node, it adds the
two node counts plus one and returns
`Next(maximum left_height right_height)`. `Natural` must be public because the
second entry names `Trees.Natural` in its closed `main` result type. `maximum`
remains private because no reader-facing operation needs to select between two
natural numbers independently of the measurement.

`find_counted` is direct pre-order search. It applies its predicate to the
current value first. A current match returns immediately. After a mismatch, a
left result returns without searching right; only left absence enters the
right recursive call. The count records predicate applications at visited
nodes.

Private `choose_counted` gives a folded result current-left-right selection
priority and adds both branch counts plus one. Public
`find_through_fold_counted` supplies it to `fold_tree` with `(None, 0)` as the
base. Its selected value can agree with direct pre-order search even though
the strict fold has already completed both branches and applied the predicate
at every node.

## Complete observations

The exact-pin feasibility check accepts these four canonical sources.

1. `src/trees.ash` is the shared module described above.

2. `src/01-size-and-map.ash` builds the balanced tree with values `1`, `2`,
   and `3`, then observes `size` and an incrementing `map_tree` together:

   ```text
   (3, Node(Node(Empty, 2, Empty), 3, Node(Empty, 4, Empty))) : (Int, Tree<Int>)
   ```

3. `src/02-balanced-and-skewed.ash` gives two three-node shapes to
   `nodes_and_height`:

   <!-- markdownlint-disable MD013 -->
   ```text
   ((3, Next(Next(Zero))), (3, Next(Next(Next(Zero))))) : ((Int, Natural), (Int, Natural))
   ```
   <!-- markdownlint-enable MD013 -->

4. `src/03-selective-and-fold.ash` places `42` at the root and one non-matching
   node in each branch. It passes the same predicate and tree to both searches:

   ```text
   ((Some(42), 1), (Some(42), 3)) : ((Option<Int>, Int), (Option<Int>, Int))
   ```

All three entries must exit with status `0`, write exactly one expected line to
standard output, and leave standard error empty. The case needs no intentional
rejection. Its negative boundary is the accepted strict-fold observation: a
combiner that selects the current root still receives branch results produced
by visiting both branches. Repeating the list fold's `type.argument` rejection
would not answer this question.

## Structural size, height, and work

The case considers a tree with a finite structural expansion: recursively
following both branch fields eventually reaches `Empty` on every path. Let
`n` be the number of `Node` encounters in that expansion. Let `h` be the
maximum number of `Node` forms on a root-to-`Empty` path, with height `0` for
`Empty`.

For a completed `fold_tree`, assume every required combiner application
returns. The traversal selects the `Node` equation and completes the combiner
exactly `n` times. Its maximum chain contains `h` pending `Node` results. At
the deepest terminal step, those results wait while one `Empty` call returns
the base, so counting the active terminal call gives `h + 1` simultaneous
`fold_tree` calls in the source dependency chain. Neither count states how a
host implementation represents calls.

The balanced example has `n = 3` and `h = 2`. The skewed example has `n = 3`
and `h = 3`. Both folds therefore complete three node combiners, while their
longest pending-result chains differ.

`size` performs two primitive integer `+` operations per node. This is
`2 * n` additions, not a constant-time claim about arbitrary-precision integer
arithmetic. Assuming the supplied transform returns for
every encountered value, `map_tree` applies it `n` times and completes `n`
output `Node` constructor applications while preserving the branch shape.

`nodes_and_height` still completes one fold combiner per encountered node. Its
private `maximum` performs its own recursion over the two unary heights, and
its `Next` expressions construct height representation. That internal work is
deliberately excluded from the claims that `fold_tree` visits `n` nodes and
has dependency depth `h`. The chapter must not summarize the complete
measurement as linear work without separately accounting for `maximum` and
the arbitrary-precision additions.

For direct search, assume every predicate application required by the selected
control path returns. Let `m` be the number of nodes visited before the first
current-left-right match, or `n` for a complete miss. Direct search applies the
predicate exactly `m` times. It avoids both branches after a current match and
avoids the right branch after a left match; after a current mismatch it must
search left before it can decide whether to enter right. Under the finite-tree
premise, folded search completes, applies the predicate `n` times, and agrees
with direct pre-order search only when every predicate application over the
complete structural expansion returns. Each `choose_counted` call runs after
both branch folds have returned. In the three-node root-match observation, the
counts are therefore `1` and `3`.

These definitions do not expose physical identity. If one acyclic subtree
value is placed in both branch fields, traversal follows both fields and counts
the subtree once through each structural occurrence. Structural observation
also renders shared acyclic data in full at each occurrence. A cyclic `Tree`
value may prevent these recursive functions from returning, so the nominal
type alone establishes neither finiteness nor these counts.

## Verification and mutation boundary

The local verifier will reuse `content/checks/lib.sh`. It will check four
canonical source blocks, three exact accepted observations, and each complete
transcript line exactly once. Causal source assertions will establish:

- the exact `Tree`, `Natural`, and `Option` forms;
- one `Empty` equation and one `Node` equation for `fold_tree`;
- exactly one recursive fold of `left`, then one recursive fold of `right`,
  followed by the complete combiner application;
- one use of `fold_tree` by each of `size`, `map_tree`, and
  `nodes_and_height`, with their exact bases and node combinations;
- one transform application and one output `Node` expression in the map
  combiner;
- the three equations of private `maximum`, the structural decrease in its
  recursive equation, and the
  `Next(maximum left_height right_height)` height expression;
- direct search's exact `(None, 0)` base, current-first predicate application,
  `(Some(value), 1)` current result, left recursion only after a current
  mismatch, right recursion only after left absence, and one current-node
  increment in both false-path results;
- both folded visit counts plus one in `choose_counted`, its single predicate
  application, and its current-then-left-then-right result priority;
- one `find_through_fold_counted` use of the strict fold with exact base
  `(None, 0)`;
- the same constructed `tree` passed once to both `size` and `map_tree` in the
  first entry;
- the exact balanced and skewed shapes supplied to the same measurement; and
- the same root-match predicate and tree passed to both search operations.

Before closure, behavior-specific mutations must prove that the verifier fails
when the right fold binding targets `left`, the two branch bindings change
order, map swaps the mapped children, one visit increment disappears, the
skewed shape loses one level, or direct right recursion moves outside the
left-absence arm. Also mutate the unobserved direct-search base and a non-root
current-node increment, replace the folded predicate match with `match true`,
and change folded left-result priority so their causal assertions demonstrate
that the root-hit transcript is not the only guard. Change canonical source and
its displayed block together for each source mutation. Restore both before
rerunning the green checks.

Completion requires the lesson verifier and both content-family aggregators to
pass against a clean checkout at the exact pin. Markdown, spelling, shell, and
relative-link checks must pass. Navigation must list the verified case, the
roadmap must mark it verified and promote the ordered-tree case, and an
independent review must cover language authority, strictness, work,
dependency, sharing, cycle, attribution, continuity, and exclusions.
`git diff --check` and `git status --short` must confirm the intended final
repository state before integration.

After those reviews, this bounded design and its temporary implementation plan
leave the live tree; Git history retains them. Reconsider the lesson-local API
or verifier only when a later complete case exposes a concrete shared-tree or
harness need. Do not promote this transparent tree into shared infrastructure
from one case.

## Attribution, exclusions, and continuity

The existing *How to Design Programs* research record supplies inspiration for
deriving functions from self-referential data and naming source-operation
counts. Its CC BY-NC-ND boundary remains in that record. The lesson will use
original Ash prose, programs, tree shapes, calculations, and exercises.

The existing recursion-operator research record supports separating a
recursive traversal from the operations that replace its data forms. That
paper's lazy semantics, morphology notation, domain-theoretic results, fusion
laws, and examples do not transfer to pinned Ash. No new source record is
needed for this case.

The case introduces no ordering invariant, ordered lookup, insertion,
duplicate replacement, balancing, opacity, mutation, laziness, infinite-tree
claim, or generic tree library. It makes no claim about elapsed time, machine
instructions, native stack size, tail-call optimization, exact heap bytes,
garbage collection, pointer identity, physical sharing, integer bit cost, or
compiler representation and optimization.

Practice will ask the reader to define `sum_tree` through `fold_tree`, predict
the same sum and combiner count for the two three-node shapes, and explain their
different dependency depths. A second exercise moves the sought value into the
left child, predicts direct and folded predicate counts, and explains why only
the direct definition avoids the right branch.

The ending opens the next question: if a tree maintains smaller keys on one
side and larger keys on the other, how can one comparison select a branch
before recursion?
