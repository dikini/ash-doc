# Roadmap

The roadmap names ash-doc's next complete increment. It is a planning view, not
a curriculum, backlog, publication promise, or source of Ash semantics.

## Current edition

- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Repository state: complete eleven-lesson beginning path verified; whole-path
  review is next
- Published documentation tag: none

Active planning records:

- [Beginning lessons design](../plans/2026-08-26-beginning-lessons-design.md)
- [Beginning lessons implementation plan](../plans/2026-08-26-beginning-lessons.md)

## Verified increment

[*How can one definition work with many types?*](../../content/learn/definitions-for-many-types/README.md)
completes the beginning path with parametric functions and data. Its final
example combines a public parameterized list, recursive `map`, a function
value, and a qualified module use without introducing constrained or ad-hoc
behavior.

The learning-family check now:

- builds the Ash tool once at the pinned commit;
- runs every canonical program in all eleven lessons;
- compares each accepted result with the documented observation;
- checks rejected programs for their causal diagnostics; and
- checks every displayed program against its canonical source.

Each lesson keeps a local entry point and declares its own cases. A small
shared Bash helper owns the repeated build, execution, diagnostic, and
source-agreement mechanisms.

The learning-family index owns setup, study method, optional assistant
guidance, and reading order. Lessons contain educational prose and inherit the
edition target from the repository root. Project records and checks retain
state, source, and evidence administration.

Each lesson introduces a working model before its first command, develops that
model through connected examples, and gathers the answer at its close. The
preferred project writing skill carries this paragraph-level guidance into
future lessons.

## Next complete increment

Review the beginning learning path as one reader experience, from the first
integer expression through the parameterized list transformation.

The [beginning learning path](beginning-learning-path.md) records the verified
sequence and intended outcome. This increment reviews the whole path; it does
not activate a new lesson.

Read the lessons in order, run the complete learning-family check, and audit
the transitions, vocabulary, exercises, and optional assistant prompts as one
connected course. Confirm that each lesson relies only on earlier ideas and
that the final lesson fulfills the intended outcome. Use concrete reader or
executable evidence to revise, split, or reorder material; do not add a new
language topic during the review.

## Later decisions

Later work should supply evidence for these choices:

1. whether a renderer adds value beyond readable source Markdown;
2. which coverage view becomes useful after several lessons exist;
3. whether lesson entry pages should remain `README.md` for repository browsing
   or become `index.md` for a website, to be decided with the first renderer or
   publication design.

These are questions, not selected mechanisms. Record a new project choice only
when current work crosses its boundary.

## Updating this roadmap

Replace completed increments with the next complete outcome. Link active design
or execution plans while they exist, then remove those links when the plans
leave the current tree. Keep any provisional lesson sequencing in the
[beginning learning path](beginning-learning-path.md), not as implied
publication commitments here or in the reader-facing learning index.
