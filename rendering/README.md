# Rendering

This directory contains the approved local book specimen and its replaceable
preparation tools. Learning source remains in `content/`; these fixtures are
project material, not additional lessons.

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
- `bootstrap.py` prepares pinned local tools.
- `diagrams.mjs` derives standalone vector assets.
- `styles/` separates navigation, article typography, EPUB reflow, and PDF print
  layouts. The generated `a4` profile shares the book's typography.
- `fonts/` contains unmodified font files and their license notices.
  Notice text is preserved with whitespace normalized.
- `toolchain/` retains release hashes and the frozen npm dependency graph.
- `checks/` verifies sources, artifacts, browser behavior, and renderer gaps.
- `fixtures/conformance/` contains minimal upstream failure cases and controls.

Generated sources, tools, captures, and outputs belong under ignored `.build/`.
The specimen does not publish or tag the documentation edition.
