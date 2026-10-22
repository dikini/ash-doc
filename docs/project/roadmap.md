# Roadmap

The roadmap records the current baseline, the intended continuation of the
learning paths, and the selected delivery outcome when one exists. The learning
sequence is provisional: it establishes reader outcomes and dependencies, not
a delivery schedule, publication promise, or source of Ash semantics.

## Current baseline

Ash-doc targets `ffi-base` at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. This cumulative checkpoint includes
source
foreign contracts, resource families, strings and bytes, generated native hosts,
diagnostics, effects, library abstractions, modules, and the earlier foundation.

All indexed lessons are verified at this baseline:

- [Learn Ash](../../content/learn/README.md): sixteen lessons, 73 sources.
- [Algorithms and effects](../../content/cases/README.md): twenty-eight Cases,
  141 sources.
- [Library abstractions](../../content/libraries/README.md): eight lessons,
  43 sources.
- [Effects and scoped resources](../../content/effects/README.md): twelve lessons,
  71 sources.

The [verification guide](verification.md) names the commands and checks.
Code, prose, and verifiers use the same exact baseline. Obsolete evidence and
records leave the working tree; Git retains earlier states.

The active edition now teaches all 80 demonstrated rejections through complete
English human messages: twenty-three in Learn, twenty in Cases, sixteen in Libraries,
and 21 in Effects.
Each transcript includes the command, source excerpts, causal labels, and
reason line. Lesson-local capture checks supplement the retained semantic JSON
checks. Discovery exercises keep their unanswered observations.

The [Learn path](beginning-learning-path.md) connects predictions to observed
values and types before explaining worked traces. Rejections connect a
contract or scope requirement to its causal labels and repair. Fresh exercise
programs live outside canonical source trees, with required sibling modules
kept together. Local generalization and recursive initialization continue the
same model; the effects connection remains optional until E3.

The Learn path now compares its existing curried and tuple-input examples,
including what remains after supplying one input. The comparison retains the
canonical programs and current target.

The [library path](../../content/libraries/README.md) now asks for value,
type, and evidence predictions before its worked answers. Rejections connect
complete requirements, declaration access, and lexical scope to causal labels
and repairs. Every practice task names a fresh baseline; sibling modules stay
together outside canonical source trees. All eight chapters retain their
original 43 sources, 17 accepted observations, and 16 complete captures.

## Extend Learn Ash outcome

**State: in progress.** The
[plan](../plans/2026-10-22-extend-learn-ash.md) extends the Learn path's main
sequence from eleven lessons toward a beginner-to-intermediate arc, landing
lesson by lesson at the declared baseline. The approved candidates: strings
and bytes (surface, flagged volatile), patterns in depth, the edges of the
language, ordering from data, module channels, opaque types (surface), and a
closing orientation to interfaces and effects. Each lesson lands with
canonical sources and checks; each authoring session also records language
pressure in the [language-pressure register](language-pressure.md), which
`content/checks/language-pressure-sync.sh` keeps in agreement with volatile
lesson flags.

## Multilingual workflow decision

**State: complete for the Learn path; later families remain future work.**
Machine translation with lagging human review carries translated prose,
with the codex CLI (`gpt-6-luna`) as the pinned engine. English lessons,
canonical programs, and diagnostic captures remain the source of truth
and stay byte-identical across languages. The Learn path is fully
Bulgarian: lessons 1-2 human-owned at `corrected` after promoted owner
corrections, the other thirteen at `reviewed` after owner
certification. The machinery lives under `content/checks/translation/`
(segmentation, transplant, glossary with the coinage rule, drift and
convergence passes), and `--lang` renders translated lesson scopes in
PT Serif with tier notices in the chrome. The workflow defines no Ash
semantics and no publication mechanism.

## FFI Base migration outcome

