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

Keep this small tool while the pilot needs it. Replace it when another
authoring representation can preserve construction, defaults, and portable
SVGs more simply. It establishes no general scene language, filter registry,
automatic freshness rule, or build-time model invocation.

[decision]: ../../docs/project/illustration-authoring.md
[rough-api]: https://github.com/rough-stuff/rough/wiki
[font]: https://github.com/excalidraw/excalidraw/tree/b7de45e88111f5680ae4bb3c3f3541c7d3b279fe/packages/excalidraw/fonts/Excalifont
