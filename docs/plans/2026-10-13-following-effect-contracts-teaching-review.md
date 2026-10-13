# Following effect contracts teaching review

## Approved outcome

The reader asks which call makes a request and where that call's requirement
belongs. E2 follows the revised E1 and prepares the reader for callback effects
in E3. The user approved this prose and exercise review on 2026-10-13 as the
first of three sequential chapter revisions.

The [roadmap](../project/roadmap.md#selecting-work) owns this plan. All claims
and execution target `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

## Approach and boundaries

Keep the four canonical sources, diagnostic fixture, capture, and verifier.
The existing call chain and two returned-function programs distinguish request
timing even though their successful results agree. Revising their explanation
uses that evidence; adding programs would expand the checks without addressing
an identified gap. Deferring the revision leaves conclusions before prediction.

Use original prose informed by the existing Liquid Shplait and DCIC research
records. Claims derive from the pinned computation-row, function/application,
and evaluation rules and tool guide. Keep open rows, local generalization,
handler selection, and detailed continuation control in their later lessons.

## Execution

1. Revise `content/effects/following-effect-contracts/README.md`. Ask the reader
   to trace the call chain and predict its result before revealing the score.
2. Before the preserved missing-row capture, compare the declared contract
   with the call's requirement. Explain the labeled call and signature repair
   afterward; keep its reason code secondary.
3. Separate construction from invocation in both returned-function examples.
   Ask when the request happens and which call needs its handler. Explain
   after each observation, then consolidate the signature comparison table.
4. Start each practice task from a fresh copy of its named source. Preserve
   unanswered results and the transition to E3.
5. Review the source, governing rules, adaptation boundaries, and links. Run
   the checks below against a separate clean exact-pin checkout.
6. Update the E2 roadmap entry and remove this plan after verification. Commit
   this completed chapter before activating E3.

## Verification

From the ash-doc worktree:

```sh
env RUSTC_WRAPPER= bash \
    content/effects/following-effect-contracts/checks/verify.sh \
    /path/to/clean/diag-ash
markdownlint \
    content/effects/following-effect-contracts/README.md \
    docs/project/roadmap.md docs/plans/README.md
git diff --check
git status --short
```

Also lint this plan and verify relative links and pinned anchors. Preserve the
three `42 : Int` observations, the missing-row rejection, complete English
capture, semantic JSON, and source agreement. Confirm that the reader can
distinguish which call needs a handler when a function is returned. No Ash
behavior, compiler target, fixtures, checks, or project tooling changes.
