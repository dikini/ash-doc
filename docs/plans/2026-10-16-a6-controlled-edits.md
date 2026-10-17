# A6: Check proposed edits

**Migration status:** retargeted to FFI Base; acceptance remains unverified.
The migration does not implement this Case.

The reader asks how a controller can check a worker's proposed artifact before
allowing completion. The observable boundary is between continuation consumption
and authorization of ordinary data. Scope is one lesson implementing roadmap A6.

## Target and prerequisites

**State:** planned; application code and observations remain unverified.

Use `ffi-base`, exact Ash commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`, throughout.
Read README, workflow, writing skill, and roadmap A6. Continue
`content/cases/running-a-scripted-session/`,
`content/effects/resuming-a-calculation/`, and
`content/effects/stopping-a-calculation/`, with their local verifiers.
The [overview][overview], [effect typing][effects], and
[handler completion][completion] govern continuation claims: every normally
completing clause consumes its capability once through permitted resume or
owned discard. They do not authorize edits or verify an artifact.
DN-0052 at `9f8738b7e0d7f280f9744bf808343d2c97ce6661` is informative only.

## Fixed design

Use slug `checking-proposed-edits`, branch `codex/a6-controlled-edits`.
Non-executable design notation: `Edit(position, value)`,
`Proposal(edits, candidate_artifact)`, `Decision = Allow | Reject(RejectReason)`,
`Result = Completed(artifact) | Rejected(reason) | Cancelled`.
Use ordinary `RejectReason` alternatives `ForbiddenPosition(Int)`,
`MissingPosition(Int)`, `CandidateMismatch`, and `ScriptedRejection`.
The worker requests `Review.propose : Proposal -> Decision` (non-executable
API notation). One immutable proposal contains the entire batch. The controller
owns the original artifact and allowed positions. It accepts neither as
authoritative input from the worker. Use original `[10,20,30]`, positions
`[1,2]`, and
edits `1 := 25`, `2 := 35`, producing `[10,25,35]`.

Derive the worker's candidate using a zipper or prefix/suffix reconstruction.
The independent pure model traverses by index and applies edits sequentially.
Do not share the worker's edit function with the model. Check authorization,
position existence, and complete candidate equality before issuing `Allow`.
Check existence before permission so missing position `7` is distinguished from
existing but forbidden position `0`.
Repeated authorized positions use last edit wins; an empty batch preserves the
original. Use `Int` addition, multiplication, equality, and recursive/equality
bounds checks only; assume no built-in integer ordering operator.

A local script chooses allow, reject, or cancellation. The allow script resumes
`Allow` only after validation. Rejection resumes `Reject(reason)`; the worker
returns `Rejected(reason)`. Cancellation consumes its owned continuation with
`discard` and returns `Cancelled`. No later branch is silently collapsed into
another result. A deliberately approving controller demonstrates well-typed
invalid authorization independently of continuation errors.

Compare checking one batch against a multi-round session with mutable state.
Choose the immutable batch to keep trust and model independence visible;
deferral would leave the authority for current state unclear. This selects no
general agent protocol. Revisit it only for an approved multi-round question.

## Owned files

All paths are relative to `content/cases/checking-proposed-edits/`.
Create `README.md`, `checks/verify.sh`, and:

- `src/edits.ash`: data and worker prefix/suffix construction.
- `src/controller.ash`: independent indexed model and validation.
- `src/01-allow.ash`, `src/02-reject.ash`, `src/03-cancel.ash`:
  the three complete scripted branches.
- `src/04-batch-boundaries.ash`: forbidden, missing, wrong candidate,
  repeated-position, and empty-batch observations.
- `src/05-approve-all.ash`: well-typed invalid-controller counterexample.
- `src/06-double-resume.ash`, `src/07-missing-resume.ash`: minimal rejections.
- `src/08-resume-once.ash`, `src/09-owned-discard.ash`: accepted repairs.
- `checks/06-double-resume.diagnostic.json` and
  `checks/07-missing-resume.diagnostic.json`: inspected semantic fixtures.

Human diagnostic captures live in the README's marked transcript fences.
Do not create external worker-process fixtures or a new shared test harness.

## Implementation sequence

1. Derive proposal, decision, and result contracts from the trust boundary.
   State the unchanged controller-owned inputs and all finite examples first.
2. Implement worker construction and independent model with distinct recursion;
   verify the model against hand-calculated expected artifacts.
3. Implement validation and the three scripts. Keep owned cancellation local
   enough for pinned capture inference to establish discard permission.
4. Add boundary fixtures and approve-all; distinguish wrong application results
   from source rejection in both checks and prose.
5. Capture double/missing consumption rejections and repaired entries. Explain
   the complete message, source labels, and the change that consumes once.
6. Write the chapter and practice; check all sources and observations, then
   request integrator updates and independent review in the same Case PR.

## Acceptance and verification

- Valid allow returns `Completed([10,25,35])`. Scripted reject returns
  `Rejected(reason)` through a resumed decision. Cancellation returns
  `Cancelled` without running the worker's post-request completion suffix.
- Position `0` is forbidden even when its value happens to match the original.
  Position `7` is missing. A valid edits list paired with a wrong candidate is
  rejected. Inspect each distinct reason as ordinary application data.
- Two authorized writes `1 := 25`, `1 := 27` produce `[10,27,30]`.
  Empty edits with original candidate pass; empty edits with another candidate
  fail. Check these against literal expected values, not model equality alone.
- Approve-all completes a forbidden edit and is accepted by the compiler;
  the test asserts the wrong artifact to establish the policy counterexample.
- Minimal double and missing consumption reject with
  `effect.resume-already-consumed` and `effect.resume-not-consumed`, including
  relevant source locations. The one-resume and owned-discard repairs accept.
- Source assertions preserve distinct worker/model implementations and ensure
  controller inputs come from its own original and allowed-position values.

Run from ash-doc after implementation:

```sh
bash content/cases/checking-proposed-edits/checks/verify.sh /path/to/ffi-base
bash -n content/cases/checking-proposed-edits/checks/verify.sh
shellcheck -x -P SCRIPTDIR content/cases/checking-proposed-edits/checks/verify.sh
markdownlint content/cases/checking-proposed-edits/README.md
```

Exclude multi-round state, actual LLMs, subprocesses, files, tools, sandboxes,
concurrency, security isolation claims, and new authorization mechanisms.

## Execution and handoff

Follow the [shared execution contract](2026-10-16-application-cases-integration.md#shared-execution-contract).
Use `dikini/ash-doc`, one issue and one PR for this Case, and an isolated
`.worktrees/` checkout. Dispatch the PM with `gpt-6.1-sol` / `medium`,
the developer with `gpt-6.1-sol` / `xhigh`, and the reviewer with
`gpt-6.1-sol` / `max`. The Case author owns the lesson and this temporary plan.
The integrator owns shared index, runner, and coverage/count updates, included
in this same PR before final review. Do not edit those shared paths concurrently.

The issue must carry the reader question, exact pin, this plan, owned inventory,
acceptance criteria, and exclusions. The PR records observations, affected
checks, independent review findings and repairs, and remaining discoveries.
Do not merge until the complete Case and integrator changes pass review.
Remove this plan when its outcome is complete; Git retains its history.

Read every changed source, check spelling, relative links, attribution and
pinned anchors, and run `git diff --check` and `git status --short`.
Use original prose and code; adapt the teaching method recorded in the project's
HtDP/DCIC/Liquid Shplait research rather than copying their examples or wording.
Each displayed executable block must exactly match its canonical source.
Use the existing `content/checks/lib.sh` and its JSON and human comparisons;
assert value, type, stdout, stderr, status, and causal source relationships.
Capture every provided diagnostic in full using explicit human format and
English locale; normalize only the documented checkout prefix. Keep discovery
exercise answers undisclosed. Do not promote diagnostic wording to semantics.

No Case rendering is required here. Final integration owns HTML, EPUB, and both
PDF formats. Do not run whole-book builds or unrelated lesson checks.
Correct documentation errors against the pin. Minimize a specified-behavior
failure with passing controls as a regression candidate; return unspecified
semantics to Ash design. Retain other pressure as evidence. A regression leaves
the promised outcome incomplete: do not weaken it, modify ash-lang, or move the
pin. Report a required lab/shared change for separately bounded ownership.

[overview]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/README.md
[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[completion]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
