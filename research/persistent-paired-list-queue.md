# Eager paired-list queues under persistence

## Question

Which queue tradition can support an ash-doc case about FIFO order and
source-level amortized work when pinned Ash is eager and queue versions remain
available after an operation?

The observable boundary is a queue operation sequence that uses only each
operation's successor versus a branching history that resumes an older queue.
This record selects an algorithmic source and adaptation boundary. It neither
specifies an Ash representation nor establishes executable Ash behavior.

## Selected source

The selected source is Chris Okasaki,
[*Simple and efficient purely functional queues and
deques*](https://doi.org/10.1017/S0956796800001489), *Journal of Functional
Programming* 5(4), October 1995, pages 583--592. The
[publisher record](https://www.cambridge.org/core/journals/journal-of-functional-programming/article/simple-and-efficient-purely-functional-queues-and-deques/7B3036772616B39E87BF7FBD119015AB)
identifies the author, issue, pages, and DOI. The
[publisher PDF](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/7B3036772616B39E87BF7FBD119015AB/S0956796800001489a.pdf/simple-and-efficient-purely-functional-queues-and-deques.pdf)
was the material consulted.

Section 2 reviews the standard paired-list queue. One list contains the front
in removal order. The other contains the rear in reverse insertion order. A
new element can enter at the head of the rear list. When removal finds an
empty front and a nonempty rear, reversing the rear makes the oldest element
the new front. The paper credits the paired-list technique's earlier lineage
to Hood and Melville, Gries, and Burton; ash-doc does not claim the technique
as Okasaki's invention.

The paper gives two boundaries that are essential to the case. Along
one sequence counted from an empty queue, a rear list of length `m` is reversed
only after the operations that put those `m` elements there, so the occasional
linear reversal has constant amortized cost. One reversal can still make an
individual operation linear. When earlier queue versions may be accessed,
repeatedly removing from the same pre-reversal version can trigger that same
reversal repeatedly. The ordinary eager paired-list account therefore does
not give a constant amortized bound over an arbitrary persistent version graph.

The remainder of the paper develops lazy incremental queues with stronger
worst-case behavior. That mechanism is evidence for the selected boundary,
not part of the eager Ash case.

## Corroborating analysis

Okasaki's 1996 Carnegie Mellon University dissertation, *Purely Functional
Data Structures*, chapter 3, "Amortization and Persistence via Lazy
Evaluation," gives a stronger paired-list variant whose smart constructor
normalizes operation results so a nonempty queue has a nonempty front. It then
shows where traditional amortized analysis breaks under persistent branching.
The [author's dissertation
record](https://www.cs.cmu.edu/~rwh/students/okasaki.pdf) is consulted only for
that amortization and persistence analysis, not as the implementation source
for the selected 1995 transfer-on-dequeue variant.

The dissertation distinguishes a single logical history from multiple logical
futures. That vocabulary sharpens the case's limit: the eager implementation
may be analyzed along one linear chain counted from `empty`, while work
repeated by calling an operation again on an older state must be counted
again. The case uses its own plain-language account rather than
copying the dissertation's formal framework.

## Alternatives considered

### One forward list

A queue can keep its complete logical order in one list. Removing the first
element then follows the first constructor, but adding to the far end must
traverse and reconstruct the preceding list. Reversing that representation
trades which operation pays the linear rebuild; it does not avoid it.

This is a useful comparison because readers already know append and
accumulator reversal. It is not selected as the queue representation because
it rebuilds a growing path on every operation of one kind.

### Lazy or scheduled rotation

Okasaki's later construction in the selected paper uses lazy lists and
incremental work to improve individual-operation bounds. It is a credible
queue design in a language with the required lazy and memoizing behavior.
Pinned Diag Ash instead evaluates ordinary applications and constructors
eagerly and supplies no selected lazy-list mechanism.

The case does not translate that construction, encode
thunks, or imply memoization. A stricter worst-case queue would be a different
case with a different representation and proof burden.

## Adaptation classification and rights boundary

The paired-list idea and persistence warning are **conceptual inspiration**,
not direct adaptation. The publisher record identifies Cambridge University
Press publication and does not identify an open-content adaptation license.
Public access to the article and dissertation is not treated as permission to
translate or redistribute their expression.

Ash-doc will cite the tradition and write original Ash names, programs,
operation sequences, work counts, prose, tests, and exercises. It will not
copy the paper's figures, pseudocode, examples, proof presentation, or lazy
implementations. A later direct or close adaptation would require a new
rights review and an updated classification.

## Contribution to case 11

The selected source can support an original case with these claims:

- logical queue order is the front list followed by the reversal of the rear
  list;
- insertion adds one rear node without traversing the front;
- removal uses the front directly when possible and reverses a nonempty rear
  only when the front is empty;
- one such reversal visits and reconstructs every rear node and can make an
  individual eager removal linear;
- each rear node transfers at most once along one linear chain of successor
  states counted from `empty`, which supports constant amortized source work;
  and
- resuming a retained pre-transfer state can perform the same transfer again,
  so no such bound covers arbitrary branching reuse.

The exact Ash work account remains case-specific. It must name constructor
applications, pattern-selected nodes, helper applications, and the operation
sequence that causes them. It must not turn the paper's time model into an Ash
runtime contract.

## Ash-specific departures

The queue uses complete strict nominal lists, an opaque nominal
queue, exhaustive equations, and an `Option` result instead of an exception or
partial removal. `empty` is a function from `Unit` because a pinned Ash
module contains declarations rather than an evaluated module value.

Every language claim must come from the
[pinned specification](https://github.com/dikini/ash-lang/tree/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec),
and every command observation must follow the pinned
[`ash` tool
guide](https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/docs/tools/ash.md).
The target is `diag-ash` at
`57eec5bbadae885e49c323e0a05e7a01b9ce8a36`. Neither the selected sources nor
current `ash-lang/main` can add behavior to that edition.

## Deliberate exclusions

The source relationship excludes:

- lazy lists, memoization, scheduling, streams, thunks, and real-time queues;
- double-ended queues and concatenation;
- a global amortized bound across arbitrary persistent branching;
- infinite or cyclic queue-spine return claims;
- elapsed time, machine instructions, native-stack depth, heap bytes, pointer
  identity, physical sharing, garbage collection, or compiler optimization;
- a claim that opacity proves a representation invariant; and
- copied figures, programs, proofs, exercises, or teaching order.

This record owns source attribution, adaptation boundaries, and excluded
claims. The canonical programs and checks in the corresponding Case establish
its behavior at the repository baseline.
