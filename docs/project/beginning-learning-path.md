# Beginning learning path

This document connects the first Ash lessons into one learning path. It helps
contributors preserve the path's intended outcome and progression. It is not a
table of contents, a backlog, a publication promise, or a source of Ash
semantics.

The active path targets `ffi-base` at commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`, as declared by the
[repository](../../README.md#current-edition-ffi-base). Language details
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
- **next**: the roadmap owns this question as the next complete increment; or
- **provisional**: the question helps explain the path but has not entered
  lesson design.

Only one entry can be **next**. A provisional entry creates no lesson
directory, reader-facing link, or publication date.

## Programs and calculations

- **1. [What is an Ash program?](../../content/learn/what-is-an-ash-program/README.md)**
  — **verified.**
  Predict expression values, call substitutions, and composition, then connect
  the observation to main's entry contract.

- **2. [How can one source file use another?](../../content/learn/using-another-source-file/README.md)**
  — **verified.**
  Trace qualified calls through public declarations and explain the
  private-helper rejection through both source files.

- **3. [How can a function use more than one input?](../../content/learn/using-more-than-one-input/README.md)**
  — **verified.**
  Predict each call step's value and remaining function type; connect
  a supplied argument to the remaining arrow's requirement.

- **4. [How can a program choose a result?](../../content/learn/choosing-a-result/README.md)**
  — **verified.**
  Separate condition calculation from arm selection and compare possible
  Boolean inputs with coverage before the rejection.

- **5. [How can a calculation name an intermediate value?](../../content/learn/naming-intermediate-values/README.md)**
  — **verified.**
  Predict each named intermediate value and the block result; explain
  forward-reference rejection through sequential scope.

## Data and structure

- **6. [How can several values travel together?](../../content/learn/values-travel-together/README.md)**
  — **verified.**
  Predict field values and tuple types; compare a single pair input
  with chained inputs and connect rejection to the wrong shape.

- **7. [How can a program define its own data?](../../content/learn/defining-data/README.md)**
  — **verified.**
  Connect constructor forms to represented information and predict
  observations before comparing distinct nominal identities.

- **8. [How can a function handle each form of data?](../../content/learn/handling-data-forms/README.md)**
  — **verified.**
  Derive patterns and equations from constructor forms; explain coverage
  for every admitted input independently of main's chosen value.

- **9. [How can a function follow recursive data?](../../content/learn/following-recursive-data/README.md)**
  — **verified.**
  Follow each finite rest field with a recursive call and use Empty's
  result as the base; distinguish this argument from general termination.

## Functional abstraction

- **10. [How can a function itself be a value?](../../content/learn/functions-as-values/README.md)**
  — **verified.**
  Trace callback calls and captured inputs separately from function
  creation; connect a supplied value to its callable contract.

- **11. [How can one definition work with many types?](../../content/learn/definitions-for-many-types/README.md)**
  — **verified.**
  Choose substitutions for reusable functions and recursive data;
  distinguish a type constructor from a complete value type.

## Local-function continuation

The following verified chapters extend the beginning path in the same family:

- **12. [When can a local function work at several types?](../../content/learn/generalizing-local-functions/README.md)**
  — **verified.**
  Locate independent and shared type choices at local bindings, calls,
  captures, and ordinary parameters; keep the E3 connection optional.

- **13. [How can local definitions refer to one another?](../../content/learn/defining-local-recursion/README.md)**
  — **verified.**
  Separate simultaneous scope, guarded construction, and later use;
  predict bounded cycle observations without assuming termination.

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
- effects and resource ownership; or
- documentation tooling and publication mechanisms.

These subjects require a later learning stage or a concrete project need.
Parametric polymorphism remains in the beginning path because it completes the
first account of reusable data and functions. Ad-hoc polymorphism begins after
that account rather than competing with it.
