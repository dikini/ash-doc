# Roadmap

The roadmap records the current baseline, the intended continuation of the
learning paths, and the selected delivery outcome when one exists. The learning
sequence is provisional: it establishes reader outcomes and dependencies, not
a delivery schedule, publication promise, or source of Ash semantics.

## Current baseline

Ash-doc targets `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. This cumulative checkpoint includes
diagnostics, effects and resources, library abstractions, modules, and the
earlier language foundation.

All content is verified at this baseline:

- [Learn Ash](../../content/learn/README.md): thirteen lessons, 57 sources.
- [Algorithms and effects](../../content/cases/README.md): twenty Cases,
  64 sources.
- [Library abstractions](../../content/libraries/README.md): eight lessons,
  43 sources.
- [Effects and scoped resources](../../content/effects/README.md): twelve lessons,
  71 sources.

The [verification guide](verification.md) names the commands and checks.
Code, prose, and verifiers use the same exact baseline. Obsolete evidence and
records leave the working tree; Git retains earlier states.

The active edition now teaches all 60 demonstrated rejections through complete
English human messages: sixteen in Learn, seven in Cases, sixteen in Libraries,
and 21 in Effects.
Each transcript includes the command, source excerpts, causal labels, and
reason line. Lesson-local capture checks supplement the retained semantic JSON
checks. Discovery exercises keep their unanswered observations.

## Curriculum direction

The next learning stage asks: how can a reader design a calculation that
requests behavior, explain the effects in its contract, and keep control and
resource access within their scopes?

The existing Learn path supplies functions, nominal data, pattern matching,
recursion, closures, and type parameters. The library path supplies interface
requirements, explicit implementation imports, higher kinds, method parameters,
and determination. The Cases supply experience deriving pure algorithms and
explaining their invariants and costs. Verification at the current baseline
does not imply that these paths teach every feature of that baseline.

Continue that foundation through three connected strands:

- **Effects and scoped resources:** requests, computation contracts, handlers,
  continuation control, resource lifetimes, cleanup, and hooks.
- **Local functions and recursion:** local generalization and explicit recursive
  groups, extending the existing account of functions and bindings.
- **Library abstractions:** generic implementations, nominal wrappers, and
  scoped exact evidence, extending the existing library path.

E1–E12, F1–F2, and L1–L3 are **verified**. Their identifiers express curricular
relationships, not task identifiers or delivery batches. The current effect
Cases outcome is complete at the current baseline.

### Teaching approach

Use a small calculation over a finite list as the recurring effects example.
Begin with an explicit argument supplying a scoring rule or configuration.
Introduce a request when the reader needs to separate that calculation from
how the required value is supplied. Later versions count processed elements,
stop early, and transform published values within scopes. Preserve a pure
version when it helps explain the same observable result.

Prefer this connected path to scattered additions in the beginning lessons:
the latter would interrupt their established progression. A large application
would introduce control, ownership, and library machinery before the reader
could explain each boundary. Reuse a problem only while it serves the next
question; native buffers can use a separate small byte calculation.

The progression is requests, contracts, control, ownership, and composition.
Introduce the smallest complete handler in E1, including its required resume;
E5 later develops the continuation model in detail. Teach a closed row with
the first effectful signature rather than leaving its notation unexplained.

## Effects and scoped resources

E1 follows the complete [Learn path](../../content/learn/README.md). E2 through
E12 follow in order. The additional bridges below are conceptual prerequisites,
not requirements to complete every library lesson or algorithm Case.

### E1. How can a calculation request a value from its caller's context?

**State: verified.** [Read the lesson](../../content/effects/requesting-a-value/README.md).

Start from an ordinary configuration argument and introduce one effect
operation, a request with `perform`, and a complete handler that resumes with
a fixed value. Change the handler while retaining the calculation.

The reader can distinguish declaring an API, requesting an operation, and
supplying its interpretation. They can read the first closed effect row and
explain why the complete entry produces its result. Compare the handled
program with a request left outward at the entry boundary. Leave multiple
operations, open rows, and abandonment for later chapters.

### E2. What does an effectful function promise?

**State: verified.** [Read the lesson](../../content/effects/following-effect-contracts/README.md).

Follow the request through several ordinary calls and a returned function.
Distinguish a value type from computation effects, and constructing a function
from calling it. Explain where latent effects belong on chained arrows.

The reader can trace requirements from a request through callers and explain
why the entry computation must have an empty row. Compare a correct contract
with one that omits a required effect. Use closed rows so the next chapter has
one new abstraction to introduce.

### E3. How can a reusable function preserve its caller's effects?

**State: verified.** [Read the lesson](../../content/effects/preserving-callback-effects/README.md).

Revisit a higher-order function from Learn with pure and effectful callbacks.
Introduce open rows, row parameters, and the `EffectRow` kind because the
function must preserve the callback's requirements.

The reader can distinguish ordinary type parameters from row parameters and
explain a reusable effectful contract. Compare an appropriately parameterized
contract with a falsely pure callback contract. Explain row exclusions and
ambiguous unions through a small example when needed to show the boundary of
inference. Row order is not an execution order.

Use explicitly signed global helpers first. Complete F1 before examples rely
on generalized local callbacks; do not silently treat every local binding as
polymorphic.

### E4. Which handler answers a request?

**State: verified.** [Read the lesson](../../content/effects/choosing-a-handler/README.md).

Nest handlers and move a request between handled bodies and operation clauses.
Then distinguish parameterized instances and APIs with equal spellings from
different modules. Reuse the module knowledge from Learn.

The reader can identify the exact instance a handler removes, trace the
nearest matching handler, and explain which clause effects remain outward.
Contrast handling the intended instance with handling a different one. Explain
that constructing a closure under a handler does not capture that handler.

### E5. What happens when a handler resumes a calculation?

**State: verified.** [Read the lesson](../../content/effects/resuming-a-calculation/README.md).

Trace the work before a request, the suspended remainder, and the result of
`resume`. Extend the API to several operations and explain complete clause
coverage. Separate the operation's result from the handled calculation's
result.

The reader can explain the continuation's scope and its consumption exactly
once on each normally completing clause path. Compare a valid resumption with
missing consumption, repeated consumption, or attempted capture, using separate
small examples. Do not introduce resource ownership yet.

### E6. How can a handler stop a calculation early?

**State: verified.** [Read the lesson](../../content/effects/stopping-a-calculation/README.md).

Use a resource-free list calculation that can finish with an ordinary result
or stop with a domain-defined outcome. Introduce `discard` as consumption of
the suspended continuation without resuming its calculation.

The reader can identify skipped work and explain why `discard` returns `Unit`
while the clause must still produce the handler's result. Compare this with
ordinary propagation of an outcome through pure calls. State that safe discard
has further obligations when scopes own completion; E9 develops those cases.
Do not imply that discard is universally pure.

### E7. How can a calculation keep scoped mutable state?

**State: verified.** [Read the lesson](../../content/effects/counting-with-a-cell/README.md).

Count processed elements with a scoped cell and compare the result with a
pure accumulator. Explain acquisition, reusable access, reading, writing, and
scope-owned release.

Before this chapter, use the existing
[implementation-evidence lesson](../../content/libraries/choosing-implementation-evidence/README.md)
as a bridge. Then explain how acquisition supplies the sealed provider
relation and interpreter; ordinary implementation selection does not create
resource authority.

The reader can trace repeated access to one live cell, distinguish access from
release ownership, and explain which effects acquisition discharges. Use
ordinary completion first; escape and abandonment follow in E8 and E9.

### E8. Why can a result leave a resource scope while access cannot?

**State: verified.** [Read the lesson](../../content/effects/keeping-access-in-scope/README.md).

Return a copied count, then consider returning a handle or a closure that
retains access. Compare separate acquisitions and transport through a tuple or
data constructor.

The reader can follow retained resource dependencies beyond visible result
types. They can explain valid use within a live owner and a rejected escape,
including why hiding access inside a closure does not make it safe. Include
request payload transport to connect resource lifetimes with E4's handlers.

### E9. How can work run when a scope finishes?

**State: verified.** [Read the lesson](../../content/effects/running-cleanup/README.md).

Introduce `cleanup` through normal completion: retain an action, run the body,
invoke the action, and preserve the body's result. Use an enclosing cell to
make ordering observable without introducing external I/O.

Then revisit early stopping and explain which owned actions execute, which
resources remain live, and which handlers are available at closing positions.
The reader can distinguish safe abandonment from skipping required completion
or relying on a removed interpreter. Separate the normal-completion,
abandonment-order, and rejected-context examples so each has one causal point.
No source-cleanup guarantee is implied for internal termination or exhaustion.

### E10. How can several scopes transform one publication?

**State: verified.** [Read the lesson](../../content/effects/transforming-publications/README.md).

Declare an effect with one endomorphic `publish` operation, establish a hook,
and register transformations. Predict outer-to-inner transformation order,
callback effects, and the separate chain established by a nested exact root.

The reader can distinguish registration context from publication context and
explain registration lifetime across normal return, capture, resume, and owned
abandonment. Compare a qualifying API with a nonqualifying one, then connect
retained callback access to E8. Registration introduces no escaping token or
arbitrary removal mechanism.

### E11. How can acquiring a resource fail?

**State: verified.** [Read the lesson](../../content/effects/acquiring-a-buffer/README.md).

Use a small byte calculation with a scoped native buffer. Explain acquisition
outcomes before entering the body, checked access, and release. Choose small
deterministic success and failure observations permitted by the fixed API.

The reader can distinguish acquisition failure, a successful acquisition whose
body returns a domain outcome, and nested acquisition outcomes. They can
explain why those wrappers remain distinct and apply the lifetime model from
cells. This chapter introduces neither source pointers nor general FFI.

### E12. How do these boundaries fit together?

**State: verified.** [Read the lesson](../../content/effects/combining-effects-and-scopes/README.md).

Compose an effectful scoring policy, scoped counting, early stopping, and
cleanup in one complete finite-list calculation. Derive it from earlier
versions rather than presenting a finished application without explanation.

The reader can account for the result, outward row, handler selection,
continuation consumption, cleanup order, and resource lifetimes. Use one
boundary change at a time to challenge that account. Hooks and buffers are
extensions only where the problem creates a reason to use them; the final
example need not contain every syntax form.

## Local functions and recursion

These chapters follow the beginning path and support the other strands without
making effects a prerequisite for learning local function behavior.

### F1. When can a local function work at several types?

**State: verified.** [Read the lesson](../../content/learn/generalizing-local-functions/README.md).

Revisit anonymous functions and type parameters. Compare an eligible local
anonymous-function binding used at different types with an annotated binding
and an application that returns a function.

The reader can explain the boundary of local generalization and why ordinary
value positions remain rank-1. Keep initial observations pure, then connect
eligible row parameters with the global row-polymorphic helpers already
taught in E3. Generalization does not create new interface requirements.

### F2. How can local definitions refer to one another?

**State: verified.** [Read the lesson](../../content/learn/defining-local-recursion/README.md).

Continue from sequential bindings and global recursion. Introduce annotated
`let rec` groups through local recursive functions, then mutual references.
Explain which names enter scope together and why initialization must be safe.

The reader can distinguish a recursive group from sequential `let` bindings
and predict accepted delayed uses and rejected forcing uses. Develop guarded
cyclic nominal data as a separate final exploration, connected to the Cases'
finite-data assumptions. Constructor guarding is not general laziness, and a
cycle does not establish termination of a traversal.

## Continuing library abstractions

These chapters continue the opening five lessons of the
[library path](../../content/libraries/README.md). L1 through L3 follow in order.
The effects path does not require completing this strand; later synthesis may
reuse it after its concepts have been introduced.

### L1. How can an implementation depend on its element's behavior?

**State: verified.** [Read the lesson](../../content/libraries/requiring-element-behavior/README.md).

Extend a concrete interface implementation to a nominal container whose
implementation requires behavior for its element type. Trace prerequisite
evidence from an imported constrained use to the selected implementation.

The reader can explain generic heads, explicit prerequisites, ownership,
overlap restrictions, and the structural decrease required of nonground
prerequisites. Choose separate small rejections for missing evidence and an
inadmissible implementation. Connect determination to selection keys without
re-teaching the existing determination lesson.

### L2. How can a wrapper give an existing representation a distinct meaning?

**State: verified.** [Read the lesson](../../content/libraries/wrapping-a-representation/README.md).

Compare ordinary nominal data with a module `newtype`. Construct and match the
wrapper explicitly, then give it interface behavior distinct from its
representation. Revisit public and opaque boundaries where useful.

The reader can explain nominal distinction, the lack of implicit coercion or
inherited implementation evidence, and allocation-free wrapping after checked
lowering. A runtime-cost explanation must use appropriate pinned evidence;
printed values alone do not demonstrate allocation behavior.

### L3. How can one lexical scope supply its own exact behavior?

**State: verified.** [Read the lesson](../../content/libraries/supplying-scoped-evidence/README.md).

Introduce a local `newtype`, first by consuming it within its scope and then
by returning an identity-free result. Supply methods through sequential
`with` evidence whose selection key contains that active local nominal.

The reader can explain following-scope availability, capture of preceding
ordinary values, identity escape restrictions, and why exact evidence is not
local implementation search. Compare an escaping identity with a closure that
legitimately captures and unwraps a local value. Keep effects out of the first
example; combine the strands only after their individual boundaries are clear.

## Apply effects in short Cases

The approved continuation illustrates one concept per Case with a small Ash
program and sufficient explanation to predict its output. Use the existing
layout and checks. The programs are original illustrations; they introduce no
shared application framework or new repository tooling. Follow-up exercises
stay within concepts already introduced. They are not deep treatments of
algorithms, protocol design, or dependency-injection architecture.

The intended order and current state are:

<!-- markdownlint-disable MD013 -->
| Case | Concept | State |
| --- | --- | --- |
| [Number tree leaves](../../content/cases/numbering-tree-leaves/README.md) | Replace explicit counter threading with `Fresh.next` and scoped state. | Verified |
| [Measure tree search](../../content/cases/measuring-tree-search/README.md) | Count comparisons through a handler while keeping ordering fixed. | Verified |
| [Supply order prices](../../content/cases/supplying-order-prices/README.md) | Select regular, promotional, or unavailable dependency responses. | Verified |
| [Run a scripted session](../../content/cases/running-a-scripted-session/README.md) | Keep domain transitions pure; supply commands and collect replies. | Verified |
| [Bound search work](../../content/cases/bounding-search-work/README.md) | Request before expansion; distinguish exhaustion from absence. | Verified |
| [Compress parent paths](../../content/cases/compressing-parent-paths/README.md) | Use a scoped parent buffer; compare repeated lookup reads and writes. | Verified |
| [Read a bounded message](../../content/cases/reading-a-bounded-message/README.md) | Decode a byte length prefix through a checked cursor. | Verified |

<!-- markdownlint-enable MD013 -->

All seven Cases retain their intended comparisons at the current baseline.

Prerequisites are Learn's foundation and the relevant effects lessons:
requests, resumption, cells, discard for bounded search, and native buffers for
parent paths and messages. Earlier tree and frontier Cases provide context for
those algorithms. The effect, cell, and buffer specification sections below
govern their contracts and scope boundaries.

Completion requires unchanged intended comparisons at the declared baseline,
short prose, displayed-source agreement, and applicable output checks. Runtime
unavailable, refused, truncated, and exhausted outcomes provide the negative
comparisons; static rejections need not repeat the effects path. Keep broader
union–find operations, general session infrastructure, external I/O, timing
claims, and asymptotic analysis outside these examples.

## Hook pipeline Case

**Verified.** [Who controls the next pipeline step?](../../content/cases/controlling-a-hook-pipeline/README.md)
combines three registered transformations with ordinary policy and trace
operations. Separate entries show permitted processing, rejection before later
stages, and omitted enrichment. The source, transformations, and consumer form
a bounded reactive-programming analogy; publication is synchronous, callbacks
form a chain, and discard is not an event filter.

Prerequisites are E10 hooks, E6 discard, and the scripted session's trace
handler. The pinned hook and effect rules below govern callback context, rows,
and continuation ownership. This is original teaching code and prose; it adds
no framework or tooling. The three observations pass at the current baseline.

## Prerequisites and governing sources

The dependencies above describe reading order, not delivery commitments:

- Learn precedes F1, F2, and E1.
- E1 through E12 form the principal effects sequence.
- F1 precedes generalized-local examples in E3.
- The existing implementation-evidence lesson precedes E7's provider bridge.
- The existing library path precedes L1, then L2 and L3.
- The first twelve Cases provide optional pure comparisons; completing them is
  not a prerequisite for entering the effects path.

Language claims and future examples must use the specification at the current
baseline. These sections govern the proposed boundaries:

- [Computation types and effect rows][rows]: E1–E3, including row kinds,
  exact instances, exclusions, and inference boundaries.
- [Effects][effects]: E1–E6 and the control model reused by later chapters.
- [Scoped cells and resource dependencies][cells] and
  [scoped native buffers][buffers]: E7, E8, and E11.
- [Scoped cleanup actions][cleanup] and [synchronous typed hooks][hooks]:
  E9, E10, and their interactions in E12.
- [Blocks][blocks], [rank-1 restrictions][rank1], and
  [recursive block groups][recursion]: F1 and F2.
- [Implementations][implementations]: L1.
- [Specification overview][overview], [local nominal scope][nominals], and
  [scoped exact evidence][evidence]: L2 and L3.

[rows]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#computation-types-and-effect-rows
[effects]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#effects
[cells]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[buffers]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-native-buffers
[cleanup]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-cleanup-actions
[hooks]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#synchronous-typed-hooks
[blocks]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#blocks
[rank1]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#inference-and-rank-1-restrictions
[recursion]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#recursive-block-groups
[implementations]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#implementations
[overview]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/README.md
[nominals]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#local-nominal-scope
[evidence]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-exact-evidence

## Evidence and completion expectations

Every eventual chapter must join a connected explanation with canonical
programs, positive observations, relevant rejections, and discovery exercises.
Use the edit, predict, run, inspect, and explain cycle without making it a
repeated prose template. Introduce vocabulary when the example needs it.

Capture complete human diagnostics from the pinned tool and explain the
causal source labels and correction. Keep exact transcript agreement separate
from semantic JSON checks. Preserve unanswered observations in discovery
exercises. The [verification guide](verification.md) governs the existing
mechanism; this roadmap selects no new tooling.

Each chapter is complete only when its reader can explain the promised
boundary and its prose, canonical code, observations, and checks agree.
E12 additionally requires a coherent account of interacting boundaries.
A compiler regression or unresolved semantic question leaves the affected
material incomplete and follows the project's discovery classification.

## Scope and delivery state

This roadmap covers the proposed continuation, not an exhaustive reference
manual. Named module roots, broader command-line usage, and remaining syntax
reference details can motivate later bounded work. External I/O, concurrency,
general FFI, and new language mechanisms are not assumed by these examples.
Historical Ash remains reference evidence only; all planned code and prose
teach the cumulative current baseline.

E1–E12, F1–F2, L1–L3, the seven initial effect Cases, and the hook pipeline
Case are complete.
The documentation remains unpublished; no ash-doc `diag-ash`
publication tag exists. Refine chapter boundaries when executable design
exposes a dependency or an overloaded question, and replace superseded wording
rather than keeping parallel roadmaps.

## Selecting work

**Active outcome: E1 teaching pilot.** Revise the existing chapter's prose and
exercises to place predictions before revealed results and connect the unmet
request to the entry contract. Preserve its four canonical programs and
observations at `diag-ash`, commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. The approved
[execution plan](../plans/2026-10-13-requesting-a-value-teaching-pilot.md)
also adds ash-lang's Codex context defaults to this project.

Select one complete reader outcome under the [project workflow](workflow.md).
State its prerequisites, governing baseline, canonical sources, positive and
negative observations, and completion checks. Keep its temporary execution
plan under [plans](../plans/README.md) while work remains active. Remove the
plan after verification and update this roadmap.

A unit is verified only when its prose, displayed code, canonical sources, and
observations agree at the declared baseline. A compiler failure or unresolved
semantic question keeps the affected unit incomplete; it does not authorize
changing Ash or weakening the unit's promised observation.
