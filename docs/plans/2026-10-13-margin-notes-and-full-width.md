# Margin notes and full-width specimen plan

Can a reader see a short note beside its reference, read a longer sidenote
without overlap, and use the combined text and note width for an aside?
This change crosses layout and note-placement boundaries in the existing
specimen. It changes neither Ash behavior nor learning source.

**Goal:** revise A4 notes and demonstrate portable full-width formatting.

**Authority:** the user requested a wider A4 right margin for short notes,
confirmed that the longer note also remains a sidenote, and requested a
full-width note or formatting example. Sources still target `diag-ash`,
Ash commit `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

**Architecture:** reuse Quarto's margin-note conversion and `column-page`
blocks with pinned Marginalia. A4 uses fixed right notes; the book keeps
mirrored outer notes. The shared Markdown example spans the text and note
area in print and desktop HTML, then reflows in mobile HTML and EPUB.

## Bounded design

Ordinary footnotes preserve wide body text but fail the requested adjacent-note
behavior. A narrower right gutter would force tiny type or cramped wrapping.
Use a 50 mm note column, 6 mm separation, and 20 mm distance to the right paper
edge. Keep 25 mm on the left and 20 mm above and below. This leaves a 109 mm
main column and 165 mm combined width. Both short and long notes use readable
secondary type with collision-aware placement.

Select native Quarto `column-page` markup rather than duplicate HTML and Typst
content. A short full-width block keeps the example together on a print page;
pinned Marginalia does not reliably handle a wide block across mirrored pages.
The example must not occupy navigation chrome or overlap sidenotes. No new
dependency, note language, or publication mechanism is selected.

## Execution and verification

1. Update `rendering/checks/verify.py` to require fixed right-hand A4 sidenotes,
   actual note-column bounds, separation from the body, complete notes near
   references without overlap, and a complete full-width example. Confirm RED
   against the existing footnote PDF before changing the layout.
2. Set the A4 profile's `reference-location` to `margin`. Configure Marginalia
   with fixed left/right geometry in `rendering/styles/book.typ`, preserving
   the book setup. Add a short `column-page` example to
   `rendering/specimen/notation.md`; use original prose, emphasis, and a table.
3. Build HTML, EPUB, and both PDFs. Check actual margins, note positions, text
   bounds, all code/transcripts, and full-width expansion in both PDFs. Inspect
   representative pages and note collision behavior.
4. Extend `rendering/checks/browser.mjs` to check the full-width block on
   desktop and its readable reflow on mobile and EPUB. Check that navigation
   retains its space. Run EPUBCheck and the existing preparation tests.
5. Update the rendering guide, roadmap, and verification description to record
   the revised geometry and the concrete full-width markup. Review source,
   relative links, Markdown lint, and `git diff --check`.
6. Remove this completed plan and its links, commit the verified change on the
   specimen branch, and retain the updated outputs for review.

Revisit the note width when concrete content or binding requirements need it.
Replace local styling only after the replacement passes these artifact checks.
