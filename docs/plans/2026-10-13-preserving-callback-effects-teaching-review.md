# Preserving callback effects teaching review

## Approved outcome

The reader asks how one helper accounts for callbacks with different effect
requirements. E3 follows the completed E2 review and prepares the reader for
handler selection in E4. The user approved this prose and exercise review on
2026-10-13 as the second of three sequential chapter revisions.

The [roadmap](../project/roadmap.md#selecting-work) owns this plan. All claims
and execution target `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

## Approach and boundaries

Keep all six canonical sources, three diagnostic fixtures and captures, and
the verifier. The existing callback, known-effect, unknown-union, and exclusion
cases already distinguish the contracts. Revising their explanations avoids
expanding evidence without a teaching gap; deferring preserves premature
answers and ambiguous exercise starting points.

Use original prose informed by the existing Liquid Shplait and DCIC records.
The pinned computation-row and function/application rules govern the claims;
the pinned tool governs diagnostics. Keep signed global helpers and distinguish
row requirements from request counts. Local generalization and detailed
handler control remain in their established lessons.

## Execution

1. Revise `content/effects/preserving-callback-effects/README.md`. Ask for a
   trace of both callback calls before the pure result. Compare supplied and
   required callback types before revealing the preserved rejection.
2. Explain `A`, `R`, and their kinds beside first use. Ask readers to identify
   the substitutions for the pure and effectful uses and predict both results
   before consolidating the explanation.
3. Separate the known member, unknown union, and excluded-callback boundaries.
   Place prediction before the known-effect result. Connect each diagnostic's
   labels to its cause and existing repair, keeping reason codes secondary.
4. Preserve the distinction between E2's closed-contract mismatch and the
   open-tail union here. Start tasks one and two from separate copies of the
   open-row program and task three from the known-effect program.
5. Review source, governing rules, attribution, and links. Run the checks below
   against the separate clean exact-pin checkout.
6. Update the E3 roadmap entry and remove this plan after verification. Commit
   this completed chapter before activating E4.

## Verification

From the ash-doc worktree:

```sh
env RUSTC_WRAPPER= bash \
    content/effects/preserving-callback-effects/checks/verify.sh \
    /path/to/clean/diag-ash
markdownlint \
    content/effects/preserving-callback-effects/README.md \
    docs/project/roadmap.md docs/plans/README.md
git diff --check
git status --short
```

Also lint this plan and verify links and pinned anchors. Retain the accepted
values and types, all three rejections, semantic JSON, complete English human
agreement, and source agreement. Confirm that readers can explain both row
instantiations and why the tail exclusion limits a call without limiting the
number of requests. Leave practice results undisclosed. No Ash behavior,
compiler target, programs, fixtures, checks, or project tooling changes.
