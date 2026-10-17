# Deliver A1–A8 at Diag Ash

How can independently developed application Cases join one verified edition
without changing its language target or sharing unfinished implementations?
This plan owns the bounded coordination work: GitHub delivery, shared indexes
and checks, and final book integration. Each Case has its own implementation
brief and remains a separate outcome.

**State:** A1 is locally verified with nine canonical sources and one complete
human rejection capture. [Issue #1](https://github.com/dikini/ash-doc/issues/1)
and [PR #2](https://github.com/dikini/ash-doc/pull/2) track delivery. Independent
review passed; the user approved A1 for merge on 2026-10-17 despite the separate
foundation gate. The remaining briefs retain acceptance targets rather
than captured results. The user selected parallel Case development and deferred
all rendering to final integration. Broader foundation and final integration
gates remain unclaimed by A1.

**Target:** `diag-ash`, Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. All source, claims, diagnostics,
and checks retain this exact target. [DN-0052][dn0052], inspected at
`9f8738b7e0d7f280f9744bf808343d2c97ce6661`, supplies informative motivation;
it changes neither the target nor Ash semantics.

## Delegate the whole programme or one part

For the whole programme, give an agent this request:

> Implement docs/plans/2026-10-16-application-cases-integration.md. Coordinate
> the foundation, eight independent Cases, and final integration through the
> specified GitHub issues and PRs. Keep every observation at the exact Diag
> Ash pin and use the specified role settings. Respect the shared-file owner
> and final-review gates.

For one Case, give an agent its brief; for example:

> Implement only docs/plans/2026-10-16-a6-controlled-edits.md. Read its shared
> execution contract, use its exact Diag Ash pin, and deliver its issue and
> complete Case PR. Do not take ownership of other Cases or global integration.

The foundation and final integration sections below are independently
assignable to an integrator. Read [AGENTS.md](../../AGENTS.md), the required
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
it under the project's ignored `.worktrees/diag-ash` if no suitable dedicated
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

The PM creates one integration issue, titled “Deliver A1–A8 at Diag Ash”,
and eight linked Case issues with the brief titles. The integration issue
tracks the foundation PR, Case issue/PR links, and final integration PR. This
gives nine issues and ten planned PRs. Record actual URLs in the relevant
briefs and issue checklist once they exist; do not invent issue numbers.

Each Case issue contains its reader question, exact pin, chosen design,
prerequisites, acceptance targets, exclusions, file ownership, and completion
checks. Link the source brief. A directly assigned Case agent may find or
create only its own issue; it must not create or take over the whole programme.

Publish the plan bundle in the foundation before distributing new independent
checkouts. Uncommitted files in a primary checkout are not inherited by Git
worktrees. A Case author may develop its local subtree before foundation merge,
but must keep its PR draft and report the integration dependency. Only the
integrator takes responsibility for the foundation.

All PRs target `main`. Attach each created PR to its working Codex chat.
Use `Refs #<integration-issue>` for the foundation and
`Closes #<case-issue>` for each Case. The final integration PR closes the
integration issue. Default to human approval before merge and use merge
commits to preserve the accepted history.

### Case delivery and independent verification

Land a complete Case: connected prose, canonical source, fixtures, independent
application comparisons, applicable static rejections, and local checks. Its
brief fixes the teaching question and data/API boundary. Expand its file list
only for a concrete observation within that boundary; do not create empty
scaffolds or a shared application framework.

For an assigned Case, set `case_slug` to its destination and `diag_checkout`
to the absolute clean compiler checkout, then run:

```sh
bash "content/cases/$case_slug/checks/verify.sh" "$diag_checkout"
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

All rendering is deferred to final integration. A Case PR establishes content
and executable verification; its presentation remains pending. Do not claim
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

## Foundation implementation

**Assignable scope:** shared Cases verification and delivery preparation.
Use branch `codex/application-cases-foundation` and PR title
“Prepare Diag Ash application Case delivery”.

The plan bundle is now published on `main` at
`e610e918b085b6e342b72cd08870e41c0ceb8069`. A1 carries the runner's required
count derivation in its Case PR. Bash syntax, ShellCheck, and throwaway
inventory probes check that narrow change while preserving the first twenty
destinations. The probes use compiler and leaf-verifier stubs; they do not run
existing Cases. The broader foundation assignment and its acceptance below,
including the unchanged twenty-Case aggregate and foundation review, remain
unclaimed. Final book integration also remains separately assigned.

At planning time, local `main` was `1c6dd1f364c5dcd815354dfd1aa8f4cc5c4d35a7`;
remote `main` was `0b6b9c8a9fba9e9b87f0c8c047001743e81682c1`. The local
history additionally contains accepted commits `4838213` (roadmap) and
`1c6dd1f` (cover). Refresh remote state before implementation. Publish any
still-unpublished accepted commits and this plan bundle through the foundation
PR without rewriting `main` or duplicating already integrated changes.

At planning time, the Cases runner repeated twenty in its slot-count check
and loop while separately retaining an explicit ordered destination array.
Compare changing those literals in every Case PR with deriving the count from
that array once. Select derivation: it preserves the existing inventory and
avoids repeated parallel edits. Deferral would make the first added Case fail
the twenty-slot check.

1. Move the existing `active_destinations` array before slot validation.
2. Derive one expected count from that array and iterate its indices. Retain
   strict numbering, each slot's exact destination, and verifier/index count
   agreement. Add no registry or extra metadata source.
3. Run Bash syntax and ShellCheck, then the unchanged twenty-Case aggregate:

   ```sh
   bash -n content/cases/checks/verify.sh
   shellcheck -x -P SCRIPTDIR content/cases/checks/verify.sh
   bash content/cases/checks/verify.sh "$diag_checkout"
   ```

4. In a throwaway copy, check that broken numbering, a wrong destination, and
   an extra unindexed verifier still fail. Preserve the real source tree.
5. Review the final foundation diff and merge after approval. Update the
   integration issue with its commit and PR URL. This preparation is complete
   when the existing twenty Cases still pass and the count has one owner.

Revisit the derived-count choice only if a real indexed lesson cannot be
represented by the current destination array and local verifier convention.

## Final integration implementation

**Assignable scope:** the complete local review book after all eight Cases
have merged. Use branch `codex/application-cases-integration` and PR title
“Verify the eight application Cases in the complete review book”.

1. Confirm twenty-eight indexed Cases and sixty-one total lessons, in Learn →
   Libraries → Effects → Cases order with four family introductions. Reconcile
   prerequisite links, shared introductions, actual source/capture counts,
   roadmap state, and current inventory statements. Do not infer counts from
   these plans' proposed source inventories.
2. Run the Cases aggregate at the exact Diag Ash pin. Reuse applicable evidence
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
[spec]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/README.md
[tool]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/tools/ash.md
[dn0052]: https://github.com/dikini/ash-lang/blob/9f8738b7e0d7f280f9744bf808343d2c97ce6661/docs/design/DN-0052-diag-ash-case-studies-and-teaching.md
