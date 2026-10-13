# Demonstrate notes in the search-tree lesson

The reader's question is how the search-tree representation keeps its height
bounded. This change makes the distinction between subtree consistency and
the public root condition visible, and keeps the repair diagram readable in
both print layouts. The user requested all three accepted note forms in a real
lesson and regenerated PDFs for layout review.

The existing rendering decision owns this plan. Ash remains pinned to
`diag-ash`, commit `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
The lesson's canonical programs, invariant checks, and specification links
govern the figures; the figures do not establish language guarantees.

## Bounded design

Use `content/cases/guaranteeing-logarithmic-retrieval/README.md`. Add a numbered
sidenote with an optional red-root/black-Empty sketch, an unnumbered counting
reminder in the height proof, and a full-width comparison of left-left repair
with the common normalized result. Required reasoning stays in the main text.
Labels name colors so grayscale retains their meaning.

Stage self-contained, outlined SVG files from this lesson's local `assets/`
directory through Pandoc image nodes, including notes and Divs. Preserve image
attributes and surrounding source structure. Copy unchanged bytes into distinct
generated paths and retain source paths and hashes. Missing or unsuitable
assets fail preparation rather than becoming broken figures.

The alternative is a new placement schema for generated fences and recursive
conversion inside notes. That expands two interfaces for one lesson. Deferring
staging leaves relative lesson images unresolved after chapters are flattened.
The selected static-image boundary can be replaced when a concrete generated
figure needs richer placement; existing raw diagram fences stay top-level.

## Execution and verification

1. Add a failing preparation check for source-local images in notes and wide
   Divs. Verify exact text, image attributes, bytes, source hashes, distinct
   paths, and rejected unresolved or nonportable images.
2. Implement bounded image staging in `rendering/build.py`; run its preparation
   checks. Update the rendering guide and formatting reference for this source
   form without changing the raw-fence contract.
3. Add original figures under the lesson's `assets/` and the three note forms
   in its README. Check each diagram against `restore_three`, the left-left
   `restore` pattern, and the `red_root` invariant control.
4. Scope existing fixture-note verification to its fixture. Add checks for the
   real lesson's note references, image descriptions, margin placement, wide
   region, and reflow. Preserve existing code/transcript checks.
5. Run the lesson's pinned executable check, Markdown lint, source/link review,
   and `git diff --check`. Build the specimen with its cached pinned tools.
6. Inspect affected pages from both PDFs with Poppler, plus narrow HTML and
   enlarged EPUB. Require readable labels, correct outer/right notes, one-page
   wide material, and no clipping or overlap. Run artifact, browser, and
   EPUBCheck checks; obtain independent content and implementation review.
7. Remove this completed plan and show both PDFs with their review page numbers.
   Retain the isolated worktree and generated artifacts for review.
