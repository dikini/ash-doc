# Lib Ash documentation milestone design

Status: approved on 2026-08-31 for staged work on `main`

## Reader and maintainer problem

The current ash-doc edition teaches the exact `modular-ash` checkpoint. Ash has
since completed the `lib-ash` milestone, which changes how programs select
implementation evidence and adds explicit kinds, higher-kinded declaration
parameters, method-local type parameters, and relational interfaces with one
total forward determination edge.

Readers need one coherent edition that teaches those advances without mixing
language releases. Maintainers need to migrate the existing Learn and Cases
paths, preserve each unit's established teaching promise, decide where the new
features genuinely improve an existing explanation, and add a focused path for
the new library-abstraction model. Unexpected compiler failures must become
upstream evidence rather than ash-doc compiler work.

The reader question for the new material is:

> What new programs and reusable abstractions can I design at `lib-ash`, and
> how do they build on the existing Ash learning path?

The observable boundary is the exact language, tool, and library-abstraction
difference between `modular-ash` and `lib-ash`. Ash-doc must cross that boundary
as one edition rather than assigning different targets to individual pages.

## Authority and publication boundary

The new edition targets the annotated `ash-lang` tag `lib-ash`, resolved to:

```text
d1e323d23390cdad03202ee3df76cd9100556e1d
```

