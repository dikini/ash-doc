# Accumulating list results design

Status: approved by the 2026-08-30 autonomous remaining-cases request

## Reader and maintainer problem

The fold and unfold cases separate a recursive traversal from the operation or
transition that guides it. The next reader question concerns information that
must survive from one input element to the next: when should recursion retain
knowledge from earlier elements?

Reversing a finite list exposes the boundary. A reverse through repeated
append first builds the result for `rest`, then traverses that already-built
list to place `first` at the end. An accumulator instead retains the reversed
processed prefix and places each new element at its front. Both produce the
same list, but the source performs different work.

The case must make the accumulator invariant, the extra append work, and
source tail position observable without claiming mutation, tail-call
optimization, constant host-stack use, elapsed time, or exact runtime memory.

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
accumulator invariants, retained knowledge, and source-level cost comparison.
The examples and prose remain original. Its CC BY-NC-ND terms prohibit
redistributing an adapted curriculum, passage, diagram, exercise, or program.
No new source tradition, research record, or license boundary is needed for
this case.

## Approaches considered

### Put counters in the ordinary reverse APIs

One design would teach only counted reverse functions. Every run would expose
work directly, but instrumentation would shape the ordinary algorithm before
the reader can see its program-design role.

### Return every observation from one entry

One nested tuple could contain both reverse results, both counters, an
invariant checkpoint, and a deliberately wrong initial accumulator. This
would reduce the number of files while combining four distinct predictions
into one dense observation.

### Keep ordinary algorithms beside focused counted mirrors

The selected design keeps `append`, append-based reverse, `fold_left`, and
accumulator reverse ordinary. Two lesson-local counted mirrors expose only the
work named by the roadmap. Four entries then separate equal results, counted
work, an invariant checkpoint, and an accepted invariant violation.

This repeats two small traversals for evidence, but it keeps instrumentation
out of the ordinary API and lets each observation answer one reader question.
A separate direct `reverse_onto` traversal would duplicate `fold_left` without
adding evidence: `reverse_with_accumulator` is the specialization
`fold_left prepend Empty`.

## Lesson and program design

Create `content/cases/accumulating-list-results/` with one shared
`src/lists.ash` module and four complete entry programs. The module defines:

```text
List<A> = Empty | More(A, List<A>)

append : List<A> -> List<A> -> List<A>
reverse_through_append : List<A> -> List<A>
reverse_through_append_with_revisits : List<A> -> (List<A>, Int)

fold_left : (B -> A -> B) -> B -> List<A> -> B
prepend : List<A> -> A -> List<A>
reverse_with_accumulator : List<A> -> List<A>
reverse_with_accumulator_and_visits : List<A> -> (List<A>, Int)
```

Private counted helpers mirror the left traversal of `append` and the input
traversal of `fold_left`. The ordinary functions remain the source of the
reader model; the mirrors exist only to expose named counts.

The entries establish these observations over
`More(1, More(2, More(3, More(4, Empty))))`:

1. append-based and accumulator reverse both produce
   `More(4, More(3, More(2, More(1, Empty))))`;
2. counted append reverse reports six visits to previously built left-hand
   `More` values, while counted accumulator reverse reports four visits to
   original input `More` values;
3. after processing `[1, 2]`, the retained accumulator `[2, 1]` and remaining
   input `[3, 4]` complete to `[4, 3, 2, 1]`; and
4. starting the fold with `[99]` is accepted and produces
   `[4, 3, 2, 1, 99]`, demonstrating that the accumulator type does not prove
   its algorithmic invariant.

The fourth entry is the negative case. It is an accepted semantic
counterexample, not a compiler diagnostic. A new `type.argument` rejection
would repeat the fold case's result-type boundary and would not answer the
reader's invariant question.

## Invariant and work account

At a call `fold_left prepend accumulated remaining`, let `processed` be the
prefix already removed from the original list. The invariant is:

```text
accumulated is reverse(processed)
original is processed followed by remaining
```

Initialization uses `processed = Empty` and `accumulated = Empty`.
`prepend accumulated first` preserves the relationship when `first` moves
from `remaining` into the processed prefix. When `remaining` is `Empty`, the
processed prefix is the complete original list, so the accumulator is its
reverse. The invariant entry exposes one nonempty intermediate state; the
source-directed initialization, preservation, and ending argument supplies
the general explanation.

For an input with `n` `More` forms, append-based reverse follows the original
input once and gives append left operands of lengths `0` through `n - 1`.
Append therefore revisits
`0 + 1 + ... + (n - 1) = n * (n - 1) / 2` previously built nodes. The roadmap
counter reports only those extra revisits: it is `6` at `n = 4`, not a claim
that the complete algorithm performs only six operations. Including the four
original input visits gives ten named node inspections for that example.

Each revisit also completes one copied output `More` expression. Together
with one singleton `More` per input element, append-based reverse completes
`n + n * (n - 1) / 2` result or intermediate `More` applications. The
accumulator traversal visits each original input `More` once and constructs
one new `More` per visit. These source counts grow quadratically and linearly,
respectively. They do not specify elapsed time, exact heap bytes, garbage
collection, or compiler optimization.

## Evaluation and tail-position boundary

The pinned binding rules evaluate a next-accumulator initializer before the
block continues. The recursive `fold_left` call is then the block's result
expression: no source operation in that equation waits for the recursive
result. The lesson names that placement *tail position*.

Pinned Ash specifies strict evaluation and ordinary recursive calls. It does
not promise tail-call optimization, a particular host stack, or constant stack
space. The lesson will state only the source relationship. It will also avoid
mutation and in-place reversal; the accumulator is an ordinary immutable Ash
value passed to the next call.

## Verification and removal conditions

The local verifier will reuse `content/checks/lib.sh`. It will check five
canonical source blocks, four exact successful observations, and the source
relationships supporting append-left traversal, extra revisit counting,
single input traversal, accumulator construction, final recursive-call
placement, the invariant checkpoint, and the deliberately wrong initial
accumulator.

Completion requires both content-family aggregators to pass at the exact pin;
Markdown, spelling, shell, and relative-link checks to pass; navigation to
list the case; the roadmap to mark accumulating results verified and promote
the association-list dictionary case; and an independent review of semantic,
cost, invariant, attribution, and exclusion claims.

The bounded design and implementation plan then leave the live tree. Git
history retains them. Reconsider counted mirrors only if a later case exposes
a work measure that the existing lesson-local source assertions cannot express;
do not promote these list definitions into a shared library from one case.
