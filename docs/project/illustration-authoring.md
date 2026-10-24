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
  stroke: mild
```

Both pilot figures adopt those settings with roughness 0.6, bowing 0.5, and
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

## Pilot evidence

The implementation passes eleven focused adapter tests, including nested
fences, source preservation, invalid artwork, and missing or escaping assets.
The parser/writer integration test uses the installed standalone Pandoc; it is
not evidence for the pinned Quarto output layouts. The skill passes its
front-matter validator. Repeated authoring renders produce identical SVG bytes.
The standalone pilot image has been inspected.

A separate skill trial reconstructed the lesson and saved construction and
recommended preserving the vocabulary during a targeted boundary-emphasis
revision. That source review does not establish final-size visual acceptance.

### Verified toolchain

On 2026-10-24, the cached Quarto 1.10.19 Linux amd64 archive hashed to
`8e38c2b2df6a6dbd369ea16e15acded6894545258d13a02f777f81ad18fd7973`.
This agrees with the unchanged manifest, retained GitHub release asset digest,
and a fresh download of the official release checksum list. The complete
`python3 rendering/bootstrap.py --offline` check passes. No checksum check was
disabled and no tool pin changed. The earlier mismatch is not reproducible
with this archive; the rejected bytes were not retained, so its cause remains
unknown. Do not infer that an arbitrary replacement archive is acceptable.

### Selected lesson review

Both English and Bulgarian lesson scopes build in HTML, EPUB, book PDF, and A4
PDF with the pinned toolchain. Artifact checks retain the saved SVGs as two
canonical lesson assets and preserve all nine code/transcript blocks. EPUBCheck
5.4.0 reports no errors or warnings. English PDFs contain nine and eight pages;
Bulgarian PDFs contain nine pages in each layout.

The English browser review passes desktop and 390-pixel HTML checks and
390-pixel EPUB reflow at a 28-pixel root font in Chrome and Firefox. Visual
inspection of the figure at these sizes and in both print layouts confirms
that the shared contour, component seam, arrow, and result remain distinct,
with the caption below. The brief does not appear in the outputs. Print review
is limited to this lesson, not complete-book pagination. The saved SVG retains
English labels in both languages; the Bulgarian caption and description
explain the same relationship.

Review artifacts live under ignored `.build/lessons/learn/values-travel-together/`
and `.build/illustration-bg/`; page previews and focused figure captures live
under `.build/illustration-review/`. Reproduce the builds with:

```sh
python3 rendering/build.py --lesson content/learn/values-travel-together/README.md
python3 rendering/build.py \
    --lesson content/learn/values-travel-together/README.bg.md \
    --lang bg --output .build/illustration-bg
