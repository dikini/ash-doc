# Beginning Learning Path Design

## Problem

The first Ash lesson now answers one reader question, and the project roadmap
names the next complete lesson. Neither document should carry the longer
beginner sequence. The roadmap would become a backlog, while the learning index
would promise chapters that readers cannot use.

Contributors still need a shared account of the early learning arc. Without
one, each lesson can be coherent by itself while leading toward a different
idea of what the beginning path should teach.

## Decision

Add `docs/project/beginning-learning-path.md` as a provisional planning view.
Index it from `docs/README.md`. The document will connect reader questions in
dependency order and explain the model a learner should have at the end.

The three planning surfaces keep separate jobs:

- `docs/project/beginning-learning-path.md` owns the provisional beginner
  sequence;
- `docs/project/roadmap.md` owns the one next complete project increment; and
- `content/learn/README.md` owns only the reading order for lessons that exist.

The learning path cannot define Ash behavior or commit the project to
publishing every proposed lesson. Language claims remain subordinate to the
specification at the edition's pinned Ash commit.

## Shape of the path

The path begins with programs and calculations, moves to data and structure,
and ends with functional abstraction. Each entry starts with a question a
learner can ask and names only the ideas needed to answer it.

### Programs and calculations

- **1. What is an Ash program?** Definitions, expressions, `main`, functions,
   function calls, and composition.
- **2. How can one source file use another?** Modules, imports, public
   declarations, and qualified names.
- **3. How can a function use more than one input?** Chained arrows, chained
   calls, and multiple parameters.
- **4. How can a program choose a result?** `Bool`, integer equality, and
   exhaustive matching.
- **5. How can a calculation name an intermediate value?** Blocks, sequential
   `let` bindings, and scope.

### Data and structure

- **6. How can several values travel together?** Tuples, tuple types, and tuple
   patterns.
- **7. How can a program define its own data?** Nominal types and constructors.
- **8. How can a function handle each form of data?** Constructor patterns,
   equations or matches, and coverage.
- **9. How can a function follow recursive data?** Recursive nominal data and
   recursive functions.

### Functional abstraction

- **10. How can a function itself be a value?** Anonymous functions,
    higher-order functions, and lexical capture.
- **11. How can one definition work with many types?** Type parameters,
    parameterized data, and rank-1 parametric polymorphism.

The ordering is provisional. Executable lesson design may show that two
questions belong together or that one question needs two lessons. Such a
change revises this planning view before it changes the active roadmap.

## State and lifecycle

The document uses three states:

- **verified** means the lesson and its local evidence exist;
- **next** means the project roadmap owns its design as the next complete
  increment; and
- **provisional** means the question helps explain the intended sequence but
  has not entered lesson design.

Only one entry may be **next**. A provisional entry has no lesson directory,
link from the reader-facing index, or implied publication date. When a lesson
becomes verified, the project adds it to `content/learn/README.md`, advances the
next entry, and checks whether the remaining sequence still follows from what
the learner now knows.

## Beginner outcome

At the end of this path, a learner should be able to design, run, and explain a
pure multi-file Ash program over data they define. They should understand how
values move through functions, how patterns distinguish data, how recursion
follows a data definition, and how parametric definitions reuse one structure
without depending on a particular element type.

## Deliberate exclusions

The beginning path does not teach:

- interfaces, implementations, constraints, or ad-hoc polymorphism;
- opaque or hidden representation boundaries;
- targeted imports, named roots, or re-export details;
- advanced restrictions on recursive initialization; or
- documentation tooling and publication mechanisms.

These subjects are not absent from Ash. They require a later learning stage or
a concrete project need. Keeping ad-hoc polymorphism after parametric
polymorphism lets the beginner path first establish reuse that follows from
type parameters alone.

## Alternatives considered

Expanding `docs/project/roadmap.md` would put a speculative curriculum beside
the active increment and weaken its one-outcome purpose. Listing future lessons
in `content/learn/README.md` would present plans as available reading. A
separate project document preserves both boundaries and can be replaced without
changing published navigation.

## Verification

Review the new planning view against these conditions:

- the first lesson is marked **verified** and the module lesson is **next**;
- every later entry is marked **provisional**;
- the project roadmap still names only one next complete increment;
- the learning index still lists only lessons that exist;
- the beginner outcome and exclusions are explicit;
- links resolve from the project documentation index; and
- Markdown lint, the existing lesson check, the writing-skill validator, and
  `git diff --check` pass.
