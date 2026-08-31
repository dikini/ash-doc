# Beginning learning path

This document connects the first Ash lessons into one learning path. It helps
contributors preserve the path's intended outcome and progression. It is not a
table of contents, a backlog, a publication promise, or a source of Ash
semantics.

The active path targets `lib-ash` at commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`, as declared by the
[repository](../../README.md#unpublished-lib-ash-migration). Language details
come from the specification at that commit. The [project roadmap](roadmap.md)
owns the one next complete increment. The
[learning index](../../content/learn/README.md) lists only lessons that readers
can use now.

## Intended outcome

After the beginning path, a learner should be able to design, run, and explain
a pure multi-file Ash program over data they define. They should be able to
trace how values move through functions, use patterns to distinguish data,
follow a data definition with recursion, and use type parameters when a
definition does not depend on a particular element type.

The sequence reaches that outcome through three connected parts. It begins
with programs and calculations, moves to data and structure, and then develops
functional abstraction. Each lesson should continue the model built by the
lessons before it instead of offering a broad tour of language features.

## Planning states

Each entry has one state:

- **verified**: the lesson, canonical programs, and applicable checks exist;
- **migration-pending**: an immutable predecessor exists, but the lesson has
  not returned to the active path at the new target;
- **next**: the roadmap owns this question as the next complete increment; or
- **provisional**: the question helps explain the path but has not entered
  lesson design.

Only one entry can be **next**. A provisional entry creates no lesson
directory, reader-facing link, or publication date.

## Programs and calculations

- **1. [What is an Ash program?](../../content/learn/what-is-an-ash-program/README.md)**
  — **verified.** Definitions, expressions, `main`, functions, function calls,
  and composition.
- **2. [How can one source file use another?](../../content/learn/using-another-source-file/README.md)**
  — **verified.** Modules, complete imports, public declarations, and qualified
  names.
- **3. How can a function use more than one input?** — **migration-pending.**
  Chained function arrows, function clauses with several inputs, and chained
  calls.
- **4. How can a program choose a result?** — **migration-pending.** `Bool`,
  integer equality, and exhaustive matching.
- **5. How can a calculation name an intermediate value?** —
  **migration-pending.**
  Blocks, sequential `let` bindings, and scope.

## Data and structure

- **6. How can several values travel together?** — **migration-pending.**
  Tuples, tuple types, and tuple patterns.
- **7. How can a program define its own data?** — **migration-pending.** Nominal
  types and constructors.
- **8. How can a function handle each form of data?** — **migration-pending.**
  Constructor patterns, equations or matches, and coverage.
- **9. How can a function follow recursive data?** — **migration-pending.**
  Recursive nominal data and recursive functions.

## Functional abstraction

- **10. How can a function itself be a value?** — **migration-pending.**
  Anonymous functions, higher-order functions, and lexical capture.
- **11. How can one definition work with many types?** —
  **migration-pending.** Type parameters, parameterized data, and rank-1
  parametric polymorphism.

## Maintaining the path

Executable lesson design may show that one question needs two lessons or that
two questions belong together. Revise this path when that evidence appears.
Do not preserve the numbering at the cost of a coherent explanation.

When a lesson becomes verified:

1. add it to the reader-facing learning index;
2. update its state here;
3. select at most one later question as **next** in the roadmap; and
4. check that the remaining questions still follow from what the learner now
   knows.

## Outside the beginning path

The beginning path does not teach:

- interfaces, implementations, constraints, or ad-hoc polymorphism;
- opaque or hidden representation boundaries;
- targeted imports, named roots, or re-export details;
- advanced restrictions on recursive initialization; or
- documentation tooling and publication mechanisms.

These subjects require a later learning stage or a concrete project need.
Parametric polymorphism remains in the beginning path because it completes the
first account of reusable data and functions. Ad-hoc polymorphism begins after
that account rather than competing with it.
