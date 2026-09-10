# Working on Ash Documentation

> Teach the reader how to design and understand Ash programs without turning
> an explanation into language truth.

Ash-doc is a separate, version-pinned learning and evidence stream governed by
the experiment in
[DN-0024](https://github.com/dikini/ash-lang/blob/main/docs/design/DN-0024-executable-learning-and-evidence-stream.md).
It may discover language, tool, library, diagnostic, and application pressure.
It cannot define Ash semantics or accept Ash architecture.

## Required writing skill

Before drafting, editing, reviewing, or planning any ash-doc prose, use
[`writing-ash-documentation`](.agents/skills/writing-ash-documentation/SKILL.md).
This requirement includes tutorials, research records, project documentation,
reviews, plans, and commit or pull-request messages. Prefer this project skill
over general writing guidance; use a general skill only when it adds a
compatible capability that the project skill does not cover.

## Authority and target

The planned edition target is `diag-ash` at Ash commit
`9231b21228c5ccacbbee0cc0da60b380e5d2dc59`, under the
[Diag Ash migration plan](docs/plans/2026-09-10-diag-ash-migration.md).
This cumulative checkpoint includes diagnostics, the migration repairs,
effects, library abstractions, and modules. Do not interpret its name as a
feature subset or plan a separate stop at `effect-ash`.

**Work and reference have different roles.** All new edition work targets
`diag-ash`. Earlier Ash milestones supply historical reference and
comparison evidence only. Their successful checks do not establish
Diag Ash correctness, and they are not alternative work targets.

Content cutover has not happened. Existing teaching sources, specification
links, and verifiers retain their last verified Lib Ash baseline at
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Only complete verified units under
an indexed content family and linked as active from that family index belong
to that baseline. An unavailable numbered Case remains historical evidence.
Do not relabel baseline verification as Diag Ash verification. During cutover,
move the shared pin and all target administration together, mark pending units
as drafts, and restore active navigation only after each unit verifies.

The immutable predecessor targets `modular-ash` at commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. It remains historical evidence and
does not govern active material. DN-0024 proposed Mini-Ash for the first pilot
edition; the project's version choices retain the note's other experiment
boundaries.

A published ash-doc edition uses the exact tag name of its target Ash
milestone. The tags are repository-local and identify different commits: the
`ash-lang` tag retains language and tool behavior, while the ash-doc tag retains
the corresponding documentation source snapshot. Never move or reuse a
published documentation tag.

Use sources according to the claim you are making:

1. The [Diag Ash specification](https://github.com/dikini/ash-lang/tree/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec)
   governs current migration work and all migrated material. The historical
   [Lib Ash specification](https://github.com/dikini/ash-lang/tree/d1e323d23390cdad03202ee3df76cd9100556e1d/spec)
   explains only the retained baseline and comparisons.
2. The [Diag Ash tool guide](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/docs/tools/ash.md),
   implementation, and tests at that commit govern new tool observations.
   Historical observations retain their own exact tool and compiler pin.
3. Accepted architectural decisions in `ash-lang` govern the non-language
   choices within their scope and retained version.
4. Change proposals describe proposed transitions. Tasks authorize work.
   Design notes explore ideas and uncertainty. None defines current Ash.
5. Historical Ash and documentation experiments are evidence only.

Use current `ash-lang/main` for current project process, future pressure, and
the latest
[Ash writing guide](https://github.com/dikini/ash-lang/blob/main/docs/project/writing.md).
Do not import language behavior from `main` into the pinned edition.

The repository README declares the planned target, content-cutover state,
last verified baseline, and immutable predecessor. Learning pages inherit
their declared content target; do not repeat it in every lesson. Plans and verification must still name the
exact target. An upstream canary may test a newer exact commit, but it does not
change the active migration target.

## Reconstruct enough context

Begin every task by stating the reader's question and the observable boundary
it crosses. Then reconstruct the smallest causal model that answers it:

1. Read [README.md](README.md) and identify whether the work is published,
   experimental, migratory, or project-level.
2. Read the pinned specification overview, then only the chapters that govern
   the language claims in the task.
3. Read the pinned tool guide and relevant tests or implementation when the
   task describes commands, output, failures, or diagnostics.
4. Read current design or project artifacts only when the task concerns future
   pressure, evidence exchange, or repository workflow. Preserve each
   artifact's stated authority.
5. Challenge the first explanation. Look for a negative case, an interaction
   with another feature, or a simpler account through existing Ash semantics.
6. Stop when you can explain current behavior, crossed boundaries, relevant
   evidence, downstream pressure, simplification opportunities, and intentional
   exclusions.

Do not replace this model with a reading list. Link each semantic conclusion to
the pinned specification section that supports it. Label unknown or proposed
behavior instead of filling the gap from memory, implementation accidents, or
historical Ash.

## Writing and teaching style

The required writing skill owns ash-doc's voice, vocabulary, exposition shape,
teaching recipe, and source-adaptation style. The current Ash writing guide
remains its baseline. This file owns repository authority, executable-example,
workflow, discovery classification, and verification rules.

`content/learn/` is one sequential self-learning work. Its index owns shared
setup and reading order. Each lesson continues the reader's model and renders
only teaching material. Keep project state, targets, governing-source lists,
evidence records, and migration administration in project documents and checks.
If a future tool needs page-local metadata, give it a concrete schema and place
the data in YAML front matter rather than rendered lesson prose.

## Code and executable examples

Write Ash for the pinned milestone, not from memory and not for
`ash-lang/main`.

- Follow the source style used by the pinned specification: descriptive
  `snake_case` term names, `PascalCase` type and constructor names, signatures
  adjacent to their global definitions, and consistent four-space indentation
  inside declarations and branches.
- Choose names from the problem domain. Keep `main` focused on the observation
  the lesson promises. Remove unrelated language features from small examples.
- Keep a runnable program in a canonical source file. A displayed runnable
  block must be transcluded from that file or checked for exact agreement with
  it. A hidden source marker may support that check; the lesson need not expose
  a canonical-source link.
- Test successful examples for the applicable value, type, standard output,
  and exit status. Test intentional rejections for the stable reason and
  relevant source location on which the explanation depends. Also assert any
  causal source relationship that the explanation teaches.
- Present the smallest negative example that still establishes the boundary.
  Do not teach incidental diagnostic prose, colors, or layout as a contract.
- Label pseudocode, transcripts, future Ash, and incomplete fragments as
  non-executable. Do not place them in an `ash` fence.
- Keep tests deterministic and hermetic. Use checked-in inputs and controlled
  time, randomness, temporary storage, and loopback services when those
  facilities become relevant.

Execution is necessary but insufficient. Explain the representation,
invariant, derivation, and cost when they carry the idea being taught.

The repository has not selected a host language, formatter, renderer, or test
harness. Do not introduce local coding conventions for hypothetical tooling.
When the project selects a tool, adopt its formatter and linter and record any
additional rules that evidence requires.

## Repository workflow

Follow the [ash-doc project workflow](docs/project/workflow.md). Select one
complete outcome in the [roadmap](docs/project/roadmap.md), obtain approval for
its bounded design, and use a temporary plan under
[`docs/plans/`](docs/plans/README.md) owned by that outcome or decision. Create a
content family or lesson only when its prose, canonical code, fixtures, and
applicable checks can land together.

Keep project choices behind concrete needs. A new directory layout, renderer,
harness, manifest, dependency, CI service, or publication mechanism requires a
bounded design before implementation:

1. State the reader or maintainer problem.
2. Identify the authority and version boundaries involved.
3. Compare at least two credible approaches and the cost of deferring the
   choice.
4. Select the smallest replaceable choice that supports the next complete
   lesson.
5. State its verification and removal or migration condition.
6. Obtain project approval, then implement and verify it in one narrow change.

Do not create empty structure for anticipated work. Keep lesson prose,
programs, fixtures, and checks together once the project accepts a lesson layout.
Do not establish a second specification, duplicate every tutorial program in
`ash-lang`, or add compatibility machinery for old Ash editions.

The repository has one active forward line on `main`, now planned for
`diag-ash`. Preserve a published edition with the immutable tag named by its
target Ash milestone. During content cutover, move `main` to one exact Ash
commit, expose incomplete
coverage, and restore lessons only after their examples pass. Do not backport
new work or maintain an old edition branch.

## Classify discoveries

When text and its source of truth disagree:

- correct an ash-doc mistake against the pinned specification or tool contract;
- minimize a failure of specified behavior as an Ash regression candidate;
- return an unspecified semantic question to Ash design or proposal work; and
- retain library, tooling, diagnostic, performance, and application pressure
  as evidence without presenting it as a language obligation.

An upstream evidence candidate identifies the ash-doc case and exact commits,
the reader or user task, its source tradition, executable observations, the
blocked or costly boundary, and why the finding matters beyond one example.
One case may expose pressure; it does not accept a new language mechanism.

## Verification

Before completing a change:

1. Read every changed file as source, not only as rendered output.
2. Check Markdown structure, spelling, and relative links. Run the repository's
   Markdown checks when they exist.
3. Verify every language claim against the pinned specification and every tool
   claim against the pinned tool behavior.
4. Run every affected executable example against its declared exact Ash target.
5. Confirm that displayed code agrees with its canonical source and that
   positive and negative observations assert the promised boundary.
6. Review attribution, adaptation notes, and license constraints.
7. Confirm that facts, proposals, experiments, and unknowns retain their actual
   status.
8. Run `git diff --check` and inspect `git status --short` before committing.

The repository selects the indexed `docs/`, `content/`, `lab/`, and `research/`
roots, the first learning family, and lesson-local source and checks. It selects
no renderer, shared harness, manifest, CI service, publication platform, or
license.
