# Eager recursive algorithms design

Status: approved on 2026-08-29 for implementation on `main`

## Reader and maintainer problem

The beginning Learn Ash path ends after a reader can define parameterized
recursive data and map over it. It does not yet show how to design a family of
algorithms from one traversal, reason about the source-level work that traversal
performs, or change the representation when an operation needs a different cost
or invariant.

The next path must answer these design questions without implying that its
algorithms define Ash. It must also let maintainers verify each complete case
without making a second content family depend on Learn Ash's internal check
directory.

## Authority and version boundary

Every executable case targets the published Modular Ash checkpoint at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Language claims come only from the
[specification at that commit](https://github.com/dikini/ash-lang/tree/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec).
Tool invocation, observations, failures, and exit statuses come from the
[pinned tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
and executable. Current `ash-lang/main` remains relevant only to project
process and a future migration.

The published ash-doc `modular-ash` tag is immutable. These cases begin as
unpublished work on `main`; they neither move the tag nor retarget the published
edition. The previously proposed current-main canary is deferred until an
explicit forward migration names its target and classification policy.

## Approaches considered

### Extend the beginning Learn Ash path

One approach would append eleven algorithm chapters to `content/learn/`. It
would reuse the existing setup and reading order directly. It would also turn a
bounded language introduction into a long algorithms curriculum and obscure
the point at which the reader starts comparing representations, invariants, and
costs.

### Add isolated laboratory experiments

A second approach would place each algorithm under `lab/`. That would support
executable pressure cases, but laboratories are evidence rather than a
sequential reader path. Readers would have no owned progression from folds to
balanced dictionaries, iterators, and search frontiers.

### Add a sequential Cases path

The selected approach creates `content/cases/` after the complete eleven-lesson
Learn Ash path. Cases can assume the language model and tool setup already
established by Learn Ash, then organize each chapter around a program-design
question and observable cost boundary. The family index owns the edit,
predict, run, and explain cycle and the source-level cost vocabulary. It lists
only verified cases.

Deferring this choice would leave the first case either detached from a reading
order or entangled with the beginning path. The new family is the smallest
replaceable choice that can preserve both sequences.

## Graduated roadmap

The roadmap uses three states:

- **next** identifies the one increment with an approved boundary and an
  active execution plan;
- **provisional** orders downstream questions without authorizing their
  content directories, source, or tooling; and
- **verified** identifies content whose prose, canonical programs, and checks
  pass together at the exact target.

Only one provisional increment may be promoted at a time. Verification of an
increment promotes its successor and may revise the remaining order when the
completed case supplies new evidence. The durable direction remains balanced
dictionaries, explicit eager iterators, and deterministic graph-search
frontiers.

## First increment: folding recursive lists

The first case asks how repeated recursive list equations can share one
traversal. It introduces a right `fold` whose equations mirror `List<A>`, then
defines `sum`, `length`, `map`, and `filter` through that fold. A counted
first-element calculation makes the lack of short-circuiting observable under
Ash's strict evaluation rules.

The case compares the direct recursive definitions the reader already knows
with one traversal supplied with different combiner functions. Direct
definitions introduce less abstraction for one operation, but repeat the
recursive control. The selected fold makes that control one named definition
and leaves each operation responsible only for its base value and combiner.

The case counts source-level operations and representation nodes. It does not
claim host stack optimization, constant stack space, exact heap bytes, or
compiler allocation strategy. Those properties would require separate,
reproducible implementation observations and would remain tool or performance
evidence rather than language semantics.

## Sources and adaptation

[*How to Design Programs*, second edition, 2026-02-25](https://htdp.org/2026-2-25/Book/)
informs the structural design method, the distinction between structural and
generative recursion, source-level cost reasoning, and later accumulator work.
Its contribution is inspiration: ash-doc will not copy its curriculum, prose,
or examples. The source is available under CC BY-NC-ND, which rules out
redistributing derivatives without separate permission.

Meijer, Fokkinga, and Paterson's *Functional Programming with Bananas, Lenses,
Envelopes and Barbed Wire* informs the separation of recursive traversal from
the operations supplied to a fold or unfold. The cases use original Ash prose
and examples. They exclude the paper's lazy semantics, infinite data, CPO
results, formal morphology notation, and any fusion law whose prerequisites
have not been established for pinned Ash.

Focused records under `research/` retain the source, contribution, license, and
exclusion details outside reader-facing cases.

## Verification design

The existing Bash helper moves from `content/learn/checks/lib.sh` to
`content/checks/lib.sh`. Learn Ash and Cases each retain a family aggregator,
while every lesson or case retains a local verifier that declares its canonical
source and observable outcomes. The promotion removes a cross-family ownership
error without selecting a manifest, renderer, host-language harness, CI
service, or publication mechanism.

Each successful entry must assert exact standard output, including value and
type, empty standard error, and status `0`. Each intentional rejection must
assert status `1`, empty standard output, the stable reason, and causal source
evidence. Every displayed `ash` block must match one complete canonical source
file exactly.

Reconsider the shared Bash helper when it cannot directly express the evidence
for one complete case, or when the first publication or migration design names
a concrete need for a manifest or another harness. Until then, local verifiers
and two family aggregators remain sufficient.

## Completion and removal conditions

The first increment is complete when both content-family aggregators pass at
the exact pin, research attribution and licenses have been reviewed, navigation
lists the verified case, and the roadmap promotes the finite `unfold` case.
Its temporary implementation plan then leaves the current tree; Git history
retains it.

The Cases family remains replaceable if a publication design later selects a
different reader-facing organization. Any migration must preserve each case's
canonical source, executable observations, source-level cost boundary, and
actual verification state.
