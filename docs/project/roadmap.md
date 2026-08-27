# Roadmap

The roadmap names ash-doc's next complete increment. It is a planning view, not
a curriculum, backlog, publication promise, or source of Ash semantics.

## Current edition

- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Repository state: complete eleven-lesson beginning path verified and
  reviewed; first repository-source edition publication is next
- Published documentation tag: none

## Verified increment

The [beginning learning path](beginning-learning-path.md) passes its whole-path
review as one reader experience. All eleven lesson checks pass at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`, every displayed runnable program
agrees with its canonical source, and the final lesson fulfills the path's
intended outcome.

The review made three local continuity repairs: lesson 5 now identifies the
earlier source used by its exercise; lesson 11's assistant prompt matches the
reasoning task it supports; and lesson 11 explains why a public transparent
type's constructors are available through its complete import. No lesson
split, reorder, new language topic, executable change, or project mechanism
was warranted.

## Next complete increment

Publish the reviewed beginning learning path as the first repository-source
ash-doc edition and preserve it with an immutable documentation tag.

The edition remains bound to `modular-ash` at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. The future documentation tag will
identify one verified ash-doc source snapshot; it will not define Ash behavior
or change the language target.

Before creating the tag or changing external state, obtain approval for a
bounded publication design. Select the smallest source-publication operation
that gives readers and downstream evidence a durable edition reference, then
verify the complete learning family, documentation links and structure,
canonical-source agreement, and the final clean tag target.

This increment does not select a renderer, publication platform, lesson-entry
rename, manifest, coverage view, CI service, license, new language topic, or
forward migration. A future presentation may consume the immutable source
snapshot; a future Ash edition receives a new documentation tag rather than
moving this one.

## Later decisions

Later work should supply evidence for these choices:

1. whether a renderer adds value beyond readable source Markdown;
2. which coverage view becomes useful after several lessons exist;
3. whether lesson entry pages should remain `README.md` for repository browsing
   or become `index.md` when a renderer or publication design needs different
   entry behavior.

These are questions, not selected mechanisms. Record a new project choice only
when current work crosses its boundary.

## Updating this roadmap

Replace completed increments with the next complete outcome. Link active design
or execution plans while they exist, then remove those links when the plans
leave the current tree. Keep any provisional lesson sequencing in the
[beginning learning path](beginning-learning-path.md), not as implied
publication commitments here or in the reader-facing learning index.
