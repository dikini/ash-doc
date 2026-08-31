# Library abstractions learning path design

Status: approved for staged implementation on 2026-09-01

## Reader and maintainer problem

The beginning path teaches enough Ash to read functions, modules, recursive
data, higher-order functions, and parameterized definitions. The recursive
Cases use interfaces where an algorithm needs reusable ordering, but they do
not form a systematic account of the source-library mechanisms completed at
`lib-ash`.

The reader asks:

> How can I design a reusable Ash source library whose type constructors,
> operations, and implementation evidence cross module boundaries explicitly?

The observable boundary crosses from using a concrete imported function to
designing and consuming abstractions that require checked evidence. It includes
independent name and implementation import channels, public re-export routes,
explicit function kinds, method-local type parameters, and one total forward
determination edge. It ends before package management, a shipped standard
library, runtime registration, dynamic dispatch, or new Ash design.

Maintainers need a sequential path whose prose, complete canonical programs,
positive and negative observations, and local checks land together. The path
must reuse the existing lesson evidence model without creating a renderer,
manifest, registry, CI service, or second specification.

## Authority and exact target

The path belongs to the unpublished ash-doc edition targeting exact Ash commit:

```text
d1e323d23390cdad03202ee3df76cd9100556e1d
```

Language claims come only from the specification at that commit:

