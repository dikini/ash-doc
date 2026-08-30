# Guaranteeing logarithmic retrieval design

Status: approved on 2026-08-30 after independent specification and teaching
review

## Reader and maintainer problem

The reader's question is: **How can the representation prevent a search tree
from degenerating?**

The observable boundary crosses from access control to a maintained shape
invariant. Case 8 prevents importing modules from constructing or matching the
opaque dictionary representation, but opacity alone says nothing about tree
height. Its ordered insertion can still produce a linear chain, so one-branch
lookup has no logarithmic guarantee.

This case retains the public dictionary name and normal client operations while
changing the hidden representation to a persistent red-black tree. Every
completed public insertion prefix in the selected ascending, descending, and
four repair-triggering sequences must satisfy global key order, a black root,
no red parent with a red child, and equal black-height. Lookup must still find
every inserted key and return `None` for a fixed absence. A separate build and
replacement observation must preserve case 8's input order, later-equal
replacement, and older dictionary values.

The representation and public functions do not prove their own laws. The
preservation argument remains conditional on one fixed, returning `Order<K>`
implementation with the stated ordering premises, finite valid input, and the
selected source equations. The defining module can still construct invalid or
cyclic values or publish a bad operation.

This work remains unpublished Cases material on ash-doc `main`. It cannot
define Ash semantics, accept Ash architecture, or move the immutable published
documentation tag.

## Authority and version boundary

All language and tool observations use the clean pinned Ash checkout at:

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

The pinned specification is the only authority for language behavior. The
design follows the question into these sections:

