# Rendering

This directory selects all 61 indexed, verified lessons for a local review book
and retains the smaller specimen as a regression build. The book follows
Learn → Libraries → Effects → Cases and includes the four family introductions.
Learning source remains in `content/`; notation fixtures remain project material.
Retained book outputs cover 54 lessons, including the cleanup-reporting Case.
The local-pricing, immutable-world, cancellable-journal, event-redaction,
controlled-edits, stable-sort, and tagged-frame Cases await presentation
checks.

Read the [rendering guide](../docs/project/rendering.md) for the selected
sources, tool pins, commands, checks, and replacement conditions. The
[notation renderer report](../docs/project/notation-renderer-bugs.md) and
[rendering tool report](../docs/project/rendering-tool-bugs.md) retain current
development handoffs.

For chapter authoring, use the writing skill's
[formatting reference](../.agents/skills/writing-ash-documentation/references/formatting.md).
It explains when to use sidenotes, full-width material, diagrams, and page
breaks, with source examples and the bounds shared by the four outputs.

- `specimen.json` selects indexed lessons and exact renderer inputs.
- `specimen/notation.md` tests sidenotes, full-width formatting, and the four
  notation cases.
- `build.py` prepares sources and renders HTML, EPUB, and both PDF variants.
  Its default selects the specimen; `--whole-book` selects the complete book.
- `bootstrap.py` prepares pinned local tools.
- `diagrams.mjs` derives standalone vector assets.
- `styles/` separates navigation, article typography, EPUB reflow, and PDF print
  layouts. The generated `a4` profile shares the book's typography. The EPUB and
  Typst adapter uses generated source records to retain selected page links,
  family introductions, and their anchors.
- `fonts/` contains unmodified font files and their license notices.
  Notice text is preserved with whitespace normalized.
- `toolchain/` retains release hashes and the frozen npm dependency graph.
- `checks/` verifies sources, artifacts, browser behavior, and renderer gaps.
- `fixtures/conformance/` contains minimal upstream failure cases and controls.

Generated sources, tools, captures, and outputs belong under ignored `.build/`.
The specimen uses `.build/specimen/`; the complete book uses `.build/book/` and
the `ash-doc-review` output basename. Each project retains `build.json` identity,
`sources.json` source/code/asset records, and browser evidence in `qa-browser/`.
Both modes share the pinned tools, cache, fonts, and styles. Rendering does not
publish or tag the documentation edition.
