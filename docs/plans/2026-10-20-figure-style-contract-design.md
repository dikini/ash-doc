# Figure style contract design

Date: 2026-10-20
Status: Draft, pending maintainer approval
Scope: Shared rendering infrastructure — diagram generation style and figure
authoring rules. No lesson content changes. The edition target remains
`ffi-base` at `354c76b391fe4af665cf6a03479a9874a57cb3e3`.

## Problem

A reader currently meets three unrelated visual dialects in one book:

- Hand-authored static SVGs with lesson-local palettes, used by two lessons
  (`content/learn/using-more-than-one-input/`,
  `content/cases/guaranteeing-logarithmic-retrieval/`).
- Generated diagrams (mermaid, railroad, sequent) drawn in DejaVu Serif/Sans
  Mono with paint `#111` and mermaid's `neutral` theme
  (`rendering/diagrams.mjs:11-12, 81, 96, 99, 109, 211`).
- The book itself, set in TeX Gyre Pagella and IBM Plex Mono on the Ash
  palette (paper `#f5f3ec`, ink `#171c18`, accent `#973b18`).

A maintainer who wants "the Ash look" in a diagram has no definition of it.
Style values are hardcoded across `diagrams.mjs`, and the authoring rules in
the writing skill describe vocabulary and legibility but not the shared
typeface and palette. Generated diagrams prove the fence-to-SVG pipeline in
the specimen only; no content lesson uses them yet, so the divergence will
grow as coverage work proceeds.

## Authority and version boundaries

- `docs/project/rendering.md` keeps its authority over tools, page geometry,
  diagram kinds, and the fence-to-asset schema. This design adds no diagram
  kind and no placement option for generated diagrams.
- The design-token v1 contract (`docs/project/design-tokens.md`) stays
  HTML-scoped and synchronised with ash-site. Diagrams mirror its values at
  implementation time rather than reading the CSS during a build, so diagram
  builds stay hermetic and tool-pinned.
- The writing skill's `formatting.md` keeps the prose authoring rules —
  visual vocabulary, grayscale, label legibility — and gains one normative
  pointer to the new machine-readable contract.
- Tool pins do not change. Mermaid 12.1.0 supports `themeVariables`;
  TeX Gyre Pagella and IBM Plex Mono are already bundled and hash-pinned in
  `rendering/fonts/` and `rendering/toolchain/manifest.json`.

## Approaches considered

### A. Style module consumed by the pipeline (selected)

One `rendering/styles/diagram-style.json` defines fonts, palette, and
per-kind renderer configuration. `diagrams.mjs` imports it and loses all
hardcoded style constants. Fonts are fixed at render time, before outlining
bakes glyphs into paths. A paint-and-font whitelist check over generated SVGs
makes the contract enforceable.

### B. Post-process recolor pass

A filter rewrites `fill`/`stroke`/`font-family` in finished SVGs. It cannot
fix fonts — outlining has already replaced DejaVu glyphs with paths — and
rewriting paint after outlining risks corrupting path data. Rejected: it
addresses color only, late and fragile.

### C. Per-renderer configuration without a shared module

Edit the mermaid, railroad, and sequent configurations independently. This is
the smallest change now and recreates the current scattered state as soon as
a second renderer or kind appears. Rejected: it institutionalises the drift
this design removes.

## Selected design

### Contract file: `rendering/styles/diagram-style.json`

The single normative definition of an Ash figure:

- `fonts`: serif `TeX Gyre Pagella`, monospace `IBM Plex Mono` — the book's
  own faces, so figure labels read as book text.
- `palette`: mirrors design-token v1. `ink` `#171c18` for strokes, text, and
  lines; `accent` `#973b18` for emphasis, highlighted borders, and arrows;
  `selection` `#f8cfad` for light node or state fills; `accent-bright`
  `#f48658` for marked accents. Each palette entry records the token name it
  mirrors. The background stays transparent in every output; paper is never
  a diagram fill.
- `kinds`: per-kind renderer configuration — mermaid `theme: neutral` plus
  explicit `themeVariables` for the supported diagram types (flowchart,
  sequence), railroad paint CSS, and sequent CSS — each channel assigned a
  palette role as data, not prose.

Grayscale-safety holds by construction: ink is near-black, accent is a mid
tone, and selection is light, giving three luminance steps. The prose rule
that colour alone must not carry a relationship stays in `formatting.md`.

### Pipeline rewiring: `rendering/diagrams.mjs`

- Import the contract; delete the hardcoded family and paint constants at
  lines 11-12, 81, 96, 99, and 109, and the hardcoded family switch at
  line 211.
- Extend `pinnedFonts()` to embed the Pagella and Plex faces and repoint the
  fontconfig aliases at them, using the already-pinned files in
  `rendering/fonts/`.
- Keep the existing kind-to-font invariant (ebnf gets monospace; mermaid and
  sequent get serif) with both families drawn from the contract.

### Authoring rules: `formatting.md`

Add a short "Figure style" section: the JSON file is normative for generated
diagrams; hand-authored static SVGs should follow the same palette roles and
font families. The existing "Keep a visual vocabulary" section is unchanged —
a lesson-defined local palette remains legitimate where the lesson defines
its own vocabulary, as the red-black repair figures do.

### Out of scope

Restyling the two existing lessons' figures; a placement schema for generated
diagrams in notes or wide regions; figure coverage work in lessons; chart or
data-visualisation tooling; wiring the cover artwork into the build. Each is
separate scoped work, governed by this contract where it touches style.

## Verification

1. Extend `rendering/checks/diagrams.test.mjs` with a paint-and-font
   whitelist check: enumerate every `fill`, `stroke`, and font reference in
   the generated specimen SVGs and assert membership in the contract. This
   fails the build on a stray renderer default instead of shipping it.
2. Rebuild the specimen (`rendering/specimen/notation.md` fixture) and
   confirm the determinism and accessibility checks still pass. Inspect the
   notation diagrams in HTML, EPUB, and both PDF variants for grayscale
   readability, the 9-10 pt label target, and clipping.
3. Run scoped builds of the two figure lessons and confirm their staged
   assets are byte-identical — the static-SVG path is untouched.
4. Run the repository Markdown checks on changed prose, ShellCheck on any
   changed script, and `git diff --check`.

## Migration and removal conditions

- A new diagram renderer or kind must consume the contract file, or the
  whitelist check fails. There is no per-renderer opt-out.
- Changing the figure style is a single-file edit plus a specimen rebuild.
- This plan is temporary: it leaves the tree when its implementation lands,
  per `docs/plans/README.md`, and links from the owning decision only while
  active.

## Risks

- Mermaid `themeVariables` may leave an unthemed surface. The whitelist
  check turns this into a build failure rather than a silent inconsistency.
- `pdftocairo` may shift accent tones during the outline round-trip.
  Inspect the specimen in both PDFs before merging.
- Pagella OTF embedding through Chrome print-to-PDF is the riskiest unknown.
  Sequence the work fonts-first: swap families, inspect the outlined glyphs
  in the specimen, then apply the palette.

## Completion conditions

- The contract file exists and `diagrams.mjs` contains no hardcoded style
  constants outside it.
- The whitelist check passes on the rebuilt specimen in all four outputs.
- `formatting.md` names the contract and preserves its existing rules.
- All verification commands above pass at the declared edition target.
