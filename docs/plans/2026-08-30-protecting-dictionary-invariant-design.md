# Protecting the dictionary invariant design

Status: approved on 2026-08-30 after independent specification and teaching review

## Reader and maintainer problem

The reader's question is: **How can clients use a dictionary without
constructing invalid trees?**

The observable boundary is static access across a module edge. In the preceding
case, `Tree<K, V>` is public and transparent. An importing module can name the
type, call the operations, and also construct or match `Empty` and `Node`
directly. The malformed-tree observation demonstrates the consequence: the
client can put a key in the wrong branch, and invariant-guided lookup can miss a
structurally present key.

This case changes only that representation boundary. The defining module uses
`pub opaque type Dictionary<K, V>` and retains its constructors internally.
Clients can name `Dictionary<K, V>` in signatures and obtain values through
`empty`, `insert`, and `build`, but separate complete programs that use a
dictionary constructor as a value or pattern are rejected with
`resolve.opaque-constructor`.

The public API must still do the semantic work. Opacity does not prove ordering
laws, inspect function bodies, or prevent the defining module from writing a bad
operation. The chapter therefore derives why the selected `empty`, `insert`,
and finite list `build` preserve the same global descendant invariant under the
same explicit ordering and return premises. `invariant_holds` traverses the
complete finite representation and checks that invariant; it does not turn the
invariant into a type theorem.

The work remains unpublished Cases material on ash-doc `main`. It creates no
Ash semantics, accepts no Ash architecture, and does not change the published
`modular-ash` documentation tag.

## Authority and version boundary

Every language and tool observation uses the clean pinned Ash checkout at:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Its required commit is:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

The immutable ash-doc `modular-ash` tag must continue to peel to:

```text
e963a1597176f86003926eef827498db2a661b75
```

The pinned specification overview establishes that a public opaque nominal is
nameable in an importer while its constructors are not. The design follows the
question into only these governing sections:

