# Deliver A1–A8 at FFI Base

How can independently developed application Cases join one verified edition
without changing its language target or sharing unfinished implementations?
This plan owns the bounded coordination work: GitHub delivery, shared indexes
and checks, and final book integration. Each Case has its own implementation
brief and remains a separate outcome.

**State:** A1 is integrated and verified at FFI Base with nine canonical sources
and one complete human rejection capture.
[Issue #1](https://github.com/dikini/ash-doc/issues/1) and
[PR #2](https://github.com/dikini/ash-doc/pull/2) retain its delivery record.
A2–A8 remain unimplemented and unverified at this target. Their independent
Case delivery and later integration require their own acceptance checks.

**Target:** `ffi-base`, Ash commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. All source, claims, diagnostics,
and checks retain this exact target. [DN-0052][dn0052], inspected at
`9f8738b7e0d7f280f9744bf808343d2c97ce6661`, supplies informative motivation;
it changes neither the target nor Ash semantics.

## Delegate the whole programme or one part

For the whole programme, give an agent this request:

> Implement docs/plans/2026-10-16-application-cases-integration.md. Coordinate
> the seven remaining Cases and final integration through the specified
> GitHub issues and PRs. Keep every observation at the exact FFI Base pin and
> use the specified role settings. Respect the shared-file owner
> and final-review gates.

For one Case, give an agent its brief; for example:

> Implement only docs/plans/2026-10-16-a6-controlled-edits.md. Read its shared
> execution contract, use its exact FFI Base pin, and deliver its issue and
> complete Case PR. Do not take ownership of other Cases or global integration.

The final integration section below is independently assignable to an
integrator; the foundation is already incorporated. Read
[AGENTS.md](../../AGENTS.md), the required
[writing skill][writing], [workflow][workflow], and [verification guide][verify]
before starting. A new chat needs no previous conversation to use this bundle.

<!-- markdownlint-disable MD013 -->
| Outcome | Brief or verified lesson | Case destination |
| --- | --- | --- |
| A1: cleanup reporting | [Verified lesson](../../content/cases/preserving-outcomes-through-cleanup/README.md); [issue #1](https://github.com/dikini/ash-doc/issues/1), [PR #2](https://github.com/dikini/ash-doc/pull/2) | `preserving-outcomes-through-cleanup` |
| A2: scoped pricing | [A2](2026-10-16-a2-scoped-pricing.md) | `supplying-a-local-pricing-policy` |
| A3: immutable ECS | [A3](2026-10-16-a3-immutable-ecs.md) | `querying-an-immutable-world` |
| A4: cancellable journal | [A4](2026-10-16-a4-cancellable-journal.md) | `rolling-back-a-cancellable-journal` |
| A5: event redaction | [A5](2026-10-16-a5-event-redaction.md) | `redacting-before-publication` |
| A6: controlled edits | [A6](2026-10-16-a6-controlled-edits.md) | `checking-proposed-edits` |
| A7: stable sorting | [A7](2026-10-16-a7-stable-sort.md) | `cancelling-a-stable-sort` |
| A8: tagged frames | [A8](2026-10-16-a8-tagged-frames.md) | `round-tripping-tagged-frames` |
<!-- markdownlint-enable MD013 -->

## Shared execution contract

### Authority, source, and compiler isolation

The [pinned specification overview][spec] and governing sections linked by
each brief own language claims. The [pinned tool guide][tool], implementation,
and tests own invocations and observations. Use Git objects at the exact pin
when reading the sibling repository; its working tree is not the target.
Historical discussions supply problem ideas only. Write original prose and
programs, with adaptation and license records where actual reuse requires them.

Use one dedicated, clean, detached Ash checkout at the exact target. Create
it under the project's ignored `.worktrees/ffi-base` if no suitable dedicated
checkout exists. Do not switch or modify the sibling Ash working tree, reuse
an obsolete compiler pin, or recreate a compiler checkout under lesson content.
Verify its exact HEAD and clean status before each run. The existing
`ash_doc_prepare` helper checks both and builds with locked dependencies into
a unique temporary Cargo target. Parallel jobs may share the immutable source
checkout; do not introduce shared prepared binaries or a new build cache.

The [shared Bash helper](../../content/checks/lib.sh) and
[rendering configuration](../../rendering/specimen.json) must retain the exact
pin. No compiler repair, checkpoint movement, external I/O, concurrency,
general FFI, or new Ash mechanism belongs to this programme. Use only existing
primitive operations and library definitions supported at the pin.

### Roles, branches, and ownership

Set these subagent configurations explicitly when dispatching work:

<!-- markdownlint-disable MD013 -->
| Role | Model | Reasoning | Responsibility |
| --- | --- | --- | --- |
| PM | `gpt-6.1-sol` | `medium` | Issues, assignments, dependencies, and evidence handoff |
| Development | `gpt-6.1-sol` | `xhigh` | One bounded Case or assigned integration change |
| Review | `gpt-6.1-sol` | `max` | Independent source, specification, prose, and check review |
<!-- markdownlint-enable MD013 -->

Use at most two development subagents concurrently and reserve one subagent
slot for PM or review, within the current four-slot limit including the root.
Start the assignment queue with A1, A2, and A3, then A4–A8. These are priorities,
not dependencies between new Cases. Each Case depends on existing lessons.

Each author uses an isolated `.worktrees/` checkout and a
`codex/aN-<topic>` branch. Authors own their Case subtree and its temporary
brief. They must not edit other Cases or import their new application code.
Keep any genuinely needed shared module inside the owning Case.

The integrator owns shared edits: the Cases introduction and index, aggregate
runner, roadmap, this coordination plan, current inventory statements in the
root README and AGENTS.md, and affected verification/project records. The
integrator adds those edits on the corresponding Case branch before final
review. Do not let parallel authors race to update shared counts or navigation.

### GitHub issue and PR lifecycle

Use repository `dikini/ash-doc` and the existing `documentation` label. Inspect
current issues and PRs before creating anything; reuse matching work instead
of creating duplicates. Use GitHub CLI if the connector cannot access the
repository. Use body files for multiline issue and PR descriptions.

The PM reuses a matching integration issue or creates one titled
“Deliver A1–A8 at FFI Base”, then finds or creates issues for the seven remaining
Cases. Keep A1's existing issue and merged PR as its delivery record. Track the
remaining Case PRs and final integration PR; do not recreate foundation work.
Record actual URLs in the briefs and checklist, without inventing issue numbers.

Each Case issue contains its reader question, exact pin, chosen design,
prerequisites, acceptance targets, exclusions, file ownership, and completion
checks. Link the source brief. A directly assigned Case agent may find or
create only its own issue; it must not create or take over the whole programme.

The plan bundle and count derivation are already integrated. Base new work on
the current FFI Base edition; do not reopen the old foundation publication
or import an older compiler target from an existing Case branch.

All PRs target `main`. Attach each created PR to its working Codex chat.
Use `Refs #<integration-issue>` for shared integration work and
`Closes #<case-issue>` for each Case. The final integration PR closes the
integration issue. Default to human approval before merge and use merge
commits to preserve the accepted history.

### Case delivery and independent verification

Land a complete Case: connected prose, canonical source, fixtures, independent
application comparisons, applicable static rejections, and local checks. Its
brief fixes the teaching question and data/API boundary. Expand its file list
only for a concrete observation within that boundary; do not create empty
scaffolds or a shared application framework.

For an assigned Case, set `case_slug` to its destination and `ffi_checkout`
to the absolute clean compiler checkout, then run:

```sh
bash "content/cases/$case_slug/checks/verify.sh" "$ffi_checkout"
bash -n "content/cases/$case_slug/checks/verify.sh"
shellcheck -x -P SCRIPTDIR "content/cases/$case_slug/checks/verify.sh"
markdownlint "content/cases/$case_slug/README.md"
git diff --check
git status --short
```

Lint any additional changed Markdown or Bash as well. Check relative links,
pinned anchors, attribution, and every changed file as source. Use the existing
whole-source agreement helper for complete runnable blocks; where exposition
needs exact excerpts, follow an existing lesson-local standard-library check.

Assert complete accepted values and types, stdout, stderr, and exit status.
Build independent application expectations before running the implementation.
An accepted but incorrect application is different from a typed error result,
source rejection, or internal failure. Use deterministic checked-in inputs;
do not force allocator failure or depend on timing, live services, or randomness.

For supplied rejections, capture semantic JSON with causal locations and
complete English human messages with `--message-format human --locale en`.
Keep those comparisons separate; normalize only the documented checkout
prefix. Include the reproducible command and explanation in the lesson.
Discovery exercises retain their unanswered observations. Proposed diagnostic
episodes and test expectations in these plans become evidence only after a
fresh exact-pin run.

An independent reviewer checks the complete final revision. After the author
freezes development, the integrator incorporates current `main`, adds shared
updates, and reruns affected checks. Review of an earlier revision does not
cover later integration edits. Record the final commit, exact Ash pin, commands,
results, and remaining limitations in the PR.

For A2–A8, rendering is deferred to final integration. A Case PR establishes
content and executable verification; its presentation remains pending until
checked. A1 now passes the complete 54-lesson FFI Base book checks. Do not claim
fresh book verification or rewrite older rendering receipts after adding a Case.

### Merge, discovery, and plan retirement

Serialize shared integration and merges. Insert only verified Cases into the
A1–A8-ordered active subset, preserving the first twenty destinations and
contiguous numbering. There are no placeholder slots. Ready Cases may merge
while another is blocked; the final complete order is A1–A8 at slots 21–28.

An unexpected result follows the [discovery workflow][discoveries]. Correct
documentation mistakes against the pin; preserve a minimal executable lab
case for a regression candidate; return unspecified semantics upstream; retain
library or diagnostic pressure as evidence. Do not weaken the promised
comparison or change Ash. Continue unaffected Cases.

When a Case completes, the integrator removes its temporary brief in that
Case PR and replaces its incoming roadmap and coordination links with the
verified lesson and actual issue/PR references. Git retains the plan history.
Keep this coordination plan until final book integration completes, then
remove it and its incoming links. Never maintain a completed-plan archive.

## Foundation state

A1 is already indexed. Its 21-Case runner derives its count from the ordered
`active_destinations` array. The FFI Base migration verifies that runner and
all 54 current lessons. Earlier foundation publication and twenty-Case gates
are superseded; do not reopen them or republish their old commits.

Future Case acceptance remains unverified at FFI Base until each complete
lesson passes its own checks. Run inventory mutation probes when a future
Case changes numbering or destinations; retain strict index/verifier agreement.

## Final integration implementation

**Assignable scope:** the complete local review book after all eight Cases
have merged. Use branch `codex/application-cases-integration` and PR title
“Verify the eight application Cases in the complete review book”.

1. Confirm twenty-eight indexed Cases and sixty-one total lessons, in Learn →
   Libraries → Effects → Cases order with four family introductions. Reconcile
   prerequisite links, shared introductions, actual source/capture counts,
   roadmap state, and current inventory statements. Do not infer counts from
   these plans' proposed source inventories.
2. Run the Cases aggregate at the exact FFI Base pin. Reuse applicable evidence
   for unchanged Learn, Libraries, and Effects inputs; do not rerun their
   aggregates merely because the book grew.
3. Use the existing pinned rendering toolchain and documented dependency paths.
   Build all four formats and check the generated project:

   ```sh
   python3 rendering/build.py --whole-book
   python3 rendering/checks/verify.py .build/book
   node rendering/checks/browser.mjs .build/book
   java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar \
       .build/book/output/ash-doc-review.epub
   ```

4. Review desktop/mobile HTML, enlarged EPUB text, and all eight new chapters
   in both PDF layouts. Inspect code, diagnostics, pagination, notes, diagrams,
   chapter order, and navigation. Artifact checks must retain full canonical
   code/transcript text, source identity, and actual indexed coverage.
5. Repair presentation in this PR. Changes to canonical source, executable
   promises, observations, or checks require their dependent executable checks.
   Layout-only fixes retain applicable executable evidence. A shared renderer
   change additionally runs its affected regressions under the existing guide.
6. Record fresh measured results in project records without presenting previous
   render receipts as current results. Remove completed plans and fix incoming
   links in the same change. Review the final source and evidence before merge.
7. Close the integration issue after approval and merge; clean up only this
   programme's worktrees, including its dedicated compiler checkout when no
   longer needed. Keep the edition unpublished and create no publication tag.

[writing]: ../../.agents/skills/writing-ash-documentation/SKILL.md
[workflow]: ../project/workflow.md
[verify]: ../project/verification.md
[discoveries]: ../project/workflow.md#classify-discoveries
[spec]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/README.md
[tool]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md
[dn0052]: https://github.com/dikini/ash-lang/blob/9f8738b7e0d7f280f9744bf808343d2c97ce6661/docs/design/DN-0052-diag-ash-case-studies-and-teaching.md
