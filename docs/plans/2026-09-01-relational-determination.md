# Relational determination implementation plan

Status: approved by the library-abstractions design

## Outcome and boundary

The reader asks how a known interface argument can determine another. This
crosses from complete multi-parameter evidence applications to one total
forward edge whose known key permits improvement before selection.

The exact target is Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`. The governing rules are interface
binding in `spec/name-resolution.md`, interfaces and checked evidence in
`spec/static-semantics.md`, and the pinned `ash` tool guide.

The lesson will observe:

- a client selecting `Measure<Bool, Unit>` and producing `42 : Int` even though
  `Result` is absent from the method type; and
- the parallel name-only client rejecting with status `1`, empty stdout, and
  `constraint.ambiguous` because `Bool` is known but no selected source can
  determine `Result`.

It excludes associated-output syntax, reverse or partial improvement, multiple
edges, defaults, specialization, and runtime evidence lookup.

## Smallest teaching shape

A single-module pair would repeat the implementation body and blur which
source supplies improvement. The selected three-source shape keeps one public
`Measure` library and two entries differing only by `impl Measure`. It reuses
the established lesson-local verifier and adds no tooling.

## Execution

1. Add the lesson verifier first with a three-source inventory, exact pin,
   selected success, name-only rejection, causal diagnostic spans, source
   relationship, and displayed-source checks. Confirm it fails while sources
   are absent.
2. Add `src/measurement.ash`, `src/01-selected.ash`, and
   `src/02-name-only.ash`; run both compiler observations.
3. Add the lesson prose and family-index link; run lesson and family checks.
4. Update root/content navigation and the roadmap to five lessons and seventeen
   sources, then remove this temporary plan.
5. Run one combined closure pass: all active content, retained upstream-failure
   evidence, focused pinned Ash tests, Markdown, shell, relative-link, count,
   whitespace, and clean-status checks.

Completion means the fifth lesson and the complete library family pass at the
exact target. A compiler failure is documented for upstream and not repaired
in ash-doc.
