# Requesting a value teaching pilot

## Approved outcome

The reader asks how a calculation obtains a bonus from its caller's context,
and what must be handled before the complete program can run. This pilot
revises E1's prose and exercises after Learn Ash. It preserves the four
canonical programs, their observations, fixtures, and checks.

The [roadmap](../project/roadmap.md#selecting-work) owns this outcome. Work
targets `diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
The user approved the design and requested implementation on 2026-10-13.

## Approach and boundaries

Revise the existing exploration instead of adding programs. Its argument-based
calculation, two handler answers, and unmet entry requirement already
distinguish how the bonus is used, chosen, and required. Additional programs
would expand the evidence without closing an identified teaching gap. Deferring
the revision would leave explanations revealing answers before predictions.

Use original prose informed by the [Liquid Shplait record](../../research/liquid-shplait-teaching.md)
and [DCIC record](../../research/data-centric-introduction-to-computing.md).
Preserve their teaching-inspiration classification and adaptation boundaries.
Ash claims derive from the pinned specification's effects, computation-row,
entry, and handler-evaluation rules, and its tool guide. Detailed continuation
control, open rows, multiple operations, and resources remain in later lessons.

## Execution

1. Revise `content/effects/requesting-a-value/README.md` in its existing order.
   Put predictions before revealed numerical results. Explain operation,
   request, handler, resumption, and row through the scoring calculation.
   Ask what remains unanswered before showing the preserved rejection;
   connect its source label to the entry contract and the handler repair.
2. Start each practice task from a fresh copy of `02-handled.ash`. Retain
   changing the answer to seven, doubling earned points, and writing the
   equivalent argument-based version. Leave the results undisclosed and
   preserve the transition to E2.
3. Add `.codex/config.toml` with `model_context_window = 500000` and
   `model_auto_compact_token_limit = 450000`, matching ash-lang's defaults.
   Check the values as TOML. Saving this configuration does not establish
   that the running chat has adopted it.
4. Review source, semantics, teaching continuity, attribution, and links.
   Run the checks below against a separate clean exact-pin checkout; preserve
   the upstream checkout and its unrelated edits.
5. Update the roadmap after verification and remove this plan. Land the
   completed chapter and configuration as one reviewable revision.

## Verification

From the ash-doc worktree, run:

```sh
bash content/effects/checks/verify.sh /path/to/clean/diag-ash
git ls-files -z '*.md' | xargs -0 markdownlint
git ls-files -z '*.sh' | xargs -0 -n1 bash -n
git ls-files -z '*.sh' | xargs -0 shellcheck -x -P SCRIPTDIR
git diff --check
git status --short
```

The effects aggregate must retain E1's `42 : Int`, `42 : Int`, `45 : Int`,
and `entry.main-effects` rejection. Its checks retain displayed-source
agreement, the handler-only difference, semantic JSON, and complete English
human capture. Do not regenerate observations to hide a disagreement.

Check relative links and pinned specification anchors. Confirm that the
reader can locate who chooses and uses the bonus, explain what the row
records, and connect the rejection and repair to the entry boundary.
No language behavior, compiler target, verification tooling, or publication
choice changes. Any broader teaching rollout needs a separately selected
outcome.