Language claims come only from the
[`lib-ash` specification](https://github.com/dikini/ash-lang/tree/d1e323d23390cdad03202ee3df76cd9100556e1d/spec).
Tool invocation, output, failures, and exit status come from the
[`ash` guide](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md),
implementation, and tests at the same commit. Accepted Ash decisions govern
the non-language choices within their retained scopes. Design notes and
evidence reports explain history and pressure but do not define Ash.

The immutable ash-doc `modular-ash` tag remains the published predecessor.
The `recursive-1` tag remains a project checkpoint rather than the publication
tag for the new edition. The migration does not move or reuse either tag.

At the migration cutover, `main` becomes the sole forward line for an
unpublished `lib-ash` edition. The root README and roadmap name the exact target
and expose incomplete coverage. A lesson or Case enters the active reading
order only after its prose, canonical sources, observations, and checks pass at
that target. Unmigrated material remains recoverable from Git history and the
immutable predecessor tag rather than being presented as current `lib-ash`
teaching. The repository creates the annotated ash-doc tag `lib-ash` only after
the complete edition closes cleanly.

Project records may compare the two exact milestones or retain historical
evidence. Active teaching pages and their executable checks may not mix them.

## Approaches considered

### Rewrite the edition atomically

One large branch could migrate Learn, Cases, and all new lessons before one
merge. This would keep every intermediate `main` commit apparently complete,
but it would combine target migration, compatibility work, teaching revisions,
new content, compiler evidence, and publication closure in one review surface.
Failures would be hard to attribute and successful migration could not provide
feedback to later lesson design.

### Maintain a parallel edition branch

A long-lived `lib-ash` branch could preserve the current tree until the new
edition finishes. It would create a second forward line, invite drift, and
conflict with the repository rule that immutable tags preserve old editions
while `main` moves forward.

### Stage one forward migration

The selected approach moves `main` through three ordered outcomes. It first
migrates Learn, then Cases, then adds the new library-abstraction path. Each
existing unit regains its current promise before an independent enhancement
assessment. Only one outcome is active; downstream outcomes remain provisional
until promoted.

This exposes the real migration state, keeps failures attributable to one unit,
and lets verified observations refine later work. Deferring the sequence would
either mix targets or make the new lessons depend on unverified prerequisites.

## Milestone sequence

The milestone has three ordered outcomes:

```text
migrate Learn -> migrate Cases -> add library-abstraction lessons
```

Each outcome receives its own bounded implementation plan, implementation,
review, and closure. Completing one outcome does not automatically authorize
the next; the roadmap promotes the successor only after reviewing the evidence
just obtained.

### Outcome 1: migrate Learn

Migrate `content/learn/` in reading order. Each lesson first preserves its
existing reader question and observable boundary at `lib-ash`. After that
baseline passes, evaluate whether the new functionality simplifies its code or
strengthens its abstraction, verification, or expression through types.

An enhancement belongs in the existing lesson only when it clarifies the same
reader question with no unearned prerequisite. If it changes the central
question, it belongs in the new library path. If the new feature would add
cognitive load without improving the lesson's explanation or evidence, record
that no enhancement is warranted.

The Learn outcome includes the repository target cutover, migration coverage,
shared verification changes required by the exact pin, and restoration of all
eleven lessons. It does not implement Cases or create the new content family.

### Outcome 2: migrate Cases

Apply the same two-stage process to `content/cases/` in reading order. Preserve
each algorithmic question, representation invariant, derivation, and
source-level cost boundary before evaluating improvements.

Explicit implementation selection is expected to affect the interface-based
Cases. Explicit kinds, method-local type parameters, or relational interfaces
enter an existing Case only when they improve that Case's established problem
model. The migration does not turn the recursive-algorithms path into a feature
catalogue.

### Outcome 3: add library-abstraction lessons

Create `content/libraries/` only when its first complete lesson can land with
its canonical source and verifier. The family is titled **Design library
abstractions in Ash**. It assumes the completed Learn path but not the
recursive-algorithm Cases.

The initial sequence contains five lessons:

1. **How can a program choose the implementation a library abstraction
   needs?** Introduce interfaces, constrained globals, implementations, and the
   independent `impl Interface` import channel. Contrast a name-only import
   with successful explicit evidence selection.
2. **How can a facade forward a capability without redefining it?** Separate
   public name re-exports from implementation authorization routes. Preserve
   defining identity, privacy, and opacity without implying runtime lookup.
3. **How can an abstraction accept a type constructor?** Introduce `Type`,
   function kinds, explicit higher-kinded parameters, partially applied
   constructors, and the omitted-kind negative boundary.
4. **How can one method work at unrelated element types?** Introduce
   method-local type parameters through a `Functor`-shaped abstraction while
   preserving Ash's rank-1 source boundary and runtime erasure.
5. **How can one interface argument determine another?** Introduce complete
   multi-parameter applications and one total forward determination edge.
   Contrast successful improvement with an underdetermined or ambiguous
   obligation.

The family teaches source-library abstraction. It does not claim that Ash ships
a standard library, implicit prelude, package manager, runtime implementation
registry, or dynamic dispatch mechanism.

## Per-unit migration flow

Every existing lesson or Case crosses four gates.

### Baseline comparison

Run the current canonical sources at both exact tags. Classify every difference
as unchanged behavior, required language migration, changed tool observation,
an ash-doc mistake, or an unexpected compiler failure. Preserve the commands,
statuses, and channel observations needed to reproduce that classification.

### Minimal migration

Update sources, prose, specification links, expected output, diagnostics, and
the local verifier only enough to preserve the unit's current teaching promise
at `lib-ash`. Keep its displayed Ash byte-identical to canonical source. The
unit returns to active navigation only after all applicable checks pass.

### Enhancement assessment

Review the migrated unit against the four `lib-ash` feature groups. A change
must provide at least one concrete benefit:

- remove manual capability plumbing;
- make an abstraction boundary clearer;
- state a stronger or more complete invariant;
- express a relevant relationship through types; or
- make the promised boundary more directly executable and verifiable.

Land an enhancement as a separate reviewed change after the minimal migration.
Record a no-change result in project work when no benefit justifies the added
concept. Do not retrofit a feature merely because the target supports it.

### Aggregate regression

Re-run every previously restored unit after each migration or enhancement.
Later changes cannot weaken earlier exact observations, source agreement, or
navigation.

## Compiler failure ownership

Ash-doc documents every unexpected compiler failure and does not solve it.
It does not modify `ash-lang`, move the `lib-ash` tag, design an Ash fix, or
silently restructure a lesson merely to conceal the failure.

The first failure creates `lab/lib-ash-migration/<failure>/` together with its
complete record. Each retained failure case includes:

- the exact ash-doc source and both Ash commits;
- the reader or maintainer task;
- the complete reproduction command;
- exit status and standard-output and standard-error observations;
- the governing specification expectation or the precise unknown;
- a minimal reproduction when minimization improves attribution;
- the lesson or Case blocked or made costly; and
- why the result matters upstream beyond one documentation example.

The lab verifier reproduces the exact observation while classifying it as
implementation evidence, not language truth or desired behavior. Specified
source rejections remain lesson evidence. A mismatch with specified behavior
is an Ash regression candidate; an unspecified semantic question returns to
Ash design.

A legitimate teaching migration may independently change the triggering
source, but the original failure remains documented. If an unexpected compiler
failure blocks required behavior at the exact tag, the affected unit and final
publication remain blocked until upstream supplies a separately authorized
resolution. Ash-doc does not prescribe that resolution.

## Initial executable observations

A disposable compatibility canary changed only the expected pin in a copy of
the current verifier helper and ran the existing 23 units against the clean
`lib-ash` checkout. It observed:

- 17 units passing without source or expectation changes;
- two interface-based Cases rejected because an ordinary module import no
  longer selects public implementation evidence;
- the unsaturated-list negative lesson reporting `kind.expected-type` with
  expected `Type` and found `Type -> Type`, rather than the predecessor arity
  reason; and
- three imported dependency modules failing with status `2`, empty standard
  output, and `resolve.internal-state` because their body-free summaries did
  not authenticate.

These observations establish migration pressure only. Every unit receives a
fresh isolated comparison during its owned outcome. The three internal failures
must become permanent upstream evidence before any source migration could make
them disappear from the active examples.

## Verification design

Every check uses a clean checkout whose `lib-ash` tag peels to
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Checks never use floating
`ash-lang/main` as the edition authority.

For each teaching unit:

- successful programs assert exact value, type, standard output, empty standard
  error, and status `0`;
- intentional source rejections assert empty standard output, status `1`, the
  stable reason, and causal source evidence;
- tool or internal failures retain only the exact stable observations justified
  by the pinned tool and implementation evidence;
- displayed executable blocks agree exactly with complete canonical sources;
- language conclusions link to the governing `lib-ash` specification section;
  and
- tool conclusions link to or name the governing pinned tool behavior.

Family aggregators verify all restored Learn lessons, all restored Cases, all
library lessons, and retained migration labs. Whole-edition closure also checks
Markdown structure, spelling, relative links, navigation, source counts,
attribution, licenses, tag identity, the clean Ash pin, `git diff --check`, and
clean worktrees.

Each outcome receives an authority/specification review, an instructional and
workflow review, and a final whole-branch review. A correction invalidates the
affected evidence and requires the applicable checks and reviews again.

## Completion and removal conditions

The milestone closes only when:

- all eleven Learn lessons and twelve Cases are restored and verified;
- all five initial library-abstraction lessons pass;
- every compiler failure encountered during migration has permanent executable
  evidence and correct status classification;
- no active page or check names `modular-ash` as its current target;
- the README, family indexes, and roadmap agree on one exact edition;
- all temporary implementation plans and migration-only administration leave
  the current tree;
- the edition-wide verification and independent reviews pass from clean
  `main`; and
- the annotated ash-doc tag `lib-ash` is created at that exact closure commit.

The milestone design leaves the current tree after closure; Git history retains
it. Permanent failure labs remain because they are upstream evidence, not
migration administration. The immutable `modular-ash` tag remains available as
the predecessor edition.

## Intentional exclusions

The milestone does not add a renderer, manifest, registry, CI service,
publication platform, package resolver, compiled-module cache, artifact format,
implicit prelude, shipped standard library, compatibility layer, or second
edition branch.

The new lessons do not teach source-level higher-rank values, kind polymorphism,
kind inference, associated outputs, defaults, specialization, general
determination graphs, effects, providers, runtime registration, or dynamic
implementation lookup. Those boundaries remain outside `lib-ash` or require
separate future work.
