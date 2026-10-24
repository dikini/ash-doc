# Worked illustration examples

Read each example in the same order: problem, interpretation, prose brief,
construction, appearance/filter, and review/limits. These are authoring stages,
not a fence grammar. The problem summaries reconstruct context from saved
briefs, construction, and feedback; they are not verbatim original requests.
The linked fences are the actual saved descriptions. Replaying drawing code
rebuilds an interpretation; it does not understand a changed problem.

## Pair input versus separate inputs

**Problem.** Help the reader compare receiving one pair of Ints with the
literal signature `Int -> Int -> Int`, using the lesson's solid type squares.

**Interpretation.** Attachment denotes one composite input with two components;
the seam distinguishes them. Add needs three separate positions. A function
result enclosure answers a different question and was rejected for this
comparison. Neither picture is a heap trace or conversion between values.

**Prose brief.** Request attached blue squares for the pair, a separate result,
and three separate matching squares for add. Keep signatures in captions.
Read the [lesson fences](../../../../content/learn/values-travel-together/README.md)
and [accepted local rules](pilot.md), including the shared margin aside.

**Construction.** Explicit vector geometry controls the meaningful attachment
and seam. The lesson's
[sidecar](../../../../content/learn/values-travel-together/assets/fig-sum-pair/illustration.json)
and [drawing source](../../../../content/learn/values-travel-together/assets/fig-sum-pair/draw.py)
retain the choices; the [wrapper](../../../../rendering/illustrations/author.mjs)
rebuilds the complete final artwork for the two named figures.

**Appearance/filter.** The accepted lesson resolves mild rough strokes and
Excalifont. Saved settings persist until explicit revision. These glyph and
stroke adapters are not arbitrary-SVG filters.

**Review/limits.** Inspect seam continuity, matching square size, separation,
caption placement, and margin-width labels. These are integrated lesson figures
with scoped English/Bulgarian cross-format evidence; owner Bulgarian translation
recertification remains separate. Do not invent mappings for new types. This
reference edit does not refresh the rendering evidence.

## Tree repair with stable identities

**Problem.** Follow the same associations and four ordered subtrees through a
left-left repair, adapting an existing lesson comparison.

**Interpretation.** Upper circle halves denote forms; lower identity colors
track associations as their positions change. Triangles denote subtrees. The
middle association becomes root while subtree order remains. The state arrow
is distinct from within-tree edges; it makes no mutation or allocation claim.

**Prose brief.** Describe both trees, attachments, stable colors, before/after
order, and label-free artwork. Read the
[saved brief](../../../../rendering/illustrations/tree-trial.md).

**Construction.** Use split-md native trees, not hand-placed shapes. The
[saved source](../../../../rendering/illustrations/tree-trial.json)
and [cycle](../../../../rendering/illustrations/tree-cycle.mjs) retain the
interpretation. This cycle authenticates the checkout against the consumer
pin; a newer upstream checkout can block replay without authorizing a pin move.

**Appearance/filter.** The [tree adapter](../../../../rendering/illustrations/split-sketch.mjs)
applies mild rough strokes while protecting fills and topology. There are no
printed labels, so this does not verify Excalifont tree lettering.

**Review/limits.** Follow identities and subtree order before judging strokes.
The original renderer painted connectors over node interiors; that exposed a
renderer bug, not a need for extra filtering. Check source layering first.
The [adapter checks](../../../../rendering/illustrations/split-sketch.test.mjs)
and standalone reviews do not certify changed lesson EPUB or production PDFs.

## Request and reply sequence

**Problem.** Explain a caller receiving an item through a service that delegates
a read to a store, rather than the caller contacting the store directly.

**Interpretation.** Fixed participants exchange four downward-ordered messages:
caller request, delegated request, store reply, service reply. Solid/dashed
arrows distinguish requests/replies, not storage internals or error handling.

**Prose brief.** Name participants, message labels, directions, order, and arrow
styles. Exclude retries and failures. Read the
[saved brief](../../../../rendering/illustrations/sequence-trial.md).

**Construction.** Choose Mermaid sequence layout for lifelines and messages.
The agent wrote the [Mermaid source](../../../../rendering/illustrations/sequence-trial.json);
the [cycle](../../../../rendering/illustrations/sequence-cycle.mjs) uses the
pinned renderer and outlines final labels. The prose fence is not Mermaid code.

**Appearance/filter.** This example deliberately uses regular lettering and
crisp strokes, with no rough filter. Lifelines, markers, and meaningful reply
dashes are not proven compatible with the box/tree filters. Do not silently
substitute appearance if rough or Excalifont sequence artwork is requested.

**Review/limits.** The [checks](../../../../rendering/illustrations/sequence-cycle.test.mjs)
assert participant/message order. Inspect directions and labels as well as
layout. Standalone HTML/print review does not establish production lesson
EPUB/PDF suitability or untried appearance combinations.

## Foldr with typeset mathematical structure

