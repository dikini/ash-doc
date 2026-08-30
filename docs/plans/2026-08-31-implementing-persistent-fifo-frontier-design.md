# Implementing a persistent FIFO frontier design

Status: approved on 2026-08-31 after independent specification and
instructional/workflow review

## Reader question and observable boundary

**Question:** How can two lists preserve queue order while avoiding a full
rebuild on every operation?

Case 10 makes unfinished traversal explicit as a LIFO frame stack. A search
frontier sometimes needs the other end: the earliest item added must be the
first item removed. Keeping that order in one forward list makes enqueue
traverse and reconstruct the list's existing prefix.

The crossed boundary is one representation rebuilt on every enqueue versus
two persistent lists that defer one reversal until the front is empty. The
same boundary separates constant amortized source work along one linear chain
that begins at `empty` from repeated reversal work when an older state is
retained and resumed through several futures.

## Sequence and outcome

The reader already knows:

- recursive `List<A>` equations and structural traversal;
- append rebuilding and accumulator-based reversal from case 3;
- persistent older values from the dictionary cases;
- opaque construction boundaries from cases 8--10; and
- the difference between one worst-case eager step and one linear-history
  amortized account from case 10.

The case adds one idea: a queue can keep the directly removable prefix in
front order and newly enqueued elements in reverse rear order. A reader
completes the case able to:

- derive the queue's logical order from its two lists;
- predict when `dequeue` follows the front and when it reverses the rear;
- explain why the operation sequence returns FIFO order;
- count enqueue, ordinary dequeue, and transfer list-node work; and
- state why constant amortized work applies to one linear state history that
  begins at `empty` but not to arbitrary branching from retained queues.

The case belongs at
`content/cases/implementing-persistent-fifo-frontier/`. Its prose, three
complete canonical source files, accepted observations, and checks land
together only after this design and its implementation plan are approved.

## Authority and target

The exact Ash target remains the published Modular Ash checkpoint:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

The ash-doc `modular-ash` tag remains immutable at
`e963a1597176f86003926eef827498db2a661b75`. The new case remains unpublished
work on `main` and does not retarget the edition.

Language claims are limited to the pinned:

- [specification
  overview](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/README.md)
  for pure modules, strict nominal data, rank-1 globals, and opacity;
