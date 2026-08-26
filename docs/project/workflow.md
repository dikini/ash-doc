# Project workflow

Ash-doc plans and verifies one complete documentation unit at a time. The unit
is the boundary that connects a reader's question, explanatory prose, canonical
programs, observations, and resulting evidence.

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

An index defines each root before the first leaf exists. Add a family, unit, lab
case, or research record only for approved work. Do not create empty leaf
scaffolds.

## Isolate project work

Create new task worktrees under `.worktrees/` in the repository. The directory
is ignored by Git; its worktrees and build artifacts remain local. Give each
worktree its own branch, and perform the complete planning, writing, and
verification cycle there.

## Plan one complete unit

Start in the [roadmap](roadmap.md). Name:

- the reader's question and reason for answering it;
- the content family and observable learning outcome;
- the exact Ash milestone and resolved commit;
- the governing specification or tool sections;
- prerequisites and the coverage gap the unit closes;
- applicable source tradition and adaptation constraints; and
- important boundaries the unit will exercise or deliberately exclude.

Compare at least two credible ways to teach and test the outcome. Select the
smallest unit that answers the question without relying on unintroduced Ash,
libraries, or tooling. Record any repository choice that the unit forces and
the condition under which that choice should be replaced.

After approval, create an execution plan under [`docs/plans/`](../plans/README.md).
One active roadmap outcome or bounded repository decision owns the plan and
links it while work remains active. The plan names exact files, executable
observations, verification commands, and the order in which prose and evidence
become complete.

## Materialize the unit

Published-track material uses this path shape:

```text
content/<family>/<unit>/
```

Create the family and unit together when the first complete unit needs them.
The unit keeps its explanation and canonical code together. Add `src/`,
`fixtures/`, or `checks/` inside that unit only when its programs need those
roles. Do not create shared code or test trees before two complete units expose
the same stable need.

The unit's `README.md` records, in readable Markdown:

- its draft, verified, or migration state;
- the Ash milestone and resolved commit it targets;
- the reader question, prerequisites, and learning outcomes;
- the governing specification and tool sections;
- commands and expected observations;
- source, adaptation, and licensing information when applicable; and
- known limitations, intentional exclusions, and evidence links.

These fields do not select a machine-readable manifest. The path is the initial
unit identity. Use an immutable ash-doc commit when another repository needs a
durable reference.

Runnable blocks follow [AGENTS.md](../../AGENTS.md): their canonical source and
applicable check must exist before the block is presented as executable. Land
the prose, source, fixtures, and checks in one narrow change. Keep incomplete
unit work in its plan until the prose and applicable local evidence can land
together. A complete but unverified unit remains a draft and cannot join a
coherent published edition.

## Verify and close the unit

Before marking a unit verified:

1. Check language claims against the specification at the declared commit.
2. Check tool claims and commands against the tool at the same commit.
3. Run the unit's positive, negative, and source-agreement checks.
4. Review prerequisites, outcomes, navigation, attribution, and licenses.
5. Classify every discovery without promoting it into Ash truth.
6. Update the roadmap and remove the completed execution plan.

Git history retains the plan. The current tree retains the unit, its evidence,
and only project records that still guide forward work.

## Route experiments and research

Create `lab/<case>/` when code must answer a bounded design or pressure
question. A versioned pressure case names its pinned specification or tool
boundary and exact edition target. A design experiment names its governing Ash
design note and immutable experimental target. Every case records comparison
criteria, observations, and a retention or disposal condition. Lab results are
evidence, not published instruction.

Create `research/<source>.md` when the project must evaluate a source or
technique before planning a unit. A record names the contribution, edition,
material consulted, adaptation classification, licensing constraints, and
deliberate exclusions. Research may motivate a unit or lab case; it does not
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

This is a pilot workflow. Revisit it when three complete units exist, a second
unit demonstrates a shared tooling need, or the project begins its first
publication or forward migration. Adopt a manifest, registry, renderer, shared
harness, or CI service only when that review names the concrete problem and a
smaller local convention cannot solve it.
