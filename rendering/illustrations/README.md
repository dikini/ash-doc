# Author the pilot illustrations

Can an author choose a shared appearance without making document assembly
interpret illustration requests? This authoring tool applies saved lettering
and stroke settings to the two input-shape illustrations. It targets FFI Base,
Ash commit `354c76b391fe4af665cf6a03479a9874a57cb3e3`. It changes no language
claim or compiler input. The [illustration decision][decision] owns the boundary.

## Select and save appearance

Defaults resolve per setting, from lowest to highest priority:

1. `illustrationDefaults` in `rendering/styles/diagram-style.json`.
2. `illustration-defaults` in the lesson's YAML front matter.
3. An explicit illustration request, interpreted by the authoring agent.

The global choice is regular lettering and crisp strokes. The pilot lesson
selects:

```yaml
illustration-defaults:
  font: excalifont
  stroke: mild
```

The agent can interpret “use rough strokes” in a fence as a request override.
There is no prose parser. Pass the interpreted choice explicitly:

```sh
node rendering/illustrations/author.mjs \
    --lesson content/learn/values-travel-together/README.md \
    --figure fig-add-inputs --resolve-defaults --override '{"stroke":"rough"}'
```

Omit `--override` to adopt the document/global defaults. This example is an
authoring operation, not a document-build command; it replaces that figure's
accepted SVG after successful validation. The pilot currently selects mild,
not the rough override shown above.

The resolver accepts `font`, `stroke`, `roughness`, `bowing`, and `seed`.
Font choices are `regular` and `excalifont`; stroke choices are `crisp`,
`mild`, `rough`, and `custom`. Numeric roughness alone selects custom.
Choosing a stroke resets its roughness/bowing preset; explicit numeric values
in the same layer override those values. Crisp requires zero roughness.
Unknown fields, unsupported choices, and invalid numbers fail.

| Stroke | Roughness | Bowing |
| --- | --- | --- |
| Crisp | 0 | 0 |
| Mild | 0.6 | 0.5 |
| Rough | 1.8 | 1 |
| Custom | Explicit 0–5 | Inherited or explicit |

The saved `construction.appearance` records resolved values, including seed.
`appearanceSelection` records the default sources and interpreted request.
A normal rebuild uses the command in `illustration.json`, without
`--resolve-defaults`. It reads saved settings, not current document/global
defaults. Changing defaults does not change accepted artwork or trigger a
freshness decision. Adopt new defaults only through explicit authoring review.

## Construction phases and dependencies

The authoring command supports only `fig-sum-pair` and `fig-add-inputs` in
`content/learn/values-travel-together/`. It runs the lesson-local `draw.py`
to construct crisp geometry in temporary storage, selects outlined lettering,
and applies seeded Rough.js strokes. It validates the result and saves the
crisp intermediate as `base.svg`, the final as `figure.svg`, and resolved
state beside them. A failed drawing or validation preserves accepted files.

The drawing programs consume shared diagram colors and dimensions. The font
phase preserves text, centers, baselines, size, color, geometry, titles, and
descriptions. Regular lettering bypasses replacement. Excalifont glyphs are
outlined, not embedded. Missing characters fail rather than silently falling
back. This bundled subset is Latin only; both lesson languages currently share
the figures' English labels. New Cyrillic labels need a separately verified
font subset.

The stroke phase recognizes the pilot's exact rectangle/path roles and
protects every outlined `g[aria-label]` group. It keeps flat blue fills,
anchors the pair seam to vertices in the one outer contour, and preserves the
three separate boxes. Geometry transforms, unexpected structure, unmarked
lettering, and disconnected seams are rejected. Zero roughness retains the
selected source bytes. This is not an arbitrary SVG converter.

Rough.js 4.6.6 and Chrome 152.0.7977.75 come from the existing frozen toolchain.
The runner checks the source/installed lock, Rough.js version, and Chrome.
Each figure/role receives a stable seed derived from saved seed 1729.
The [Rough.js API][rough-api] documents these parameters. Rough.js is
MIT-licensed; its installed package retains the license.

The unmodified Excalifont Latin subset comes from the [official directory][font]
at commit `b7de45e88111f5680ae4bb3c3f3541c7d3b279fe`, version 1.000:
`Excalifont-Regular-a88b72a24fb54c9f94e3b5fdaa7481c9.woff2`.
Its checked SHA-256 is
`e4423b318e11432aff2e6e865e300b7ca270f92321a3f56632268fede01c1b48`.
The [retained license](fonts/LICENSE.txt) includes copyright, design credits,
and SIL Open Font License 1.1.

Prepare Python dependencies explicitly, never during document preparation:

```sh
uv pip install --target .build/illustration-python \
    fonttools==4.61.1 Brotli==1.1.0
```

Document preparation continues to read only the saved JSON envelope and SVG.
It does not load defaults, execute these phases, interpret requests, or assess
freshness.

