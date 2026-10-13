# Add formatting guidance to the writing style

How should an author choose notes, wide material, and notation without making
the explanation depend on one output layout? This task crosses the boundary
between chapter source and HTML, EPUB 3, book PDF, and A4 PDF reading order.
The user accepted the first rendering draft and requested these instructions.

The [rendering decision](../project/rendering.md) owns this bounded follow-up.
Ash remains pinned to `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. No language claim, executable Ash
example, renderer behavior, or publication choice changes.

## Choice and scope

Putting every syntax example in the main writing skill would burden ordinary
prose work. Keeping the guidance only in the maintainer rendering guide would
leave authors to infer usage from fixtures. Add concise selection rules to the
writing skill and one linked formatting reference with supported syntax and
current bounds. Update that reference when the verified renderer contract
changes; do not turn the first specimen into a general Quarto manual.

## Execution and verification

1. Compare the existing skill's response to a formatting request with the
   source preparation, diagram adapter, styles, and specimen checks. The
   baseline retrieves specimen examples but lacks author guidance and the
   top-level diagram restriction.
2. Extend `.agents/skills/writing-ash-documentation/SKILL.md` with selection
   rules and review questions; add `references/formatting.md` beside it.
3. Add an application scenario to the skill's existing
   `tests/writing-scenarios.md`. Link the reference from `rendering/README.md`
   and `docs/project/rendering.md`.
4. Have an independent agent apply the updated skill to the same request.
   Check note choices, output differences, wide-block bounds, diagram metadata,
   top-level fences, and the distinction between sequents and sequences.
5. Validate the skill, lint changed Markdown, check relative links, and parse
   the documentation examples with pinned Pandoc. Compare their notation with
   the verified fixture. Read every changed source and run `git diff --check`.
6. Remove this plan and its links after verification. Retain the authoring
   instructions and scenario; leave generated artifacts and renderer code
   unchanged.
