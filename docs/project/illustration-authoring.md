# Author illustrations in lesson context

An author should be able to request an illustration beside the passage it
explains, review the result, and rebuild accepted artwork without recovering
an agent conversation. This bounded decision implements that workflow for the
pair-input figure and its `add` comparison in *Making values travel together*.
The discussion approved
agent-led authoring, lesson-local construction state, and deterministic document
assembly. It leaves Ash at FFI Base, commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`.

## Choice and ownership

An ordinary Markdown image with a separate prompt would need no fence adapter,
but would separate the request from the passage. An `illustration` fence keeps
the brief in reading order and replaces it with accepted artwork during
preparation. Select the fence for this pilot. Keep existing native SVG images
and notation fences supported; migrate neither automatically.

The [authoring skill](../../.agents/skills/author-ash-illustrations/SKILL.md)
guides the agent. The lesson owns its brief. An asset directory owns the accepted
construction, optional drawing program, provenance, and SVG. The existing
figure metadata owns its caption and alternative description. Document
preparation resolves the SVG and uses the existing source-image validation,
staging, and hashing. It does not invoke drawing code or an agent.

## Source and asset contract

Use Pandoc's attributed code-fence syntax:

````markdown
```{#fig-sum-pair .illustration}
Show sum_pair receiving one pair containing two Int slots and producing one
Int slot. Attach the two input squares. Use the same color for every Int.
```
````

The content is the authoring request, not JSON or rendered lesson prose. The
agent reads the surrounding section, relevant canonical code, and referenced
examples. Add a missing stable `fig-` ID during authoring. Keep it when the
request changes. The document generator rejects an absent or duplicate ID.

Add an entry with `kind: illustration`, matching `id`, `caption`, and
`description` to the lesson's existing `diagrams` list in fence order. The
request stays in the fence; do not copy it into front matter.

The `.illustration` class is the explicit fence tag in Pandoc's attributed
syntax; the same attributes retain its stable ID. To place an authored figure
in an unnumbered margin note, wrap the fence in a `.column-margin` Div. A
numbered sidenote can contain the fence in its indented footnote definition.
The adapter substitutes saved artwork in either location; the usual note
layout controls placement. Review label size at margin width before selecting
that layout. The two comparison figures share the `note-input-shapes` margin
aside beside the comparison paragraph and table.

Resolve `assets/<id>/illustration.json` beside the lesson. The document
generator requires this small envelope:

```json
{
  "version": 1,
  "svg": "figure.svg"
}
```

The JSON may also contain `construction`, `renderer`, and `provenance` fields.
Their contents belong to the selected drawing tool and authoring skill, not
the document generator. `svg` is a plain relative path within that asset
directory. Referenced files must stay within the lesson even through symlinks.
The SVG must meet the existing outlined, self-contained source-image contract.

Keep small construction data in JSON; retain a drawing program when necessary.
Reference the shared `rendering/styles/diagram-style.json` and bundled fonts
rather than copying them. Record tools required to rebuild the artwork beside
its construction. These authoring dependencies do not become document-build
dependencies. The pilot uses Python and fontTools for outlined labels.

## Author, revise, and assemble

The agent decides whether to preserve, create, revise, or regenerate state.
It may propose the initial brief or infer additional requirements, preserving
the author's wording and identifying its interpretation separately. A changed
input hash is evidence for review, not a regeneration command. An existing SVG
without state needs inspection; do not overwrite it automatically.

The agent invokes the selected drawing tool, inspects the image, and updates
the SVG reference after successful generation. Preserve existing work if
generation fails. Review meaning separately from composition and appearance.
Use the current construction during revision instead of restarting by default.

Document preparation reads only the saved JSON envelope and SVG. It substitutes
the fence at its original location, including notes and Divs, then applies the
usual caption, alternative description, asset staging, and output pipeline.
It does not compare request or context hashes. Missing state, invalid JSON,
missing SVGs, mismatched figure metadata, and invalid SVGs fail preparation.
The authoring brief must never leak into published code blocks.

## Shared shape sizes and lesson migration

The approved extension migrates the three input figures and five tree figures
to prose illustration fences. Their IDs, captions, descriptions, relationships,
and note/body placements remain stable. Split-md syntax now belongs to saved
construction, not the learning page. The named wide repair uses the program's
original association names. Its obsolete standalone SVG is removed after the
new reproducible asset is saved.

`illustrationSizes` in the shared style specifies physical primitive sizes:
aside squares are 6.5 mm, aside circle diameters 5 mm, body squares 9 mm, and
body circle diameters 8 mm. There is no body-square figure in this migration.
Roughness may vary a contour around that nominal geometry; it must not change
the construction's intended size or topology. Longer rows receive greater
image width, not smaller squares. Figures do not independently grow to fill notes.

HTML adds a shared presentation scale for authored illustrations in notes:
1.1 at desktop widths of at least 992 px with a note column at least 210 px
wide, 1.5 when the note's own inline
width reaches 450 px, and 1 otherwise. The wide-inline rule takes precedence.
This gives inline notes more presence without making the four repair cases
use different circle diameters. Tight note columns apply a shared fit factor
against a 50 mm reference span, large enough for the widest nominal aside.
This prevents long diagrams from shrinking their primitives independently of
shorter ones. Phone examples retain their baseline size; a narrow tablet note
column may shrink all its primitives slightly. The full-width
labelled figure, EPUB, and PDF retain their authored sizes. Preparation exposes
only the literal width and its ratio to the shared reference span as CSS
properties; CSS does not inspect construction.
The redundant red-root illustration and its numbered note have been removed.

During explicit authoring, `size.mjs` derives the complete image width from its
viewBox and primitive dimensions. Save the resolved size and literal physical
width beside construction. Put the same `width: <positive number>mm` in the
figure's YAML metadata. The drawing wrappers reject a mismatch. Updating the
shared size settings therefore requires an intentional authoring/layout review,
not an implicit document-build restyle.

Preparation validates and copies the literal width; it does not read size
defaults or construction geometry. Missing width retains the earlier full-width
behavior for unmigrated fixtures and trials. Existing responsive maximum-width
rules may shrink a wide body figure on a narrow screen or EPUB viewport; the
aside figures fit without shrinking. Do not claim absolute physical dimensions
on arbitrary screen hardware or enlarged/reflowed e-reader layouts.

`lesson-shapes.mjs` consumes the approved split-md parse/layout/style sources
from Git without changing a checkout or pin. It draws edges before fills,
roughens supported contours and guides, and outlines Excalifont labels.
It preserves type/value halves and form/identity halves. It is a bounded
authoring adapter for these saved scenes, not a universal SVG filter.

The two existing pair figures explicitly adopt rough strokes and the shared
aside square size. English/Bulgarian prose and translated captions remain
unchanged; protected illustration fences and presentation metadata are
transplanted through the existing translation workflow. Using more than one
input returns to `mt-draft` with its earlier certification retained as history;
Making values travel together remains `mt-draft`. Only the owner can renew
their certification.

## Appearance defaults

The [pilot authoring tool](../../rendering/illustrations/README.md) resolves
explicit illustration requests over document `illustration-defaults` YAML over
global `illustrationDefaults` in the shared diagram style. An agent interprets
prose such as “use rough strokes and Excalifont”; no prose parser is added.
Shared defaults avoid repeating appearance in every brief; explicit per-figure
settings alone would be simpler but duplicate the same choices. Select the
hierarchy with saved resolved settings, not build-time inheritance.

Global defaults remain regular/crisp. The selected lesson declares:

```yaml
illustration-defaults:
  font: excalifont
  stroke: rough
```

Both pilot figures adopt those settings with roughness 1.8, bowing 1, and
seed 1729. Construction records the resolved values and selection sources.
Normal artwork rebuilds use saved settings. Only an explicit authoring command
with `--resolve-defaults` adopts current defaults; an interpreted request can
override them through `--override`. Changing defaults does not alter accepted
SVGs, trigger regeneration, or affect document preparation. The crisp
intermediate `base.svg` and styled `figure.svg` remain beside the lesson assets.

The font phase outlines selected glyphs; the geometry phase protects lettering
and fills, uses seeded Rough.js from the existing frozen toolchain, and outputs
ordinary SVG paths. Excalifont is pinned with its retained OFL notice. The
bundled Latin subset supports the shared English figure labels, not new
Cyrillic labels. The tool supports only these two pilot figures, not arbitrary
SVGs. Replace it if a simpler authoring representation preserves these bounds.

## Verification and replacement

Check the pure adapter's boundaries with malformed and missing assets, duplicate
and absent IDs, nested fences, mixed notation, and source preservation. Rebuild
the pilot SVG twice and compare bytes. Review the selected lesson in narrow
HTML, enlarged EPUB, and both PDFs before claiming publication readiness.
Reuse exact-pin executable evidence while canonical code and its promises are
unchanged. Do not run the whole book for this pilot.

Keep this adapter replaceable. Remove the pilot drawing program if a pinned
split-md extension expresses the same accepted construction and retains its
visual checks. Revisit the sidecar envelope only when another concrete drawing
tool cannot supply an SVG through it. This decision creates no general scene
language, model service, automatic freshness policy, or publication mechanism.

## Current migration evidence

The scoped migration review on 2026-10-25 targets FFI Base at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. Canonical Ash programs,
observations, and executable promises are unchanged; their exact-pin evidence
is reused. There is no whole-book render or publication claim for this change.

### Tool and preparation boundaries

The pinned Quarto 1.10.19 archive has SHA-256
`8e38c2b2df6a6dbd369ea16e15acded6894545258d13a02f777f81ad18fd7973`.
It agrees with the manifest and previously checked official release digest.
Offline bootstrap passes without bypassing checksums or changing pins.
The earlier rejected archive was not retained, so the cause of its historical
checksum mismatch remains unknown.

All 114 rendering Python regressions pass, including thirteen illustration
adapter checks. These exercise nested placement, missing/invalid assets,
unchanged source, literal physical widths, mixed notation, and the prohibition
on authoring/default interpretation during preparation. The thirteen browser
helper tests, two default-resolution tests, twelve pilot appearance tests, six
tree-sketch tests, and two size-calculation tests pass. The lesson-state checks
cover all ten figures' widths, saved hashes, outlined labels, edge-first
tree layering, and the named repair's preserved association names.

The authoring wrappers assert repeated-render byte agreement. Current SVG
hashes, resolved dimensions, and dependencies live in each figure's sidecar;
this document does not duplicate hashes from an earlier appearance.

### Affected outputs

The three English lesson scopes and two Bulgarian counterparts build in HTML,
EPUB, book PDF, and A4 PDF. Artifact checks pass for all five scopes, retaining
three input assets, two pair assets, and five tree assets respectively. The
briefs do not appear in the rendered learning pages. All five EPUBs pass
EPUBCheck 5.4.0 without errors or warnings.

The four Learn/language browser reviews each pass 68 checks, including enlarged
EPUB text in Chrome and Firefox. The tree review passes 77 checks using the
stable illustration ID and literal physical widths, rather than the previous
notation-generated alias and full-container-width assumption. The separate
size review measures 105 primitive sizes across desktop, intermediate, tablet,
and phone widths using the shared HTML scale above. The baseline dimensions
are matching 6.5 mm aside squares across both lessons, 5 mm aside circles,
and 8 mm body circles. Wide
body artwork remains subject to responsive maximum-width limits on narrow
screens. Sizes are nominal layout dimensions, not calibrated screen hardware.

Visual review covers the input guides, type/value halves, pair seam, labelled
wide repair, the four compact repair cases, and both PDF layouts. Label
collisions and the
short application-arrow shaft found during review were corrected in saved
construction, not patched only in SVG. Captures and browser evidence live under
the current worktree's ignored `.build/illustration-size-review/`,
`.build/pdf-review/`, and scoped projects' `qa-browser/` directories.

Reproduce a selected English scope with:

```sh
python3 rendering/build.py --lesson content/learn/using-more-than-one-input/README.md
```

Use the corresponding `README.bg.md` plus `--lang bg` for a translated scope.
The other selected lessons are `content/learn/values-travel-together/README.md`
and `content/cases/guaranteeing-logarithmic-retrieval/README.md`.
Scoped outputs are not complete-book pagination evidence.

### Translation and remaining review

The protected illustration fences and nontranslatable metadata are identical
between English and Bulgarian. Existing translated prose, captions, and
descriptions are retained. `converge` refreshes the exact English claims after
mechanical transplant review; translation sync and all eighteen translation
tests pass. No new machine translation was needed for these protected blocks.

Using more than one input is now `mt-draft`, with its earlier owner
certification retained as history. Making values travel together remains
`mt-draft`. Both await owner review of the changed artwork and sizes.
An agent's mechanical and visual review does not renew human certification.

### Standalone skill examples

The foldr, foldl, and Mermaid examples remain separate authoring references,
not additional lesson figures. Their briefs, construction, filtering boundaries,
commands, and evidence limits are indexed by the
[worked example set](../../.agents/skills/author-ash-illustrations/references/examples.md).
The earlier tree-sketch trial remains a comparison tool; it now reads native
construction from lesson sidecars. Its explicit `SPLIT_MD_ROOT` option selects
an exact pinned checkout without relaxing commit or source-hash checks.
