# Design recursive algorithms in Ash

The [Learn Ash path](../learn/README.md) builds the language model needed here:
modules, functions, patterns, recursive data, higher-order functions, and
parameterized definitions. Complete its eleven lessons before beginning these
cases. Keep the same `ash` executable available through the
[shared setup](../../README.md#prepare-ash).

The Cases path asks what changes when a program must do more than produce the
right value. Each chapter begins with a recursive representation, makes an
algorithmic choice visible in complete Ash programs, and then accounts for the
work and retained data caused by that choice. Later cases change the
representation when an operation or invariant demands it.

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

1. [How can one recursive traversal define many list
   algorithms?](folding-recursive-lists/README.md) — separate a list traversal
   from the operations supplied to a strict right fold.
2. [How can changing finite state produce a recursive
   list?](building-finite-lists/README.md) — use a transition and a structural
   measure to produce a complete eager list.
3. [When should recursion retain knowledge from earlier
   elements?](accumulating-list-results/README.md) — use accumulator state to
   avoid repeated append traversal while preserving the same reversed value.
4. [What does lookup cost when a dictionary is a recursive
   list?](dictionary-as-list/README.md) — use explicit equality for selective
   lookup, contrast its work with a strict fold, and observe older dictionary
   versions retained behind new front entries.
5. [How does the data-directed method extend from lists to
   trees?](folding-branching-data/README.md) — fold both branches, compare
   equal-size trees with different heights, and contrast selective search with
   whole-tree fold work.
6. [How can an invariant let lookup ignore most of a
   tree?](searching-ordered-tree/README.md) — pass an explicit comparator to
   ordered lookup and insertion, state the descendant invariant, and observe
   why an unbalanced tree provides no logarithmic guarantee.
7. [How can modules reuse an ordering capability without passing it
   manually?](abstracting-key-order/README.md) — replace repeated comparator
   arguments with an `Order<K>` requirement and explicitly select the
   implementation evidence used by each client.
8. [How can clients use a dictionary without constructing invalid
   trees?](protecting-dictionary-invariant/README.md) — keep `Dictionary`
   nameable while hiding its constructors, and combine that opacity with
   explicitly selected ordering evidence.
9. [How can the representation prevent a search tree from
   degenerating?](guaranteeing-logarithmic-retrieval/README.md) — maintain an
   opaque persistent red-black representation whose ordering and color
   invariants bound height while preserving the dictionary API.
10. [How can traversal pause and resume without
    laziness?](resuming-tree-traversal/README.md) — use an opaque eager iterator
    whose private frames retain unfinished in-order work, then distinguish one
    step's worst-case cost from one linear traversal's amortized frame work.
11. [How can two lists preserve queue
    order?](implementing-persistent-fifo-frontier/README.md) — split logical
    order between a front and reversed rear, transfer eagerly only when
    removal needs it, and bound list-node work along one successor history.
12. [How does frontier representation change a search
    algorithm?](choosing-a-search-frontier/README.md) — hold one shared search
    transition fixed, let LIFO return a longer path and FIFO return the
    shortest path, guard the cycle by marking before addition, and account for
    logical pending entries separately.
