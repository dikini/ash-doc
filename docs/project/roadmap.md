# Roadmap

The roadmap names ash-doc's next complete increment. It is a planning view, not
a curriculum, backlog, publication promise, or source of Ash semantics.

## Current edition

- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Repository state: eight connected learning lessons verified; shared lesson
  checks retained after workflow review
- Published documentation tag: none

Active planning records:

- [Beginning lessons design](../plans/2026-08-26-beginning-lessons-design.md)
- [Beginning lessons implementation plan](../plans/2026-08-26-beginning-lessons.md)

## Verified increment

[*How can a function handle each form of data?*](../../content/learn/handling-data-forms/README.md)
follows the preceding data definition with constructor patterns. Its examples
connect each form to a match arm or function equation and use coverage to
expose an omitted form.

The learning-family check now:

- builds the Ash tool once at the pinned commit;
- runs every canonical program in the learning path;
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

The lesson now introduces a working model before its first command, develops
that model through connected examples, and gathers the answer at its close.
The preferred project writing skill carries this paragraph-level guidance into
future lessons.

## Next complete increment

Complete the next learning lesson around the question: How can a function
follow recursive data?

The [beginning learning path](beginning-learning-path.md) supplies the
provisional sequence around this question. This roadmap owns only the recursive
data lesson; it does not activate the later entries.

The lesson should define a finite integer list whose non-empty form contains an
integer and another list. Construct a small value before defining a recursive
sum that follows the same two forms. Include a rejected function that omits the
empty form. Keep the explanation grounded in the shrinking data rather than a
broad account of recursion.

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
leave the current tree. Keep provisional lesson sequencing in the
[beginning learning path](beginning-learning-path.md), not as implied
publication commitments here or in the reader-facing learning index.
