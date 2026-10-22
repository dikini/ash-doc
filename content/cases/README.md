# Explore algorithms and effects in Ash

The [Learn Ash path](../learn/README.md) builds the language model needed here:
modules, functions, patterns, recursive data, higher-order functions, and
parameterized definitions. Complete its first seventeen lessons before beginning these
cases. The cases are written for intermediate and advanced readers: the
algorithm cases assume comfort with recursive data and higher-order
functions, and the later cases assume the effects path. Keep the same `ash`
executable available through the
[shared setup](../../README.md#prepare-ash).

The Cases path asks what changes when a program must do more than produce the
right value. Each chapter begins with a recursive representation, makes an
algorithmic choice visible in complete Ash programs, and then accounts for the
work and retained data caused by that choice. Later cases change the
representation when an operation or invariant demands it.

The short effect Cases then apply the
[effects path](../effects/README.md) to scoped state, replaceable dependencies,
scripted sessions, search budgets, checked byte storage, and hook pipelines.
Each isolates one
concept in a small program; its introduction names the relevant effects
prerequisites.

The application Cases continue through finite models. A batch retains its
primary outcome alongside ordered completion reports, then gives the caller an
explicit policy for interpreting them. An order calculation compares explicit
pricing functions, selected imported evidence, and locally supplied policies
whose methods retain a tariff. An immutable world joins component stores by
entity identifier, then compares direct and generic movement while preserving
the original snapshot. A journal compares cancellation with explicit
compensation, then uses saved snapshots and commit flags to restore staged
state across nested scopes. An event pipeline compares internal snapshots
with an explicit public view, then separates the public shape from the
application policy that keeps sensitive values out of it. A controller
checks a proposed batch against its own artifact and allowed positions
before returning a decision, then compares rejection with cancellation.
A sorter charges comparisons before performing them and returns either a
complete stable ordering or cancellation. An independent reference exposes
how the insertion position preserves the original order of ties. A tagged
frame pairs golden byte lists with a scoped direct decoder, keeping logical
input length separate from allocated capacity and copied messages separate
from live buffer access.

## How to work through a case

Start in this directory so the commands in each chapter match your shell:

```text
cd /path/to/ash-doc/content/cases
```

The [diagnostic reading notes](../../README.md#read-a-diagnostic) explain the
shell prompt, English output, and source-path convention used in rejection
transcripts. Run those commands from this same Cases directory.

Use the same cycle for each observation:

1. **Edit** a complete program or make a separate copy for an exercise.
2. **Predict** its value, type, and the source operations the input will cause.
3. **Run** the named entry with `ash` and inspect the complete observation.
4. **Explain** how the representation and function equations produced both the
   result and the counted work.

The checked-in programs remain the canonical observations. Restore a source
after experimenting if you want to compare it with the chapter again.

## Cost vocabulary

The cases count properties visible in the program unless a chapter explicitly
records a separate tool observation:

- **work** is a named source operation, such as a combiner call, comparison, or
  constructor application;
- **constructed representation** counts new data forms such as output `More`
  values;
- **recursive dependency depth** counts how many recursive results are waiting
  on smaller results;
- **retained state** is source-level information carried for later steps; and
- `n`, `h`, and similar names measure stated representation features, such as
  list length or tree height.

These counts support comparisons between algorithms. They do not by themselves
state elapsed time, host stack optimization, exact heap bytes, or a compiler's
storage strategy.

## Cases in order

1. [Folding recursive lists](folding-recursive-lists/README.md) — separate a list traversal
   from the operations supplied to a strict right fold.
2. [Building finite lists](building-finite-lists/README.md) — use a transition and a structural
   measure to produce a complete eager list.
3. [Accumulating list results](accumulating-list-results/README.md) — use accumulator state to
   avoid repeated append traversal while preserving the same reversed value.
4. [Representing a dictionary as a list](dictionary-as-list/README.md) — use explicit equality for selective
   lookup, contrast its work with a strict fold, and observe older dictionary
   versions retained behind new front entries.
5. [Folding branching data](folding-branching-data/README.md) — fold both branches, compare
   equal-size trees with different heights, and contrast selective search with
   whole-tree fold work.
6. [Searching an ordered tree](searching-ordered-tree/README.md) — pass an explicit comparator to
   ordered lookup and insertion, state the descendant invariant, and observe
   why an unbalanced tree provides no logarithmic guarantee.
7. [Abstracting key order](abstracting-key-order/README.md) — replace repeated comparator
   arguments with an `Order<K>` requirement and explicitly select the
   implementation evidence used by each client.
8. [Protecting the dictionary invariant](protecting-dictionary-invariant/README.md) — keep `Dictionary`
   nameable while hiding its constructors, and combine that opacity with
   explicitly selected ordering evidence.
9. [Guaranteeing logarithmic retrieval](guaranteeing-logarithmic-retrieval/README.md) — maintain an
   opaque persistent red-black representation whose ordering and color
   invariants bound height while preserving the dictionary API.
10. [Resuming tree traversal](resuming-tree-traversal/README.md) — use an opaque eager iterator
    whose private frames retain unfinished in-order work, then distinguish one
    step's worst-case cost from one linear traversal's amortized frame work.
11. [Implementing a persistent FIFO frontier](implementing-persistent-fifo-frontier/README.md) — split logical
    order between a front and reversed rear, transfer eagerly only when
    removal needs it, and bound list-node work along one successor history.
12. [Choosing a search frontier](choosing-a-search-frontier/README.md) — hold one shared search
    transition fixed, let LIFO return a longer path and FIFO return the
    shortest path, guard the cycle by marking before addition, and account for
    logical pending entries separately.
13. [Numbering a tree's leaves](numbering-tree-leaves/README.md) — compare explicit state passing
    with a fresh-number request handled by a scoped cell.
14. [Measuring tree-search comparisons](measuring-tree-search/README.md) — measure the same lookup in
    two tree shapes through a handler.
15. [Supplying an order's dependencies](supplying-order-prices/README.md) — run one calculation under
    regular, promotional, and unavailable responses.
16. [Running a scripted session](running-a-scripted-session/README.md) — keep domain transitions
    pure while a handler supplies commands and builds the transcript.
17. [Bounding search work](bounding-search-work/README.md) — request permission before each
    nonempty expansion and distinguish exhaustion from absence.
18. [Compressing parent paths](compressing-parent-paths/README.md) — compare reads and writes
    with and without compression in a scoped buffer.
19. [Reading a bounded byte message](reading-a-bounded-message/README.md) — separate parsing from a
    scoped cursor, and distinguish truncation from acquisition failure.
20. [Controlling a hook pipeline](controlling-a-hook-pipeline/README.md) — combine local hook
    transformations with ordinary policy and trace handlers; connect the
    synchronous pipeline to reactive composition.
21. [Preserving outcomes through
    cleanup](preserving-outcomes-through-cleanup/README.md) — retain the body
    outcome and ordered completion reports, distinguish reporting from merely
    constructing an error, and choose a caller policy explicitly.
22. [Supplying a local pricing
    policy](supplying-a-local-pricing-policy/README.md) — distinguish money from
    quantity, supply methods that capture a tariff, and retain a quote closure
    whose exposed type contains no local identity.
23. [Querying an immutable world](querying-an-immutable-world/README.md) — join position and velocity
    stores by entity identifier, select component evidence explicitly, and
    preserve the original world through repeated movement.
24. [Rolling back a cancellable journal](rolling-back-a-cancellable-journal/README.md) — distinguish control
    abandonment from restoring state, record commitment with explicit flags,
    and compare nested snapshots and surviving cleanup interpreters.
25. [Redact before
    publication](redacting-before-publication/README.md) — project an explicit
    public event, observe internal snapshots around redaction, and distinguish
    the payload type boundary from the application secrecy policy.
26. [Check proposed
    edits](checking-proposed-edits/README.md) — validate a complete proposal
    against an independent model and controller-owned inputs, then distinguish
    edit authorization from continuation consumption.
27. [Cancel a stable
    sort](cancelling-a-stable-sort/README.md) — preserve input order among ties,
    request permission before each comparison, and distinguish a complete
    sorted result from cancelled work.
28. [Round-trip a tagged
    frame](round-tripping-tagged-frames/README.md) — check golden encoding and
    decoding independently, distinguish logical length from capacity, and
    return copied messages from scoped buffer access.
