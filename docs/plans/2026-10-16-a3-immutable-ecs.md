# A3: Querying an immutable world

**Migration status:** retargeted to FFI Base; acceptance remains unverified.
The migration does not implement this Case.

Reader question: how can one generic movement system join components and
preserve a snapshot?
The observable boundary is explicit component evidence versus the entity-join
application invariant.
Action and scope: implement one complete Cases lesson under the fixed subtree
below, including prose, canonical programs, fixtures, and local checks.
This is selected application design, not a language or architecture decision.

**State:** planned; application code and observations remain unverified.

Target: `ffi-base`, Ash commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. Read the
[specification overview][overview] and the governing sections before coding.
The [tool guide][tool]
at that same pin governs commands, diagnostics, and output. DN-0052 at
`9f8738b7e0d7f280f9744bf808343d2c97ce6661` is informative motivation only.
Use the [project workflow][workflow], [verification guide][verification], and
[writing skill][writing]. All signatures and constructor forms named in this
brief are non-executable design notation; derive tested Ash in canonical files.

## Design and prerequisites

Own [roadmap A3](../project/roadmap.md#a3-how-can-a-generic-system-query-an-immutable-ecs-world).
Continue [dictionary as list](../../content/cases/dictionary-as-list/README.md)
and [implementation evidence](../../content/libraries/choosing-implementation-evidence/README.md).
Consult their local verifiers for existing checks. [Interfaces][interfaces]
govern the complete `StoreAccess<W, C>` application and explicit selection.
Do not declare a `W -> C` determination edge: the same world has both stores.

Use nominal entity identifiers and two-dimensional `Position` and `Velocity`.
`World` contains `Store<Position>` and `Store<Velocity>`. Each immutable store
is a unique-identifier association list. Its `put` replaces an existing entry
or inserts an absent one; copied dictionary shadow bindings would violate the
unique enumeration invariant. Derive lookup and joining before generic access.
The interface has `component_store : W -> Store<C>` and
`replace_store : (W, Store<C>) -> W` (non-executable contract notation).
Both parameters belong to the key and occur in each method type. Explicit
argument/result context fixes the requested component; provide selected facts.

Start with direct world-specific movement, then the generic movement system.
Join by entity identifier, in position-store order; never by list position.
Produce a new position store and replace the world's position field once at
the end. State actual nested lookup and repeated linear `put` work; do not
claim physical rebuilding happens once. Pure data preserves the old world.
A fixed direct schema is the comparison; open registries would introduce an
unneeded mechanism. Keep the fixed generic design, and defer heterogeneous
paths.

## Owned files

Use `content/cases/querying-an-immutable-world/` with:

- `README.md`: entity model, join derivation, direct/generic comparison, cost.
- `src/stores.ash`: entities, components, list store, lookup,
  replace-or-insert, and enumeration.
- `src/world.ash`: world, direct movement, and public store evidence.
- `src/systems.ash`: interface contracts, constrained join and movement.
- `src/01-direct-movement.ash`, `02-generic-movement.ash`,
  `03-repeated-step.ash`: complete accepted entries under `src/`.
- `src/04-store-boundaries.ash`, `05-positional-zip.ash`:
  accepted boundary checks and the well-typed wrong join comparison.
- `src/06-missing-evidence.ash`, `07-wrong-component.ash`:
  minimal source rejections; successful generic entry supplies repairs.
- `checks/verify.sh`; `checks/06-missing-evidence.diagnostic.json`,
  `07-wrong-component.diagnostic.json`.
- Complete human captures in `README.md`, checked by the shared helper.

Keep public API dependency order acyclic: `systems` owns the interface and
imports `stores`, which defines both component types, without importing
`world`; `world` implements it. Generic algorithms consume these contracts
without importing `world`.
Enumerate all source modules and entries; only display checked canonical code.

## Implementation and acceptance

1. Derive store uniqueness, lookup, and replace-or-insert from a finite example.
   Test inserting and replacing an identifier leaves exactly one binding.
2. Fix positions `1=(10,5), 2=(20,7), 3=(30,9)` and velocities deliberately
   ordered `3=(1,2), 1=(2,-1), 4=(9,9)`. Independently enumerate joined IDs
   `1,3` and their correct component pairs before implementing movement.
3. Implement direct movement. One step yields positions `1=(12,4)`,
   `2=(20,7)`, `3=(31,11)`; the velocity store and old world are unchanged.
   Check exact stores, not only aggregate coordinate sums.
4. Implement selected `StoreAccess` facts for both components and generic
   movement with explicit result context. Require the same independently
   specified step result. Explain why one world's type cannot determine `C`.
5. Two steps yield `1=(14,3), 2=(20,7), 3=(32,13)`, with unique identifiers
   and unchanged velocities. Retain and compare the original snapshot.
6. Check empty stores, missing velocity, velocity-only ID `4`, and absent
   lookup. Never create a position merely because a velocity exists.
7. Show a well-typed positional zip pairs different IDs on the fixed order;
   independently assert its wrong rows and distinguish application failure
   from type checking. Repair with identifier lookup.
8. Capture missing selected evidence and wrong-component rejections with stable
   reason/location assertions. Keep each isolated from the other failure.
9. Derive lookup and update costs for this representation, distinguishing
   logical work from allocation and measured time. Write the connected lesson
   and a discovery exercise without inventing performance evidence.

Exclude mutation, packed stores, automatic type-index search, associated
outputs, dynamic components, concurrency, and a heterogeneous-path extension.
The finite examples check invariants but cannot prove a complexity bound or
compiler soundness. A schema redesign requires a separately bounded need.

## Execution and handoff

Follow the [shared execution contract][execution] for dispatch, worktree,
issue, integration, and final review. PM uses `gpt-6.1-sol` at `medium`,
development at `xhigh`, and independent review at `max`.
Find or create one matching issue and PR in `dikini/ash-doc` for this Case.
Use branch `codex/a3-immutable-ecs` in `.worktrees/a3-immutable-ecs/`.
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
bash content/cases/querying-an-immutable-world/checks/verify.sh PINNED_ASH
markdownlint content/cases/querying-an-immutable-world/README.md
shellcheck -x -P SCRIPTDIR content/cases/querying-an-immutable-world/checks/verify.sh
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
[overview]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/README.md
[tool]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md
[interfaces]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#interfaces-and-constrained-schemes
