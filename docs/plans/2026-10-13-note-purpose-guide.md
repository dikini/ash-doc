# Explain the three note forms

Which secondary material belongs in a numbered sidenote, an unnumbered margin
note, or a full-width aside? This authoring question crosses the boundary
between a note's relationship to the main explanation and its placement in
HTML, EPUB 3, and the two PDF layouts. The user selected these three forms and
requested guidance informed by Tufte's discussion.

The [rendering decision](../project/rendering.md) owns this follow-up. The
edition remains `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`; no Ash claim or example changes.
Tufte's comments inform original writing choices, not a prescribed taxonomy.

## Approach

Choosing a form by note length would confuse a reference's role with its
physical fit. Choose instead by explicit attachment to particular words,
clear local association, or a comparison that needs wider space. Keep required
reasoning in ordinary prose. Extend the existing skill and formatting
reference rather than introducing another style guide or renderer interface.

## Work and verification

1. Evaluate the current skill against source credit, a local term reminder, a
   wide comparison, and essential reasoning. The baseline lacks unnumbered
   margin-note guidance and syntax.
2. Probe native `.column-margin` through existing source preparation and the
   pinned HTML, EPUB, book PDF, and A4 PDF styles in ignored local storage.
   Verify its text, reading order, margin placement, and narrow-screen reflow
   before documenting it. Change no renderer behavior for this guide.
3. Update `.agents/skills/writing-ash-documentation/SKILL.md`, its
   `references/formatting.md`, and its application scenarios. Give each form a
   purpose, source example, and exclusions. Preserve supported diagram bounds.
4. Record the source inspiration in `docs/project/rendering.md`, distinguishing
   Tufte's own comments from other participants and ash-doc's conventions.
5. Have an independent agent apply the updated skill to the same request.
   Validate the skill, lint changed Markdown, check links, inspect changed
   source, and run `git diff --check`.
6. Remove this plan and its links when verified. Integrate the guide into the
   current main line while preserving the separate uncommitted cover work.
