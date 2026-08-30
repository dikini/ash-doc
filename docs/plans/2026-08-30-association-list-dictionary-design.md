# Association-list dictionary design

Status: approved by the 2026-08-30 autonomous remaining-cases request

## Reader and maintainer problem

The accumulator case retained a result while one traversal advanced through a
list. A dictionary encoded as a recursive list creates a different choice:
lookup can stop at the first matching entry, or a strict whole-list fold can
compute the same front-shadowing result after visiting every entry.

The reader asks what lookup costs when a dictionary is a recursive list. The
observable boundary crosses the equality result in one nonempty lookup
equation. A true result returns the current value. A false result follows the
rest. Prepending a duplicate therefore makes the new value win without removing
the older entry.

The case must make comparison count, equality sub-work, strict fold traversal,
and retained dictionary versions observable. It must not turn source-value
reuse into a claim about pointer identity, heap bytes, collection, or compiler
representation.

## Authority and version boundary

Every executable observation targets Modular Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Language claims come from the
[specification at that commit](https://github.com/dikini/ash-lang/tree/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec).
Commands, values, types, output channels, and statuses come from the
[pinned tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
and executable.

The published ash-doc `modular-ash` tag remains immutable. This case is
unpublished work on `main`; it does not retarget the edition or import behavior
from current `ash-lang/main`.

The existing *How to Design Programs* research record supplies inspiration for
structural recursion and named source-operation counts. Its CC BY-NC-ND
boundary remains in the project record. The lesson will use original Ash
programs, prose, exercises, and ordering. No new source tradition or research
record is needed for this case.

The governing pinned sections are:

- [syntax grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  and [global function
  presentations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#global-function-presentations)
  for declarations, logical lines, curried equations, and patterns;
- [type and constructor
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#type-and-constructor-scope)
  and [global
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#global-scope)
  for recursive nominal data and recursive globals;
- [tuples and
  constructors](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors),
  [functions and
  application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application),
  [patterns, matches, and
  coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage),
  [primitive
  operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#primitive-operations),
  and [globals and
  modules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  for the representation, explicit equality function, branches, and complete
  modules;
- dynamic [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  [tuples, constructors, and
  matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches),
  [primitive
  operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#primitive-operations),
  and [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
  for strict evaluation, branch selection, counters, and structural output;
  and
- the tool guide's [successful-output
  contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  for exact output and exit status.

## Approaches considered

### Wrap a generic list

One design would define `List<Entry<K, V>>` and place it inside a nominal
dictionary wrapper. Ash has no source type-alias form at the pin, so insertion
would construct an entry, a list node, and a wrapper. The tail would reuse the
old inner list rather than the preceding dictionary value directly.

### Export a generic dictionary fold

Another design would publish `fold_dictionary` and define a fold-based lookup
through that API. This makes continuity with the first case explicit, but it
turns one comparison into an unnecessary public-library decision and invites
fold reuse that the case does not yet need.

### Use a direct dictionary and a private comparison fold

The selected design gives `Dictionary<K, V>` its own `Empty` and `More` forms.
Each `More` contains an `Entry<K, V>` and the preceding dictionary value. The
required dictionary operations are public. A private strict right fold and
combiner support one public counted comparison operation.

This representation makes the front node and retained previous value visible
without another wrapper. Four focused entries keep ordinary lookup, counted
work, fold contrast, and retained versions separate. A fifth rejection would
repeat the application-domain boundary already taught in the fold case, so the
negative observation is the accepted missing lookup that visits all entries
and returns `None`.

Deferring the representation or fold boundary would block the promoted reader
question without resolving later tree design. Both choices are local and
replaceable; neither creates a shared collection library.

## Lesson-local representation and API

Create `content/cases/dictionary-as-list/` with one shared
`src/dictionaries.ash` module and four complete entries. The public
representation and ordinary API are:

```text
Entry<K, V> = Entry(K, V)
Dictionary<K, V> = Empty | More(Entry<K, V>, Dictionary<K, V>)
Option<A> = None | Some(A)

empty : Unit -> Dictionary<K, V>
insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
lookup_counted :
    (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_through_fold_counted :
    (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
```

The canonical Ash signatures will remain on one physical line. The wrapped
forms above are design notation, not executable Ash.

`insert key value dictionary` constructs
`More(Entry(key, value), dictionary)`. `lookup` matches the result of exactly
one `same_key query key` application at each visited `More`. Its true arm
constructs `Some(value)` and contains no recursive call. Its false arm contains
the only recursive call on `rest`.

The counted lookup mirrors that control flow. It reports zero at `Empty`, one
for a current hit, and adds one after a false-branch recursive result.

Private `fold_entries` is a strict right fold: it binds the folded `rest`
before applying its combiner. Private `prefer_current` increments the count for
every entry. A matching current entry replaces the already folded result from
older entries; a nonmatching current entry retains that result. The public
`lookup_through_fold_counted` therefore returns the same frontmost match as
direct lookup while visiting the complete dictionary.

## Complete observations

Every entry uses this explicit integer equality:

```ash
same_int : Int -> Int -> Bool
same_int left right = left == right
```

Each builds the current dictionary by inserting `(1, 10)`, `(2, 20)`, and
`(1, 11)` in that order.

1. `01-lookup.ash` runs ordinary hit and miss:

   ```text
   (Some(11), None) : (Option<Int>, Option<Int>)
   ```

2. `02-counted-lookup.ash` makes selective work observable:

   ```text
   ((Some(11), 1), (None, 3)) : ((Option<Int>, Int), (Option<Int>, Int))
   ```

3. `03-selective-and-fold.ash` gives query `1` to direct lookup and the strict
   fold:

   ```text
   ((Some(11), 1), (Some(11), 3)) : ((Option<Int>, Int), (Option<Int>, Int))
   ```

4. `04-retained-versions.ash` retains the two-entry version as `older`, inserts
   the new front duplicate to obtain `newer`, and looks up `1` in both:

   ```text
   ((Some(10), 2), (Some(11), 1)) : ((Option<Int>, Int), (Option<Int>, Int))
   ```

The missing result is the semantic negative case. `None` after three
comparisons distinguishes absence from rejection. A wrong-domain equality
function would only repeat `type.argument`. A type-correct function need not
obey equality laws; ordering and evidence selection belong to later cases.

## Work and equality-cost account

For a fixed query `q`, let `m` be the first matching position in front-to-back
order, or the dictionary length when no key matches. Direct lookup performs
exactly `m` equality applications and visits exactly `m` dictionary `More`
forms. These comparison and `More`-visit counts are worst-case linear in the
number of entries.

Let `E_q(k_i)` name the source work performed by the complete application
`same_key q k_i` at visited entry `i`. Once `q` is fixed, the lesson may
abbreviate this to `E(k_i)`. Equality sub-work is:

```text
E_q(k_1) + E_q(k_2) + ... + E_q(k_m)
```

Including constant per-entry inspection and branching, the source account is
`O(m + sum E_q(k_i))`. Under an explicit uniform equality bound `Emax`, this is
`O(m * (1 + Emax))`, with worst case `O(n * (1 + Emax))`. For `same_int`, each
visited entry performs one pinned primitive integer equality. The counted `Int`
reports equality applications, not elapsed time, machine instructions, or the
internal work of an arbitrary supplied equality function.

The strict fold performs one equality application per dictionary entry even
when the front entry matches. Its three-entry observation reports `3` while
selective lookup reports `1`. The comparison applies only when the finite
dictionary and every required equality application reach a result. A strict
fold can evaluate an older equality application that selective lookup would
never enter.

## Retained versions and construction

One `insert` completes one `Entry(key, value)` application and one dictionary
`More(entry, dictionary)` application. It performs no equality application and
reconstructs no older entry. The source uses the complete previous dictionary
value as the new `More` tail.

In the retained-version entry, `older` reaches two entries. `newer` reaches its
new front entry followed by the two entries reachable through `older`. The
entry then uses both values. This is a source-level construction and
reachability account. It does not expose object identity, establish physical
pointer sharing, count heap bytes, describe collection or liveness, or fix a
compiler representation.

## Verification and removal conditions

The local verifier will reuse `content/checks/lib.sh`. It will check five
canonical source blocks, four exact accepted observations, and each transcript
line exactly once. Causal source assertions will establish:

- the `Entry` and recursive `Dictionary` forms;
- empty construction and the exact front-insertion expression;
- one equality application per visited entry, recursion only in lookup's false
  arm, and the counted base, hit, and recursive-miss equations;
- strict folded-rest binding before the combiner;
- fold comparison replacement on true, retention on false, and one increment
  in both arms;
- the same three insertion bindings in every entry;
- the same query and dictionary passed to selective and folded lookup; and
- direct use of `older` as the tail of `newer`, followed by lookup in both.

Completion requires both content-family aggregators to pass at the exact pin;
Markdown, spelling, shell, and relative-link checks to pass; navigation to list
the case; the roadmap to mark the dictionary verified and promote the branching
tree-fold case; and an independent review of semantic, cost, strictness,
construction, reachability, and exclusion claims. `git diff --check` and
`git status --short` must confirm the final repository state before integration.

The bounded design and implementation plan then leave the live tree. Git
history retains them. Reconsider representation sharing only if a later case
creates a concrete need for a cross-case collection module; do not promote this
lesson-local dictionary into shared infrastructure from one case.

## Intentional exclusions and continuity

The case introduces no equality interface, evidence selection, ordering, tree,
balancing, opacity, deletion, mutation, in-place update, lazy or infinite data,
or equality-law enforcement. It makes no host-stack, tail-call-optimization,
elapsed-time, instruction-count, heap-byte, garbage-collection, pointer-
identity, or compiler-optimization claim.

Practice will ask readers to predict queries in the three-entry dictionary,
prepend a new duplicate while retaining the old version, compare direct and
fold counts, and explain why insertion does not remove the older entry. The
ending opens the next question: how does the data-directed method extend when
recursive data branches into a tree?
