# Complete the callback effect-row lesson

The active outcome is roadmap E3 at `diag-ash`, commit
`9231b21228c5ccacbbee0cc0da60b380e5d2dc59`. E2 is complete and indexed.

The E3 draft is retained in the `codex/e2-e3-effects` task worktree under
`content/effects/preserving-callback-effects/`. It contains the chapter,
five canonical programs, two semantic fixtures, and its local verifier.
All five programs and both complete human diagnostic captures verify. The
source inventory and display checks pass. It is not part of active navigation.

The [row-tail exclusion case](../../lab/effect-row-tail-exclusion/README.md)
reproduces unexpected acceptance at the exact pinned target. A result row
`{Bonus | R}` specifies that `R` excludes `Bonus`, but passing a callback with
that effect is accepted. The draft must not promise that the current compiler
rejects this call. No compiler fix or alternate pin is authorized here.

Remaining work:

1. Resolve whether the lesson waits for an upstream fix and authorized baseline
   change, or explicitly teaches the current implementation limitation. The
   user has been asked; no answer has been received.
2. Review the resulting explanation against the specification and executable
   evidence. Preserve the full E3 outcome: row parameters, pure and effectful
   callbacks, known effects, exclusions, and ambiguous union behavior.
3. Complete verification, add E3 to active navigation, update counts and
   roadmap state, and remove this plan. Preserve discovery exercise answers
   outside the published chapter.

Reuse the existing family layout and helpers. Do not add compiler compatibility
machinery or treat the accepted invalid instantiation as language permission.