- [`spec/name-resolution.md#imports-and-namespaces`](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/name-resolution.md#imports-and-namespaces)
  governs name bindings, `impl Interface` selection, public re-exports, stable
  identities, and authorization routes;
- [`spec/static-semantics.md#kinds-monotypes-and-schemes`](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#kinds-monotypes-and-schemes)
  governs `Type`, function kinds, partial application, value-type boundaries,
  and the fixed `Type` default for omitted declaration kinds;
- [`spec/static-semantics.md#interfaces-and-constrained-schemes`](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#interfaces-and-constrained-schemes)
  governs method-local parameters, complete interface applications, and total
  determination edges;
- [`spec/static-semantics.md#constraint-satisfaction-and-checked-evidence`](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
  governs improvement, ambiguity, unsatisfied obligations, and selection;
- [`spec/elaboration.md#interface-evidence-lowering`](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/elaboration.md#interface-evidence-lowering)
  and
  [`spec/dynamic-semantics.md#generated-interface-evidence`](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#generated-interface-evidence)
  govern the lowering and erasure boundary; and
- the pinned [`ash` tool guide](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md)
  governs commands, output channels, and exit status.

Pinned implementation tests may support compiler-stage and diagnostic
observations but cannot add language behavior. The existing retained Cases and
lab remain learning and migration evidence, not authority for these lessons.

## Prerequisites and continuity

The family assumes the complete eleven-lesson Learn path. Readers already know
module imports, public declarations, function application, parameterized types,
and higher-order functions. The family does not assume the recursive Cases.

The first lesson introduces interfaces, constrained globals, implementations,
and explicit selection together around one equality operation. Later lessons
may rely on that vocabulary. Each lesson begins from the model established by
the prior one and adds one abstraction boundary; it does not repeat repository
setup or present a disconnected feature catalogue.

## Approaches considered

### One comprehensive library chapter

One chapter could build a single abstraction using imports, facades, kinds,
polymorphic methods, and determination. This would minimize navigation, but a
failure or conceptual gap would cross several new mechanisms at once. Negative
examples would be difficult to attribute, and the reader could not establish a
stable model before the next feature changed it.

### Retrofit every mechanism into existing Learn and Cases pages

The existing interface Cases can demonstrate explicit selection, and the last
Learn lesson can name an unsaturated constructor kind. Retrofitting the other
features would change their questions from beginning syntax or recursive
algorithms into source-library design. It would also make the new abstraction
model depend on nonessential algorithmic representations.

### Five sequential library-design lessons

The selected approach creates `content/libraries/` with one complete lesson per
mechanism boundary. It preserves the five questions already selected by the
Lib Ash milestone design, lets every rejection isolate one missing concept, and
keeps later lessons dependent only on earlier library vocabulary. The family is
created with the first complete lesson, not as empty scaffolding.

Deferring this choice would leave the new `lib-ash` mechanisms scattered across
the specification and migration records without a reader path. The five-lesson
shape is replaceable until publication: if two adjacent lessons cannot sustain
independent observable outcomes, their later bounded design may combine them
before either is implemented.

## Selected sequence

### 1. Choose required implementation evidence

**Question:** How can a program choose the implementation a library abstraction
needs?

Introduce a public `Equal<A>` interface, `Equal<Int>` implementation, and
constrained `same`. A name-only client reaches an `Equal<Int>` obligation but
has selected no implementation fact. Adding `impl Equal` independently selects
the public fact without binding a source name.

Observable boundary:

- selected client: status `0`, empty standard error, `true : Bool`;
- name-only client: status `1`, empty standard output,
  `constraint.unsatisfied`, with the constrained call and its imported
  declaration relationship; and
- source evidence: the two imports differ only by the implementation item.

The lesson does not yet teach public re-export, generic implementations,
prerequisites, coherence, or runtime internals.

### 2. Forward a capability through a facade

**Question:** How can a facade forward a capability without redefining it?

Contrast a facade that publicly re-exports `Equal`, `equal`, and `impl Equal`
with one that re-exports names only. The successful client selects the
implementation through the facade authorization route. The names-only client
reaches `constraint.unsatisfied` rather than receiving transitive ambient
evidence.

The lesson preserves defining identities and separates public name routing from
implementation authorization. It does not imply a forwarding declaration,
runtime module object, registry, or dynamic lookup.

### 3. Accept a type constructor

**Question:** How can an abstraction accept a type constructor?

Introduce `Type`, the right-associative `Type -> Type` kind, a parameter
`F : Type -> Type`, and applications such as `F<A>`. A positive `keep` program
observes `Some(42) : Option<Int>`. An otherwise parallel declaration that omits
the kind fixes `F` to `Type` and rejects `F<A>` with `kind.not-applicable`.

The lesson does not teach kind inference, kind polymorphism, type lambdas, or
higher-order unification.

### 4. Give a method local type parameters

**Question:** How can one method work at unrelated element types?

Use `Functor<F : Type -> Type>` with
`map<A, B> : (A -> B, F<A>) -> F<B>`. One constrained global applies `map` at
`Int -> Bool` and `Bool -> Int`; a `Box` implementation observes
`(Box(true), Box(42)) : (Box<Bool>, Box<Int>)`. An interface that uses unlisted
`A` and `B` rejects with `interface.method-parameter`.

The lesson distinguishes method-local instantiation from the complete
`Functor<F>` evidence obligation. It retains ordinary source values as rank-1
and makes no higher-rank, polymorphic-recursion, or runtime-type claim.

### 5. Let one interface argument determine another

**Question:** How can one interface argument determine another?

Use `Measure<Key, Result> where Key -> Result`, whose method mentions the key
but need not mention the dependent result. A selected `Measure<Bool, Unit>`
fact improves the complete obligation and observes `42 : Int`. Without a source
for the known `Bool` key, the dependent remains unresolved and the occurrence
rejects with `constraint.ambiguous`.

The lesson teaches one total forward edge and complete applications. It does
not introduce associated outputs, projection syntax, reverse improvement,
partial or multiple edges, defaults, specialization, or proof evidence.

## First complete increment

Only lesson 1 is authorized for the first implementation plan. It creates:

```text
content/libraries/README.md
content/libraries/checks/verify.sh
content/libraries/choosing-implementation-evidence/README.md
content/libraries/choosing-implementation-evidence/src/equality.ash
content/libraries/choosing-implementation-evidence/src/01-selected.ash
content/libraries/choosing-implementation-evidence/src/02-name-only.ash
content/libraries/choosing-implementation-evidence/checks/verify.sh
```

After the lesson, family index, and family verifier pass together, the same
closure change modifies `AGENTS.md`, the root README, `content/README.md`, and
the roadmap. `AGENTS.md` must replace its Learn/Cases-only active-stream wording
with a family-neutral rule: only complete verified units under an indexed
content family and linked as active from that family index belong to the active
stream. That transition admits the verified library lesson without admitting
the four unimplemented future lessons.

The family index owns the shared setup, learning cycle, and reading order. The
lesson owns its complete explanation, three canonical sources, exact positive
observation, negative causal boundary, and source-agreement checks. Root and
content navigation add the family only when this complete lesson passes. Until
then, the current `AGENTS.md` boundary remains correct and no library material
is active.

The family aggregator follows the existing Learn and Cases Bash pattern and
reuses `content/checks/lib.sh`. This is not a new harness. No shared library-
specific helper is created for one lesson; reconsider one only after a second
lesson exposes duplicated evidence that the existing helper cannot express
directly.

## Verification design

Each lesson verifier must:

- require the exact Ash commit and a clean checkout through the shared helper;
- declare the complete canonical source inventory;
- run every accepted entry for exact value, type, stdout, empty stderr, and
  status `0`;
- run every intended rejection for status `1`, empty stdout, stable reason, and
  the causal source relationships used by the explanation;
- assert the source relationships that define the abstraction boundary;
- check every displayed `ash` block against its canonical source; and
- avoid treating color, gutters, or incidental diagnostic prose as a contract.

The family aggregator runs every complete library lesson in stable path order.
The family index and verifier count must agree before navigation becomes
active. Each lesson also reruns the complete Learn path. The Cases aggregate and
retained migration lab run at family closure because this milestone still owns
one edition, even though the library lessons do not depend on those Cases.

Before a lesson closes, run Bash syntax, repository-aware ShellCheck,
Markdownlint, relative-link checks, active-target audits, source agreement,
`git diff --check`, and clean-status inspection. Each lesson receives separate
authority/specification and instructional/workflow reviews. The completed
five-lesson family receives a whole-edition review but cannot trigger the
`lib-ash` tag while the three Cases remain blocked.

For the first lesson, closure also verifies that `AGENTS.md`, root navigation,
the content index, the library index, the family verifier, and the roadmap all
identify exactly one active library lesson. A future library lesson becomes
active only after its own complete verifier and index link pass together.

## Source and adaptation boundary

The examples are small original teaching programs derived from the behavior
specified and tested at the exact Ash commit. They use ordinary equality,
option, box, and measurement domains to expose the Ash boundary rather than to
adapt an external algorithm or library design. No external source text, code,
figures, or proof presentation is adapted, so the path requires no new research
or license record.

Pinned specification examples and implementation tests are authority and
executable corroboration, not a claim that their prose or exact fixture layout
has been copied into ash-doc. If implementation discovers a meaningful external
source tradition, pause that lesson and create the required research record
before adaptation.

## Completion and replacement conditions

The family design is complete when all five lessons pass at the exact target,
their sequence reads as one cumulative work, and the roadmap records the
verified family. The family remains unpublished while required Cases are
blocked.

The design remains as milestone guidance until family closure, then leaves the
current tree with the final temporary implementation plan. Git history retains
it. Replace the selected layout earlier only when an implemented lesson exposes
a concrete prerequisite, verification, or continuity failure that the current
one-lesson boundary cannot resolve.

## Intentional exclusions

This design adds no renderer, manifest, registry, package manager, module-root
convention, dependency manager, compiled-summary format, standard library,
implicit prelude, CI service, publication platform, compatibility layer, or
second edition branch. It makes no claim about elapsed time, zero-cost
abstraction, generated machine code, runtime allocation, or compiler
optimization.
