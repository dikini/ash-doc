# *Functional Programming with Bananas, Lenses, Envelopes and Barbed Wire*

## Question

What can ash-doc retain from the paper's treatment of recursion operators when
the target Ash edition is strict, rank-1, and limited to finite executable
examples?

## Source consulted

Erik Meijer, Maarten M. Fokkinga, and Ross Paterson, [*Functional Programming
with Bananas, Lenses, Envelopes and Barbed
Wire*](https://ir.cwi.nl/pub/1999), in *Functional Programming Languages and
Computer Architecture*, Lecture Notes in Computer Science 523, Springer, 1991,
pages 124–144. The consulted record and final paper identify a calculus for
lazy functional programming based on recursion operators associated with data
type definitions.

## Contribution to ash-doc

The useful idea is to name a recurring traversal separately from the operations
that vary among algorithms. A fold consumes recursive structure by replacing
each data form with a supplied operation. An unfold produces recursive
structure from a supplied state transition. Naming those two directions lets a
reader compare `sum`, `length`, `map`, and `filter` as different uses of one
list traversal, then ask the dual question about finite production.

That separation can transfer without the paper's notation. The first case
defines an ordinary Ash function:

```text
fold : (A -> B -> B) -> B -> List<A> -> B
```

Its two equations mirror `Empty` and `More`. Later work can introduce an
ordinary finite `unfold` from a structurally decreasing state. Each case can
explain the concrete source equations before giving the broader operation a
name.

## Adaptation classification and license

This is **conceptual inspiration**. The paper is a Springer conference
publication, and the consulted CWI and author records provide access to the
final text but state no open-content license for adaptation or redistribution.
Ash-doc therefore assumes ordinary copyright restrictions: it will cite and
summarize the contribution, but will not copy the paper's prose, notation,
figures, derivations, or examples.

All Ash programs and explanations will be original. A later desire to adapt a
substantial expression of the work would require a separate rights review; the
availability of a PDF is not treated as permission.

## Ash-specific departures

The paper develops its calculus for lazy functional programming. Pinned Modular
Ash instead evaluates function arguments strictly. For the case's right fold,
the recursive fold of `rest` becomes a value before the second combiner
application enters its body. Even a combiner that returns the current first
element therefore cannot prevent traversal of the complete finite list.

Ash also has rank-1 polymorphism. The path uses concrete ordinary functions
whose types the pinned checker accepts. It does not use a rank-2 `build`
encoding. The later dictionary operation named `build` folds a finite list
through `insert`; it does not denote the producer abstraction used by lazy
fold/build fusion.

## Deliberate exclusions

The path excludes:

- lazy evaluation, thunks, and infinite data;
- complete partial orders and the paper's domain-theoretic results;
- banana, lens, envelope, and barbed-wire morphology notation;
- fusion, cancellation, and promotion laws stated without their prerequisites;
- claims that a source-level fold forces a particular host stack or heap
  implementation; and
- a generic fold/build API.

The paper remains evidence for separating traversal from supplied operations.
It does not define Ash behavior or authorize a language mechanism.