## Compare and verify

```sh
node rendering/illustrations/settings.test.mjs
node rendering/illustrations/sketch.test.mjs
node rendering/illustrations/sketch.mjs
```

The comparison writes twelve preset SVGs to ignored
`.build/illustration-sketch/`, with `index.html`, `comparison.typ`,
`report.json`, and captures. The HTML independently selects lettering and
stroke, permits custom numeric roughness, and downloads outlined SVGs.
Invalid input preserves the last valid preview. It shows images at 50 mm,
matching the A4 margin, with an enlargement control. The book margin is 2 inches.

```sh
.build/toolchain/quarto-1.10.19/bin/quarto typst compile \
    --font-path rendering/fonts --ignore-system-fonts \
    .build/illustration-sketch/comparison.typ \
    .build/illustration-sketch/comparison.pdf
```

Focused tests cover precedence, partial/request overrides, invalid settings,
determinism, glyph replacement, protected labels, missing characters, fills,
seam attachments, distinct boxes, and rejection boundaries. The comparison
runner exercises browser controls and download agreement. It records input
and output hashes, dependency pins, and parameters. The authoring command
checks repeated-render byte agreement and the current source SVG validator.

Mild Excalifont styling is selected for the pilot. Rough strokes remain
available but their doubled arrow shaft attracts more attention. Standalone
comparison previews do not certify lesson layout: review selected HTML, EPUB,
and both PDF layouts when adopting a treatment. The decision record retains
actual verification evidence and remaining review boundaries.

## Other shapes: bounded tree trial

The approved follow-up compares the red-root sketch and left-left repair from
*Guaranteeing logarithmic retrieval*. The adapter uses the existing split-md
pin's structured scene, not a blind pass over every SVG path. It verifies the
exact checkout commit, the bundle hash, and all five source modules against
their committed bytes before importing them. Upstream split-md is unchanged.

The trial supports split/solid circles, Empty leaves, triangular subtree
markers, within-tree edges, and downward phase arrows. Filled semicircular
paths stay untouched; triangle fills retain their original geometry. Only
visible contours and connectors receive seeded rough strokes. Edges keep
their canonical center-to-center endpoints. As in the current renderer, they
extend into node centers; this trial does not reinterpret attachment geometry.
There are no clipping definitions or printed labels in these trees. Clipped
square rows, arbitrary SVGs, and font substitution in tree labels are not
verified by this trial. Unsupported scene elements or geometry fail closed.

```sh
node rendering/illustrations/split-sketch.test.mjs
node rendering/illustrations/split-sketch.mjs
node rendering/illustrations/tree-cycle.mjs
node rendering/illustrations/tree-cycle.mjs --rebuild
```

The comparison lives in `.build/split-sketch/index.html`, with crisp/mild/rough
SVGs, margin/enlarged captures, `comparison.typ`, and a parameter/hash report.
Compile `comparison.typ` with the same pinned Typst command used above, changing
the input/output directory to `.build/split-sketch/`. Review color and grayscale
at 50 mm width. The rough preset visibly separates some circular strokes from
the unchanged fill edge; mild retains a closer contour. No tree treatment is
adopted in the lesson.

### Description-to-diagram cycle

The [prose brief](tree-trial.md) is the request. The
[construction record](tree-trial.json) is this agent's interpretation of it,
not output from an automatic prose parser. It keeps association identity and
subtree order across a left-left repair, using the program's named pieces.
The replay command does not invoke a model or claim to interpret arbitrary
new descriptions. A changed brief still requires authoring judgment.

`tree-cycle.mjs` explicitly renders that construction, resolves appearance,
and saves the brief, state, crisp intermediate, and final SVG together under
`.build/split-sketch/end-to-end/`. Its `--rebuild` mode uses saved construction
and appearance, not current defaults. Both paths assert repeated SVG byte
agreement. The state records the request hash, interpretation, dependency
hashes, and the exact rebuild command. Excalifont is selected in document
defaults but not applied because the requested artwork has no printed labels.

The separate `prepare-trial.py` calls the existing `prepare_chapter` adapter
on the saved local trial. It substitutes the SVG with zero authoring jobs and
hides the prose fence. The cycle checks that changing only the brief does not
change prepared artwork and that a missing SVG fails instead of generating
one. It then prepares a self-contained HTML preview and a browser-printed A4
PDF. The prepared image hash agrees with the saved asset. Six focused shape
tests pass, including determinism, metadata/fill preservation, distinct roles,
fixed edge endpoints, and rejection cases.

These previews exercise an isolated authoring/assembly cycle. They do not
certify a changed lesson in HTML, EPUB, or either production PDF layout.
Accepted lessons, translations, renderer pins, and document preparation remain
unchanged. Remove the trial if rejected; promote only the smallest supported
adapter after its lesson integration receives separate review.

## Mermaid sequence trial

