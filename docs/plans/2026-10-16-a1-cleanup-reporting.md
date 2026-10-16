# A1: Preserving outcomes through cleanup

Reader question: how can a batch retain its primary outcome and every completion
error?
The observable boundary is primary calculation versus ordered source-level
completion reporting.
Action and scope: implement one complete Cases lesson under the fixed subtree
below, including prose, canonical programs, fixtures, and local checks.
This is selected application design, not a language or architecture decision.

**State:** planned; application code and observations remain unverified.

Target: `diag-ash`, Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. Read the
[specification overview][overview] and the governing sections before coding.
The [tool guide][tool]
at that same pin governs commands, diagnostics, and output. DN-0052 at
`9f8738b7e0d7f280f9744bf808343d2c97ce6661` is informative motivation only.
Use the [project workflow][workflow], [verification guide][verification], and
[writing skill][writing]. All signatures and constructor forms named in this
brief are non-executable design notation; derive tested Ash in canonical files.

## Design and prerequisites

Own [roadmap A1](../project/roadmap.md#a1-how-can-cleanup-failures-preserve-the-primary-outcome).
Continue [cleanup](../../content/effects/running-cleanup/README.md) and
[discard](../../content/effects/stopping-a-calculation/README.md); consult their
local `checks/verify.sh` for existing controls and diagnostic capture patterns.
[Typed failure reporting][reporting] preserves the body value independently of
ordered errors. [Cleanup checking][cleanup] forbids abandoning running required
completion. These rules do not confer failure meaning on constructors.

Use a finite command list with `Add(Int)` and `Reject(Int)`. Derive an explicit
`Outcome` success/failure with `PrimaryError` alternatives
`RejectedCommand(Int)` and `CancelledBatch`. Use a `CompletionError` sum with
`AuditFailed(Int)` and `SummaryFailed(Int)` alternatives, an ordered
`Failures` list, and `Report<A, E>` retaining both the value and that list.
The report collector resumes each request with unit, then prepends that error
to the resumed result. Caller policy retains a primary failure; for success,
completion errors remain available and the first is the primary completion
error.
Compare this with collapsing everything into one error: that loses either the
body result or later completion reports. Deferral would leave the advertised
batch outcome ambiguous. Keep the report representation local and replaceable.

Cancellation deliberately replaces the discarded body's unfinished outcome:
the cancellation clause discards, then returns `Failed(CancelledBatch)`.
It does not recover a value from an abandoned continuation. Track each closing
action and each executed command with ordinary copied observations.

## Owned files

Use `content/cases/preserving-outcomes-through-cleanup/` with:

- `README.md`: connected chapter, predictions, repair, and discovery exercise.
- `src/batch.ash`: command data, primary outcomes, recursion, and caller policy.
- `src/reporting.ash`: explicit errors, reports, resumptive collector, adapters.
- `src/01-success.ash`, `02-primary-failure.ash`, `03-nested-reports.ash`:
  complete accepted entries; each filename after the first is also under `src/`.
- `src/04-cancellation.ash`, `05-unreported-close.ash`:
  accepted abandonment and well-typed wrong-application comparison.
- `src/06-abortive-collector.ash`, `07-resuming-collector.ash`:
  minimal rejection and complete repair.
- `checks/verify.sh`; `checks/06-abortive-collector.diagnostic.json`;
  the complete human capture in `README.md`, checked by the shared helper.

Put shared source modules beside entry files; display only tested canonical
blocks and enumerate the entire source inventory in the verifier.

## Implementation and acceptance

1. Derive operation contracts from the command list and report invariant.
   Explain success, primary rejection, and modeled completion failure
   separately.
2. Implement sequential recursion that stops at rejection. Require
   `[Add(2), Add(3)]` to
   produce success `5` with no completion errors. Empty input succeeds with `0`.
3. Require `[Add(2), Reject(7), Add(3)]` to retain `RejectedCommand(7)` and
   skip the third command. Check the executed prefix, not only the final value.
4. Add nested audit/summary actions. For success and primary failure `7`,
   retain reports `22` then `11`; assert their categories and order directly.
   An independent expected value must expose both body outcome and reports.
5. Cancel with two live actions: require `CancelledBatch`, reports `22, 11`,
   each action exactly once, and no abandoned suffix. Check the explicit
   cancellation replacement rather than claiming discarded body preservation.
6. Construct `CloseFailed(error)` but omit its report request.
   Its missing report is a failed application invariant, not compiler failure.
   Contrast the emitted report and independently expected error list.
7. Capture rejection of an abortive report collector attempting to discard
   running completion. Assert the stable reason and causal action/discard
   locations, then repair by resuming and retaining all reports.
8. Write the chapter from these observations and review the caller policy.
   Keep discovery observations unanswered; check source agreement and lint.

Exclude native release guarantees, retries, host teardown promises, concurrent
cancellation, exception emulation, and a shared reporting library. Application
observations establish this finite model; they cannot strengthen cleanup rules.

## Execution and handoff

Follow the [shared execution contract][execution] for dispatch, worktree,
issue, integration, and final review. PM uses `gpt-6.1-sol` at `medium`,
development at `xhigh`, and independent review at `max`.
Find or create one matching issue and PR in `dikini/ash-doc` for this Case.
Use branch `codex/a1-cleanup-reporting` in `.worktrees/a1-cleanup-reporting/`.
The author owns the lesson subtree and this temporary plan. The integrator
owns shared index, runner, roadmap, and count changes and adds them to the same
Case PR before final review. Do not edit another Case's files.
Retain this plan while its outcome remains open; remove it on completion.
Record commands, exact target, observations, and unresolved discoveries in the
issue/PR handoff. Follow the project writing skill for both messages.

Use `content/checks/lib.sh` through the local verifier. Check every displayed
runnable block against its canonical source. Assert accepted value and type,
stdout/stderr and status; keep JSON reason/location assertions separate from
complete English human captures. Capture each supplied rejection from
`content/cases/`, using
`ash --message-format human --locale en CASE/src/ENTRY.ash` with this Case's
slug in place of `CASE`. Store full captures in README transcript
blocks and check with `ash_doc_check_human`. Normalize only the documented
checkout prefix; no separate human fixture file is needed.

Run from the ash-doc worktree, replacing `PINNED_ASH` with a clean Ash checkout
whose HEAD is the exact target (the verifier checks this and builds it):

```text
bash content/cases/preserving-outcomes-through-cleanup/checks/verify.sh PINNED_ASH
markdownlint content/cases/preserving-outcomes-through-cleanup/README.md
shellcheck -x -P SCRIPTDIR content/cases/preserving-outcomes-through-cleanup/checks/verify.sh
git diff --check
git status --short
```

Read every changed source file and check relative links and spelling. Reuse
unchanged prerequisite evidence at the exact pin; do not run all family checks.
No Case rendering is assigned here: final integration verifies all formats.
A source regression needs a minimal executable lab handoff with baseline,
expected specified behavior, actual output/status, controls, affected lesson,
and removal condition. A semantic gap goes back to Ash design. Neither permits
changing Ash, moving the pin, weakening the outcome, or adding a workaround as
the complete lesson. Continue unaffected work and report shared needs to the PM.

[execution]: 2026-10-16-application-cases-integration.md#shared-execution-contract
[workflow]: ../project/workflow.md
[verification]: ../project/verification.md
[writing]: ../../.agents/skills/writing-ash-documentation/SKILL.md
[overview]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/README.md
[tool]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/tools/ash.md
[reporting]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#typed-failure-reporting
[cleanup]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-cleanup-actions