- pinned [declaration, pattern, match, and global
  grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  for the opaque representation, nested repair patterns, and body matches;
- pinned [public, private, and opaque
  declarations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations)
  for the public dictionary name, private color name, withheld constructors,
  and defining-module access;
- pinned [patterns, matches, and
  coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage)
  for the four nested repair equations, exhaustive internal matches, and
  private validation summaries;
- pinned [interfaces and constrained
  schemes](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#interfaces-and-constrained-schemes)
  and [constraint satisfaction and checked
  evidence](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
  for the retained `Order<K>` requirements and public Natural fact;
- pinned [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  and [tuples, constructors, and
  matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches)
  for strict insertion, reconstruction, folding, and whole-tree validation;
- pinned [recursive block-group
  rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups)
  and dynamic [recursive
  bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#recursive-bindings)
  for the retained finite-spine and cycle boundaries; and
- pinned structural
  [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
  and the tool guide's [successful-output
  contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  for exact values, closed types, channels, and status.

The permanent [persistent red-black insertion source
record](../../research/persistent-red-black-insertion.md) selects Chris
Okasaki's 1999 four-configuration functional insertion as conceptual
inspiration. The MIT-licensed Software Foundations presentation corroborates
the structure. Neither source defines Ash behavior. The case uses original Ash
programs, names, diagrams, derivations, sequences, prose, and exercises and
does not directly adapt either presentation.

Current `ash-lang/main` is relevant only to current project process, future
pressure, or later evidence exchange. It cannot supply behavior to the pinned
edition.

## Reader model and prerequisites

The reader has completed case 8 and already knows:

- global ordered-tree validity and its explicit ordering-law premises;
- one-branch lookup, insertion, replacement, strict finite build, and retained
  older dictionary values;
- the distinction between top-level comparisons and recursive comparison
  method work;
- opaque source access versus operation correctness and representation
  secrecy; and
- why the case-8 unbalanced representation permits height `h = n`.

The new causal model is:

1. equal black-height gives every root-to-`Empty` path the same black count;
2. a black root and no adjacent red nodes permit at most one red `Node` for
   each black `Node` on a path;
3. inserting a red leaf preserves black-height and may create one red-red
   obligation on the reconstructed search path;
4. the red parent can be on either side of a black grandparent, and its red
   child can be on either side of that parent, giving exactly four repair
   orientations;
5. all four orientations normalize to one ordered local result with a red
   middle root and two black children while retaining every key-value
   association;
6. a repair result may expose one red-red obligation to the next ancestor,
   where reconstruction repairs it; after insertion into a valid public
   dictionary no red-red edge remains, and final root blackening restores only
   the separate black-root condition; and
7. logarithmic height turns one-branch lookup and persistent reconstruction
   into logarithmic source-level bounds.

The lesson does not reteach module setup, interface lowering, opacity
rejections, or case 8's complete cycle catalogue.

## Approaches considered

### Separate red and black node constructors

Represent the tree as `Empty | RedNode(...) | BlackNode(...)`. Color is visible
in each pattern, and a separate private color type is unnecessary.

This duplicates the node vocabulary across lookup, insertion, validation, and
repair. It also makes the requested count of newly constructed path nodes less
direct because two constructor spellings denote the same structural role. The
case needs color as one field of a dictionary node, not two public teaching
representations. This approach is not selected.

### Wrap a private tree inside an opaque dictionary constructor

Define a private colored `Tree<K, V>`, then wrap it in
`pub opaque type Dictionary<K, V> = Dictionary(Tree<K, V>)`. The wrapper makes
the public identity visibly independent of the current tree representation.

The extra nominal and unwrap/rewrap operations add source constructions and
another invariant boundary without preventing the defining module from
wrapping an invalid tree. Case 8 already established the opaque public identity
directly. No case-9 observation needs the extra layer, so this approach is
deferred.

### Add one private color field to the existing opaque node

Define a private `Color = Red | Black` and change only the hidden dictionary
constructor payload:

```ash
type Color =
    Red
    | Black

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)
```

Keep the public representations, interface, implementation, and five normal
operations from case 8. Use one private repair helper with four nested-pattern
orientations and one fallback. Use a second private helper to construct the one
normalized three-association result so the four orientations share one
original Ash reconstruction rather than repeating four equivalent right-hand
sides.

This is the selected architecture. It is the smallest replacement, preserves
the client source API, makes color and `Node` work explicit, and requires no
new repository mechanism.

### Split each insertion scenario into its own entry

Six separate client entries would isolate ascending, descending, and the four
repair orientations at the file boundary. They would also repeat the same
imports, transparent result vocabulary, prefix construction, and lookup
checks, and would expand the case from three canonical sources to eight
without adding a distinct reader boundary.

The selected single prefix-matrix entry keeps the six scenarios structurally
separate in one observable result. Its source assertions still name every
prefix and lookup group, so one mutated orientation cannot disappear into an
aggregate pass/fail value.

### Publish a diagnostic height operation

A public `height` operation would let finite examples measure the selected
trees directly. It would enlarge the unchanged client API and could make a few
measured shapes appear to establish the general logarithmic guarantee.

The selected design derives the bound from the checked red-black conditions.
The private validator observes those conditions, while the lesson's recurrence
and path argument explain why they constrain every valid public dictionary.
This keeps three sources sufficient and leaves case 10 as the next public API
extension.

## Representation, API, and validity

The public source API remains:

```text
Ordering, Natural, Option, List
Order<A>, Order<Natural>
empty : Unit -> Dictionary<K, V>
lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
build : List<(K, V)> -> Dictionary<K, V> where Order<K>
invariant_holds : Dictionary<K, V> -> Bool where Order<K>
```

Source compatibility does not mean structural-output compatibility. Successful
observation of a nonempty opaque dictionary will now render the private `Red`
or `Black` constructor as part of the hidden `Node` payload. That text neither
exports `Color` nor grants client constructor access.

Fix one `Order<K>` implementation whose required comparisons return, whose
`Equal` result is the chosen key equivalence, whose reversed strict
comparisons reverse `Less` and `Greater`, whose strict order is transitive, and
whose equivalent keys have the same ordering relationship to every other key.

A finite tree is recursively ordered and red-black consistent when:

1. both subtrees are recursively consistent, every left descendant is `Less`
   than the current key, and every right descendant is `Greater`;
2. a `Red` node has no `Red` child; and
3. every path from one node to `Empty` contains the same number of black forms,
   counting terminal `Empty` as black.

A valid public dictionary is `Empty`, or it is such a recursively consistent
tree whose top-level `Node` is `Black`. The black-root condition applies only
at this public boundary; recursively requiring it of every subtree would
incorrectly forbid all red nodes.

Equal insertion has a separate preservation requirement: retain the stored
representative key, current color, both branches, and every other key-value
association while replacing only the matching value.

`Dictionary<K, V>`, `Order<K>`, and `invariant_holds` do not encode these
properties as type propositions. The guarantee comes from opaque client access
plus the selected public operations and explicit premises.

## Persistent insertion and the four repairs

Private `insert_colored` follows exactly one ordered branch. At `Empty` it
constructs a red leaf. At a `Node`, `Less` and `Greater` recursively insert and
pass the result to `restore`; `Equal` reconstructs the same colored node with
the stored key, incoming value, and unchanged branches.

`restore color left key value right` has four repair equations under a black
candidate root. There are exactly four because the red parent can be the left
or right child of that black grandparent, and the offending red child can be
the left or right child of the red parent:

| Orientation | Triggering three-key sequence |
|---|---|
| left-left | `3, 2, 1` |
| left-right | `3, 1, 2` |
| right-left | `1, 3, 2` |
| right-right | `1, 2, 3` |

Each pattern extracts the same three increasing key-value associations and
four intervening subtrees. A shared private `restore_three` reconstructs one
red middle association whose two children are black. The in-order sequence
remains:

```text
first subtree, (first key, first value), second subtree,
(middle key, middle value), third subtree,
(last key, last value), fourth subtree
```

No value changes partners during normalization. That dictionary-specific
requirement is asserted separately from ordering and balance.

The fallback constructs one node with the supplied color and fields. The four
repair patterns are a contract only for transient candidates produced while
inserting into a valid public dictionary. Their overlap on arbitrary malformed
private values does not create a public guarantee.

Private `blacken_root` uses a body match. It returns `Empty` or an already-black
dictionary unchanged and constructs one black root only when the transient
root is red. Public `insert` is `blacken_root` applied to `insert_colored`.

The preservation account is source reasoning, not a checked proof. Red-leaf
insertion preserves black-height. `restore_three` preserves in-order
key-value associations and equal black-height while removing the local
red-red edge. Its red result may become the child of a red ancestor, carrying
one obligation to the next black grandparent, where one of the four repairs
removes it. Because insertion begins from a valid black-rooted public
dictionary, the completed internal result has no red-red edge. Final
blackening restores only the root-color condition: when it recolors a red
root, it changes every root path's black count equally and cannot disturb key
order or associations.

## Two-pass invariant observation

The selected validator keeps case 8's bound-propagating ordering traversal
unchanged. `valid_between lower upper dictionary` enters both branches, keeps
the old lower bound and installs the current key as the left upper bound, then
installs the current key as the right lower bound and keeps the old upper bound.

A separate private balance traversal returns:

```ash
type BalanceCheck =
    Invalid
    | Valid(Int)
```

`Empty` returns `Valid(1)` because the terminal form counts as black. A node
binds both recursive summaries before combining them. A red parent with a red
child, an invalid child, or unequal child black-heights returns `Invalid`. A
valid red node returns the common height; a valid black node returns that
height plus one. Primitive `Int` equality and addition are used only for this
private summary; their arbitrary-precision bit cost is outside the named
source-work account.

A separate root check accepts `Empty` and a black `Node` and rejects a red
root. `invariant_holds` binds the ordering result, balance result, and root
result before combining them, so completed validation of a finite dictionary
performs both whole-tree passes even when one final Boolean is false.

The defining module's private `main` constructs five isolated observations:

1. one valid black tree;
2. a deeper ancestor-order violation whose red-black properties otherwise
   hold;
3. a red root whose ordering and remaining balance properties hold;
4. a red parent/red child edge whose ordering, root, and black-height otherwise
   hold; and
5. unequal black-height whose ordering, root, and red-child properties hold.

Its exact result must be:

```text
(true, false, false, false, false) : (Bool, Bool, Bool, Bool, Bool)
```

This matrix demonstrates that `invariant_holds` is neither a type proof nor a
tautology over values available inside the defining module.

## Complete public observations

The lesson owns exactly three canonical sources:

```text
content/cases/guaranteeing-logarithmic-retrieval/src/dictionaries.ash
content/cases/guaranteeing-logarithmic-retrieval/src/01-prefix-matrix.ash
content/cases/guaranteeing-logarithmic-retrieval/src/02-build-and-persistence.ash
```

The prefix entry uses these client-local transparent result shapes:

```text
PrefixCheck(Bool, Bool, Bool, Bool)
Scenario(Bool, List<PrefixCheck>, List<Bool>)
```

The first `Scenario` field records validity of the empty prefix. Every later
`PrefixCheck` records, in order, validity after that insertion, exact lookup of
the newly inserted key-value association, exact lookup of the scenario's first
retained key-value association, and `None` for one fixed absence. The final
Boolean list compares exact expected values for every inserted key and ends
with the same absence check. This keeps each scenario and each prefix separate
instead of reducing the complete matrix to one aggregate Boolean. The six
insertion sequences are:

- ascending `1, 2, 3, 4, 5, 6, 7`;
- descending `7, 6, 5, 4, 3, 2, 1`;
- left-left `3, 2, 1`;
- left-right `3, 1, 2`;
- right-left `1, 3, 2`; and
- right-right `1, 2, 3`.

Every Boolean position must be `true`. Distinct values tied to the keys make a
repair that preserves keys but permutes associations fail. Source assertions
retain the scenario order, empty validity, every prefix's four observations,
every exact final association, and the fixed absence so the structural output
remains interpretable.

The build-and-persistence entry uses Natural keys and the unchanged public API.
It constructs an older dictionary, replaces the same key in a newer value,
extends only the newer value, and independently builds the corresponding final
dictionary from a finite input list. Its exact structural result must show:

- the old dictionary still contains value `20`;
- the replacement and built dictionaries contain later value `99`;
- the old dictionary still lacks the later extension key;
- the extended and built dictionaries find that key;
- all retained versions satisfy `invariant_holds`; and
- the colored nonempty representation renders structurally without becoming
  accessible in client source.

The implementation plan will fix the complete sources, exact outputs, and
SHA-256 hashes after design approval. The case does not repeat case 8's value
and pattern opacity rejections; the preceding canonical programs and aggregate
verifier continue to establish that unchanged source-access boundary.

## Height, comparison, and construction bounds

Let `n` be the number of nonempty `Node` forms, `h` the largest number of
`Node` forms on a root-to-`Empty` path, and `q` the equal number of black forms
on such a path including terminal `Empty`.

For `n > 0`, the path contains `q - 1` black `Node` forms. Because the root is
black and red nodes cannot be adjacent, there can be at most one red `Node`
for each of them. Therefore:

```text
h <= 2 * (q - 1)
```

For the minimum-node count, let `N(q)` be the least number of nodes in any
recursively consistent subtree whose paths contain `q` black forms. Use
`N(1) = 0` for `Empty`. For `q > 1`, a black root contributes one node and
gives both children black-height `q - 1`, so it has at least
`1 + 2 * N(q - 1)` nodes. A red root of the same black-height must have two
nonempty black children; each contributes a node above subtrees of
black-height `q - 1`, so the red-rooted case is larger. Induction therefore
gives:

```text
2^(q - 1) - 1
```

nonempty nodes. Therefore:

```text
q - 1 <= log2(n + 1)
h <= 2 * log2(n + 1)
```

The empty tree has `n = h = 0` and is handled separately. These are
mathematical derivations from the representation conditions, not Ash numeric
operations or measured timing.

If lookup or insertion enters `m` existing nodes, it initiates exactly one
top-level key comparison at each entered node and `m <= h`. If comparison `i`
causes `C(query, key_i)` selected method applications, exact comparison
sub-work is:

```text
sum from i = 1 to m of C(query, key_i)
```

Only when every `C(query, key_i) <= Cmax`, with `Cmax >= 1`, may the combined
comparison account be summarized as `O(log(n + 1) * Cmax)`. Lookup constructs
no dictionary `Node` forms.

For absent insertion into a valid dictionary, let `m` be the entered existing
nodes, `r` the number of `restore` calls selecting a three-node repair rather
than the one-node fallback, and `b` be `1` exactly when final root blackening
constructs a replacement root. The evaluated source `Node` applications are:

```text
m + 1 + 2r + b
```

The `1` is the red leaf, `0 <= r <= m`, and `0 <= b <= 1`, so at most
`3m + 2` `Node` applications occur. Equal replacement after entering `m`
nodes constructs exactly `m` `Node` forms: one replacement and one fallback
reconstruction for each ancestor; it introduces no red-red edge, and the
already-black root is returned unchanged. Thus completed insertion constructs
`O(log(n + 1))` source-level representation nodes.

These insertion counts exclude the separate calls to `invariant_holds` in the
evidence matrix. They count source constructor applications, not runtime
allocations, elapsed time, heap bytes, pointer identity, or physical sharing.
Unentered branches and the four repair subtrees are passed unchanged into
result constructors; that supports only a source-level reuse account.

Completed validation of a finite `n`-node dictionary visits every `Node` once
in the ordering pass and once in the balance pass. The ordering pass retains
case 8's bound-comparison count: `B = 0` for `n <= 1`; otherwise
`n - 1 <= B <= 2n - 2`. Its exact selected comparison-method work is
`sum C_r`, or `O(n * Cmax)` only when every `C_r <= Cmax` and `Cmax >= 1`.
The balance pass performs bounded color and summary work per node, at most one
child black-height equality per node, and one increment for each valid black
node whose summary it returns. The separate root check is constant named
work. Thus the validator is linear outside comparison-method subwork; it is
not part of the logarithmic lookup or insertion account.

## Return and cycle boundary

The logarithmic guarantee applies to finite valid dictionary spines produced
from `empty` by completed public insertions and finite builds under the fixed
ordering premises. Required comparisons must return.

The defining module can still construct an invalid or constructor-guarded
cyclic spine or export a bad operation. Whole-tree validation enters both
branches in each of its two passes. Lookup and insertion enter only the
selected path, so an unentered cycle need not affect that call. A comparison
that follows a cyclic key may not return. Lookup can return a cyclic value
without inspecting it; final structural observation then traverses the returned
payload and renders an active-path revisit as `<cycle>`. A cyclic input list can
prevent `build` from reaching `End`.

Neither opacity nor red-black validity establishes mutation, pointer identity,
physical sharing, heap layout, garbage-collection behavior, native-stack use,
tail-call optimization, or compiler representation.

## Pinned regression candidates and workarounds

The case retains case 8's minimized equation-level tuple-pattern regression.
The specified irrefutable helper form exits at the exact pin with status `2`,
empty standard output, and `internal.resource.coverage`. The accepted
`insert_entry` continues to bind its tuple argument and destructure it in a
one-arm body match. This workaround stays outside rendered lesson prose.

Case-9 prototyping also minimized a local implementation of an imported public
interface to status `2`, empty standard output, and
`evidence.validation.unknown-identity`. Qualified and targeted routes fail at
the executable evidence-validation boundary even though the pinned checked
module model admits the source relationship. The lesson therefore uses the
already executable module-owned public `Order<Natural>` fact and an exact
repeated Natural key for replacement. It does not teach a client-owned
implementation workaround or treat the failure as language behavior.

Both failures are Ash regression candidates. A durable lab or upstream record
is deferred until the completed case has an immutable ash-doc commit to
reference and the evidence matters beyond this lesson.

## Teaching sequence

The chapter will:

1. reopen case 8's `h = n` degeneration without repeating opacity mechanics;
2. introduce the private color field and the recursive and top-level validity
   conditions through prose and original labeled diagrams;
3. explain the two-pass validator and its isolated fixtures without presenting
   incomplete fragments as executable Ash;
4. explain why a red leaf preserves black-height and creates only a red-red
   repair obligation;
5. derive exactly four orientations from the two branch choices, then show
   their one association-preserving `restore_three` result in an original
   diagram;
6. explain that reconstruction removes red-red obligations before final root
   blackening restores only the black-root condition;
7. present the complete canonical defining module, predict the private matrix,
   and run its exact five-result observation;
8. predict and run the six separately observable prefix checks and exact final
   association lookups;
9. reflect that the finite matrix catches the named failures but the general
   preservation and height guarantees come from the source equations and
   stated premises;
10. predict and run build order, equal replacement, retained older values, and
    colored structural observation;
11. derive the height recurrence, path bound, comparison-method account, and
    `Node`-application bound; and
12. end by asking how in-order traversal can pause without building a complete
    result list.

Practice will ask the reader to predict the repair and colors for `5, 3, 4`,
explain why duplicate replacement creates no red leaf, derive the constructor
bound for an insertion with `m` entered nodes and `r` repairs, explain why
blackening a red root preserves equal black-height, and connect equal
black-height plus the no-red-red rule to the minimum-node recurrence and final
height bound.

## Verification and mutation boundary

The lesson-local verifier will use the existing Cases helper and must:

- require exactly the three canonical sources and no extra top-level Ash file;
- assert exact agreement between each displayed Ash block and its canonical
  source;
- run all three entries at the exact pin with status `0`, empty standard error,
  and exact complete standard output;
- assert the private color and opaque representation, unchanged public API,
  retained constrained lookup, strict build, and stored-key replacement;
- assert the shared three-association reconstruction without value
  permutation, all four repair patterns, one fallback, red leaf, conditional
  root blackening, and public insertion composition;
- assert both ordering-bound directions and recursive bounds, two bound
  validation results before combination, both balance summaries before their
  black-height comparison, red-child checking, black-height update, separate
  black-root check, and the five private fixtures;
- assert all six scenario sequences, empty-prefix validity, every prefix's
  invariant, exact new and retained association lookups and fixed absence,
  every exact final association, and each final absence; and
- assert the build, replacement, extension, retained-version, and structural
  observations without claiming runtime identity or storage.

The implementation plan must prove mutation-facing failures for at least:

1. opacity or the private color field;
2. either lookup branch;
3. the red leaf;
4. each of the four repair patterns independently;
5. the shared ordered reconstruction;
6. the restore fallback;
7. stored-key equal replacement;
8. conditional red-root blackening and already-black reuse;
9. build's fold order, initial dictionary, and combiner;
10. both ordering comparison directions and both propagated bounds;
11. red-child rejection, child black-height equality, black-height increment,
    and black-root rejection;
12. each private valid or invalid fixture;
13. every prefix invariant, new association, retained association, absence, or
    final exact-lookup group; and
14. build, replacement, extension, and retained-version observations.

Each mutation must fail for its focused reason, be restored with `apply_patch`,
and be followed by GREEN and fixed source hashes. Independent specification
review must cover representation access, all four invariants, preservation,
costs, returns, cycles, regressions, source classification, and verifier
adequacy. A different instructional review must cover continuity, prediction,
the one-normalization explanation, proof readability, practice, and the
iterator transition.

Completion requires Markdown, spelling when available, relative-link, Bash,
ShellCheck, local, Learn, and Cases checks at the exact pin. The completed
aggregate must report eleven Learn lessons, nine Cases, and forty-two canonical
Case sources. `git diff --check`, clean branch and pin status, exact tag and pin
resolution, independent closure review, local merge, and merged-main
verification are mandatory.

## Repository integration and closure

The lesson uses only:

```text
content/cases/guaranteeing-logarithmic-retrieval/
```

with `README.md`, `src/`, and `checks/verify.sh`. It adds no fixture, renderer,
manifest, dependency, CI service, shared dictionary library, or harness change.
The existing helper is sufficient.

After independent case verification, root and Cases navigation will add the
ninth case. The roadmap will replace this active outcome with a durable
verified summary, promote case 10 only to its bounded design gate, preserve
cases 11 and 12 as provisional, and remove this design and its temporary
implementation plan after closure approval.

No push is authorized. After a clean local merge and merged-main verification,
remove the feature worktree and merged branch.

## Deliberate exclusions and replacement condition

The case excludes:

- deletion, left-leaning red-black trees, cached size or rank, bulk balancing,
  sets, and generic collection infrastructure;
- public colors, type-indexed invariants, ordering-law enforcement, or a claim
  that the nominal type proves validity;
- repeated opacity-rejection programs or a client-owned interface
  implementation workaround;
- lazy evaluation, infinite structures, mutation, in-place rotations, and
  concurrent access;
- elapsed time, machine instructions, native-stack guarantees, tail-call
  optimization, exact heap bytes, garbage collection, pointer identity,
  physical sharing, compiler representation, and arbitrary-precision integer
  bit cost; and
- direct source adaptation, copied diagrams or exercises, universal
  optimality, or teaching either pinned regression as Ash semantics.

Keep this lesson-local representation until case 10 consumes the public opaque
dictionary through an eager iterator. Replace or extend the verifier only if
that concrete case cannot express its evidence with the existing helper.
