# Roadmap

The roadmap names ash-doc's next complete increment. It is a planning view, not
a curriculum, backlog, publication promise, or source of Ash semantics.

## Current edition

- Ash milestone: `modular-ash`
- Resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`
- Repository state: first repository-source edition published with its
  complete eleven-lesson beginning path verified and reviewed
- Published documentation tag: `modular-ash`

## Verified increment

The first repository-source edition preserves the reviewed
[beginning learning path](beginning-learning-path.md) as one immutable source
snapshot. All eleven lesson checks pass at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`, every displayed runnable program
agrees with its canonical source, and the final lesson fulfills the path's
intended outcome.

The ash-doc tag uses the target Ash milestone's `modular-ash` name. The tags
are repository-local and identify different commits: the `ash-lang` tag
retains language and tool behavior, while the ash-doc tag retains the
corresponding documentation source. The documentation tag neither defines Ash
behavior nor changes the exact publication target.

## Next complete increment

Run and record the first exact-commit compatibility canary for the complete
published learning path against one fetchable `ash-lang/main` commit.

The canary will test whether the published programs and their promised
observations remain compatible with that exact newer tool. It will retain
`modular-ash` at `dca16039923475c48025c5f17beadeb6bcb6a4bf` as the publication
target and classify each incompatibility as an intentional transition, an Ash
regression candidate, a documentation assumption, or other downstream
pressure. A passing canary records compatibility with only the tested commit;
it does not retarget the edition.

Before adding a canary command or record, obtain approval for a bounded design
that names the exact fetchable commit, cases, observations, failure
classification, and retention condition. Select the smallest manual mechanism
that can run the complete family without weakening its publication-pin check.

This increment does not select a schedule, CI service, renderer, publication
platform, manifest, expanded shared harness, forward migration, new language
topic, or new content family.

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
