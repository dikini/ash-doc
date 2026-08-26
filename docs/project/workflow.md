# Project workflow

Ash-doc plans and verifies one complete lesson at a time. A lesson is a chapter
in a coherent learning sequence. Its directory is the evidence boundary that
connects the prose, canonical programs, observations, and checks.

This workflow adapts the experimental model in
[DN-0024](https://github.com/dikini/ash-lang/blob/main/docs/design/DN-0024-executable-learning-and-evidence-stream.md).
That note remains informative. This policy governs ash-doc project work; it
cannot define Ash semantics or accept Ash architecture.

## Repository roots

The indexed roots separate work by purpose:

```text
docs/       project policy, roadmap, and temporary plans
content/    material intended for a coherent documentation edition
lab/        bounded executable experiments and pressure cases
research/   source and technique evaluations
```

An index defines each root before the first leaf exists. Add a family, lesson, lab
case, or research record only for approved work. Do not create empty leaf
scaffolds.

## Isolate project work

Create new task worktrees under `.worktrees/` in the repository. The directory
is ignored by Git; its worktrees and build artifacts remain local. Give each
worktree its own branch, and perform the complete planning, writing, and
verification cycle there.

## Plan one complete lesson

Use the [beginning learning path](beginning-learning-path.md) to understand the
provisional sequence and the [roadmap](roadmap.md) to select the one active
outcome. A provisional entry creates no lesson directory or reader-facing
navigation. It enters the roadmap only when the project selects it as the next
complete increment.

For that increment, name:

- the reader's question and reason for answering it;
- what the reader already knows, the next idea, and the resulting model;
- the content family and observable learning outcome;
- the exact Ash milestone and resolved commit;
- the governing specification or tool sections;
- prerequisites and the coverage gap the lesson closes;
- applicable source tradition and adaptation constraints; and
- important boundaries the lesson will exercise or deliberately exclude.

Compare at least two credible ways to teach and test the outcome. Select the
smallest lesson that answers the question without relying on unintroduced Ash,
libraries, or tooling. Check that it continues the learning sequence instead of
repeating shared setup or standing alone. Record any repository choice that the
lesson forces and the condition under which that choice should be replaced.

After approval, create an execution plan under [`docs/plans/`](../plans/README.md).
One active roadmap outcome or bounded repository decision owns the plan and
links it while work remains active. The plan names exact files, executable
observations, verification commands, and the order in which prose and evidence
become complete.

## Materialize the lesson

Published-track material uses this path shape:

```text
content/<family>/<lesson>/
```

Create the family and lesson together when the first complete lesson needs
them. The lesson keeps its explanation and canonical code together. Add `src/`,
`fixtures/`, or `checks/` inside that directory only when its programs need
those roles. Do not create shared code or test trees before two complete
lessons expose the same stable need.

The learning-family index owns shared setup, the learning method, and reading
order. A lesson's `README.md` is a reader-facing chapter. It begins in the
subject, assumes the established setup and prior lessons, and introduces only
the next concepts the reader needs.

Keep administration outside rendered lesson prose:

- the repository README owns the edition target and authority boundary;
- the roadmap and temporary plans own state, questions, prerequisites,
  outcomes, governing sources, exclusions, and migration work;
- canonical files and checks own executable evidence; and
- research records own source and adaptation evaluation.

Do not render an administrative header, specification inventory,
canonical-source inventory, or evidence report in a lesson. Legally required
attribution may appear where readers encounter adapted material; keep the full
adaptation record in project work. Add page-local metadata only for a concrete
consumer, and place it in YAML front matter so it does not render as lesson
prose.

The path is the initial lesson identity. Use an immutable ash-doc commit when
another repository needs a durable reference.

Runnable blocks follow [AGENTS.md](../../AGENTS.md): their canonical source and
applicable check must exist before the block is presented as executable. Land
the prose, source, fixtures, and checks in one narrow change. Keep incomplete
lesson work in its plan until the prose and applicable local evidence can land
together. A complete but unverified lesson remains a draft and cannot join a
coherent published edition.

## Verify and close the lesson

Before marking a lesson verified:

1. Check language claims against the specification at the declared commit.
2. Check tool claims and commands against the tool at the same commit.
3. Run the lesson's positive, negative, and source-agreement checks.
4. Review continuity, prerequisites, outcomes, navigation, attribution, and
   licenses.
5. Classify every discovery without promoting it into Ash truth.
6. Update the roadmap and remove the completed execution plan.

Git history retains the plan. The current tree retains the lesson, its
evidence, and only project records that still guide forward work.

## Route experiments and research

Create `lab/<case>/` when code must answer a bounded design or pressure
question. A versioned pressure case names its pinned specification or tool
boundary and exact edition target. A design experiment names its governing Ash
design note and immutable experimental target. Every case records comparison
criteria, observations, and a retention or disposal condition. Lab results are
evidence, not published instruction.

Create `research/<source>.md` when the project must evaluate a source or
technique before planning a lesson. A record names the contribution, edition,
material consulted, adaptation classification, licensing constraints, and
deliberate exclusions. Research may motivate a lesson or lab case; it does not
claim executable Ash behavior.

## Classify discoveries

When an observation conflicts with an expectation:

- correct an ash-doc mistake against the pinned specification or tool contract;
- minimize a failure of specified behavior as an Ash regression candidate;
- return an unspecified semantic question to Ash design work; or
- retain library, tooling, diagnostic, performance, and application pressure as
  evidence without presenting it as an Ash obligation.

An upstream evidence candidate links the complete ash-doc context at an
immutable commit and identifies the exact Ash target, reader task, source
tradition, executable observations, blocked boundary, and wider significance.
Ash owns any resulting design, proposal, or retained regression obligation.

## Replacement boundary

This is a pilot workflow. Revisit it when three complete lessons exist, a second
lesson demonstrates a shared tooling need, or the project begins its first
publication or forward migration. Adopt a manifest, registry, renderer, shared
harness, or CI service only when that review names the concrete problem and a
smaller local convention cannot solve it.
