# Split diagram renderer design

Date: 2026-10-20
Status: Draft, pending maintainer approval
Scope: A new standalone renderer repository for split-shape figures, plus a
bounded ash-doc integration mirroring the `sequent-md` consumption pattern.
No Ash language content changes. The edition target remains `ffi-base` at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`.

## Problem

Two lessons teach with the same split-shape visual idiom, expressed as
hand-authored SVG:

- [Using more than one input](../../content/learn/using-more-than-one-input/README.md)
  draws split *squares*: the upper half names a type (function or `Int`), the
  lower half names a value. Editable `*-source.svg` files sit beside the
  outlined lesson assets, and the Inkscape CLI converts text to paths
  (`rendering/experiments/partial-application/README.md`).
- [Guaranteeing logarithmic retrieval](../../content/cases/guaranteeing-logarithmic-retrieval/README.md)
  draws split *circles*: the upper semicircle names the red-black form, the
  lower semicircle names the key/value association, with subtree triangles and
  before/after phases. Its checked-in figures are final outlined SVGs with no
  editable source; the rendering guide records that evaluated helpers produced
  them and the book reuses them directly ([rendering.md](../project/rendering.md)).

A maintainer who wants another figure in this vocabulary must hand-draw SVG.
Case 9's figures cannot be regenerated from anything in the tree, and each
lesson hardcodes its own palette and geometry. The reader sees one idiom; the
repository stores two unrelated production routes for it.

## Decision context

On 2026-10-20 the maintainer directed that this renderer be built as a
separate project following the [`sequent-md`](https://github.com/dikini/sequent-md)
example: its own repository, notation grammar, tests, and release history,
consumed by ash-doc at an exact commit with recorded bundle hashes — the same
trust model as the railroad and sequent renderers.

## Authority and version boundaries

- The new repository (working name `split-md`, a sibling of `sequent-md`)
  owns the notation grammar (`grammar.md`), parser, layout engine, SVG
  emitter, default styles and fonts, and its test suite, including a
  conformance corpus that encodes the ash-doc pilot figures. It versions
  independently; ash-doc consumes it by exact commit and bundle hash.
- ash-doc owns the fence metadata contract (one bare `split` fence plus one
  `diagrams:` YAML entry per figure), the adapter in `rendering/diagrams.mjs`,
  the style-contract consumption, the renderer pins, the lesson rewrites, and
  the output checks. It does not own the notation.
- The [figure style contract design](2026-10-20-figure-style-contract-design.md)
  remains the normative source for diagram fonts, palette roles, and the
  paint/font whitelist. `split-md` receives those values through render
  options so ash-doc diagram builds stay hermetic; it also ships documented
  standalone defaults, as `sequent-md` does with its styles. This design
  depends on that plan: if it is rejected or materially reshaped, this design
  returns for re-approval.
- The writing skill's `formatting.md` keeps the visual-vocabulary and
  legibility rules and, after implementation, gains one normative pointer to
  the `split-md` grammar, matching its existing sequent guidance.

## Approaches considered

### A. Separate renderer repository modeled on `sequent-md` (selected)

The maintainer's direction. Costs: two-repository coordination, a second test
suite, and pin bookkeeping for eight small figures today. Benefits: the notation
and renderer evolve under their own commits and tests; the renderer is
reusable outside ash-doc (preview plugins, other books); ash-doc keeps the
same narrow adapter it already maintains for sequent; and the trust model —
exact commit, bundle hash, conformance corpus — is proven in this repository.

### B. Fourth in-tree diagram kind in `diagrams.mjs`

The smallest change now: one new branch beside `sequentSvg`, no new
repository. Rejected by maintainer direction. It would also grow ash-doc with
a general-purpose renderer whose notation changes would ride content commits,
and it leaves case 9's source-gap problem solved only for ash-doc.

### C. Retain hand-authored SVG

No new machinery. Deferral cost: every future split figure is manual SVG;
case 9's figures remain non-reproducible; and the style divergence the figure
style contract exists to remove keeps growing as coverage work proceeds.

## Selected design

### The `split-md` repository

A private npm-workspaces repository mirroring `sequent-md`, shipping
`packages/core` first and deferring remark/rehype or editor packages until a
consumer needs them.

- `packages/core/src/index.js` exports `render(source, options)` returning
  `{ svg, diagnostics }`, plus the default palette and geometry constants.
  Unlike sequent, the renderer emits SVG directly: geometry is computed, not
  CSS-laid-out, so no browser measurement pass lives in the renderer.
- Authors declare structure and alignment; the renderer computes every
  coordinate from per-shape constants (square box size, pitch, and label
  offset; circle radius, level spacing, and subtree markers) and an optional
  scale. The notation carries no coordinates.
- Render options accept `{ fonts, palette, categorical }`, so ash-doc passes
  its style contract values at build time; standalone callers get documented
  defaults. Whitelisting in ash-doc therefore stays enforceable.
- The test suite runs under `node --test` and includes a conformance corpus
  that fixes the eight ash-doc pilot figures' structure and geometry, so a
  renderer change that would alter a lesson figure fails in `split-md`
  before ash-doc's pins move.

### v1 notation summary

The normative grammar lives in `split-md`'s `grammar.md`. The summary fixes
the surface the pilot figures require:

- An item is `top[/bottom]`. The top names a category: `fn` or `int` for
  squares, `red` or `black` for circles. The bottom names an identity (a
  value like `20` or `add_20`, or an association like `(k1,v1)`); identities
  receive categorical hues deterministically in first-use order, with an
  override. An item without a bottom renders solid, as the type-only
  currying figure does.
- `sig: [add] : [Int] -> [Int] -> [Int]` — bracketed tokens center on
  successive items; unbracketed tokens flow into the gaps between anchors.
  This one rule reproduces the signature alignment the currying figures
  teach from.
- A block is a `sig:` plus a `row:` of items, or a `tree:`. `arrows: i j`
  connects the lower halves of row items `i` and `j` with the schematic
  application-guide arrow. Blocks in one fence stack vertically with an
  implicit transformation arrow between them, covering both the currying
  two-row figure and the red-black before/after repairs.
- `tree:` nests by indentation, binary, left then right. `Empty` is reserved
  and renders the black-upper, white-lower empty circle; any other childless
  name renders as a subtree triangle.
- Figure-level `shape: square | circle` selects the idiom.

### ash-doc integration, mirroring sequent

- `rendering/specimen.json` gains `renderers.split` (exact commit) and
  `renderer_bundles.split` (`packages/core/src/index.js` and its SHA-256), the
  existing authentication boundary for external renderers.
- `rendering/build.py` gains a `--split` argument defaulting to the sibling
  checkout, verified through the same commit-and-hash preparation as sequent
  (`rendering/build.py:541-552`); the kind allowlists gain `split`
  (`rendering/build.py:328,353`; `rendering/checks/verify.py:398,410`).
- `rendering/diagrams.mjs` gains a `splitSvg` adapter: import the pinned
  bundle, call `render` with the contract's fonts, palette, and categorical
  list, then reuse the shared `accessibleSvg` and `outlineSvg` steps
  unchanged. Glyph outlining stays in ash-doc with its pinned browser and
  `pdftocairo`.
- The specimen notation fixture gains `split` examples; the static-export
  checks gain `split` cases behind a `SPLIT_BUNDLE` input, as sequent uses
  `SEQUENT_BUNDLE` (`rendering/checks/diagrams.test.mjs:9`).
- The lessons replace eight figures with fences: the three currying figures
  and `red-root-sketch` plus the four repair figures. The annotated wide
  `tree-repair.svg` composite remains a checked-in static SVG; its bespoke
  annotations do not fit the v1 vocabulary.
- Retire the lesson-3 `*-source.svg` trio and the Inkscape refresh step in
  `rendering/experiments/partial-application/build_delivery.py`; that
  experiment's README records the new route, and its scale check is deleted
  or redirected at the `split-md` corpus, since generated figures no longer
  carry hand-maintained source geometry.

### Open questions carried into implementation

- The type-only currying figure contains an arrow between its last two boxes
  (`currying-types-source.svg:51`). The notation reproduces it as written;
  keep it or drop it as an artifact is a figure-review decision.
- Whether the categorical identity hues live in the style contract or in
  `split-md` defaults resolves with the contract plan; cross-figure
  consistency argues for the contract.

## Verification

In `split-md`: parser, layout, and render unit tests; the ash-doc conformance
corpus; byte-stable output across repeated renders; and SVG format checks
mirroring its existing format verification.

In ash-doc, after the pins exist:

1. Build the specimen and confirm determinism and accessibility checks pass
   with the new fixture figures.
2. Rebuild the two affected lessons scoped, and inspect HTML, EPUB, and both
   PDFs for grayscale readability, the 9–10 pt label target, figure order,
   and clipping.
3. Regenerate the eight figures from fences and confirm the generated assets
   replace the checked-in static ones in staged output.
4. Confirm the paint-and-font whitelist check passes on the new kind, once
   the contract plan lands it.
5. Run the static-export checks with `SPLIT_BUNDLE`, the affected lesson
   checks, repository Markdown checks, ShellCheck where scripts change, and
   `git diff --check`.

## Migration and removal conditions

- The notation is the durable source. Replacing the renderer means
  re-rendering the fences at a new pin, the same migration story as sequent.
- Advancing the `split-md` pin requires its conformance corpus to pass and
  the regenerated figures to pass scoped visual review.
- This plan is temporary and leaves the tree when its implementation lands,
  per [docs/plans/README.md](README.md); `split-md` retains its own design
  history.

## Risks

- Two-repository drift. Mitigated by the existing pin, hash, and corpus
  boundaries; the corpus runs in `split-md`, the hash pins the consumed file
  in ash-doc.
- Style-contract coupling through the options seam. Kept one-directional:
  `split-md` never reads ash-doc files, so standalone use keeps working.
- Regenerated figure bytes differ from the current checked-in assets. This is
  expected and is gated by scoped visual review, not by byte comparison.
- Sequencing. The contract plan is still a draft; approving it first, or at
  least its categorical-palette answer, keeps this design's style boundary
  single-sourced.

## Completion conditions

- `split-md` exists with its grammar, core renderer, tests, and conformance
  corpus, and ash-doc records its consumed commit and bundle hash.
- The eight lesson figures render from `split` fences in all four outputs and
  pass scoped review.
- The retired source SVGs, Inkscape step, and redirected scale check are
  gone or repurposed, with the experiment README updated.
- Every verification command above passes at the declared edition target,
  with no change to the Ash pin.