- the pinned [declaration and pattern
  grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  for `pub opaque type`, function equations, matches, tuples, and blocks;
- pinned [public, private, and opaque
  declarations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations)
  for the exported nominal identity and withheld constructor values and
  patterns;
- pinned [imports and
  namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces)
  for qualified public operations and the public `Order<Natural>` fact;
- pinned [patterns, matches, and
  coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage)
  for constructor access, exhaustive internal equations, and the rule that an
  imported opaque nominal is not treated as an empty sum;
- pinned [interfaces and constrained
  schemes](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#interfaces-and-constrained-schemes),
  [constraint satisfaction and checked
  evidence](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence),
  and [globals and
  modules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  for the retained `Order<K>` requirements;
- pinned [blocks](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks),
  dynamic [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  and [tuples, constructors, and
  matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches)
  for strict left folding, insertion, and whole-tree validation; and
- pinned structural
  [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
  and the tool guide's [successful
  output](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  and [failure](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#failures)
  contracts for exact channels and statuses.

Retained pinned tests for module visibility, module resolution, specification
examples, and opaque constructors provide implementation evidence. They do not
add language rules beyond the specification.

Current `ash-lang/main` is relevant only to current process or later upstream
evidence exchange. It cannot supply behavior to this edition.

The existing [recursive-algorithm source
record](../../research/how-to-design-programs-recursive-algorithms.md) supports
the source-directed invariant and work account as inspiration. The existing
[recursion-operator source
record](../../research/functional-programming-with-bananas.md) already fixes
the separate boundary for this case: `build` is an ordinary strict left fold
over a finite list, not the rank-2 producer from lazy fold/build fusion.

## Reader model and prerequisites

The reader has completed the preceding seven Cases and already knows:

- transparent nominal types, constructor values and patterns, modules, imports,
  tuples, blocks, and strict evaluation;
- recursive lists and trees, right and left folds, accumulator invariants, and
  named source-level work;
- dictionary lookup, equal-key replacement, persistent older values, and the
  global ordered-tree invariant;
- one-branch lookup, unbalanced insertion, and the difference between tree
  height and node count; and
- `Order<A>`, constrained globals, checking-time evidence selection, and the
  fact that the interface method type does not state ordering laws.

The new reader model is:

1. a module may export a nominal type identity without exporting its
   constructors;
2. the defining module can still construct and match those constructors;
3. clients compose the public operations over values whose representation they
   cannot construct or inspect in source;
4. opacity restricts the routes by which client source can produce a value, but
   preservation still follows from the exported operations' equations and
   explicit premises; and
5. printed structure is an observation, not constructor access or a secrecy
   guarantee.

The case does not repeat shared setup, interface lowering, or the full ordered
lookup cost derivation. It recalls only the parts needed to explain the new
module boundary and finite build.

## Approaches considered

### Wrap a private tree in an opaque public constructor

Define a private `Tree<K, V>`, then define
`pub opaque type Dictionary<K, V> = Dictionary(Tree<K, V>)`. This cleanly
separates the public dictionary identity from its representation and would make
a later representation replacement explicit.

It also adds a wrapper constructor and one unwrap/rewrap layer to every
operation before the reader has a need for two nominal identities. A client
construction rejection could still occur during resolution, but the extra
nominal and unwrap/rewrap layer answer no observation in this case. The next
case can preserve the opaque `Dictionary` spelling and normal client API while
replacing its constructor representation without this extra wrapper.

### Put the list and dictionary in sibling modules

Retain the earlier `List<A> = Empty | More(A, List<A>)` spelling in one module
and import it into a dictionary module. Entries would import both modules to
construct the input to `build`.

This reuses familiar constructor names but adds a second lesson-local module,
another dependency edge, and a public scheme containing the sibling nominal
identity. No observation needs that architecture. The case should spend its
module complexity on opacity, not on a list library boundary.

### Use one opaque dictionary module and one focused entry per boundary

Define the recursive tree directly as
`pub opaque type Dictionary<K, V> = Empty | Node(...)`. Define a small public
`List<A> = End | More(A, List<A>)` in the same module so `build` has a concrete
client-constructible input without colliding with the private dictionary
constructor spelling. Keep the retained `Order`, `Natural`, `Option`, lookup,
and insertion behavior together with `empty`, `build`, and `invariant_holds`.

Use the dictionary module's private entry contract to accept the program and
observe `false` for one deeper global violation without exporting it. Use three
accepted importing entries for ordinary API behavior, build order, and
structural observation, then two rejected entries for constructor use as a
value and a pattern. This is the selected design. It crosses one boundary at a
time, needs no new repository mechanism, and leaves the dictionary's public
operation surface ready for the next representation.

## Lesson-local representation and API

The canonical module will begin with these public shapes:

```ash
pub type Ordering =
    Less
    | Equal
    | Greater

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Dictionary<K, V>, K, V, Dictionary<K, V>)
```

The constructors are intentionally visible in the defining source and
available to its definitions. `pub opaque` withholds them only from importers.
The public API is:

```text
empty : Unit -> Dictionary<K, V>
lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
build : List<(K, V)> -> Dictionary<K, V> where Order<K>
invariant_holds : Dictionary<K, V> -> Bool where Order<K>
```

`Order<A>` and the public Natural implementation retain their exact preceding
definitions. `empty` returns the internal `Empty`. `lookup` and `insert` retain
their preceding equations, except their tree argument and result use
`Dictionary<K, V>`.

The private strict left fold has the familiar accumulator-first combiner:

```text
fold_left : (B -> A -> B) -> B -> List<A> -> B
```

Its `More` equation computes `next_accumulated = combine accumulated first`
before its final recursive source expression. A private `insert_entry` accepts
the dictionary accumulator and one `(K, V)` entry, destructures the entry in a
complete one-arm tuple match, and calls `insert key value dictionary`. `build`
is exactly:

```ash
build entries = fold_left insert_entry (empty ()) entries
```

This order is observable when an equal key appears twice: the later list entry
is inserted later and replaces the earlier value.

`invariant_holds` calls a private
`valid_between lower upper dictionary`, initially with both bounds absent. At
each `Node`, it checks `lower < key` when a lower bound exists and `key < upper`
when an upper bound exists. The left recursion retains `lower` and installs the
current key as its upper bound. The right recursion installs the current key as
its lower bound and retains `upper`. Both recursive results are bound before
the Boolean results are combined, so a completed check enters both branches.

This propagated-bound test checks the global descendant invariant. Testing only
each immediate child would be insufficient: a descendant can satisfy its
parent relationship while violating an older ancestor bound.

The same source has a private entry contract used only by its direct executable
check. It constructs root `two`, left child `one`, and key `three` in the right
branch below `one`. The immediate `one < three` relationship holds, but `three`
violates the older upper bound `three < two`. Running the defining module
directly must therefore observe `false : Bool`. Importers cannot resolve this
private `main` or obtain its malformed value.

## Complete observations

The lesson owns exactly six canonical sources:

```text
content/cases/protecting-dictionary-invariant/src/dictionaries.ash
content/cases/protecting-dictionary-invariant/src/01-public-api.ash
content/cases/protecting-dictionary-invariant/src/02-build.ash
content/cases/protecting-dictionary-invariant/src/03-observe.ash
content/cases/protecting-dictionary-invariant/src/04-construct.ash
content/cases/protecting-dictionary-invariant/src/05-match.ash
```

Running `dictionaries.ash` directly exercises the defining module's private
malformed value and produces:

```text
false : Bool
```

The accepted public-API entry starts from an annotated `empty`, then inserts
`three`, `one`, `two`, and `four`. The resulting root has a left branch whose
right descendant carries both bounds and a separate right branch. The entry
returns the invariant check, four hits, and one absence. Its exact observation
is:

<!-- markdownlint-disable MD013 -->
```text
(true, Some(10), Some(20), Some(30), Some(40), None) : (Bool, Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>)
```
<!-- markdownlint-enable MD013 -->

The accepted build entry supplies `(two, 20)`, `(one, 10)`, then `(two, 99)` in
that list order. It returns the invariant check followed by lookups for `two`
and `one`:

```text
(true, Some(99), Some(10)) : (Bool, Option<Int>, Option<Int>)
```

The third accepted entry returns `Dictionaries.empty()` at the explicitly
annotated dictionary type:

```text
Empty : Dictionary<Natural, Int>
```

That structural tool observation is a deliberate negative interaction with the
word *opaque*. The importer still cannot resolve `Dictionaries.Empty` in
source. The output does not grant a constructor binding, expose a pointer, or
promise representation secrecy.

The construction rejection is exactly:

```ash
import dictionaries as Dictionaries

main : Unit -> Dictionaries.Dictionary<Dictionaries.Natural, Int>
main () = Dictionaries.Empty
```

The matching rejection is exactly:

```ash
import dictionaries as Dictionaries

inspect : Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Int
inspect Dictionaries.Empty = 0

main : Unit -> Int
main () = inspect(Dictionaries.empty())
```

Each rejected entry must produce status `1`, empty standard output, first
standard-error line `resolve.opaque-constructor`, a primary causal label on the
`Empty` member token within the unique qualified `Dictionaries.Empty`
occurrence in source `0`, and a related label on the withheld `Empty`
declaration token in the dependency. Exact byte ranges are derived from each
source rather than hardcoded. Colors, gutters, offsets, and remaining
diagnostic prose are not teaching contracts.

## Opacity, invariant, return, and cost boundaries

Fix one `Order<K>` implementation whose required comparisons return, whose
`Equal` result is the chosen key equivalence, whose reversed strict comparisons
reverse `Less` and `Greater`, whose strict order is transitive, and whose
equivalent keys have the same ordering relationship to every other key.

A valid dictionary requires both subtrees to be valid, every key in the left
subtree to compare `Less` than the current key, and every key in the right
subtree to compare `Greater`. Under those premises:

- `empty` is valid;
- for a finite valid input whose entered-path comparisons return, completed
  `insert` preserves validity;
- equal-key insertion retains the stored representative key and both branches
  while replacing only its value; and
- for a finite input list whose successive insertions return, `build` preserves
  validity by starting from `empty` and applying `insert` once per entry in
  list order.

The interface and opaque nominal do not encode those laws or conclusions. The
type checker establishes the method types, evidence obligations, constructor
access boundary, and program typing. The invariant-preservation argument comes
from the selected operation equations and premises.

For a finite list of `n` entries, completed `build` invokes its strict
`fold_left` combiner exactly `n` times and therefore invokes `insert` exactly
`n` times. If insertion `j` enters `m_j` existing `Node` forms and
`C_j(i)` counts the completed comparison-method applications for its `i`th
visited key, the named comparison sub-work is the double sum of those costs;
surrounding named source work is `O(n + sum m_j)` for the list steps and entered
tree nodes. Without balancing, ascending or descending entries can make that
sum quadratic in `n`. The case does not call this build logarithmic.

For a finite dictionary with `n` `Node` occurrences whose required bound
comparisons return, completed `invariant_holds` visits exactly those `n` nodes.
Let `B` be the number of validator-initiated `compare` calls. It is exactly the
number of present lower bounds plus the number of present upper bounds across
those visits: `0` for an empty or one-node dictionary, and between `n - 1` and
`2n - 2` when `n > 1`. For call `r`, let `C_r` count all completed method
applications performed by the selected comparison for that pair, including a
recursive Natural comparison's terminal equation. Exact comparison sub-work is
`sum C_r` over those `B` calls. Only when every `C_r <= Cmax`, with
`Cmax >= 1`, may that work be summarized as `O(B * Cmax)` and therefore
`O(n * Cmax)`. Surrounding named source work is `O(n)`. These are source-level
counts, not elapsed time or machine instructions.

The selected public operations `empty`, `insert`, and `build` produce a finite,
acyclic `Dictionary` constructor spine from a finite prior dictionary spine and
a finite input-list spine. Generic key or value payloads can still contain
cycles. More generally, a nominal recursive type does not prove finiteness, and
code inside the defining module could admit a constructor-guarded dictionary-
spine cycle or a bad public operation. A required nonreturning comparison or a
dictionary-spine cycle on an entered path may prevent the relevant operation
from returning. A cycle confined to a key or value payload matters only when a
comparison, returned-value observation, or other selected computation demands
that payload. Opacity does not change those semantic boundaries.

Returning a new dictionary value does not establish mutation, physical
sharing, pointer identity, heap layout, or garbage-collection behavior. Source
equations show which old subtrees are passed to new `Node` applications, but
the case makes no stronger runtime representation claim.

## Pinned regression candidate and workaround

Exact-pin prototyping challenged the most direct helper equation:

```ash
type Tree<K, V> =
    Empty
    | Node(Tree<K, V>, K, V, Tree<K, V>)

keep : Tree<K, V> -> (K, V) -> Tree<K, V>
keep tree (key, value) = tree

main : Unit -> Int
main () = 0
```

The tuple pattern is irrefutable for `(K, V)`, so the pinned pattern and
coverage rules specify an exhaustive function. The exact pinned executable
instead exits with status `2`, empty standard output, and
`internal.resource.coverage`. Replacing the equation payload pattern with a
binder and destructuring the tuple in a one-arm body match accepts. The lesson
therefore uses:

```ash
insert_entry dictionary entry = match entry {
    (key, value) => insert key value dictionary
}
```

This is classified as an Ash regression candidate, not a language rule or a
reason to teach body matches as necessary for tuple destructuring. It remains
outside rendered lesson prose. The verifier retains the accepted workaround so
the pinned case stays executable. A durable lab or upstream evidence record is
deferred until the complete case has an immutable ash-doc commit to reference.

## Teaching sequence

The chapter will:

1. recall the malformed transparent-tree client and state the new source-access
   boundary;
2. introduce the opaque dictionary declaration and public operations inside
   the defining module;
3. predict and run normal construction across both root branches, invariant
   checking, hits, and absence;
4. derive `build` from strict left fold and use a repeated key to observe input
   order;
5. explain the propagated lower and upper bounds, then run the defining
   module's deeper ancestor-bound violation and observe `false`;
6. run the two separate constructor-access rejections;
7. show the accepted structural observation so opacity is not mistaken for
   secrecy; and
8. separate constructor access, operation correctness, ordering premises,
   balancing, and runtime representation before opening the red-black-tree
   question.

Practice will ask the reader to predict the value retained by three repeated
keys in `build`, identify the bounds passed into one left and one right
recursive call, and explain why a local-child-only check can miss a deeper
violation. Practice changes remain outside the canonical files.

## Verification and mutation boundary

The local verifier follows the existing Cases helper convention. It will:

- require exactly the six declared canonical sources and no extra top-level
  `src/*.ash` file;
- require the lesson README before checking displayed blocks;
- assert exact agreement between every displayed Ash block and its canonical
  source;
- run the defining module and three accepted importing entries at the exact pin
  and assert status `0`, exact standard output, and empty standard error;
- run both rejected entries and assert status `1`, empty standard output, the
  stable first reason line, a primary label on the member token derived within
  the unique qualified constructor occurrence, and a related label on the
  withheld declaration token in the dependency;
- assert one opaque dictionary declaration, the exact public operation
  signatures, retained constrained recursion, stored-key replacement, strict
  left-fold order, build initialization through `empty`, global bound
  propagation, the private deeper invalid example, and whole-tree validation;
- avoid asserting incidental colors, layout, numeric offsets, remaining prose,
  elapsed time, or compiler representation.

The implementation plan must prove the focused assertions by mutating at least
opacity, one lookup arm, equal-key replacement, fold direction, build's initial
value and combiner, lower and upper comparison direction, both propagated
bounds, the private malformed topology and its exact `false` observation, the
three accepted importing entries, and both negative constructor occurrences.
Each mutation must fail with its intended causal message, be restored with
`apply_patch`, and be followed by a green local verifier and exact source-hash
check.

Independent specification review must cover opaque type and constructor
resolution, internal constructor access, evidence requirements, build order,
the global invariant, return and cost premises, structural observation, the
regression classification, and diagnostic boundaries. A separate instructional
review must cover continuity, clarity, prediction before execution, practice,
and deliberate exclusions.

Completion requires Markdown, spelling when available, relative-link, Bash,
ShellCheck, local, Learn, and Cases checks at the exact pin. The final aggregate
must report eleven Learn lessons, eight Cases, and thirty-nine canonical Case
sources. `git diff --check`, clean branch and pin status, exact tag and pin
resolution, independent closure review, local merge, and merged-main
verification are mandatory.

## Repository integration and closure

The lesson uses only:

```text
content/cases/protecting-dictionary-invariant/
```

with `README.md`, `src/`, and `checks/verify.sh`. It needs no fixture, renderer,
manifest, dependency, CI service, shared dictionary module, or harness change.
The existing helper is sufficient.

After the case passes independently, root and Cases navigation will add the
eighth case. The roadmap will replace this active outcome with a durable
verified summary and remove this design and its temporary implementation plan.

Case 9 has an additional before-promotion gate: a focused source record must
select the persistent red-black-tree tradition and record its license. Case 8
closure may promote case 9 only after that separate research record is reviewed
and lands. This design does not preselect that source or infer a license.

No push is authorized. After a clean local merge and merged-main verification,
remove the clean worktree and merged feature branch.

## Attribution, exclusions, and replacement condition

The lesson's programs, examples, explanations, and exercises will be original.
The two existing research records remain conceptual inspiration under their
recorded license constraints. The rendered lesson needs no quotation or direct
adaptation.

The case intentionally excludes:

- a claim that opacity proves the dictionary invariant or ordering laws;
- representation secrecy, cryptographic privacy, capability security, or
  runtime access control;
- balancing, rotations, deletion, mutation, iteration, sets, or a generic
  collection framework;
- lazy or infinite lists, rank-2 polymorphism, fold/build fusion, or a generic
  producer API;
- constant-time, logarithmic, or universally optimal build and lookup claims;
- elapsed time, machine instructions, native-stack guarantees, tail-call
  optimization, exact heap bytes, garbage collection, pointer identity,
  physical sharing, compiler optimization, and arbitrary-precision integer bit
  cost; and
- teaching the pinned coverage regression or its workaround as Ash semantics.

Keep this lesson-local architecture until the next case replaces the opaque
dictionary's internal representation while preserving the normal client API.
Replace or extend the verifier only if that concrete case cannot express its
evidence with the existing helper.
