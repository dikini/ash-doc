# Choosing a handler teaching review

## Approved outcome

The reader asks which active handler matches a request and what an ordinary
closure retains after its creating call finishes. E4 follows the completed
E2 and E3 reviews and prepares the reader for resumption in E5. The user
approved this prose and exercise review on 2026-10-13 as the third chapter.

The [roadmap](../project/roadmap.md#selecting-work) owns this plan. All claims
and execution target `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

## Approach and boundaries

Keep the eight canonical sources, including both sibling modules, the
diagnostic fixture and capture, and the verifier. Existing nested, forwarding,
parameterized, module, and closure cases support the question. Better traces
use that evidence; new programs would expand the checks without a demonstrated
gap. Deferring leaves explanations revealing answers before readers trace them.

Use original prose informed by the existing Liquid Shplait and DCIC records.
The pinned effects, exact-row identities, application, and handler-evaluation
rules govern the claims; the pinned tool governs the rejection. Keep detailed
continuation control, multiple operations, and resources in later lessons.

## Execution

1. Revise `content/effects/choosing-a-handler/README.md`. Ask readers to locate
   the answering clause before revealing the nested and forwarding results.
   Explain why the equal results follow different request paths.
2. Introduce exact parameterized instances through the existing requests.
   Compare request and handler targets before the preserved rejection. Explain
   the labeled target and repair both target and answer type afterward.
3. Keep the two sibling module declarations and consumer together. Have
   readers identify declaring modules and handlers before predicting the sum.
   Distinguish declaration identity from import spelling.
4. Trace closure construction separately from its later call, identifying
   saved values and the active handler before predicting the score.
5. Use fresh exercise copies beside the sibling modules. Preserve unanswered
   results and the transition to E5.
6. Review source, governing rules, attribution, and links. Run the effects
   aggregate and repository checks below against the clean exact-pin checkout.
7. Update the E4 roadmap entry and remove this plan after verification. Commit
   the completed chapter, integrate the ordered revisions, and clean up the
   temporary worktree and exact-pin checkout.

## Verification

From the ash-doc worktree:

```sh
env RUSTC_WRAPPER= bash content/effects/checks/verify.sh /path/to/clean/diag-ash
git ls-files -z '*.md' | xargs -0 markdownlint
git ls-files -z '*.sh' | xargs -0 -n1 bash -n
git ls-files -z '*.sh' | xargs -0 shellcheck -x -P SCRIPTDIR
git diff --check
git status --short
```

Verify relative links and pinned anchors. Preserve E4's values, types, wrong
instance rejection, semantic JSON, complete English capture, and source
agreement. The aggregate also checks the revised E2 and E3 chapters. Confirm
that all 18 canonical files and five captures remain intact, readers can trace
matching and closure captures, and no practice answer is disclosed. No Ash
behavior, target, programs, fixtures, checks, or project tooling changes.
