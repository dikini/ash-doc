# A2: Supplying a local pricing policy

Reader question: how can a pricing method retain a tariff without exporting
local evidence?
The observable boundary is nominal units, lexical evidence selection, and an
identity-free quote closure.
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

Own [roadmap A2](../project/roadmap.md#a2-how-can-a-local-pricing-policy-capture-configuration).
Continue [order prices](../../content/cases/supplying-order-prices/README.md),
[nominal wrappers](../../content/libraries/wrapping-a-representation/README.md),
and [scoped evidence](../../content/libraries/supplying-scoped-evidence/README.md).
Consult their local verifiers for unchanged controls and diagnostic conventions.
[Local nominal scope][nominals] forbids outward local identities; [exact evidence][evidence]
permits retained selected methods in an identity-free closure.
[Interfaces][interfaces] govern explicit policy requirements; imported names
do not select implementations.

Use `Money(Int)` cents and `Quantity(Int)` counts over stated finite,
nonnegative inputs. Products are `Book` and `Pen`; an order has two lines.
A quote is `Priced(Money)` or `Unavailable`. Derive `PricePolicy<P>` with a
method accepting both policy token and product and returning availability with
a unit price. The generic quote operation receives the token and order.
Use only `+`, `*`, and `==`; finite nonnegative inputs are a declared domain,
not runtime range validation. Do not assume division, Float, or inferred units.

Compare an explicit pricing function, an explicitly selected imported
implementation, and sequential local `with` evidence for `TariffPolicy(Unit)`.
Each local method captures the preceding integer tariff. Nested policies use
distinct local keys, not duplicate evidence for the same key.
Return an `Order -> Quote` closure with no local identity in its exposed type;
it retains selected method functions, never an exported evidence fact.
Explicit parameters alone could solve pricing but would omit this lexical
selection question; global tariff evidence would not express the local choice.
Keep the domain module local; defer a reusable commerce library.

## Owned files

Use `content/cases/supplying-a-local-pricing-policy/` with:

- `README.md`: calculation, three policy approaches, nesting, repair, exercise.
- `src/orders.ash`: products, lines, money, quantity, quote, explicit
  calculation.
- `src/pricing.ash`: policy interface and constrained quote operation.
- `src/base_policy.ash`: public nominal base key and imported implementation.
- `src/01-explicit-policy.ash`, `02-imported-policy.ash`, `03-local-policy.ash`:
  complete accepted entries; abbreviated filenames are also under `src/`.
- `src/04-nested-policies.ash`, `05-returned-closure.ash`,
  `06-boundary-orders.ash`: accepted independent comparisons.
- `src/07-mixed-units.ash`, `08-before-evidence.ash`, `09-local-escape.ash`:
  minimal rejection entries.
- `checks/verify.sh`; `checks/07-mixed-units.diagnostic.json`,
  `08-before-evidence.diagnostic.json`, `09-local-escape.diagnostic.json`.
- Complete human captures in `README.md`, checked by the shared helper.

Enumerate modules and entries and check every displayed runnable block.

## Implementation and acceptance

1. Derive the unit-price and order-total operations from the two-line example.
   Separate availability from zero price. Make quantities explicit at each step.
2. Implement the direct function calculation and the selected imported policy.
   Two books at `2000` plus three pens at `300` must yield `Priced(4900)`.
   Both paths must agree with that literal arithmetic, not just with each other.
3. Supply local exact methods. Tariffs per item `100` and `200` yield `5400`
   and `5900`; charge five units, not two lines. Check both quote constructors.
4. Use distinct nested keys and require observations `5400, 5900, 5400`.
   Explain which lexical call selects which complete evidence application.
5. Return and call the identity-free closure after its evidence block returns.
   Require the captured tariff's quote and show its exposed `Order -> Quote`
   contract; do not imply later callers can select the local evidence.
6. Check all-zero quantity gives `Priced(0)` when prices are available, and an
   unavailable requested product yields `Unavailable`. State that this model
   requests both line prices, including zero-quantity lines, and test that rule.
7. Develop mixed-unit application, a constrained call before `with`, and local
   identity escape as three isolated rejections. Assert stable reasons and
   relevant locations; capture full messages and show complete tested repairs.
8. Explain the domain, representation, selection boundary, and arithmetic cost.
   End with practice using only introduced units and evidence operations.

Exclude currency conversion, tax rounding, negative/range validation, runtime
fresh policy identity, dynamic registries, and new library infrastructure.
Any ambiguity in availability or the type boundary must be resolved in the
explicit application contract before the Case is declared verified.

## Execution and handoff

Follow the [shared execution contract][execution] for dispatch, worktree,
issue, integration, and final review. PM uses `gpt-6.1-sol` at `medium`,
development at `xhigh`, and independent review at `max`.
Find or create one matching issue and PR in `dikini/ash-doc` for this Case.
Use branch `codex/a2-scoped-pricing` in `.worktrees/a2-scoped-pricing/`.
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
bash content/cases/supplying-a-local-pricing-policy/checks/verify.sh PINNED_ASH
markdownlint content/cases/supplying-a-local-pricing-policy/README.md
shellcheck -x -P SCRIPTDIR content/cases/supplying-a-local-pricing-policy/checks/verify.sh
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
[nominals]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#local-nominal-scope
[evidence]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-exact-evidence
[interfaces]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#interfaces-and-constrained-schemes
