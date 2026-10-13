# Rendering Specimen Implementation Plan

> Execute this approved plan in the current session with independent renderer
> evaluations and implementation review checkpoints.

**Goal:** Render a representative ash-doc specimen as responsive HTML,
reflowable EPUB 3, and a book PDF with Tufte-inspired typography.

**Architecture:** Keep Markdown, canonical programs, and diagnostic captures
authoritative. A small preparation step selects complete existing lessons,
resolves source-relative links, and produces static diagram assets before
Quarto Book renders three layouts. Family indexes retain reading order.

**Tech stack:** Python standard library, Quarto Book, Typst, Mermaid CLI, the
existing railroad and sequent renderers where their evaluated output permits
reuse, EPUBCheck, and Poppler for visual inspection.

## Approved boundary

The reader asks whether the same explanation, examples, notes, and diagrams
remain readable across a browser, an e-reader, and a printed book. The crossed
boundary is from verified source to presentation. Rendering cannot change Ash
semantics, program text, or complete diagnostic observations.

The user approved Quarto and Typst on 2026-10-13, reflowable EPUB 3, a PDF with
generous outer margins, and evaluation of both existing notation renderers.
Sequent inference rules are separate from Mermaid interaction sequences.

All existing lesson material targets `diag-ash`, Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. Publication remains pending.

Quarto owns book assembly and output coordination. Compared with direct Pandoc
templates, it reduces locally maintained navigation and margin layout code.
Pandoc remains a replacement candidate if the specimen requires substantial
template forks or recurring changes to lesson source. Deferring the renderer
choice prevents us from testing the existing long listings and diagnostics in
the required formats.

HTML keeps book and local navigation in chrome outside the article, leaving
the outer content margin for notes and figures. Narrow screens retain usable
navigation and contain code overflow. EPUB uses linked notes and allows reader
font preferences. PDF uses outer margins, selectable text, working links, and
page breaks through long listings.

Diagram notation remains editable source. Generate static assets with captions
and prose explanations; include Mermaid graph and sequence, railroad grammar,
and sequent inference fixtures. Evaluate the local renderers at exact commits
without modifying their repositories. Record limitations rather than treating
HTML-only output as proof of multi-format support.

## Task 1: Establish the source and tool boundaries

Create `rendering/specimen.json` with the exact Ash target and selected source
paths. Select the first Learn lesson, the generic element prerequisite lesson,
and the red-black-tree Case. Their existing checks cover short programs,
complete rejections, a table, a long listing, and an unusually long output line.

Provision exact tool versions under ignored local build storage. Record hashes,
renderer commits, fonts, dependency licenses, and the commands needed to
reproduce preparation. Run the selected lesson checks against the exact Ash
checkpoint before presentation work.

## Task 2: Prepare sources without changing their content

Create `rendering/checks/test_build.py` first. Assert that selected lessons are
indexed, their family order is retained, code/transcript bytes survive staging,
source-relative links map to the correct chapter or durable source URL, and
unresolved local destinations report their source path. Confirm failures before
implementing `rendering/build.py`.

The preparation step writes a generated Quarto project to ignored build
storage. Explicit chapter paths avoid README discovery exclusions. Metadata and
source markers do not become lesson administration. Shared reader setup is
available in the specimen without rendering the whole project README.

## Task 3: Integrate static notation assets

Create `rendering/diagrams.mjs` and
`rendering/specimen/notation.md`. Use reusable APIs from evaluated renderers
where possible. Associate each figure with its source, caption, and description.
Ensure invalid notation fails with a source location. Pin generator versions,
font resources, and browser configuration. Keep generated assets out of source
control.

## Task 4: Render the three layouts

Create `rendering/styles/html.scss`, `rendering/styles/epub.css`, and only the
Typst customization needed by the specimen. Use scoped article typography and
separate navigation chrome. Test sidenotes, wide figures, long labels,
diagnostic alignment, multi-page code, and tables. Preserve source text while
allowing layout-specific overflow and visual line breaks.

Run the generated project with the pinned Quarto executable for HTML, EPUB,
and Typst. Require successful exits and all three artifacts before reporting
the specimen built.

## Task 5: Verify, review, and close

Create `rendering/checks/verify.py` for output structure, selected chapter order,
internal links, complete code/transcript text, and static assets. Run unit tests,
the selected lesson checks, EPUBCheck, Markdown lint, ShellCheck, and
`git diff --check`.

Inspect desktop and mobile HTML, EPUB in two reading systems where available,
and PDF pages rendered with Poppler. Record any remaining reader or renderer
limitation precisely. Review source files and licenses, then request independent
specification and implementation reviews and resolve material findings.

Retain the resulting commands, evaluated choices, and observations in
`docs/project/rendering.md`; link it from `docs/README.md`, the roadmap, and the
verification guide. Remove this completed plan and its active links. Keep the
specimen local and the edition unpublished. Revisit the renderer if source
preservation, link mapping, note placement, or readable pagination cannot be
maintained with small replaceable adapters.
