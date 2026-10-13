# Consolidate the rendering review's authoring guidance

The author asks how to carry the accepted teaching and visual conventions into
other ash-doc chapters. The boundary is between one lesson's successful choices
and reusable authoring guidance. This is project work within the approved local
rendering outcome, targeting `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`; it changes no Ash behavior.

## Choice and scope

A separate style handbook could be convenient to browse, but would compete with
the required writing skill. Extend that skill instead: keep its common rules
short, add one program-design reference, and extend its formatting reference.
Link them from the project index and workflow for human authors. Deferring the
consolidation would leave accepted decisions in the conversation and make each
new author rediscover them.

Preserve problem-to-program calculation, proportional explanation of new
concepts, legible structural wiring, explained observations, note purpose,
visual continuity, and caption order. Keep the tree lesson's shapes and palette
as a worked example, rather than a universal diagram language. Apply guidance
to new work and material revisions; do not rewrite every existing chapter.

## Work and verification

1. Run fresh-agent program and visual scenarios against the existing guidance.
   Record actual gaps without treating already successful behavior as failure.
2. Extend `.agents/skills/writing-ash-documentation/SKILL.md`, add
   `references/program-design.md`, and extend `references/formatting.md` within
   that skill. Align `AGENTS.md` with explained local mnemonics while preserving
   descriptive global and API names.
3. Extend the existing `tests/writing-scenarios.md`. Add author discovery links
   in `docs/README.md` and a feedback-preservation step in
   `docs/project/workflow.md`. Keep one authority for each rule.
4. Test the updated guidance in fresh sessions on another program, a queue
   drawing, large successful observations, and a small example that should not
   acquire unnecessary machinery. Review the actual decisions and exclusions.
5. Read every changed file, check links, run `markdownlint` on tracked Markdown
   and the new reference, validate the skill front matter with the existing
   skill-creator validator, and run `git diff --check`. No canonical lesson or
   rendered source changes, so no compiler or PDF rebuild is required.
6. Update the rendering outcome in `docs/project/roadmap.md`, remove this plan,
   and commit without GPG signing. Do not upload, publish, push, or merge.

Completion means the accepted conventions are discoverable, explained with
current examples and limits, and usable in another problem family. Revise or
remove a rule when another complete lesson demonstrates that it obscures the
idea or conflicts with the current Ash baseline. Git retains this plan and the
earlier guidance.