**Problem.** Adapt a supplied foldr picture without its yellow background or
frame. Unlike foldl below, this task starts from a visual reference.

**Interpretation.** Colon-to-f and []-to-z replacement preserves the
right-associated structure and corresponding numbered leaves. The intended
composition is a compact mathematical silhouette, not colored nodes.

**Prose brief.** Request paired diagonal spines, corresponding numbered leaves,
an operation arrow, serif mathematical lettering, and italic f/z. Read the
[saved brief](../../../../rendering/illustrations/fold-trial.md).

**Construction.** Direct SVG geometry controls placement and typography. The
[state](../../../../rendering/illustrations/fold-trial.json)
and [drawing source](../../../../rendering/illustrations/fold-trial.py) retain
the construction and pinned outlined fonts. Identical branch starts initially
overlapped italic f: meaningful correspondence did not require identical offsets.

**Appearance/filter.** The [wrapper](../../../../rendering/illustrations/fold-sketch.mjs)
roughens connector segments, protecting math lettering and the tiny filled
arrowhead. Hand-drawn strokes need not mean handwritten fonts. The Python base
drawing alone is not the complete final-artwork rebuild command.

**Review/limits.** Check leaf correspondence, association, descender clearance,
and transparency. The [geometry check](../../../../rendering/illustrations/test_fold_trial.py)
and [filter check](../../../../rendering/illustrations/fold-sketch.test.mjs)
protect endpoints and lettering. Standalone review does not certify production
lesson EPUB/PDF layouts. Compare the structural alternative below.

## Foldr with colored structural trees

**Problem.** Explain the same replacement with split-md's circles and triangular
leaves. The author requested rough-only output to judge its structural reading.

**Interpretation.** Blue colon circles become orange f circles. Numbered leaves
retain colors and order; [] and z share a further color. Labels carry identity
alongside color. The right-associated topology stays unchanged.

**Prose brief.** Specify both trees, matching leaves, labels, operation arrow,
and appearance. Retain the common leaf baseline despite its long branches.
Read the [saved brief](../../../../rendering/illustrations/fold-tree-trial.md).

**Construction.** The [adapter](../../../../rendering/illustrations/fold-tree-trial.mjs)
extracts exact pinned layout sources from Git without moving the checkout or
pin. Solid function colors, labels, and side-by-side composition are explicit
authoring adaptations, not split-md grammar features.

**Appearance/filter.** Apply seeded rough strokes and pinned Excalifont through
the [outlining helper](../../../../rendering/illustrations/fold-tree-labels.py).
Paint connectors behind filled shapes. The earlier label-free repair trial
did not establish this labelled combination; this trial exercises it.

**Review/limits.** The author accepted the result. The
[check](../../../../rendering/illustrations/test_fold_tree_trial.py) covers
counts, labels, matching leaf colors, and edge-first paint order. Wide, narrow,
and grayscale HTML were inspected; phone labels benefit from enlargement.
Production EPUB/PDF remain unverified. Reuse style, not this topology, for foldl.

## Foldl with structural reassociation

**Problem.** Given a Haskell definition and a request for the preceding style,
infer a picture without a supplied diagram. Feedback clarified that the desired
comparison was constructor replacement, not recursive-call snapshots.

**Interpretation.** The list branches right, but the accumulated expression
branches left, with leaves z, 1, 2, 3. Each f takes the old accumulator on its
left. First/next/last identify recursive extensions, not forced evaluation times.

**Prose brief.** Specify association, seed position, matching elements, labels,
and the evaluation-order exclusion. Read the
[saved brief](../../../../rendering/illustrations/foldl-replacement.md) and
[full walkthrough](foldl-worked-example.md), which retains the definition,
alternative composition, feedback, and reasoning.

**Construction.** The [adapter](../../../../rendering/illustrations/foldl-replacement.mjs)
saves separate split sources and asserts both parsed associations before layout.
Recoloring the foldr tree would preserve the wrong argument structure.

**Appearance/filter.** Reuse rough strokes, filled circles/triangles, and
outlined Excalifont, not the earlier topology. Keep annotations clear of edges.

**Review/limits.** The author accepted the reassociation diagram as a skill
example. Check leaf order, seed position, argument order, annotation clearance,
repeat-render agreement, and SVG portability. The snapshots remain useful for
a different question. Phone labels need enlargement; production EPUB/PDF remain
unverified. Acceptance is not a rule for every fold diagram.

## Shared boundary

All examples retain reproducible construction that generates final SVGs.
Integrated figures retain accepted SVG assets; trial SVGs may exist only in
generated output and need explicit rebuilding. Preparation only substitutes
saved artwork; it never interprets the problem, decides semantic
freshness, or invokes drawing/filtering. Changes require authoring judgment.
See [filter guidance](approaches.md#apply-an-optional-filter) for supported inputs,
protected geometry, phase order, and deterministic checks. Generated `.build/`
previews may be absent; use checked-in sources and reproduction commands.
