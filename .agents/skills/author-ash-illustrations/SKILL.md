---
name: author-ash-illustrations
description: Author, infer, revise, or review illustrations in ash-doc lessons from prose illustration fences. Use for lesson-context interpretation, visual style references, construction state, SVG generation, and deciding whether existing artwork still explains the request. Keep ordinary document assembly deterministic.
---

# Author Ash illustrations

Read repository `AGENTS.md` and use `writing-ash-documentation` for lesson and
project prose. Read [the illustration contract](../../../docs/project/illustration-authoring.md)
before editing a fence or its assets. Use the current shared rendering style
and bundled fonts. Keep the task within the requested lesson or named shared
infrastructure. Do not change the Ash checkpoint or derive language semantics
from a visual metaphor.

## Read the explanation

1. If the user supplies a problem without an illustration fence, read its
   context, infer the explanatory relationship, and draft a prose brief before
   choosing construction. Save it as an `illustration` fence in the selected
   lesson or isolated trial, according to the approved scope. Otherwise locate
   the selected fence in the canonical lesson. Distinguish the user's problem
   from the agent-authored brief. Assign a missing stable `fig-` ID, preserve
   existing IDs, and add matching caption/description metadata in the YAML list.
2. Read the surrounding section and enough of the lesson to understand the
   reader's prior knowledge. Follow relevant canonical-code markers and actual
   figure references. Do not replace that context with a cryptic title field.
3. State the one relationship, distinction, or transformation the illustration
   should expose. Preserve discovery exercises and avoid unintroduced concepts.
4. Inspect existing state, drawing source, SVG, and related accepted figures.
   Distinguish an author's request from your inferred interpretation. Retain the
   original prompt; propose changes when it no longer expresses the intended
   lesson. Do not silently turn an example into a global visual rule.

## Decide what to change

Choose the action as an authoring judgment:

- Preserve an illustration that still explains the request and lesson.
- Create construction when no accepted state exists.
- Revise existing construction when feedback changes part of the result.
- Regenerate only when requested or when a fresh interpretation is justified.

Input hashes may help identify changes; they cannot decide semantic freshness.
Inspect orphan SVGs before adopting or replacing them. Do not treat a missing
sidecar as permission to destroy accepted artwork. Explain material choices
briefly in construction metadata, not in rendered lesson prose.

## Choose construction and appearance

Read [the approach reference](references/approaches.md) when choosing a drawing
method or adapting an unfamiliar example. It contrasts custom type shapes,
split-md trees, Mermaid sequences, and precisely aligned mathematical SVG.
Choose construction, appearance, and optional filters independently. These
are examples, not an exhaustive list of permitted tools or guaranteed renderer
and style combinations. Inspect the relevant source and its support limits.

The [worked example set](references/examples.md) explains each existing example
in the same order: problem, interpretation, prose brief, construction,
appearance/filter, and review/limits. Read the relevant example before copying
its technique. Reconstructed problem summaries are not original user prompts.

For a worked example starting from a problem rather than a supplied picture,
read [the foldl walkthrough](references/foldl-worked-example.md). It separates
the author's task, the agent's inferred relationship and prose brief, feedback,
construction, and review. Transfer that process, not its particular tree shape.

## Construct the visual explanation

Use the prompt, code, and reference figures to infer intent, composition, and
rules. Keep the lesson fence readable. Save construction and metadata under
`assets/<figure-id>/illustration.json`; retain larger drawing code beside it.
Use a renderer-native representation where adequate. Do not force every artwork
into a fixed graph schema or invent a general scene language for one example.

Give geometry and visual channels explicit meanings. For state changes, preserve
recognizable pieces and distinguish within-state connections from transitions.
Do not imply mutation, allocation reuse, or storage identity without evidence.
Use labels or other cues so color is not the only carrier of meaning.

When developing a new composition, compare a small number of alternatives using
the same example. Describe construction rules as well as aesthetic adjectives.
Reuse established visual components and mappings before inventing new ones.
Constrain any procedural variation so it cannot alter semantic relationships.

Read [the pilot reference](references/pilot.md) when working on tuple slots or
extending its visual vocabulary. It records a local example, not a universal
notation for every Ash concept.

## Generate and inspect

Resolve appearance during authoring: explicit illustration request overrides
document `illustration-defaults`, which override `illustrationDefaults` in the
shared diagram style. Interpret prose requests as authoring judgments, not a
new fence grammar. Record resolved font, stroke, roughness, bowing, and seed
in construction state. Rebuild from saved settings; adopt changed defaults only
when explicitly revising artwork. Changing a default never triggers generation
or a freshness decision during document preparation. The
[pilot authoring tool](../../../rendering/illustrations/README.md) records the
supported settings and explicit default-adoption command.

Invoke the drawing tool explicitly during authoring. Preserve its source,
parameters, and exact dependencies so accepted artwork can rebuild without an
LLM. Use a saved seed only if the algorithm needs randomness. Consume shared
style tokens rather than copying the style file into each lesson.

Apply optional filters explicitly during authoring, never during document
preparation. The current example is seeded rough-stroke treatment; its adapters
support particular constructions, not arbitrary SVGs. Follow the
[filter guidance](references/approaches.md#apply-an-optional-filter) for input
limits, protected geometry/lettering, parameters, dependencies, phase order,
and verification. Record a rebuild command for the complete final artwork,
not merely a crisp intermediate. New filters need a concrete approved example,
not a speculative registry or an assumption that every renderer supports them.

Render to a temporary location, inspect the image, and publish the SVG and its
sidecar reference only after success. Preserve accepted files on failure. The
SVG must be self-contained, have a viewBox and outlined labels, and follow the
existing source-image boundary. Do not use raster image generation for exact
slot geometry; use vector construction code for that case.

Review two questions separately:

1. Does the illustration accurately explain the passage and request?
2. Can a reader perceive the intended relationship at its displayed size?

Apply targeted edits to construction or drawing code, then regenerate. Do not
patch only the SVG if doing so makes the saved construction irreproducible.
Check repeated-render byte agreement when the drawing tool claims deterministic
output. Inspect grayscale and actual column width.

## Integrate and report

Use the selected lesson's normal document build. Preparation substitutes the
fence with the already-authored SVG; it does not run an agent, interpret the
request, execute drawing code, or decide freshness. Missing or invalid assets
are build errors, not generation triggers.

Review narrow HTML, enlarged EPUB, and both PDF layouts for a new accepted
formatting choice. Run only checks justified by changed inputs. Reuse pinned
Ash execution evidence when canonical programs and promises are unchanged.
Report what changed, the chosen visual mapping, checks actually run, and any
unverified output formats. Do not claim a standalone SVG preview verifies the
lesson's final page layout.
