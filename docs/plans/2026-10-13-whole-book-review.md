# Complete review-book implementation plan

The reader asks to review the complete Ash learning work in one navigable
book. The boundary is from 53 indexed, verified lessons to HTML, reflowable
EPUB 3, a double-sided book PDF, and a one-sided A4 PDF. All material targets
`diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

The author approved Learn → Libraries → Effects → Cases order and retention
of the specimen as a regression build. The complete draft remains local and
unpublished. Canonical lesson prose and programs remain authoritative.

## Design

Extend the existing source adapter with a whole-book mode. It derives all
lessons from the existing family indexes, includes those indexes' reader-facing
introductions, and uses native Quarto book parts. Existing note handling,
styles, static assets, renderer pins, and both print geometries remain shared.
A second manually assembled Quarto project would duplicate order, styles,
links, and checks; deferring the extension would leave full-book readability
unobserved. A separate general registry is unnecessary.

Whole-book mode writes `.build/book/`, with title and output names distinct
from the specimen. The default specimen selection and `.build/specimen/`
remain available. The notation fixture stays in the regression specimen.
The uncommitted cover draft in the primary checkout is separate work.

Each build retains generated `build.json` metadata describing mode, title,
output basename, source and Ash commits, flattened reading order, book parts,
and lesson count. Existing `sources.json` remains a list of exact source/code/
asset records; whole-book records distinguish introductions from lessons.
These files serve the build and its checks, not a repository content registry.

## Implementation and checks

1. Add failing preparation tests in `rendering/checks/test_build.py` for
   complete indexed coverage, required family order, part introductions,
   internal family links, distinct names, and exclusion of notation fixtures.
   Implement the smallest extension in `rendering/build.py` with
   `--whole-book`; preserve the default specimen behavior.
2. Extend `rendering/checks/verify.py` and its tests to read build identity and
   source records. Keep specimen note/notation probes conditional on the
   specimen mode. Verify full-book order and coverage, source/code preservation
   in each HTML and EPUB chapter, links, assets, and both PDF geometries.
   Preserve search-tree layout regressions in both builds.
3. Extend `rendering/checks/browser.mjs` for source-driven navigation and
   overflow checks. Locate EPUB chapters through its spine and source headings,
   rather than chapter-number offsets. Keep named specimen regressions and
   isolate browser evidence by build.
4. Run the four content-family verifiers against the exact clean Ash checkout.
   Run all rendering unit tests, then build and verify both the regression
   specimen and complete book. Run browser checks and EPUBCheck on each.
   Visually inspect representative PDF pages and all flagged layout failures.
5. Update `rendering/README.md`, `docs/project/rendering.md`, the verification
   guide, and roadmap with reproducible complete-book commands and actual
   coverage. Check Markdown, shell syntax, ShellCheck, relative links, source
   diffs, and authority. Remove this completed plan after verification.

Independent agents own artifact and browser checks on disjoint files; root owns
the builder, documentation, integration, and build orchestration. Review scope
and code quality before declaring completion. Commits remain unsigned.
No merge, publication, tag, upload, or hosting change is part of this task.

Revisit this mode if another complete outcome needs a different assembly or
the shared adapter cannot retain source meaning and readable pagination.
Completion requires all 53 lessons in the requested order and four reviewable
outputs, alongside a passing regression specimen; long-listing editorial
revision proceeds separately when the full rendering identifies its next need.