- [syntax
  grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  for parameterized nominal declarations, curried equations, blocks, and
  matches;
- [type and constructor
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#type-and-constructor-scope),
  [opaque declarations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations),
  and [global scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#global-scope);
- [constructor and tuple
  typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors),
  [function and application
  typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application),
  [pattern and coverage
  typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage),
  and [global checking](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules);
- dynamic [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  [constructors and matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches),
  and [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation).

Invocation, exact output, channels, and statuses come from the pinned
[`ash` tool
guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md).
The cases teach project-level representations and source work; they cannot add
Ash semantics.

## Approaches considered

### Keep one forward list and append on enqueue

A one-list queue puts the next element at the head. `dequeue` can then remove
that head directly, but `enqueue` must append at the far end. For a queue of
length `n`, the append equations visit and reconstruct the `n` existing list
nodes before adding one element. Repeating enqueue on a growing queue repeats
that rebuild.

This approach has the simplest state but does not answer the reader's
question. Case 3 already established the append reconstruction mechanism; the
new case should change the representation instead of re-teaching it as the
solution.

### Keep front and reverse-rear lists

The selected representation is one public opaque queue over two private list
positions:

```text
Queue<A> = Queue(List<A>, List<A>)
```

The first list is in dequeue order. The second records new elements in reverse
enqueue order. Enqueue adds one node to the rear. Dequeue follows a nonempty
front directly; only an empty front with a nonempty rear reverses the rear and
continues from the resulting front.

This is the smallest eager representation that makes the deferred work and
the persistent branching caveat visible. It requires no library, manifest,
renderer, generic collection API, or search code.

### Normalize at operation boundaries or schedule the reversal

A stronger eager paired-list variant runs a smart constructor after enqueue
and dequeue. It reverses the rear only when an operation would otherwise leave
an empty front, maintaining a nonempty front for every nonempty public queue.
It has the same amortized order and the same persistent branching limitation.
The selected 1995 transfer-on-dequeue variant instead uses fewer equations and
makes its empty-front, nonempty-rear pre-transfer state directly observable.

A lazy or scheduled rotation could distribute the transfer and strengthen the
worst-case bound, but pinned Ash provides no selected lazy-list or memoization
mechanism. An explicit real-time schedule would add a different representation
and proof obligation.

Both alternatives are rejected for this increment. Deferring the
representation choice would leave case 12 without the verified eager FIFO
frontier it requires.

## Selected public and private boundary

The dependency module declares transparent support types because the pinned
edition has no selected standard collection module:

```text
Option<A> = None | Some(A)
List<A> = End | More(A, List<A>)
```

It exposes exactly this queue API:

```text
pub opaque type Queue<A> = Queue(List<A>, List<A>)
pub empty : Unit -> Queue<A>
pub enqueue : A -> Queue<A> -> Queue<A>
pub dequeue : Queue<A> -> Option<(A, Queue<A>)>
```

`Queue` is opaque so clients can name and retain queue values without
constructing alternate front/rear pairs. The reader already tested value and
pattern opacity in cases 8 and 10, so this case does not repeat those rejected
programs. The verifier still fixes the declaration and public operation set.
Opacity does not prove that the operation equations preserve the logical
sequence, make a defining-module spine finite, or hide constructor spellings
from structural tool output.

The public support constructors let a client match the `dequeue` result and
collect observations as a complete list. They do not make the queue
constructor accessible. No shared library is established; case 12 may copy or
adapt the verified module inside its own evidence boundary only after its
bounded design selects that use.

## Representation relationship and operation equations

For `Queue(front, rear)`, the logical FIFO sequence is:

```text
front followed by reverse(rear)
```

There is no stronger nonempty-front invariant in the selected variant. Every
finite pair of lists denotes a queue through this relationship, including an
empty front with a nonempty rear. The public operations preserve that meaning;
they do not promise one normalized structural shape for each logical sequence.

This relationship admits four useful states:

- `Queue(End, End)` is empty;
- a nonempty front exposes the next element directly;
- an empty front with a nonempty rear is a valid pre-transfer state; and
- after a transfer, the new front is the reversed rear and the new rear is
  `End`.

`empty` constructs the first state. `enqueue value Queue(front, rear)` returns
`Queue(front, More(value, rear))`. Reversing the new rear yields the old
logical rear followed by `value`, so enqueue adds at the logical end without
traversing either list.

A private accumulator helper follows these conceptual equations:

```text
reverse_into End reversed = reversed
reverse_into More(first, rest) reversed =
    reverse_into rest More(first, reversed)
```

This is design pseudocode; the implementation plan owns exact accepted Ash
source. Its invariant is that `reversed` is the reversal of the already
entered prefix placed before the original accumulator. At `End`, the complete
input has moved into reverse order.

`dequeue` distinguishes exactly three cases:

1. empty front and rear produce `None`;
2. `More(first, rest)` at the front produces
   `Some((first, Queue(rest, rear)))`; and
3. empty front and nonempty rear eagerly reverse the complete rear into a new
   front, reset the rear to `End`, and then apply `dequeue` to that state.

The third case completes its reversal before returning. No suspension,
memoization, mutation, runtime queue service, or hidden lazy scheduling is
involved.

## Executable evidence

The bounded case owns exactly three canonical files:

```text
content/cases/implementing-persistent-fifo-frontier/src/queues.ash
content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash
content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash
```

`queues.ash` contains the complete support types, opaque queue, operations,
and private reverse helper. It has no `main` because the other two files are
complete entry modules that import it.

The sequence entry creates an empty queue, observes empty dequeue, enqueues
`1`, `2`, and `3`, and retains that pre-transfer state. Its first successful
dequeue reverses exactly one rear list. The result simultaneously exposes:

- `None` for the empty queue;
- the pre-transfer state with `End` at the front and `3, 2, 1` at the rear;
- returned value `1`;
- the successor with `2, 3` at the front and an empty rear; and
- draining that successor as `2, 3` without another rear reversal.

The exact pinned observation is:

<!-- markdownlint-disable MD013 -->
```text
(None, Queue(End, More(3, More(2, More(1, End)))), 1, Queue(More(2, More(3, End)), End), More(2, More(3, End))) : (Option<(Int, Queue<Int>)>, Queue<Int>, Int, Queue<Int>, List<Int>)
```
<!-- markdownlint-enable MD013 -->

The retained-state entry constructs the same pre-transfer queue and calls
`dequeue` from that exact binding twice. Its pinned observation is:

<!-- markdownlint-disable MD013 -->
```text
(Some(1, Queue(More(2, More(3, End)), End)), Some(1, Queue(More(2, More(3, End)), End))) : (Option<(Int, Queue<Int>)>, Option<(Int, Queue<Int>)>)
```
<!-- markdownlint-enable MD013 -->

Both outputs are exact prototype observations at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`, not predictions. Structural output
can render the opaque constructor; it grants no source access.

The verifier must also assert causal source relationships that output alone
cannot prove: the exact three-file set; logical front/rear field positions;
one rear-node construction in `enqueue`; the two reverse equations and
accumulator relationship; all three dequeue cases; resetting the rear before
the recursive dequeue; the empty observation; enqueue order; one sequence
transfer; FIFO drain; and exactly two calls from the same retained binding.

Fixed prototype hashes are:

```text
9db0dde1fd8776556ea4f4bad51aacb09fd00a7ed769cf8e457ea20795cfe7bd  queues.ash
38edc257a6e1859b96b40f523ac57199eff14aaa6bccf13176289e4b18dcfc61  01-sequence.ash
6a0981eb6dd63c2cc540983a69bc5e058db0018f670645610d518e8e6ab99d51  02-retained-state.ash
```

## Work, construction, and retained state

The case counts a **list-node unit** whenever an equation selects a `More`
node or a source expression constructs one. It separately names helper and
queue-result constructions so different costs do not collapse into a runtime
allocation claim.

One `enqueue` selects one `Queue`, constructs one rear `More`, and constructs
one successor `Queue`. It does not traverse the front or the existing rear.
Its list-node work is therefore one construction.

An ordinary successful `dequeue` selects one front `More`, reuses its `rest`
and the existing rear in one successor `Queue`, and constructs one `Some` with
one tuple payload. It constructs no list node. Its list-node work is one front
selection.

If the front is empty and the rear has `m > 0` nodes, `reverse_into` performs
`m + 1` helper applications including the terminal `End` case. It selects
exactly `m` rear `More` nodes and constructs exactly `m` new front `More`
nodes. The following recursive `dequeue` selects the first new front node.
That one operation therefore performs `2m + 1` list-node units under the named
metric and can be linear in the rear length. It is not a worst-case constant
operation.

Now consider one finite linear history that begins at `empty` and in which
each operation consumes only the state returned by the preceding operation.
Across `e` enqueues and `d` successful dequeues:

- the enqueues construct exactly `e` rear `More` nodes;
- each such rear node can be selected by a transfer at most once, because the
  successor resets that rear to `End`;
- each transfer selection constructs exactly one corresponding front `More`,
  so there are at most `e` of each transfer unit; and
- each successful dequeue selects exactly one front `More`, so there are
  exactly `d` front-selection units.

Total list-node work is therefore at most `3e + d`: one rear construction,
at most one rear selection and one front construction per enqueue, and one
front selection per successful dequeue. This is linear in the number of
operations and gives amortized constant list-node work per operation along
that one history. Empty dequeues add no `More` work. The bound does not make
any individual transfer constant.

The retained-state entry deliberately leaves that history. Both calls consume
the same queue whose front is empty and whose rear has three nodes. Each call
performs its own three rear selections, three front constructions, and first
front selection. Generalizing to `b` calls from one retained state repeats
that transfer `b` times. Credits assigned along one successor chain cannot pay
for arbitrary additional futures, so the case makes no global amortized claim
over a branching version graph.

The old queue remains a usable source value after each operation. `enqueue`
passes the old front unchanged and places the old rear under one new `More`.
An ordinary `dequeue` passes the old front tail and rear unchanged. A transfer
constructs a new front while an older state can still retain the old rear.
These are source relationships. They do not prove pointer identity, physical
sharing, allocation counts, heap reachability after collection, or copying
behavior in the implementation.

## Finite, cycle, payload, and observation boundaries

The return and work claims apply to queue spines produced by finite sequences
of `empty`, `enqueue`, and returned successor queues. Those public operations
construct finite acyclic queue-list spines. A cyclic element payload may be
enqueued and returned without traversal because the queue equations inspect
only list and queue constructors.

The defining module can still construct a queue with a cyclic front or rear.
A nonempty cyclic front can yield elements indefinitely across returned
states; reversing a cyclic rear need not return. Opacity restricts client
constructor access but does not make every value the defining module could
form finite or make every operation return.

Successful structural observation may show `Queue`, `More`, and `End` even
though `Queue` is opaque to client source. Active-path cycles render according
to the pinned observation rules. Rendering does not prove the logical-order
relationship or grant constructor access.

The source counts establish no elapsed-time, machine-instruction,
native-stack, heap-byte, pointer-identity, garbage-collection, runtime
allocation, or compiler-optimization property. Tail-position source calls do
not establish host tail-call optimization or bounded host stack use.

## Teaching shape

The chapter continues case 10's LIFO/FIFO question rather than repeating tool
setup or opacity lessons:

1. recall why appending to one forward list rebuilds its prefix;
2. split logical order into a front and reversed rear;
3. state the representation relationship before showing operations;
4. derive `empty` and one-node rear `enqueue` from that relationship;
5. derive the three `dequeue` cases and accumulator reversal;
6. predict empty dequeue and the `1, 2, 3` pre-transfer state;
7. run the sequence and explain the one eager reversal and FIFO result;
8. count ordinary and transfer work, then derive the linear-history bound;
9. retain the pre-transfer queue, predict two repeated reversals, and run the
   branching observation;
10. preserve finite, cycle, payload, persistence, source-reuse, observation,
    and runtime boundaries; and
11. end by asking how stack and queue frontiers change graph search.

Practice asks the reader to draw front and rear lists, predict a mixed
enqueue/dequeue sequence, count a transfer of `m` rear nodes, derive the
start-from-`empty` `3e + d` linear-history bound, and explain why three calls
from one retained pre-transfer state count the reversal three times.

## Source and adaptation boundary

The reviewed
[paired-list queue record](../../research/persistent-paired-list-queue.md)
selects Okasaki's 1995 account as conceptual inspiration and records the
ordinary copyright boundary. Ash-doc will cite the tradition and use original
Ash programs, names, prose, examples, work derivations, and exercises. It will
not copy or closely translate the paper's figures, pseudocode, lazy queues, or
presentation.

The existing [recursive-algorithm
record](../../research/how-to-design-programs-recursive-algorithms.md) governs
source-level cost and invariant exposition. The existing [strictness
record](../../research/functional-programming-with-bananas.md) preserves the
boundary against importing lazy behavior. The case's exact Ash behavior must
still come only from the pinned specification and tool.

## Deliberate exclusions

The case introduces no:

- lazy list, stream, thunk, memoization, scheduled rotation, or real-time
  queue;
- mutation, in-place update, destructive dequeue, or iterator invalidation;
- deque, concatenation, random access, length cache, priority ordering, or
  generic collection abstraction;
- graph, search, path, visited set, frontier-size measure, DFS, or BFS source;
- worst-case constant dequeue claim;
- amortized bound over arbitrary branching reuse of retained queues;
- claim that opacity proves internal preservation or runtime secrecy;
- totality claim for cyclic defining-module queue spines; or
- elapsed-time, machine-instruction, host-stack, heap-byte, pointer-identity,
  physical-sharing, garbage-collection, or compiler-optimization claim.

Case 12 remains provisional until this case verifies and closes. This design
authorizes no graph-search source, directory, prose, or tooling.

## Verification and completion

The implementation plan must use verifier-first evidence and name exact
outputs, source hashes, mutation-sensitivity checks, and review order. Those
checks may alter disposable copies only; they make no source-language mutation
claim. The complete case must pass:

- its lesson-local Bash verifier at the exact pin;
- both exact success outputs, channels, types, and status;
- complete displayed-source agreement for all three sources;
- source assertions for the representation, operations, one-transfer
  sequence, FIFO result, work account, and retained-state replay;
- Bash syntax and ShellCheck;
- Markdown structure, spelling when available, and relative links;
- all Learn and Cases aggregators;
- focused pinned list, opacity, strictness, and observation tests selected by
  the implementation plan;
- independent specification and instructional reviews;
- `git diff --check`; and
- exact ash-doc tag and Ash pin checks with clean worktrees.

The verifier mutation matrix must prove sensitivity to at least: swapping
front and rear; appending instead of rear-prepending; omitting the terminal
reverse equation; constructing from `rest` instead of the original current
node; failing to reset the rear; returning the newest rather than oldest
element; removing empty-dequeue evidence; changing enqueue order; hiding the
pre- or post-transfer state; changing FIFO drain order; and replacing either
retained-state call with a call from its successor.

Closure updates root and Cases navigation, replaces the active roadmap gate
with a durable verified summary, promotes only case 12 to its bounded design
gate, removes the temporary Case 11 design and implementation plan, and merges
a reviewed clean branch locally without pushing. The permanent research
record remains as source and rights evidence.
