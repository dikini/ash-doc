# Finish the blocked effect Cases

Owned by [Apply effects in short Cases](../project/roadmap.md#apply-effects-in-short-cases).
The approved outcome is seven small Ash examples with only enough explanation
to illustrate their concepts. Three independent Cases are verified. This plan
retains only the four remaining outcomes.

**State: blocked upstream.** The current target is `diag-ash` at
`57eec5bbadae885e49c323e0a05e7a01b9ce8a36`. The
[current lab case](../../lab/effect-cases-type-work/README.md) retains the
intended programs, derived outputs, reduced failure, controls, and agent prompt.
Do not change this baseline without authorization or weaken the comparisons.

After the upstream repair and authorized baseline migration:

1. Run the unchanged draft entries under
   `lab/effect-cases-type-work/drafts/` and compare stdout with the corresponding
   `checks/*.expected.txt`, requiring status zero and empty stderr. Inspect any
   disagreement against the pinned specification rather than updating expected
   values mechanically.
2. Finish the short prose and move each draft into `content/cases/` using its
   current slug: `numbering-tree-leaves`, `measuring-tree-search`,
   `bounding-search-work`, and `compressing-parent-paths`.
3. Add each unit's `checks/verify.sh` using the existing shared helper. Check
   canonical source agreement and the intended comparison. Preserve scoped
   state, comparison counts, pre-expansion budgets, and checked path compression.
4. Restore the approved reading order in `content/cases/README.md` and its
   aggregate. Update counts and project state. Keep broader algorithm treatments,
   external I/O, general session machinery, and shared frameworks excluded.
5. Run focused unit checks, then all four family verifiers once. Run Markdown
   lint, Bash syntax checks, ShellCheck, link checks, and `git diff --check`.
6. Remove the superseded lab case and this plan after all intended observations
   pass. The roadmap and active lessons retain current state; Git is the archive.

The alternatives remain a small concept Case or a larger application. The
approved choice is the small Case: one canonical program per outcome, original
prose and code, existing tooling, and optional exercises using known concepts.
The roadmap names prerequisites and governing pinned specification sections.
