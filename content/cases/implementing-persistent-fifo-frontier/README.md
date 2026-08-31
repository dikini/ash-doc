# How can two lists preserve queue order?

An unfinished computation can retain work in a list of frames. If each new
frame is added at the front and the next step removes from that front, the
newest retained work leaves first: last-in, first-out order. The
[historical iterator case](https://github.com/dikini/ash-doc/blob/fa870a280c76278361db658ff3952cf18f2b7833/content/cases/resuming-tree-traversal/README.md)
developed that stack model, but it is
[unavailable at this target](../../../lab/lib-ash-migration/body-free-summary-authentication/README.md#tree-iterator).
This chapter needs only the front-add, front-remove relationship. A traversal
that needs the earliest retained item first instead needs first-in, first-out
order: a queue rather than a stack.

One forward list can put its next item at the front, but adding at the logical
end must append. The [accumulator case](../accumulating-list-results/README.md)
showed why append enters the existing list and reconstructs its prefix. A queue
that repeatedly appends to a growing list repeatedly pays for that rebuild.
Change the representation instead.

## Split removal order from insertion order

Keep one list in removal order and a second list in reverse insertion order.
We will use `++` below as mathematical sequence concatenation, not as Ash
syntax.

`Queue(front, rear)` denotes `front ++ reverse(rear)`.

The first element of `front` is therefore the next value to remove. Prepending
a new value to `rear` places it last after that list is reversed. Starting from
empty, three enqueues can produce:

```text
front = End
rear  = More(3, More(2, More(1, End)))

logical order = 1, 2, 3
```

Every finite pair has a logical meaning under this relationship. The front may
already contain removable values, or all values may still be stored in the
rear.

The front may be empty while the rear is nonempty.

This selected eager variant does not maintain the stronger rule that every
nonempty queue has a nonempty front. It transfers the rear only when a removal
needs it. The paired-list tradition and the limit imposed by persistent
branching are recorded in the [source
research](../../../research/persistent-paired-list-queue.md). That record
selects Okasaki's 1995 discussion, including its account of earlier lineage,
as conceptual inspiration. The Ash code, example, derivation, prose, and
exercises here are original; this chapter does not adapt the paper's figures,
pseudocode, lazy designs, or proof presentation.

## Derive the queue equations

The defining module makes `Option<A>` and `List<A>` transparent so clients can
match their constructors. It makes `Queue<A>` opaque: clients can name, retain,
and pass queues, but cannot construct or match `Queue` directly. These are the
pinned rules for [public transparent and opaque
declarations](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/name-resolution.md#public-private-and-opaque-declarations).
The three public queue operations are `empty`, `enqueue`, and `dequeue`.
`reverse_into` remains private.

`empty` follows directly from the representation relationship:
`Queue(End, End)` denotes the empty sequence. For enqueue,
`More(value, rear)` reverses to the old logical rear followed by `value`.
`Queue(front, More(value, rear))` therefore adds at the logical end without
entering either existing list.

The private helper reverses through an accumulator. Suppose its original input
is divided into an entered prefix and an unentered remainder. At every call,
the accumulator is the reversal of that prefix followed by the original
accumulator. Entering `More(first, rest)` constructs
`More(first, reversed)` and continues with `rest`. At `End`, the whole original
input has moved into reverse order before the original accumulator.

That gives three removal equations in source order:

1. An empty front and rear produce `None`.
2. A front `More(first, rest)` produces `first` and a queue containing `rest`
   with the unchanged rear.
3. After the first equation has ruled out a completely empty queue, an empty
   front means the rear is the complete logical sequence in reverse. Reverse
   it, clear the rear, and remove from the resulting front.

Ash checks constructor patterns and complete equation coverage under its
pinned [pattern, match, and coverage
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#patterns-matches-and-coverage).
At evaluation, equations use the same source-order selection as pinned
[constructor matching](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#tuples-constructors-and-matches).

Here is the complete dependency module:

<!-- source: src/queues.ash -->
```ash
pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

pub opaque type Queue<A> =
    Queue(List<A>, List<A>)

pub empty : Unit -> Queue<A>
empty () = Queue(End, End)

pub enqueue : A -> Queue<A> -> Queue<A>
enqueue value Queue(front, rear) = Queue(front, More(value, rear))

reverse_into : List<A> -> List<A> -> List<A>
reverse_into End reversed = reversed
reverse_into More(first, rest) reversed = {
    reverse_into rest (More(first, reversed))
}

pub dequeue : Queue<A> -> Option<(A, Queue<A>)>
dequeue Queue(End, End) = None
dequeue Queue(More(first, rest), rear) = {
    Some((first, Queue(rest, rear)))
}
dequeue Queue(End, rear) = {
    let front = reverse_into rear End
    dequeue (Queue(front, End))
}
```

This module has no `main`; the two entries below import it. Its signatures use
the pinned [rank-1 global
model](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#globals-and-modules),
in which each free type parameter is instantiated at a use, and its payload
constructors have ordinary function types under the static [tuple and constructor
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#tuples-and-constructors).

In the transfer equation, the initializer of `front` completes before the
following block result under the dynamic [binding
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#bindings).
The following `dequeue` call then evaluates its queue argument before entering
the function under strict [application
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#application).

The transfer is eager and complete before `dequeue` returns.

There is no suspended reversal, memoized result, or mutable queue service in
this source.

## Predict one transfer

The first entry imports the transparent support constructors and the three
queue operations through the qualified `Queues` namespace, following the
pinned [import and namespace
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/name-resolution.md#imports-and-namespaces).
Its `drain` function repeatedly uses only the successor returned by
`dequeue`.

Before running it, follow the representation:

1. Removing from `empty_queue` produces `None`.
2. Enqueuing `1`, then `2`, then `3` keeps the front at `End` and stores
   `3, 2, 1` in the rear.
3. Removing from that retained `ready` state reverses the rear, returns `1`,
   and leaves `2, 3` in the front with an empty rear.
4. Draining that returned `later` state produces `2, 3` without another rear
   transfer.

<!-- source: src/01-sequence.ash -->
```ash
import queues as Queues

drain : Queues.Queue<A> -> Queues.List<A>
drain queue = match Queues.dequeue queue {
    Queues.None => Queues.End
    Queues.Some((first, later)) => Queues.More(first, drain later)
}

main : Unit -> (
    Queues.Option<(Int, Queues.Queue<Int>)>,
    Queues.Queue<Int>,
    Int,
    Queues.Queue<Int>,
    Queues.List<Int>
)
main () = {
    let empty_queue = Queues.empty ()
    let ready = Queues.enqueue 3 (
        Queues.enqueue 2 (
            Queues.enqueue 1 empty_queue
        )
    )
    let empty_result = Queues.dequeue empty_queue
    match Queues.dequeue ready {
        Queues.None => (empty_result, ready, 0, ready, Queues.End)
        Queues.Some((first, later)) => (
            empty_result,
            ready,
            first,
            later,
            drain later
        )
    }
}
```

Run the entry from the Cases directory:

```text
ash implementing-persistent-fifo-frontier/src/01-sequence.ash
```

<!-- markdownlint-disable MD013 -->
```text
(None, Queue(End, More(3, More(2, More(1, End)))), 1, Queue(More(2, More(3, End)), End), More(2, More(3, End))) : (Option<(Int, Queue<Int>)>, Queue<Int>, Int, Queue<Int>, List<Int>)
```
<!-- markdownlint-enable MD013 -->

The five result fields confirm the prediction in order: empty removal,
pre-transfer state, oldest value, returned successor, and FIFO drain. Success
uses one standard-output line and status `0` under the pinned [`ash`
contract](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md#successful-output).

The line spells `Queue`, `More`, and `End` because successful
[observation](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#observation)
renders nominal data structurally. Opacity restricts constructor access in
client source; it neither conceals structural output nor proves that the queue
equations preserve the logical sequence.

## Count the named list work

We need a metric narrow enough to derive from the equations.

One list-node unit is one selected or constructed `More`.

Queue, `Some`, and tuple constructions are separate source operations and are
not included in this metric. An empty removal selects no `More`. Enqueue
constructs exactly one rear `More` and enters neither existing list. An
ordinary successful removal selects one front `More`, reuses `rest` and the
rear, and constructs no list node.

Now let an empty-front queue have a rear of length `m > 0`. Reversal applies
once for each `More` and once more at `End`. It selects the `m` rear nodes and
constructs `m` new front nodes. The following recursive removal selects the
first new front node.

<!-- markdownlint-disable MD013 -->
`reverse_into` runs `m + 1` times, and the transfer costs `2m + 1` list-node units.
<!-- markdownlint-enable MD013 -->

One eager removal can therefore be linear in the rear length. The transfer is
not a worst-case constant operation.

For an amortized account, follow one finite linear history that starts from
`empty`: each operation uses only the queue returned by its predecessor. Let
`e` be its number of enqueues and `d` its number of successful removals.

- Enqueue constructs exactly `e` rear nodes.
- A rear node can be selected by a transfer at most once on this successor
  chain because the returned queue clears that rear.
- Each transfer selection constructs one corresponding front node, so there
  are at most `e` rear selections and `e` front constructions.
- Every successful removal selects one front node, for exactly `d` such
  selections.

<!-- markdownlint-disable MD013 -->
One linear successor history that starts from `empty` costs at most `3e + d` list-node units.
<!-- markdownlint-enable MD013 -->

Starting from `empty` makes the account complete: every rear node that can
transfer was constructed by one of the counted `e` enqueues. The counters
cannot restart at an already populated state. If they begin at the displayed
`ready`, that suffix has `e = 0` and `d = 1` but still performs the seven
list-node units of its three-node transfer. It omitted the three enqueues that
constructed those rear nodes. One retained future can use the bound with its
full empty-to-current prefix; each additional future counts its repeated
transfer in a separate full history.

The bound is linear in the operation count and gives constant amortized
list-node work per operation on that one chain. It does not make its occasional
eager transfer constant.

## Resume the same older queue twice

The `ready` binding remains in scope for both tuple elements under the pinned
[binding rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#bindings).
The second entry retains one empty-front queue with the rear `3, 2, 1`, then
uses that same binding as the argument to two calls. Predict two identical
results. Each call must independently reverse the complete rear, return `1`,
and produce a front containing `2, 3`.

<!-- source: src/02-retained-state.ash -->
```ash
import queues as Queues

main : Unit -> (
    Queues.Option<(Int, Queues.Queue<Int>)>,
    Queues.Option<(Int, Queues.Queue<Int>)>
)
main () = {
    let ready = Queues.enqueue 3 (
        Queues.enqueue 2 (
            Queues.enqueue 1 (Queues.empty ())
        )
    )
    (Queues.dequeue ready, Queues.dequeue ready)
}
```

Run the retained-state entry:

```text
ash implementing-persistent-fifo-frontier/src/02-retained-state.ash
```

<!-- markdownlint-disable MD013 -->
```text
(Some(1, Queue(More(2, More(3, End)), End)), Some(1, Queue(More(2, More(3, End)), End))) : (Option<(Int, Queue<Int>)>, Option<(Int, Queue<Int>)>)
```
<!-- markdownlint-enable MD013 -->

Both fields confirm that the older source value can produce the same
structural result twice. They do not show pointer identity, physical sharing,
allocation behavior, or memoization.

Retained branching repeats the transfer outside that linear-history bound.

More generally, `b` calls from one retained pre-transfer queue perform that
rear transfer `b` times. The accounting assigned to one successor chain cannot
pay for arbitrary additional futures in a branching history.

At source level, enqueue passes the old front unchanged and places the old rear
under one new `More`. Ordinary removal passes the old front tail and rear into
the successor. Transfer constructs a new front while the retained older state
can still refer to its rear. These relationships explain persistence without
claiming a runtime storage representation.

## Keep finite spines and runtime claims separate

Starting from `empty`, a finite sequence of enqueues and operations on returned
successors constructs finite acyclic queue-list spines. A cyclic element
payload can still be enqueued and returned because the queue equations inspect
the list and queue constructors, not the element's internal structure.

Opacity does not constrain what the defining module itself could construct.
Pinned Ash admits constructor-guarded recursive data under its static
[recursive block-group
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#recursive-block-groups)
and dynamic [recursive binding
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#recursive-bindings).
A defining module could form a cyclic front that yields values across
successors indefinitely, or a cyclic rear whose reversal does not return.
The nominal `Queue` type alone establishes neither finiteness nor totality.

Structural rendering uses `<cycle>` only for a location revisited on the
active observation path. Shared acyclic structure renders in full at each
occurrence. Neither behavior exposes runtime identity.

The metric excludes elapsed time, machine instructions, and host-stack behavior.
It also excludes heap bytes, allocation count, pointer identity, physical sharing,
garbage collection, and compiler optimization.

## Practice and continue

1. Start from empty, enqueue `1` and `2`, remove once, enqueue `3` into the
   returned queue, and remove twice more. Draw the front and rear before and
   after each operation. Predict exactly which removal transfers the rear.
2. For a queue with an empty front and a rear of length `4`, count the helper
   applications, rear selections, front constructions, and final front
   selection. Derive the named transfer total from those parts.
3. For one successor chain that starts from `empty`, with `e = 5` and `d = 4`,
   use the per-node account to derive the stated upper bound. Then restart the
   counters at the displayed `ready`: compare `e = 0`, `d = 1`, and the
   apparent bound of `1` with the transfer's `7` units. Explain which prefix
   the restarted count omitted and why the theorem does not apply to it.
4. Call `dequeue` three times from one retained pre-transfer queue with three
   rear nodes. Explain why the reversal is counted three times rather than
   once.

The [historical graph-search case](https://github.com/dikini/ash-doc/blob/fa870a280c76278361db658ff3952cf18f2b7833/content/cases/choosing-a-search-frontier/README.md)
compares this FIFO queue with a LIFO list stack while holding one search
transition fixed. That comparison is unavailable at this target because both
entries encounter the retained
[dependency-summary authentication failure](../../../lab/lib-ash-migration/body-free-summary-authentication/README.md#search-frontier).
The queue representation, equations, and cost boundary established here remain
available without that later comparison.
