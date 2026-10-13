# E9 teaching review: cleanup

## Approved outcome

Reader question:
How do closing actions affect the log while preserving a body result?
The observable boundary is owned completion and interpreter availability
during closing.
The [active roadmap outcome](../project/roadmap.md#selecting-work) owns this
plan. Implement the approved E5–E12 review one complete chapter at a time.

Target `diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
Use an isolated ash-doc worktree and a separate clean exact-pin Ash checkout;
preserve unrelated edits in the upstream checkout.

## Design and authority

Revise the existing distinguishing cases rather than add programs. Additional
programs would require new evidence without closing an identified teaching
gap. Deferral leaves explanations revealing results before useful predictions.
Choose original prose informed by the existing
[DCIC record](../../research/data-centric-introduction-to-computing.md) and
[Liquid Shplait record](../../research/liquid-shplait-teaching.md).
These inspire teaching; the pinned specification and tool define behavior.

The pinned [static rule][static] and [evaluation rule][dynamic] govern the
boundary. Retain the [tool contract][tool] for commands and observations.
Preserve six sources, four accepted results, and two complete diagnostics.
Do not change Ash APIs, program behavior, source files, fixtures, checks,
compiler pin, tooling, publication choices, or earlier lessons.

## Execution

1. Revise `content/effects/running-cleanup/README.md`.

   Predict body results and logs separately; trace inner-to-outer actions during
   normal return and owned abandonment. Teach closing-position interpreter
   selection before asking about a removed nearest handler. Explain why a running
   action must finish and retain the limits on cleanup guarantees. Use fresh
   scratch copies for practice.

2. Review every changed file as source, nearby interpretations, prerequisite
   vocabulary, natural specification links, and undisclosed exercise answers.
3. Verify the existing evidence and unchanged executable/captured fences.
4. Update this chapter's roadmap outcome, remove this plan and its index link,
   and commit the complete verified chapter before selecting the next one.

## Verification

Use the clean exact-pin checkout as `/path/to/diag-ash`:

```sh
env RUSTC_WRAPPER= bash \
    content/effects/running-cleanup/checks/verify.sh \
    /path/to/diag-ash
git ls-files -z '*.md' | xargs -0 markdownlint
git ls-files -z '*.sh' | xargs -0 -n1 bash -n
git ls-files -z '*.sh' | xargs -0 shellcheck -x -P SCRIPTDIR
git diff --check
```

Check relative links and pinned anchors. Keep semantic JSON assertions separate
from complete English human agreement. Review source agreement, output, type,
status, causal boundaries, attribution, and guarantee limits. Exercise copies
belong outside canonical source trees. At E12, run the effects aggregate once
instead of only its lesson script to verify all twelve lessons / 71 sources.

[static]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-cleanup-actions
[dynamic]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#scoped-cleanup-actions
[tool]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/tools/ash.md