The [sequence brief](sequence-trial.md) requests a caller → service → store
lookup and its two replies. The agent's [interpretation](sequence-trial.json)
records three Mermaid participants and four messages in the requested order.
The document contains a prose illustration fence, not a Mermaid fence.

```sh
node rendering/illustrations/sequence-cycle.test.mjs
node rendering/illustrations/sequence-cycle.mjs
node rendering/illustrations/sequence-cycle.mjs --rebuild
```

This trial uses Mermaid 12.1.0 through CLI 12.0.0 and the existing vector
outlining adapter. It checks installed versions, the frozen dependency lock,
and bundled font hashes. The authoring operation saves `source.mmd`, resolved
appearance, renderer/provenance state, and outlined `figure.svg` under
`.build/mermaid-sequence/assets/fig-item-lookup-trial/`. Rebuild mode uses that
saved construction and appearance; no model or prose parser runs in replay.

Regular lettering and crisp geometry are explicit choices for this first
sequence trial. The box/tree roughening adapters are not applied to Mermaid's
lifelines, arrow markers, or reply dashes. Handwritten lettering and sketch
strokes for sequences remain unverified, rather than being silently simulated
by those adapters.

The existing pure document adapter substitutes the saved SVG and hides the
brief. Controls verify that a changed brief does not regenerate the image,
and a missing SVG fails. Two focused tests check participants, message order,
and request/reply arrow kinds. Two authoring renders agree byte-for-byte;
saved-state rebuilds reproduce the same image. The resulting SVG passes the
source-image validator and contains outlined lettering, not runtime text.

The HTML preview at `.build/mermaid-sequence/index.html` links to the prose
brief, Mermaid construction, saved state, and final SVG. The wide diagram
scrolls horizontally on narrow screens rather than shrinking its labels.
Browser checks verify image loading and narrow scrolling. The trial includes
a browser-printed A4 PDF; these are local previews, not production lesson
HTML/EPUB or either Quarto PDF layout certification. Accepted lessons,
translations, shared rendering behavior, and all pins remain unchanged.

## Typeset mathematical tree trial

The [fold brief](fold-trial.md) requests matched diagonal trees in the style
of the supplied visual reference, without its background or frame. The
[construction](fold-trial.json) records shared branch geometry, numbered
leaves, colon constructors on the left, and italic `f`/`z` on the right.
The native SVG drawing program uses shared ink and hash-checked bundled
Pagella regular/italic outlines; it copies no pixels or source artwork.

```sh
python3 rendering/illustrations/test_fold_trial.py
PYTHONPATH=.build/illustration-python python3 rendering/illustrations/fold-trial.py
node rendering/illustrations/fold-sketch.mjs
node rendering/illustrations/fold-sketch.test.mjs
python3 rendering/illustrations/prepare-trial.py \
    .build/fold-trial/README.md .build/fold-trial/document
```

Saved state and SVG live together under `.build/fold-trial/`, with an ordinary
saved-image preparation trial. The focused test checks repeated byte agreement,
matching leaf attachments and spine geometry, corresponding labels, clearance
below italic `f` descenders, and absence of background rectangles,
runtime text, scripts, images, and filters. The result passes the source SVG
validator. Inspect it as body-width artwork, not as an accepted margin figure.
The transparent SVG can look dark on a dark viewer canvas; the document preview
shows the same asset on its normal page without adding a background to the SVG.
HTML and a standalone A4 print preview are local reviews, not adoption in a
lesson or cross-format book certification. This is a mathematical illustration,
not a claim about Ash syntax or library behavior.

The requested hand-drawn revision keeps the mathematical lettering and roughens
only the 21 connector/arrow-shaft segments. The tiny filled arrowhead remains
crisp. A saved roughness of 1.8, bowing of 1, and seed 1729 reproduce the result.
`fold-sketch.mjs` constructs the crisp base explicitly, saves it as `base.svg`,
then writes the styled `figure.svg` and resolved renderer provenance. Its test
checks byte agreement, unchanged lettering, anchored segment endpoints, and
continued transparency. Numbered branches on the right retain clearance below
the italic `f` descenders. A crisp/mild/rough comparison is available at
`.build/fold-trial/comparison.html`; document preparation still reads only the
selected saved SVG. The drawing program alone rebuilds the crisp intermediate,
not the selected hand-drawn final.

Keep this small tool while the pilot needs it. Replace it when another
authoring representation can preserve construction, defaults, and portable
SVGs more simply. It establishes no general scene language, filter registry,
automatic freshness rule, or build-time model invocation.

[decision]: ../../docs/project/illustration-authoring.md
[rough-api]: https://github.com/rough-stuff/rough/wiki
[font]: https://github.com/excalidraw/excalidraw/tree/b7de45e88111f5680ae4bb3c3f3541c7d3b279fe/packages/excalidraw/fonts/Excalifont
