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