```

Rebuilding the crisp intermediate with fontTools 4.61.1 produces identical bytes,
with SHA-256
`b29bccfb86b7c5dc6025831bc1e55f8a7f746bf4bb1416fd6683388d4459bea0`.
The ten adapter tests and skill validator pass. The rendering suite runs 111
tests: 110 pass directly; the token-worktree fixture requires signing disabled
for its temporary Git commit. Rerunning its twelve-test module with
`GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=commit.gpgsign GIT_CONFIG_VALUE_0=false`
passes without changing repository or user Git configuration.

### Bulgarian synchronization and remaining boundary

The comparison revision's `compare` pass produced 30 divergences. Agent review
retained the existing wording, including the new captions and descriptions;
the fresh description also failed a protected-term check. `converge` consumed
the adjudications and refreshed the exact English claim. The illustration fence
is transplanted byte-identically. The comparison table retains its words with
restored Markdown row breaks. `content/checks/translation/sync.sh` passes.

The previous owner certification predates the new figure metadata. The lesson
therefore returns to `mt-draft` pending renewed owner certification; this agent
review does not claim human approval. These scoped checks do not publish the
edition or certify a whole-book build.

The Bulgarian review exposed three checker failures on generated `index.html`:
its Cyrillic heading yields a percent-encoded URL fragment, while the checker
compared it with an unencoded Pandoc identifier. The approved follow-up fixes
the browser checker to decode URL fragments once before comparing them with
heading IDs, including keyboard-navigation waits. Page headings, IDs, and URLs
remain unchanged. A regression test covers Cyrillic, ASCII, encoded reserved
characters, literal percent escapes, and distinct heading IDs. All thirteen
browser unit tests pass. Rerunning both scoped browser reviews passes all 68
checks per language, including the formerly failing Bulgarian index navigation
and enlarged EPUB review in Chrome and Firefox.

The function signature now appears in each language's figure caption rather
than inside the artwork. The drawing removes that label and its vertical space;
the pair contour, seam, type labels, and arrow retain their meanings. The
lesson brief and construction record retain this requested separation.

The companion `fig-add-inputs` has three separate blue squares and arrows
between adjacent positions, following the author's literal-signature choice.
Its square size, color, and labels align with `fig-sum-pair`; the two pair
components remain attached. No region encloses the remaining function.
Repeated renders of the companion's crisp intermediate with fontTools 4.61.1
agree at SHA-256
`d5b70b9f6592d0509f7ec7ce23f2c8c1f5d93c45db2ae4108eb77f9fdfff48c6`.
Canonical Ash programs and captured observations are unchanged; their
exact-pin execution evidence is reused.

The two fences now share one `.column-margin` Div after the comparison
paragraph. Their reading order remains pair, then separate inputs. Desktop
HTML and both PDFs place the group in the margin; narrow HTML and EPUB retain
it in ordinary reading order. Margin-size inspection required larger outlined
labels: both drawings now use size 28, with lower labels shortened to
`pair input` / `result` and `first` / `second` / `result`. The captions and
alternative descriptions still identify the input and result roles.
The prose and translated metadata did not change during this placement step;
`converge` refreshed the English claim after reviewing the byte-identical Div
and fence transplants. Aside previews live in `.build/illustration-review/aside/`.

### Defaults and styled artwork verification

On 2026-10-24, the defaults resolver passes two focused tests and the style
phases pass twelve. Eleven adapter tests include a new boundary check:
document preparation substitutes saved SVG bytes even when authoring defaults
and saved appearance settings are invalid. It neither resolves those settings
nor executes authoring code. The twelve token-sync tests pass with signing
disabled for the fixture's temporary Git commit; shared tokens are unchanged.
The updated authoring skill passes its structural validator.

Explicit default adoption selects Excalifont and mild strokes for both figures.
Rebuilding from saved settings produces identical bytes. Current final hashes:

`fig-sum-pair`:
`c7529e966d9b57a2c589940b2ba93570d884db7122f11b1f413f49a68316e93d`.

`fig-add-inputs`:
`54d003bc6a8ca4b494f8bc8ae91824440e57eede54425d078f4ad6609e9086f2`.

The English and Bulgarian YAML defaults agree. No prose or translated captions
changed; `converge` refreshed the English drift claim after reviewing that
structural transplant. Translation sync passes; owner recertification remains
pending at `mt-draft`.

Both language scopes rebuild HTML, EPUB, book PDF, and A4 PDF. Artifact checks
pass, EPUBCheck 5.4.0 reports no errors or warnings, and all 68 browser checks
pass per language, with enlarged EPUB reviewed in Chrome and Firefox. Visual
inspection covers the figure group in desktop/narrow HTML, enlarged EPUB, and
both PDF layouts, including grayscale. Labels, seam, separate boxes, captions,
and margin placement remain readable. Captures are retained locally in
`.build/illustration-review/defaults/`. Canonical Ash programs and their
promises are unchanged; exact-pin executable evidence is reused.

### Tree-shape and end-to-end trial

The [bounded tree trial](../../rendering/illustrations/README.md#other-shapes-bounded-tree-trial)
extends the comparison to split circles, Empty leaves, triangular subtrees,
edges, and phase arrows using unchanged, pinned split-md scene geometry.
It preserves fills and canonical edge endpoints; only visible strokes change.
Six focused tests pass. Crisp/mild/rough SVGs, margin/enlarged views, and a
standalone print comparison are retained under `.build/split-sketch/`.

A separate prose brief is interpreted by the agent into saved split
construction. Its replay checks description → saved state/SVG → pure document
preparation, including changed-brief and missing-asset controls. Rebuilds use
saved appearance and reproduce the SVG bytes. The replay never invokes an
agent. These are isolated authoring trials, not adopted tree assets or final
lesson-format verification. No upstream renderer or document-build behavior
changes.

### Mermaid sequence authoring trial

The [sequence trial](../../rendering/illustrations/README.md#mermaid-sequence-trial)
exercises another construction renderer without changing the illustration
envelope or document adapter. A prose brief becomes agent-authored Mermaid
sequence construction, then a saved outlined SVG. Caller, Service, and Store
exchange two solid-arrow requests followed by two dashed-arrow replies.

Two focused checks and the SVG validator pass. Repeated renders and saved-state
rebuilds agree byte-for-byte. Changed-brief and missing-asset controls confirm
that document preparation substitutes saved artwork without authoring or
freshness decisions. HTML and a standalone A4 print preview live under
`.build/mermaid-sequence/`. This first trial uses regular lettering and crisp
strokes; sequence-specific sketch styling and lesson integration are not
claimed. No accepted content, renderer pin, or document-build behavior changes.
