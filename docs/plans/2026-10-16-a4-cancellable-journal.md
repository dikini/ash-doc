# A4: Rolling back a cancellable journal

Reader question: how can cancellation undo staged state changes through explicit
compensation?
The observable boundary is owned control abandonment versus restoration
performed by an application action.
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

Own [roadmap A4](../project/roadmap.md#a4-how-can-cancellation-explicitly-roll-back-a-journal).
Continue [cells](../../content/effects/counting-with-a-cell/README.md),
[discard](../../content/effects/stopping-a-calculation/README.md), and
[cleanup](../../content/effects/running-cleanup/README.md). Read their local
verifiers for retained controls and cleanup diagnostic patterns.
[Cells][cells] govern reusable state access and copied output. [Cleanup][cleanup]
checks interpreters at each closing position; [execution][closing] gives the
innermost-first invocation order. Neither rule provides automatic rollback.

Use one integer state cell, a copied entry snapshot, an integer commit flag
`0/1` per journal scope, and a closing trace. The flag's resource owner
surrounds that scope's cleanup and cancellation handler so it survives closing.
A normal commit sets the flag to `1`; cleanup restores the snapshot only for
`0`, then records closing. On cancellation, discard owned work and return an
explicit `JournalOutcome`: `Committed(Int)` or `Cancelled(CancelReason)`.
Copy state and trace out while their owners remain live; export no handles.
The body can stage additions; every cancellation path skips its abandoned
suffix.

Compare bare cancellation, which retains previous writes, with this explicit
compensation. A persistent pure journal would avoid mutation but would omit the
cell/closing interaction; automatic transactional claims have no authority here.
Select the small in-memory compensation protocol and defer a transaction API.
For nesting, each journal owns its snapshot and flag. Inner commit preserves its
changes only until an enclosing uncommitted snapshot is restored.

## Owned files

Use `content/cases/rolling-back-a-cancellable-journal/` with:

- `README.md`: snapshot model, bare/compensated comparison, nesting, repair.
- `src/journal.ash`: explicit outcome, cancellation effect, journal operations.
- `src/01-bare-cancellation.ash`, `02-compensated-cancellation.ash`,
  `03-commit.ash`: complete accepted entries under `src/`.
- `src/04-nested-completion.ash`, `05-live-inner-cancellation.ash`:
  accepted nesting matrix and outer cancellation while inner work is live.
- `src/06-removed-interpreter.ash`, `07-surviving-interpreter.ash`:
  minimal interpreter rejection and complete placement repair.
- `checks/verify.sh`; `checks/06-removed-interpreter.diagnostic.json`;
  the complete human capture in `README.md`, checked by the shared helper.

Enumerate the complete source inventory, including modules. Keep snapshots,
flags, and trace visible in canonical code rather than hiding ownership in an
unexplained helper. Resource-dependent callback captures need exact checking.

## Implementation and acceptance

1. Derive the journal operations from state `10` and one staged addition `5`.
   Record outcome, copied final state, and trace separately in observations.
2. Bare cancellation must leave state `15`. Compensated cancellation must
   restore `10`, return `Cancelled`, and omit the post-cancellation suffix.
   Check copied values and status, not an inferred transactional guarantee.
3. Commit after adding `5` must return `Committed(15)` with final state `15`.
   Closing executes once even when no restoration is needed.
4. Nest outer `+5` then inner `+2`. Both commits leave `17`; inner cancellation
   followed by outer commit leaves `15`; inner commit followed by outer
   cancellation leaves `10`. Assert each explicit outcome and final state.
5. Cancel the outer operation while inner work is live: final state is `10`,
   inner closes before outer, each once, and neither abandoned suffix runs.
   Observe intermediate restored snapshots where needed to expose causality.
6. Build a cleanup action that requires a nearest source interpreter removed
   by abandonment. An outer same-instance interpreter cannot replace it.
   Capture the rejection and its discard/action/handler labels; assert the
   stable reason and those causal locations rather than only nonzero status.
7. Repair placement so the needed interpreter encloses the relevant owner
   and cancellation handler and survives discard. Require the intended
   compensated result and closing order; do not erase the action's request.
8. Explain the resource nesting, flag lifetime, snapshot invariant, and why
   committed inner work remains subject to an outer rollback. End with
   practice distinguishing normal completion from state restoration.
9. Review every capture and return for resource dependencies, check complete
   human/source agreement, and run only this lesson's verification and lint.

Exclude automatic rollback, database isolation, concurrency, durable storage,
crash recovery, exceptions, and a general transaction library. Cleanup's
once-only invocation ownership does not establish successful compensation
under internal termination. No native or external effect is undone here.

## Execution and handoff

Follow the [shared execution contract][execution] for dispatch, worktree,
issue, integration, and final review. PM uses `gpt-6.1-sol` at `medium`,
development at `xhigh`, and independent review at `max`.
Find or create one matching issue and PR in `dikini/ash-doc` for this Case.
Use branch `codex/a4-cancellable-journal` in `.worktrees/a4-cancellable-journal/`.
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
bash content/cases/rolling-back-a-cancellable-journal/checks/verify.sh PINNED_ASH
markdownlint content/cases/rolling-back-a-cancellable-journal/README.md
shellcheck -x -P SCRIPTDIR content/cases/rolling-back-a-cancellable-journal/checks/verify.sh
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
[cells]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[cleanup]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-cleanup-actions
[closing]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#scoped-cleanup-actions
