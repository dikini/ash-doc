# Choose construction, appearance, and filters

Choose by the relationship the reader needs to see, not by the last renderer
used. These examples show different ways to satisfy the same illustration
contract; they are starting points, not an exhaustive catalogue or a required
visual vocabulary. Read only the example relevant to the current request.

Keep the decisions separate:

1. **Construction:** what representation and layout expose the relationship?
2. **Appearance:** what fonts, colors, and strokes suit the request and defaults?
3. **Optional filtering:** what supported transformation changes appearance
   without changing the explanation?

The workflow remains problem → inferred relationship → prose brief →
construction → optional styling/filtering → validated saved SVG → document
preparation. A specialised
notation can be saved construction without becoming the lesson's prose fence.
The agent interprets the request; replay commands do not interpret new prose.

## Choose an example

Read the [consistent worked example set](examples.md) for the reasoning behind
each brief and the construction/appearance boundaries. The entries below are
a tool-choice index; the worked set separates problem, interpretation, brief,
construction, appearance/filter, and review/limits for all six examples.

For a complete problem → inferred relationship → prose brief → construction
example, read [the foldl authoring walkthrough](foldl-worked-example.md).
It includes a useful initial interpretation that the author redirected, so
it demonstrates semantic revision rather than merely replaying drawing code.
The author accepted the final right-branching list → left-branching application
diagram; the earlier snapshots remain a contrasting alternative.

### Specific type-shape relationships: custom vector construction

The pair-input pilot needs two attached slots, one seam, and a separate result;
its companion needs three separate positions. Custom construction expresses
that contrast directly without introducing unrelated graph notation.

- [Lesson briefs](../../../../content/learn/values-travel-together/README.md)
  and [local visual rules](pilot.md).
- [Pair construction](../../../../content/learn/values-travel-together/assets/fig-sum-pair/illustration.json)
  and [drawing code](../../../../content/learn/values-travel-together/assets/fig-sum-pair/draw.py).
- [Authoring command](../../../../rendering/illustrations/author.mjs) and
  [appearance checks](../../../../rendering/illustrations/sketch.test.mjs).

This pilot demonstrates default resolution, regular/Excalifont lettering,
and crisp or seeded sketch strokes. The command and glyph-replacement phase
support the two named figures, not arbitrary illustrations. Do not reproduce
their geometry when another explanation needs a different structure.

### Regular trees and transformations: renderer-native construction

Use a structural renderer when it already expresses the required pieces and
connections. The split-md trial retains circles, Empty leaves, triangular
subtrees, within-tree edges, and between-state arrows without hand-placing
each item.

- [Prose brief](../../../../rendering/illustrations/tree-trial.md) and
  [agent-authored split construction](../../../../rendering/illustrations/tree-trial.json).
- [Authoring cycle](../../../../rendering/illustrations/tree-cycle.mjs),
  [shape-aware filtering](../../../../rendering/illustrations/split-sketch.mjs),
  and [checks](../../../../rendering/illustrations/split-sketch.test.mjs).

This trial verifies selected label-free tree shapes, not clipped square rows
or font replacement in tree labels. Its original source renderer painted
connectors over node interiors: preserving endpoints alone did not establish
correct layering. Inspect source rendering before filtering it. Renderer bugs
belong to the renderer owner; a styling filter is not their repair.
Check the [consumer pin](../../../../rendering/specimen.json) before replaying
a trial. A mismatched checkout is not permission to move that pin.

For a labelled, rough-only variation, compare the same fold explanation using
circles for constructors and triangles for leaves:

- [Prose brief](../../../../rendering/illustrations/fold-tree-trial.md),
  [authoring adapter](../../../../rendering/illustrations/fold-tree-trial.mjs),
  [outlined handwritten labels](../../../../rendering/illustrations/fold-tree-labels.py),
  and [structural checks](../../../../rendering/illustrations/test_fold_tree_trial.py).

The adapter uses the exact pinned split-md layout sources extracted from Git;
it does not require the upstream checkout to remain at that revision. Solid
blue colon circles and orange `f` circles, handwritten labels, and side-by-side
composition are explicit authoring adaptations, not new split-md syntax.
Matching triangular leaves retain their colors and order, including `[]` → `z`.
The common leaf baseline produces long branches: prefer this variation when
ordered structural correspondence matters more than the compact diagonal
mathematical silhouette. The user accepted the visual trial. Wide, narrow,
and grayscale HTML were inspected; small-screen labels benefit from enlarging
the SVG. This does not establish EPUB or production PDF suitability.

