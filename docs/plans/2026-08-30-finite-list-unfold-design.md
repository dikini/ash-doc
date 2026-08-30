# Finite-list unfold design

Status: approved by the 2026-08-30 autonomous implementation request

## Reader and maintainer problem

The folding case shows how one recursive list traversal consumes a finite
structure. The next reader question reverses that direction: how can a changing
state produce a finite recursive list, and what makes that production safe to
run under eager evaluation?

The case must make the transition work and additional constructed list visible
without changing the ordinary `unfold` type to serve instrumentation. It must
also distinguish a termination argument supplied by one producer from a
termination guarantee supplied by Ash or by `unfold`; neither Ash's type system
nor this generic function proves that an arbitrary transition reaches `Stop`.

## Authority and version boundary

Every executable observation targets Modular Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Language claims come from the
[specification at that commit](https://github.com/dikini/ash-lang/tree/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec).
Commands, output, diagnostics, and exit statuses come from the
[pinned tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
and executable.

The published ash-doc `modular-ash` tag remains immutable. This case is
unpublished work on `main`; it neither retargets the edition nor tests current
`ash-lang/main`.

The existing research records for *How to Design Programs* and *Functional
Programming with Bananas, Lenses, Envelopes and Barbed Wire* already cover the
structural termination method, the fold/unfold distinction, licenses, and
Ash-specific exclusions. The case uses original prose and programs and adds no
new source tradition.

## Approaches considered

### Put observation counts inside `Step`

One approach would make each transition return its own count together with
`Stop` or `Emit`. The successful examples could then expose work without a
second recursive function. The instrumentation would become part of the state
protocol, however, and the ordinary type
`(S -> Step<S, A>) -> S -> List<A>` would no longer express the reader's main
idea directly.

### Infer work only from source and final values

A smaller implementation could define only `unfold`, run one produced list,
and derive every work statement from its equations. That would show the value
but would leave the roadmap's counted-step and additional-list observations
without direct executable results.

### Instrument only the new transition boundary

The selected approach defines ordinary `unfold` and an instrumented
`unfold_counted` with the same transition protocol. The following observation
uses ordinary `map` and returns both lists. The preceding fold case already
establishes that `map` constructs one output `More` per input element, so this
case needs no second map-specific instrumentation API. The counted unfold
repeats one small traversal for evidence while keeping counting out of the
ordinary API.

Deferring the choice would either weaken the selected observable outcome or
make the first program teach an instrumentation-shaped abstraction. The
lesson-local counted variants are the smallest replaceable mechanism that
preserves the ordinary function and satisfies the current case.

## Lesson design

Create `content/cases/building-finite-lists/` with one shared `src/lists.ash`
module and four complete entry programs. The module defines:

```text
Natural = Zero | Next(Natural)
List<A> = Empty | More(A, List<A>)
Step<S, A> = Stop | Emit(A, S)

unfold : (S -> Step<S, A>) -> S -> List<A>
unfold_counted : (S -> Step<S, A>) -> S -> (List<A>, Int)
map : (A -> B) -> List<A> -> List<B>
repeat_step : Int -> Natural -> Step<Natural, Int>
```

`unfold` applies the transition once to the current state. `Stop` becomes
`Empty`. `Emit(value, next_state)` recursively produces the rest, then
constructs `More(value, produced_rest)`. `unfold_counted` mirrors those forms
and counts every transition application, including the one that returns
`Stop`. Ordinary `map` retains the definition and constructed-node account
introduced by the preceding case.

`repeat_step` gives every accepted entry one visible termination argument:
`Zero` returns `Stop`, while `Next(rest)` emits the repeated integer and uses
the direct `rest` field as the next state. A seed with three `Next` forms
therefore produces three elements after four transition applications.

The entries establish these observations:

1. ordinary `unfold` produces three `42` values;
2. `unfold_counted` produces the same list and reports four transition
   applications;
3. a strict binding obtains the complete counted production before
   `map` constructs a separate three-node list of `43` values, with both lists
   retained in the observation; and
4. a Boolean seed is rejected after `repeat_step 42` fixes the state type as
   `Natural`.

The chapter begins from the consume/produce contrast established by the fold
case, derives the three `Step` roles from the examples, and links its checking
and evaluation conclusions to the pinned static and dynamic semantics. It ends
with practice over a different structurally decreasing `Natural` transition
and opens the accumulator question selected after this case.

## Termination, evaluation, and cost boundaries

The structural termination argument belongs to `repeat_step`, not to generic
`unfold`. Each recursive call follows the `rest` field of one `Next`, and
`Zero` stops. The chapter will explain that a transition which returns an equal
or growing state may never reach `Stop`; it will not run such a program.

Pinned Ash evaluates a binding initializer before the block remainder and
evaluates constructor arguments before allocating the payload constructor.
The source will bind each recursively produced rest before constructing its
outer `More`, and the map entry will bind the complete produced list before
calling `map`. These relationships establish eager complete production
and the additional mapped representation without claiming host stack behavior,
elapsed time, exact heap bytes, or compiler optimization.

For the terminating examples, a seed with `n` `Next` forms causes `n + 1`
transition applications, constructs `n` produced `More` values, and the
following map constructs another `n` `More` values. These are source-level
counts. They do not generalize to transitions or transforms that fail to
return.

## Verification and removal conditions

The case reuses the existing content helper and Cases aggregator. Its local
verifier will check five canonical source blocks, three exact successful
observations, the rejected seed's stable reason and causal source location,
and the source relationships that support the transition, recursion,
termination, eager binding, and constructed-node claims.

Completion requires both content-family aggregators to pass at the exact pin,
Markdown and relative-link checks to pass, attribution and exclusions to remain
accurate, the Cases index to list the verified chapter, and the roadmap to mark
finite-list unfold verified and promote accumulating list results to **next**.
The bounded design and implementation plan then leave the current tree; Git
history retains them.

Reconsider the instrumented mirror if a later case needs a different work
observation that it cannot express directly, or if a future publication design
selects a different evidence mechanism. Do not promote it into a shared Ash
library from this one case.