**State: complete and locally verified.** The edition targets `ffi-base` at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. Native positives use a bounded
observer that checks the type and generated host result from the same compiled
program; source rejections still use the CLI. The
[verification guide](verification.md#ffi-base-executable-evidence) records
current executable coverage and applicable retained exact-pin evidence; the
[rendering guide](rendering.md#scoped-build-evidence) records current book
presentation coverage and limits. Completed migration plans leave the working
tree. New FFI lessons and publication remain outside this outcome.

## Rendering infrastructure outcome

Lesson 3 now introduces type colors, then distinguishes types and values
through split boxes. The accepted
[visualization experiment](../../rendering/experiments/partial-application/README.md)
retains its three figures in one grouped margin note, rendered from `split`
notation fences by the pinned split-md renderer at uniform square and label
sizes. Figure 3 folds into two rows to retain that scale. The lesson
names currying before the first program and uses `let add_20 = add 20` inside
`main` to demonstrate partial application. The former input-type rejection
section and its evidence were removed. The revised lesson passes its three
canonical-source checks and scoped HTML, EPUB, and both PDF reviews with the
generated figures.

Scoped review builds select one indexed lesson, one family part, the complete
book, or the default specimen, with independent output-format selection.
Preparation, artifact checks, and browser review follow the generated scope
and requested formats. The [workflow](workflow.md#bound-the-task) also bounds
editing, reading, review, executable checks, and reporting by the task's action
and scope. Unchanged inputs retain applicable exact-pin evidence.

The retained local review book assembles all 64 lessons in Learn → Libraries →
Effects → Cases order, with four family introductions and shared reader setup.
Artifact checks verify coverage, chapter order, source hashes, links, code text,
and both print geometries. Desktop and mobile HTML, enlarged EPUB text, and
both PDF layouts pass review, including all eight application Cases. The
original three-lesson specimen remains the default regression build, with its
notation fixture and separate browser evidence. The
[rendering guide](rendering.md#scoped-build-evidence) records fresh complete-book
results and fresh specimen evidence. The edition remains local and
unpublished.

The [traversal calculation](../../content/cases/resuming-tree-traversal/README.md)
now develops the three-entry problem, frame data and invariant, operation
types, public composition, and smaller equations. Twenty-six exact source
excerpts and ten selected observations agree with the complete canonical
programs and success captures. All five source files retain their previous
bytes, including both opaque-constructor rejections and complete human
messages. The frame-work and persistence arguments remain explicit. Longer
contracts and patterns use wider space; each wide diagnostic starts on a fresh
print page to preserve its text across mirrored margins. Eleven display-check
tests exercise source drift, wrong result selections, and incomplete captures.
The revised chapter also passes desktop/mobile HTML and enlarged EPUB checks
in Chromium and Firefox.

The frontier lesson and other longer listings remain candidates for a focused
teaching revision.

The [search-tree teaching trial](../../content/cases/guaranteeing-logarithmic-retrieval/README.md)
is verified in all four outputs. It develops colored insertion from its
problem and example, data, operation types, and worked calculations, proceeding
from public composition into the smaller operations. Sixteen checked library
fragments show the grouped repair inputs, their mnemonic fields, the four
repair equations with local explanations, and the fallback. The shared helper
destructures three groups with explicit patterns before rebuilding the tree.
A small public client demonstrates the three-key repair, and private probes
check every repair and the fallback boundaries with distinct nonempty subtrees.

Four optional sidenote sketches show before and after trees above and below,
rendered from `split` fences; the numbered red-root sketch and the annotated
wide comparison keep their accepted placements. Each circle's upper half
records Red or Black; its stable lower color tracks the association through
the rewiring. Colored triangles track whole subtrees. The ordinary body column
holds each complete repair equation and helper on one page in both PDFs.
Selected longer signatures, the insertion definition, and the common labeled
diagram use wider space at the unchanged type sizes; the annotated diagram
remains a prepared static SVG.

The prefix-check continuation is also verified. It develops observation data,
operation types, scenario composition, and recursive checks through sixteen
additional exact excerpts. Five displayed components and a six-run summary
agree with the complete captured result. The prefix, persistence, and public
repair clients retain their previous bytes and observations; the defining
module retains its previous public observations after grouping repair inputs.
The later build-and-persistence listing and observation remain available for
further teaching revision.

The first rendering outcome is verified as a local specimen in responsive HTML,
reflowable EPUB 3, and two PDF print variants. It keeps existing verified
Markdown and executable evidence authoritative, uses Quarto Book and Typst,
and evaluates the existing railroad and sequent renderers separately from
Mermaid sequence diagrams. The [rendering guide](rendering.md) records its
selected sources, verification, current development handoffs, and replacement
condition. This work does not publish the edition or change its Ash target.

Generated figures now share one style contract. The currying and search-tree
figures render from `split` fences through the pinned split-md renderer, and
chapter preparation converts diagram fences inside notes, margin Divs, and
wide regions, so each figure keeps its accepted position. The normative
style contract fixes the book's typefaces and palette roles for every
generated figure and fails the build on paint outside it; the split
vocabulary's categorical hues are contract data. Eight migrated figures keep
their established vocabulary, captions, and accessibility descriptions. This
work selects no publication platform and leaves the Ash target unchanged.

The book PDF retains mirrored margins and outer margin notes for double-sided
printing. The one-sided A4 PDF keeps 25 mm of left binding space and a fixed
50 mm right sidenote column, separated from the main text by 6 mm. Its top,
bottom, and outer paper-edge distances are 20 mm. Both short and long notes
stay beside their references without overlap.

The notation fixture also includes a full-width aside with a formatted
paragraph and table. It spans the body and note area, stays together on one
print page, and reflows in narrow HTML and EPUB previews. Both PDFs and the
browser checks verify the source text and actual layout.

The required [writing skill][writing-skill] now preserves the accepted teaching,
code, and visual conventions. Its [program-design reference][program-design]
covers problem-to-program calculation, explanation depth, structural wiring,
and selected successful observations; its [formatting reference][formatting]
preserves note purpose, visual continuity, local colour meanings, and caption
order. The [workflow](workflow.md#preserve-authoring-lessons) explains how to
apply and refine the guidance in new or materially revised chapters.

Five focused fresh-agent planning trials exercised queue calculation, grouped
run inputs, explained result selections, queue-diagram continuity, and
restraint for a simple function and standard sequence notation. The
[writing scenarios][writing-scenarios] retain repeatable requests and decision
criteria. These trials support application of the guidance; they do not
establish reader comprehension or review every chapter's rendered layout.

[writing-skill]: ../../.agents/skills/writing-ash-documentation/SKILL.md
[program-design]: ../../.agents/skills/writing-ash-documentation/references/program-design.md
[formatting]: ../../.agents/skills/writing-ash-documentation/references/formatting.md
[writing-scenarios]: ../../.agents/skills/writing-ash-documentation/tests/writing-scenarios.md

## Curriculum direction

The effects learning stage asks: how can a reader design a calculation that
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
relationships, not task identifiers or delivery batches. The initial short
effect Cases outcome is complete at the current baseline.

The eight [application Cases](#application-cases-from-dn-0052) continue that
foundation: how can a reader combine these mechanisms while preserving an
application's outcome, data invariant, or control policy? Each study develops
one application question and distinguishes what Ash checks from what the
program and its tests must establish.

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

### E1. Requesting a value

**State: verified.** [Read the lesson](../../content/effects/requesting-a-value/README.md).

Start from an ordinary configuration argument and introduce one effect
operation, a request with `perform`, and a complete handler that resumes with
a fixed value. Change the handler while retaining the calculation.

The reader can distinguish declaring an API, requesting an operation, and
supplying its interpretation. They can read the first closed effect row and
explain why the complete entry produces its result. Compare the handled
program with a request left outward at the entry boundary. Leave multiple
operations, open rows, and abandonment for later chapters.

The chapter asks for predictions before revealing each score and connects the
unhandled entry rejection to its source declaration and handler repair. Each
practice task starts from a fresh copy of the handled program.

### E2. Following effect contracts

**State: verified.** [Read the lesson](../../content/effects/following-effect-contracts/README.md).

Follow the request through several ordinary calls and a returned function.
Distinguish a value type from computation effects, and constructing a function
from calling it. Explain where latent effects belong on chained arrows.

The reader can trace requirements from a request through callers and explain
why the entry computation must have an empty row. Compare a correct contract
with one that omits a required effect. Use closed rows so the next chapter has
one new abstraction to introduce.

Trace construction and invocation separately before comparing the two
returned-function contracts. Each practice task starts from a fresh copy
of its named program.

### E3. Preserving callback effects

**State: verified.** [Read the lesson](../../content/effects/preserving-callback-effects/README.md).

Revisit a higher-order function from Learn with pure and effectful callbacks.
Introduce open rows, row parameters, and the `EffectRow` kind because the
function must preserve the callback's requirements.

The reader can distinguish ordinary type parameters from row parameters and
explain a reusable effectful contract. Compare an appropriately parameterized
contract with a falsely pure callback contract. Explain row exclusions and
ambiguous unions through a small example when needed to show the boundary of
inference. Row order is not an execution order.

Identify the value-type and row substitutions before predicting each callback
use. Read each rejection against the callback argument, unknown union, or tail
exclusion, and start each practice task from a fresh program copy.

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

Identify the answering clause before computing each result, including the
two paths that produce the same score. Trace saved closure values separately
from the handler around the later call, and keep module exercise copies beside
their sibling imports.

### E5. Resuming a calculation

**State: verified.** [Read the lesson](../../content/effects/resuming-a-calculation/README.md).

Predict the operation answer, resumed calculation's result, and clause result,
then account for each through the trace. Compare the declared operation API
with handler clauses before examining incomplete coverage.

The reader can explain the continuation's scope and its consumption exactly
once on each normally completing clause path. Compare a valid resumption with
missing consumption, repeated consumption, or attempted capture, using separate
small examples. Do not introduce resource ownership yet.

### E6. Stopping a calculation

**State: verified.** [Read the lesson](../../content/effects/stopping-a-calculation/README.md).

Use a resource-free list calculation that can finish with an ordinary result
or stop with a domain-defined outcome. Introduce `discard` as consumption of
the suspended continuation without resuming its calculation.

The reader predicts the retained prefix and skipped tail, including pending
result construction. They explain why `discard` returns `Unit` while the
clause still produces an outcome. Compare pure stopping, discard, resumption,
and a no-marker input that reaches no request. State that safe discard
has further obligations when scopes own completion; E9 develops those cases.
Do not imply that discard is universally pure.

### E7. Counting with a cell

**State: verified.** [Read the lesson](../../content/effects/counting-with-a-cell/README.md).

Predict copied reads, alias updates, and item counts, then compare a scoped
cell with a pure accumulator. The count records every visited item, including
zero. Distinguish handle access, provider evidence, the operation interpreter,
and scope-owned release.

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

The reader identifies what a result or payload retains before crossing its
owner boundary. They can explain valid live access and rejected handle,
closure, aggregate, and payload escape, including hidden dependencies beyond
visible types. A copied payload distinguishes a suspended resource from one
released during resumed normal completion.

### E9. Running cleanup

**State: verified.** [Read the lesson](../../content/effects/running-cleanup/README.md).

Introduce `cleanup` through normal completion: retain an action, run the body,
invoke the action, and preserve the body's result. Use an enclosing cell to
make ordering observable without introducing external I/O.

Predict body results and log changes separately during normal return and early
stopping. Explain which owned actions execute, which resources remain live,
and the nearest interpreter requirement at each closing position before
examining removed-handler and running-action rejections.
The reader can distinguish safe abandonment from skipping required completion
or relying on a removed interpreter. Separate the normal-completion,
abandonment-order, and rejected-context examples so each has one causal point.
No source-cleanup guarantee is implied for internal termination or exhaustion.

### E10. Transforming publications

**State: verified.** [Read the lesson](../../content/effects/transforming-publications/README.md).

Qualify a declaration before substitution, establish a hook, and register
transformations. Predict outer-to-inner order, callback context, and the chain
selected by each exact root. Separate evaluation of the registration expression
from later callback invocations.

The reader can distinguish registration context from publication context and
explain registration lifetime across normal return, capture, resume, and owned
abandonment. Compare a qualifying API with a nonqualifying one, then connect
retained callback access to E8. Registration introduces no escaping token or
arbitrary removal mechanism.

### E11. Acquiring a buffer

**State: verified.** [Read the lesson](../../content/effects/acquiring-a-buffer/README.md).

Use a small byte calculation with a scoped native buffer. Explain acquisition
outcomes before entering the body, checked access, and release. Choose small
deterministic success and failure observations permitted by the fixed API.

The reader predicts body entry and identifies which expression produces each
outcome layer. They distinguish acquisition failure from a successful
acquisition wrapping a normally returned body failure, including nested
acquisitions. Invalid access returns ordinary values with tool status zero;
retained handle escape is a source rejection. Apply the lifetime model from
cells; introduce neither source pointers nor general FFI.

### E12. Combining effects and scopes

**State: verified.** [Read the lesson](../../content/effects/combining-effects-and-scopes/README.md).

Derive an effectful scoring policy, scoped counting, early stopping, and
cleanup from a pure finite-list calculation. Observe the pure result before
the combined module, then predict score, visits, and closing actions separately
for normal, stopped, changed-policy, and empty inputs.

The reader can account for the result, outward row, handler selection,
continuation consumption, cleanup order, and resource lifetimes, including the
entry's remaining policy requirement. Practice copies keep the entry and its
sibling module together outside canonical sources. Hooks and buffers are
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

### F2. Defining local recursion

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

### L1. Requiring element behavior

**State: verified.** [Read the lesson](../../content/libraries/requiring-element-behavior/README.md).

Extend a concrete interface implementation to a nominal container whose
implementation requires behavior for its element type. Trace prerequisite
evidence from an imported constrained use to the selected implementation.

The reader can explain generic heads, explicit prerequisites, ownership,
overlap restrictions, and the structural decrease required of nonground
prerequisites. Choose separate small rejections for missing evidence and an
inadmissible implementation. Connect determination to selection keys without
re-teaching the existing determination lesson.

### L2. Wrapping a representation

**State: verified.** [Read the lesson](../../content/libraries/wrapping-a-representation/README.md).

Compare ordinary nominal data with a module `newtype`. Construct and match the
wrapper explicitly, then give it interface behavior distinct from its
representation. Revisit public and opaque boundaries where useful.

The reader can explain nominal distinction, the lack of implicit coercion or
inherited implementation evidence, and allocation-free wrapping after checked
lowering. A runtime-cost explanation must use appropriate pinned evidence;
printed values alone do not demonstrate allocation behavior.

### L3. Supplying scoped evidence

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

**Verified.** [Controlling a hook pipeline](../../content/cases/controlling-a-hook-pipeline/README.md)
combines three registered transformations with ordinary policy and trace
operations. Separate entries show permitted processing, rejection before later
stages, and omitted enrichment. The source, transformations, and consumer form
a bounded reactive-programming analogy; publication is synchronous, callbacks
form a chain, and discard is not an event filter.

Prerequisites are E10 hooks, E6 discard, and the scripted session's trace
handler. The pinned hook and effect rules below govern callback context, rows,
and continuation ownership. This is original teaching code and prose; it adds
no framework or tooling. The three observations pass at the current baseline.

## Application Cases from DN-0052

**State: all eight application Cases are integrated and verified.** Their
individual PRs have merged, and all eight pass complete-book presentation
review. [Issue #17](https://github.com/dikini/ash-doc/issues/17) and
[PR #18](https://github.com/dikini/ash-doc/pull/18)
retain final book integration evidence. The integration PR awaits human review
and merge.
[DN-0052: Diag Ash Case Studies and Teaching][dn0052] supplies these eight
outcomes. The note is exploring and informative; it reports no new executable
results and accepts no Ash semantics or architecture. Its source commit is
`9f8738b7e0d7f280f9744bf808343d2c97ce6661`; all programs target
`ffi-base` at `354c76b391fe4af665cf6a03479a9874a57cb3e3`.

Place these studies in the existing Cases family. The completed short Cases
isolate mechanisms; these continuations derive application data, operations,
invariants, and costs from a meaningful example. Reuse constituent lessons
as prerequisites. Introduce a smaller teaching example only when the new
boundary needs it, and use a pure reference or contrasting implementation
when it supplies an independent comparison. This creates no new content family
or application framework.

A1–A8 identify the verified outcomes at Cases 21–28. Their linked lessons and
individual issue and PR records retain each reader boundary and its delivery
evidence.

### A1. Preserving outcomes through cleanup

[Preserving outcomes through cleanup](../../content/cases/preserving-outcomes-through-cleanup/README.md)
is verified with nine canonical sources and one complete human rejection
capture. [Issue #1](https://github.com/dikini/ash-doc/issues/1) and
[PR #2](https://github.com/dikini/ash-doc/pull/2) retain delivery and human review
records.

The chapter follows [E9 cleanup](../../content/effects/running-cleanup/README.md)
with a finite batch calculation whose body returns success or a primary error.
Its report API retains that outcome alongside ordered completion errors, with
explicit sums for distinct categories and a caller policy for interpreting the
report.

Checks cover normal return, owned abandonment, no failures, and several
failures. The [specified reporting pattern][reporting] resumes each report so
remaining actions can finish. An abortive collector supplies a rejection and
repair episode; a well-typed action that constructs an error without reporting
it supplies an incorrect application comparison. Cancellation returns an
explicit replacement outcome after discarding the unfinished body.

The reader can explain why a successful body or primary failure survives the
reports, and distinguish command rejection from modeled completion failure.
These source-level completion models make no native release, retry, or internal
termination guarantee.

### A2. Supplying a local pricing policy

[Supplying a local pricing policy](../../content/cases/supplying-a-local-pricing-policy/README.md)
is verified with fourteen canonical sources and three complete human
rejection captures. [Issue #3](https://github.com/dikini/ash-doc/issues/3) and
[PR #4](https://github.com/dikini/ash-doc/pull/4) retain delivery and review records.

The chapter continues
[requested order prices](../../content/cases/supplying-order-prices/README.md)
after [nominal wrappers](../../content/libraries/wrapping-a-representation/README.md)
and [scoped exact evidence](../../content/libraries/supplying-scoped-evidence/README.md).
It derives distinct money and quantity types, then compares explicit pricing
functions, selected imported evidence, and sequential local `with` evidence
whose methods capture an integer tariff.

Checks compare the literal total `4900`, two tariffs producing `5400` and
`5900`, nested policies, and returned quote closures whose exposed type has no
local identity. Boundary orders distinguish zero quantity, free prices, and
unavailable prices, including an unavailable zero-quantity line. Mixed units,
a constrained call before evidence, and local identity escape each have an
isolated rejection, complete human capture, and tested repair. The declared
domain uses finite nonnegative counts and integer cents, without range
validation, Float, division, or inferred units of measure.

The [local nominal][nominals] and [exact evidence][evidence] rules govern the
boundary: the complete selection key must contain the active local nominal.
An identity-free closure may retain selected methods without exporting an
evidence fact. The reader can explain lexical selection without treating it
as global implementation search or runtime-fresh nominal identity.

### A3. Querying an immutable world

[Querying an immutable world](../../content/cases/querying-an-immutable-world/README.md)
is verified with ten canonical sources and two complete human rejection
captures. [Issue #5](https://github.com/dikini/ash-doc/issues/5) and
[PR #6](https://github.com/dikini/ash-doc/pull/6) retain
delivery and review records.

The chapter continues the
[dictionary Case](../../content/cases/dictionary-as-list/README.md) and
[implementation evidence](../../content/libraries/choosing-implementation-evidence/README.md).
It derives unique-identifier position and velocity stores, enumerates the join
rows independently, and compares direct movement with a generic system using
`StoreAccess<W, C>` evidence. Both the world and component belong to the
selection key under the [interface rules][interfaces]; one world supports both
component types.

Checks compare exact stores after one and two steps, retain the original
snapshot, and cover insertion, replacement, empty stores, missing components,
and absent lookup. A well-typed positional zip demonstrates the wrong entity
pairing. Missing selected evidence and a wrong component each supply an isolated
rejection, complete human capture, and tested repair.

The reader can explain identifier joins, explicit evidence selection, and the
nested lookup and repeated linear update work of this representation. The
fixed schema assumes no automatic type-index search, open registry, associated
output, mutation, packed layout, or heterogeneous-path extension.

### A4. Rolling back a cancellable journal

[Rolling back a cancellable journal](../../content/cases/rolling-back-a-cancellable-journal/README.md)
is verified with eight canonical sources and one complete human
rejection capture. [Issue #7](https://github.com/dikini/ash-doc/issues/7) and
[PR #8](https://github.com/dikini/ash-doc/pull/8) retain
delivery and review records.

The chapter continues [E7 cells](../../content/effects/counting-with-a-cell/README.md),
[E6 discard](../../content/effects/stopping-a-calculation/README.md), and
[E9 cleanup](../../content/effects/running-cleanup/README.md). It compares bare
cancellation, which retains staged writes, with an explicit compensation
protocol using an entry snapshot and a commit flag for each journal scope.

Checks cover normal commit, cancellation, nested completion, and outer
cancellation while inner work remains live. They assert explicit outcomes,
copied final states, closing order, and omitted abandoned suffixes. A removed
nearest interpreter supplies a rejection, complete human capture, and
placement repair under the [cleanup rules][cleanup].

The reader can distinguish closing owned control from restoring state and
explain why an outer snapshot can undo an inner commit. The in-memory model
claims no automatic rollback, database isolation, durable storage, or
successful compensation under internal termination.

### A5. Redact before publication

[Redact before publication](../../content/cases/redacting-before-publication/README.md)
is verified with eight canonical sources and two complete human
rejection captures. [Issue #9](https://github.com/dikini/ash-doc/issues/9) and
[PR #10](https://github.com/dikini/ash-doc/pull/10) retain
delivery and review records.

The chapter continues the
[hook pipeline](../../content/cases/controlling-a-hook-pipeline/README.md)
and [E10 hooks](../../content/effects/transforming-publications/README.md).
It derives separate internal and public event types, projects a public view,
and collects ordinary internal snapshots around a redactor.

Checks compare the sensitive field before and after redaction, a collector
installed too early, and a nested exact root that isolates its internal chain.
A copied-secret public code remains well typed while violating the chosen
application policy. A type-changing registration and an internal argument to
the public collector each supply an isolated rejection, complete human capture,
and tested repair under the [hook contract][hooks] and module type boundary.

The reader can explain how an explicit public interface excludes the internal
shape and why field contents still depend on application code. The finite
synchronous model claims no automatic secrecy, observer grants, introspection,
asynchronous delivery, or external I/O.

### A6. Check proposed edits

[Check proposed edits](../../content/cases/checking-proposed-edits/README.md)
is verified with eleven canonical sources and two complete human
rejection captures. [Issue #11](https://github.com/dikini/ash-doc/issues/11) and
[PR #12](https://github.com/dikini/ash-doc/pull/12) retain
delivery and review records.

The chapter continues
[scripted sessions](../../content/cases/running-a-scripted-session/README.md),
[E5 resumption](../../content/effects/resuming-a-calculation/README.md),
and [E6 discard](../../content/effects/stopping-a-calculation/README.md).
A worker builds one immutable edit proposal with prefix/suffix reconstruction.
The controller checks it with an independent indexed model, using its own
original artifact and allowed positions.

Checks distinguish allowed completion, resumed rejection, and owned
cancellation that omits the worker completion suffix. Boundary proposals
cover forbidden and missing positions, a wrong candidate, repeated writes,
and empty batches. An approving controller remains well typed while
completing an unauthorized edit. Double and missing resumption each supply
an isolated rejection and complete human capture, with one-resume and
owned-discard repairs under the [effect rules][effects].

The reader can distinguish continuation consumption from edit authorization
and artifact correctness. The finite scripted interaction claims no security
isolation and runs no LLM, external process, filesystem operation, tool,
sandbox, or concurrent worker.

### A7. Cancel a stable sort

[Cancel a stable sort](../../content/cases/cancelling-a-stable-sort/README.md)
is verified with eight canonical sources and one complete human
rejection capture. [Issue #13](https://github.com/dikini/ash-doc/issues/13) and
[PR #14](https://github.com/dikini/ash-doc/pull/14) retain
delivery and review records.

The chapter continues
[explicit ordering](../../content/cases/searching-ordered-tree/README.md),
[comparison measurement](../../content/cases/measuring-tree-search/README.md),
and [search budgets](../../content/cases/bounding-search-work/README.md).
It derives records with a finite priority and a result that separates
complete sorting from cancellation, then inserts each original head before
equal priorities in its sorted tail. Permission
precedes each comparator invocation. An independent pure reference uses
three stable filters rather than insertion or its comparator.

Checks retain the complete expected records, identifier order `2,5,1,3,4`,
and seven performed comparisons. Budgets zero and six cancel without a
partial sorted result; seven and eight complete with seven comparisons.
Empty, singleton, and equal-priority inputs preserve their stated results.
A well-typed alternative that inserts after equals reverses ties. A double
resumption supplies an isolated rejection, complete human capture, and
one-resume repair under the [effect rules][effects].

The reader can explain the invariant for the sorted tail, preservation of
all records, and original tie order, then derive quadratic source work
separately from charged requests and physical time. Cancellation is
synchronous and returns no partial sequence labelled
as complete. The Case adds no general sorting library or multi-shot control.

### A8. Round-trip a tagged frame

[Round-trip a tagged frame](../../content/cases/round-tripping-tagged-frames/README.md)
is verified with eight canonical sources and one complete human
rejection capture. [Issue #15](https://github.com/dikini/ash-doc/issues/15) and
[PR #16](https://github.com/dikini/ash-doc/pull/16) retain
delivery and review records.

The chapter continues
[bounded message decoding](../../content/cases/reading-a-bounded-message/README.md),
[E11 native buffers](../../content/effects/acquiring-a-buffer/README.md),
and [E8 access scope](../../content/effects/keeping-access-in-scope/README.md).
It derives one tagged frame for `Ping`, `Reading`, and `Pair`, encodes
ordinary integer lists, and decodes within one live buffer owner. The cursor
derives logical length from the supplied byte list, independently of capacity.

Checks compare golden encoding and decoding separately before round trips,
including distinct pair fields and byte boundaries zero and 255. Malformed
tags, truncation, trailing bytes, and spare capacity distinguish logical input
from allocated storage. Acquisition refusal omits body entry; invalid index
and byte writes remain inner operation failures, and a refused byte write
preserves the previous byte. A well-typed swapped-pair encoder breaks golden
agreement. An escaping cursor supplies an isolated rejection, complete human
capture, and a repair that decodes within the live scope and returns copied
data under the [buffer rules][buffers] and
[execution rules][buffer-execution].

The reader can explain format agreement, logical length, nested ordinary
outcomes, and scoped access separately. The declared profile adds no standard
codec, String/Bytes API, intermediate representation framework, pointer,
general FFI, or external I/O.

## Prerequisites and governing sources

The dependencies above describe reading order, not delivery commitments:

- Learn precedes F1, F2, and E1.
- E1 through E12 form the principal effects sequence.
- F1 precedes generalized-local examples in E3.
- The existing implementation-evidence lesson precedes E7's provider bridge.
- The existing library path precedes L1, then L2 and L3.
- The first twelve Cases provide optional pure comparisons; completing them is
  not a prerequisite for entering the effects path.
- A1–A8 each name their existing lesson prerequisites. Their numbering
  does not make cleanup reporting a prerequisite for pricing or ECS.

Language claims and future examples must use the specification at the current
baseline. These sections govern these boundaries:

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
- [Typed failure reporting][reporting]: A1; [cleanup][cleanup] and
  [cells][cells] also govern A4's completion and compensation boundaries.
- [Interfaces and constrained schemes][interfaces],
  [local nominal scope][nominals], and [scoped exact evidence][evidence]:
  A2 and A3's abstraction choices.
- [Hooks][hooks], [effects][effects], and [native buffers][buffers]:
  A5, A6–A7, and A8 respectively. Application invariants require their own
  independent comparisons; these rules do not establish redaction, edit
  authorization, sorting correctness, or codec agreement.

[rows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#computation-types-and-effect-rows
[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[cells]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[buffers]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-native-buffers
[buffer-execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#scoped-native-buffer-execution
[cleanup]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cleanup-actions
[hooks]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#synchronous-typed-hooks
[blocks]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#blocks
[rank1]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#inference-and-rank-1-restrictions
[recursion]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#recursive-block-groups
[implementations]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#implementations
[overview]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/README.md
[nominals]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#local-nominal-scope
[evidence]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-exact-evidence
[interfaces]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#interfaces-and-constrained-schemes
[reporting]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#typed-failure-reporting
[dn0052]: https://github.com/dikini/ash-lang/blob/9f8738b7e0d7f280f9744bf808343d2c97ce6661/docs/design/DN-0052-diag-ash-case-studies-and-teaching.md

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

For A1–A8, derive public operation types from the application data and invariant.
Use independently specified examples or a reference calculation for successful
and incorrect application behavior. Distinguish source rejection, ordinary
typed failure, internal resource failure, and a wrong application result.
The A1–A8 diagnostic episodes now retain exact-pin captures and semantic
checks. DN-0052 supplies motivation, not transcripts or verification receipts.

Keep fixtures and scripts deterministic and hermetic. Add a bounded scaled
case only to answer a stated cost question, separating logical operations,
compiler exhaustion, and physical measurements. A finite run proves neither
a complexity bound nor soundness. Record source traditions and adaptation
limits when selecting each design; historical motivation supplies no current
Ash behavior. Simplify or revise a study if it duplicates an existing lesson
or its evidence plumbing obscures the application question.

When a Case verifies, update its family index, affected runner, and coverage
expectations in the same change. The current Cases inventory is twenty-eight
after A1–A8; further units join only when they satisfy these conditions.
Incomplete studies stay outside active navigation and rendering selection.

## Scope and delivery state

This roadmap covers the proposed continuation, not an exhaustive reference
manual. Named module roots, broader command-line usage, and remaining syntax
reference details can motivate later bounded work. External I/O, concurrency,
general FFI, and new language mechanisms are not assumed by these examples.
Historical Ash remains reference evidence only; all planned code and prose
teach the cumulative current baseline.

E1–E12, F1–F2, L1–L3, the seven initial effect Cases, the hook pipeline Case,
and A1–A8 are complete. All eight application Case PRs have merged. Their
aggregate passes at the exact FFI Base target, and the complete 61-lesson book
passes presentation checks in all four formats. Final integration
[PR #18](https://github.com/dikini/ash-doc/pull/18)
awaits human review and merge under
[issue #17](https://github.com/dikini/ash-doc/issues/17).
The documentation remains unpublished; no ash-doc `ffi-base` publication tag
exists. Refine chapter boundaries when executable design exposes a dependency
or an overloaded question, and replace superseded wording rather than keeping
parallel roadmaps.

## Selecting work

Select one complete reader outcome under the [project workflow](workflow.md).
State its prerequisites, governing baseline, canonical sources, positive and
negative observations, and completion checks. Keep its temporary execution
plan under [plans](../plans/README.md) while work remains active. Remove the
plan after verification and update this roadmap.

A unit is verified only when its prose, displayed code, canonical sources, and
observations agree at the declared baseline. A compiler failure or unresolved
semantic question keeps the affected unit incomplete; it does not authorize
changing Ash or weakening the unit's promised observation.
