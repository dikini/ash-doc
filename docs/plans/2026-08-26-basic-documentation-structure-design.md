# Basic Documentation Structure Design

- Status: approved for this bootstrap change
- Ash target: `modular-ash` at
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`

## Problem

Ash-doc needs to plan tutorials and keep their prose, programs, fixtures, and
checks connected. It also needs places for bounded experiments and source
research without presenting either as published Ash instruction.

[DN-0024](https://github.com/dikini/ash-lang/blob/main/docs/design/DN-0024-executable-learning-and-evidence-stream.md)
proposes useful conceptual areas and a unit-local evidence model. The note is
informative. Ash-doc must accept its own replaceable pilot workflow rather than
treating that proposal as permanent repository architecture.

## Compared approaches

### Unit-first indexed roots

Create indexed roots for project work, content, laboratory work, and research.
Materialize a content-family or unit directory only when approved work needs
it. Keep each unit's prose, canonical code, fixtures, and checks together.

This approach preserves the causal link between an explanation and its evidence
without selecting a renderer, manifest, or harness.

### Separate prose, code, and check trees

Separate trees make bulk tooling straightforward, but every unit then needs a
mapping among its explanation, source, fixtures, and checks. That mapping would
become repository architecture before the project has selected its first unit
or toolchain.

### Manifest-first registry

A registry could provide numeric identities and coverage queries immediately.
It would also select metadata syntax, validation, and maintenance rules before
cross-repository links or automation demonstrate that need.

## Decision

Use unit-first indexed roots:

```text
docs/
  README.md
  project/
    workflow.md
    roadmap.md
  plans/
    README.md
content/
  README.md
lab/
  README.md
research/
  README.md
```

The root indexes define boundaries and future path shapes. They do not create
empty content families or hypothetical unit internals.

Use a stable family and unit slug as the initial identity. Cite an immutable Git
commit when another repository needs a durable reference. Defer numeric IDs and
a registry until path identity proves insufficient.

## Workflow

1. Select one reader question, observable outcome, content family, exact Ash
   target, and coverage need in the roadmap.
2. Compare credible approaches and approve the smallest complete unit.
3. Create a temporary execution plan under `docs/plans/`.
4. Materialize `content/<family>/<unit>/` only when its prose, canonical code,
   and applicable checks can land together.
5. Verify the unit against its exact target, classify discoveries, update the
   roadmap, and remove the completed execution plan.

A content unit records its state, exact target, governing specification
sections, prerequisites, outcomes, observations, limitations, and applicable
source or evidence links in readable Markdown. No machine-readable manifest is
selected.

Create `lab/<case>/` only for a bounded executable experiment with a governing
Ash design note, immutable target, comparison criteria, observations, and a
retention or disposal condition. Create `research/<source>.md` only for a
concrete source or technique evaluation, including contribution, edition,
material consulted, adaptation classification, and licensing constraints.

## Verification and replacement boundary

This bootstrap verifies Markdown structure, links, authority wording, and the
absence of empty leaf scaffolds. Future content verifies every executable claim
against its declared target using the unit's applicable checks.

The workflow is a pilot choice. Revisit it after several complete units expose
real navigation, coverage, reuse, or automation pressure. Until then, defer a
renderer, shared code tree, manifest, harness, CI service, publication platform,
and compatibility machinery.