The saved prose brief records the agent's interpretation of the request;
the adapter records its construction choices.
Replaying that adapter rebuilds the saved interpretation rather than parsing
new prose. Document preparation only consumes the resulting saved SVG.

### Ordered messages: specialised sequence layout

Use Mermaid sequence construction when the explanation is participant/message
order. Let the renderer arrange lifelines, requests, and replies rather than
calculating their coordinates in a new drawing program.

- [Prose brief](../../../../rendering/illustrations/sequence-trial.md) and
  [Mermaid construction](../../../../rendering/illustrations/sequence-trial.json).
- [Authoring cycle](../../../../rendering/illustrations/sequence-cycle.mjs)
  and [message-order checks](../../../../rendering/illustrations/sequence-cycle.test.mjs).

The demonstrated combination is regular lettering and crisp strokes.
Excalifont and sketch filtering for sequences are unverified. Existing box
and tree adapters do not establish support for lifelines, markers, or dashed
reply semantics. If the request needs that combination, propose a bounded
trial; do not silently substitute a different appearance or claim support.

### Exact correspondence and mathematics: direct SVG drawing

Use explicit geometry when two pictures must align or typography carries
meaning. The fold example shares spine and leaf positions across two trees,
with regular numbers, italic mathematical labels, and no background or frame.

- [Prose brief](../../../../rendering/illustrations/fold-trial.md) and
  [construction](../../../../rendering/illustrations/fold-trial.json).
- [Native drawing code](../../../../rendering/illustrations/fold-trial.py)
  and [geometry/portability check](../../../../rendering/illustrations/test_fold_trial.py).
- [Optional stroke filter](../../../../rendering/illustrations/fold-sketch.mjs)
  and [filter check](../../../../rendering/illustrations/fold-sketch.test.mjs).

The right-hand numbered branches need clearance below italic `f` descenders;
mechanically identical branch starts caused an overlap. Preserve the intended
correspondence, not an accidental coordinate equality. The filter roughens
connector shafts while protecting the mathematical lettering and tiny filled
arrowhead. Hand-drawn strokes do not require handwritten lettering.

## Apply an optional filter

The current filter is seeded rough-stroke treatment, with separate adapters
for the supported constructions above. It is not a universal SVG filter and
is not necessarily an SVG `<filter>` effect: these implementations save
ordinary vector paths. Crisp artwork needs no roughening phase.

For a new filter or a new input kind, make its boundary concrete:

- Name what it changes, its supported inputs, and the output it produces.
  Distinguish scene geometry, visible strokes, fill shapes, clip definitions,
  markers, and outlined glyph paths; not every SVG path is an outline.
- State the invariants: connections, state order, type/identity colors,
  meaningful dash patterns, arrow direction, label placement, and glyph
  clearance as applicable. Protect what the filter does not own.
- Record parameters, implementation/dependency versions, and a seed only
  when randomness is used. Keep source construction so the treatment is
  replaceable or removable.
- Declare phase order. Choose fonts before final lettering is outlined,
  and before layout measurement when font metrics affect layout. The current
  roughening phases protect outlined lettering. Do not assume future filters
  commute or can be applied repeatedly to already-filtered output.
- Verify repeated output where determinism is promised, negative/unsupported
  cases, and the final SVG contract. Inspect meaning, glyph collisions, actual
  display width, and grayscale separately. A filter can preserve bytes or
  endpoints while still producing a distracting or incorrect picture.

Save the selected treatment and the command that reconstructs the **complete
final artwork** in renderer-owned construction state. Check that command:
some example programs create only a crisp intermediate; their wrapper applies
the selected filter. A prototype fixture is not automatically the accepted
asset's rebuild command. No new common filter schema or registry is selected
by this guidance. Add a filter only for a concrete approved need and example.

## Reuse evidence without overstating it

The pair figures are integrated lesson artwork. The other examples are local
authoring trials; their standalone HTML/print checks do not certify changed
lesson EPUB or production PDF layouts. The [tool reference][tools] retains
reproduction commands, dependencies, and current limitations. Generated
`.build/` previews may be absent; follow the checked-in sources, not an old
capture or remembered rendering.

Changing defaults or a prose brief calls for authoring judgment, not automatic
regeneration. Document preparation substitutes only the selected saved SVG;
it does not run construction, filters, or agents, resolve authoring defaults,
or assess semantic freshness. Unsupported combinations need an explicit
proposal or a reported blocker, not a hidden fallback or pin change.

[tools]: ../../../../rendering/illustrations/README.md
