# Beginning Lessons Design

## Problem

The first lesson explains one-file Ash programs. The beginning learning path
now identifies ten more reader questions, but none of those entries has lesson
prose or executable evidence. Implementing them as isolated feature tours would
lose the connected learner model established by the first lesson.

## Decision

Implement lessons 2 through 11 in sequence on one cumulative content branch.
Complete and verify each lesson before beginning the next. A lesson includes
its narrative, exercise, canonical sources, accepted and rejected observations,
checks, learning-index entry, and planning-state transition.

The sequence remains the one approved in
`docs/project/beginning-learning-path.md`:

1. source modules;
2. functions with more than one input;
3. Boolean choice;
4. sequential local bindings;
5. tuples;
6. nominal data;
7. constructor patterns and coverage;
8. recursive data and functions;
9. higher-order functions and capture; and
10. rank-1 parametric polymorphism.

The final lesson recombines the path in a multi-file `List<A>` and `map`
program. This supplies the beginner outcome: a learner can design, run, and
explain a pure multi-file program over data they define.

## Teaching shape

Every chapter continues the preceding chapter. Its opening gives the learner a
reason and a working model before the first command. Its examples create the
need for the next example, and its ending gathers the answer and opens the next
question. Project state, specification inventories, and verification machinery
remain outside rendered lesson prose.

The prose and code are original. The project uses the teaching method of *How
to Design Programs*, not its wording or exercises. Assistant prompts appear
only where dialogue improves prediction or explanation: module diagnosis,
coverage, recursive tracing, and type-parameter reasoning.

## Evidence shape

The second lesson repeats the first lesson's source-agreement and CLI checks.
That repetition justifies a small shared Bash helper under
`content/learn/checks/`. Each lesson retains a local `checks/verify.sh`; a
family-level verifier builds pinned Ash once and runs every local verifier.

The helper supports four operations:

- validate and prepare the exact clean Ash checkout;
- compare marked displayed blocks with canonical source files;
- run an accepted entry and compare exact standard output; and
- run a rejected entry and check status, reason, and causal source evidence.

It is not a manifest, renderer, publication system, or general test framework.
Lesson verifiers remain readable evidence for their chapter.

## Project workflow

Use `.worktrees/beginning-lessons` on `content/beginning-lessons`, based on
`docs/beginning-learning-path`. Keep all branch commits unsigned and leave the
branch unmerged and unpushed.

After the third verified lesson, record the required pilot-workflow review.
Retain the unit-local evidence layout and the shared Bash helper. Continue to
defer a renderer, manifest, CI service, and publication platform.

After each lesson, publish only the verified chapter in the learning index,
advance the path state and project roadmap, and remove that lesson's temporary
plans. After lesson 11, all beginning entries are verified and the roadmap asks
for a review of the complete learner journey before choosing a later stage.

## Exclusions

The beginning slice does not introduce targeted imports, named roots, opaque
or hidden representation boundaries, advanced recursive initialization,
interfaces, implementations, constraints, or ad-hoc polymorphism. It does not
select a renderer or change lesson entry files from `README.md`.

## Verification

Every runnable block must match canonical source. Accepted programs must assert
status 0, exact output, and empty standard error. Rejected programs must assert
status 1, empty standard output, the stable reason, and the source location or
causal label used by the explanation.

Run every local verifier and the complete family verifier against
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Also run Bash syntax checks,
Markdown lint, the project writing-skill validator, relative-link review,
`git diff --check`, and an unsigned-commit audit.
