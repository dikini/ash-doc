# A7: Cancel a stable sort

The reader asks what a sort can promise when permission to compare can stop.
The observable boundary separates a complete stable result, charged comparison
work, and cancellation. Scope is one lesson implementing roadmap A7.

## Target and prerequisites

**State:** planned; application code and observations remain unverified.

Use `diag-ash`, exact Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`, throughout.
Read README, workflow, writing skill, and roadmap A7. Continue
`content/cases/searching-ordered-tree/`,
`content/cases/measuring-tree-search/`, and
`content/cases/bounding-search-work/`, including local checks.
The [overview][overview], [effect typing][effects], and
[handler completion][completion] govern requests and single consumption.
Neither those rules nor a successful execution establish sorting correctness.
DN-0052 at `9f8738b7e0d7f280f9744bf808343d2c97ce6661` remains informative only.

## Fixed design

Use slug `cancelling-a-stable-sort`, branch `codex/a7-stable-sort`.
Non-executable design notation: `Priority = Low | Normal | High`,
`Record(priority, id)`, and `Result = Sorted(records) | Cancelled`.
Use ordinary recursive lists and an explicit finite-priority comparator.
Do not assume built-in integer ordering. Recursively sort the tail, then insert
the original head before the first equal or greater priority. The equal branch
is necessary for preserving the original order of ties with this recursion.

Request `Compare.allow : Unit -> Unit` (non-executable API notation) before
every comparator invocation. A permitted request
charges one performed comparison; a denied request charges none and abandons
owned work with checked discard. Return no partial sequence labelled `Sorted`.
Return ordinary used-count data alongside the result so completed and cancelled
runs are comparable. A separate pure reference performs three stable filters
for Low, Normal, High and concatenates them; share neither the insertion
algorithm nor its comparator with that reference.

Use input `Normal/1, Low/2, Normal/3, High/4, Low/5`.
The expected IDs are `2,5,1,3,4`; tail-first insertion performs exactly seven
comparisons. Explain this finite calculation before discussing a bound.
A deliberately wrong insertion after equal priority reverses ties while staying
well typed. A separate double-resume handler is a control error, not a sorting
counterexample; alternatives need ordinary data or fresh calls.

Compare tail-first insertion with a general merge-sort implementation.
Choose insertion because the equality position and charge point remain visible;
deferring the choice prevents a precise work promise. Its source work is
quadratic in the worst case, explained from insertion traversal and allocation,
not inferred from wall time. Revisit only for an approved larger-input question.

## Owned files

All paths are relative to `content/cases/cancelling-a-stable-sort/`.
Create `README.md`, `checks/verify.sh`, and:

- `src/sort.ash`: records, explicit comparator, permission request, insertion.
- `src/reference.ash`: independent stable filters and concatenation.
- `src/01-complete.ash`: full example with ordinary used count.
- `src/02-budgets.ash`: budgets `0`, `6`, `7`, `8` on that same input.
- `src/03-small-inputs.ash`: empty, singleton, and equal-priority examples.
- `src/04-unstable.ash`: well-typed insertion-after-equals counterexample.
- `src/05-double-resume.ash`: minimal invalid permission handler.
- `src/06-single-resume.ash`: accepted repaired handler.
- `checks/05-double-resume.diagnostic.json`: inspected semantic fixture.

Keep human diagnostics in marked README transcript fences. An optional cost
fixture, if used, is exactly `src/07-scaled-work.ash` and must answer the stated
comparison-count question; do not introduce benchmarks or external inputs.

## Implementation sequence

1. Derive result and permission contracts from complete versus cancelled work.
   Write independent expected order and the seven-comparison calculation.
2. Implement insertion and pure reference separately. Explain the ordered-tail,
   permutation, and tie-order invariants through the equal-priority branch.
3. Add budget handling before comparator invocation. Inspect count and result
   together for both completed and cancelled branches.
4. Add the unstable alternative and small inputs; compare literal expected IDs
   and per-priority input order independently of the implementation's comparator.
5. Capture the double-resume diagnostic and accepted repair. Explain its source
   labels without conflating it with an unstable yet checked program.
6. Write the chapter, practice and next question; verify locally and obtain
   integrator changes and independent review before closing the Case PR.

## Acceptance and verification

- The main fixture returns IDs exactly `[2,5,1,3,4]` and count `7`, agrees
  with the reference, preserves all complete records, and preserves order of
  input IDs in each priority. Check literal order as well as reference equality.
- Budget `0` returns `Cancelled` with used `0`; budget `6` returns
  `Cancelled` with used `6`. Budgets `7` and `8` return the complete expected
  result with used `7`. Denied permission never invokes the comparator.
- Empty and singleton inputs complete at budget `0` with used `0`.
  At least three equal-priority records keep their input ID sequence.
- The insertion-after-equals alternative compiles and reverses an equal-priority
  sequence, independently demonstrating failure of the stated stability contract.
- Double resumption rejects with `effect.resume-already-consumed` and the
  relevant resume locations; the repaired entry returns the expected full sort.
- Check source order of permission request before comparison, distinct reference
  structure, and absence of a partial `Sorted` result on cancellation.
- If the optional fixture is included, four High records followed by four Low
  records perform exactly `22` comparisons. Keep this finite observation
  separate from the derivation of quadratic source work and from physical time.

Run from ash-doc after implementation:

```sh
bash content/cases/cancelling-a-stable-sort/checks/verify.sh /path/to/diag-ash
bash -n content/cases/cancelling-a-stable-sort/checks/verify.sh
shellcheck -x -P SCRIPTDIR content/cases/cancelling-a-stable-sort/checks/verify.sh
markdownlint content/cases/cancelling-a-stable-sort/README.md
```

Exclude built-in Int ordering assumptions, asynchronous interruption, threads,
partial-result promises, timing benchmarks, general sorting libraries, and new
multi-shot continuation mechanisms.

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

[overview]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/README.md
[effects]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#effects
[completion]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#effect-handlers-and-completion
