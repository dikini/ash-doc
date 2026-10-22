# Ash Documentation

Ash-doc is the external learning and evidence stream for the Ash programming
language. It teaches Ash through executable programs, adapts durable ideas
from established programming works, and exercises the language with programs
that expose real design pressure.

This repository follows the experiment described by
[DN-0024: Executable Learning and Evidence Stream](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/design/DN-0024-executable-learning-and-evidence-stream.md).
That design note is informative. This repository explains and tests Ash; it
does not define the language.

## Current edition: FFI Base

This repository targets **`ffi-base`** at Ash commit
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. This cumulative checkpoint adds
source foreign contracts, resource families,
immutable strings and bytes, and generated native hosts to the earlier
diagnostics, effects, libraries, modules, and language foundation.

All seventeen Learn lessons, twenty-eight algorithm and effect Cases, eight library
lessons, and twelve effects lessons are verified at this exact target. The
[verification guide](docs/project/verification.md) gives the checks for this
baseline. The documentation remains
unpublished; no ash-doc `ffi-base` publication tag has been created.

**Code, prose, and checks target FFI Base.** Remove obsolete evidence and
records from the working tree; Git retains earlier states.

## Prepare Ash

The learning path uses the `ash` command-line tool. You need Git and a Rust
toolchain that includes Cargo. Clone Ash with its Git URL, select the exact
commit for this edition, and build it:

```text
git clone git@github.com:dikini/ash-lang.git
cd ash-lang
git switch --detach 354c76b391fe4af665cf6a03479a9874a57cb3e3
cargo build --locked
```

The executable is now `target/debug/ash`. Make the shorter name `ash` available
in the current terminal:

```text
export PATH="$PWD/target/debug:$PATH"
export ASH_LIBRARIES="$PWD/libraries"
export ASH_NATIVE_CACHE="$PWD/target/ash-doc-native"
```

Keep this terminal open while you work through the learning path.
`ASH_LIBRARIES` selects the same checkout's source libraries. The buffer lesson
uses it with `--root ffi="$ASH_LIBRARIES"`; ordinary lessons need no root option.
`ASH_NATIVE_CACHE` lets successive native builds reuse their dependencies.
Native buffer builds currently require Linux x86-64 GNU, the matching Rust
toolchain, cached Cargo dependencies, and a native linker. Their generated
executables print a value without the interpreter's `: Type` suffix.

## Read a diagnostic

When a lesson shows a rejected program, its transcript includes the command
and the complete English message. A leading `$` marks the shell prompt; do not
type it. `--message-format human --locale en` selects that presentation
explicitly. This compiler's human renderer emits plain text without terminal
color; it has no color option to set.

Ash prints canonical absolute source paths. In the displayed messages, only
the checkout prefix is replaced by `/path/to/ash-doc/`. Your terminal will show
your checkout's actual location. The remainder of each path, source excerpt,
label, and message is unchanged. Run the named checked-in example from the
working directory given by its learning path to compare the message directly.
A copy saved with another filename will naturally show that name instead.

Read the explanation first, then follow its source labels back to the program.
The `reason:` line gives a secondary identifier for the kind of failure; it is
not a replacement for the explanation. These source rejections write their
messages on standard error, leave standard output empty, and exit with status
`1`.

## Learn Ash

Begin at [Learn Ash](content/learn/README.md). It contains the one-time tool
setup, the method used throughout the learning path, and all twenty verified
chapters in reading order. The path begins with one source file and one
value, then builds through functions, modules, choices, local bindings,
tuples, text, structured data, patterns, recursion, the language's
boundary, and numbers and comparison built from data, before functions
become values and definitions parameterize by type; late chapters widen the
module boundary with targeted imports, re-export, and opaque types. The
continuation develops local generalization and annotated recursive groups,
and a closing lesson previews interfaces, effects, and scoped resources.

The examples use the
[pinned `ash` tool](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md).
When you need the precise language rules, begin with the
[pinned specification overview](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/README.md),
then follow the question into the applicable chapter:

- [lexical structure](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/lexical-structure.md)
  for source text and tokens;
- [syntax](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md)
  for modules, declarations, expressions, and patterns;
- [name resolution](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md)
  for modules, imports, scope, and identity;
- [static semantics](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md)
  for typing and checked programs;
- [elaboration](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/elaboration.md)
  for the connection between checked source and typed Core; and
- [dynamic semantics](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md)
  for values and evaluation.

You do not need to read the specification before the first lesson. Use it when
you want to check an explanation, answer a new question, or understand a result
that surprised you.

## Work with effects and scoped resources

After Learn Ash, begin
[Working with effects and scoped resources](content/effects/README.md). The
twelve verified lessons develop requests and rows, handler selection,
resumption and discard, scoped cells, resource dependencies, cleanup, hooks,
and native buffers. A final calculation combines policy, state, early stopping,
and cleanup. Each chapter connects working programs with complete diagnostic
explanations.

## Design library abstractions

After Learn Ash, begin
[Design library abstractions in Ash](content/libraries/README.md). Its eight
verified lessons choose implementation evidence, carry it through a public
facade, use explicit function kinds for type constructors, give an interface
method local type parameters, let one interface argument determine another,
derive generic container behavior from element prerequisites, wrap existing
representations with new nominal types, and supply exact behavior in local
scopes.

## Explore algorithms and effects

Continue with [Explore algorithms and effects in Ash](content/cases/README.md).
The first twelve Cases derive recursive algorithms from explicit
representations and account for their work. Eight short effect Cases then
illustrate scoped numbering and measurement, dependency injection, scripted
sessions, search budgets, parent-path compression, bounded byte input, and
hook pipelines controlled by ordinary handlers. The eight application Cases
combine completion reporting, local pricing, immutable component stores, journal
compensation, event redaction, controlled edits, cancellable stable sorting, and
tagged frames.

## Authority

- Language claims and executable observations derive from the exact FFI Base
  specification and tool. Earlier results do not establish current correctness.
- `ash` invocation, output, and failures come from the tool guide and executable
  at the same commit as the content being verified.
- Ash project status and possible future behavior come from current `ash-lang`
  artifacts, read according to their stated authority.
- Explanations and learning paths belong to this repository and remain
  subordinate to the pinned specification and tool behavior. Historical
  material retains the authority and target declared by its immutable
  snapshot.

An example, test, tutorial, laboratory result, or repository convention cannot
create Ash semantics. Design notes explore possibilities. Historical Ash is
evidence, not current language truth.

## What this repository will contain

The documentation stream will grow through three equal kinds of work:

- focused paths for learning Ash and program design;
- structures, algorithms, and techniques adapted from established work; and
- deterministic application slices that test several boundaries together.

Laboratory cases and source research will support those publications without
being presented as ordinary Ash lessons. The project will add lesson
directories, metadata, executable-example tooling, rendering, and automation
only when concrete work needs them. The
[project workflow](docs/project/workflow.md) defines that boundary.

The teaching approach combines Ash's plain, status-conscious writing with
techniques visible in
[*How to Design Programs*, second edition](https://htdp.org/2026-2-25/Book/):
start from a concrete problem, make intermediate design reasoning visible,
introduce vocabulary as it becomes useful, and turn examples into checks. The
project also draws teaching inspiration from
[Liquid Shplait](research/liquid-shplait-teaching.md) for explaining contracts,
rejections, and guarantee boundaries, and from
[*A Data-Centric Introduction to Computing*](research/data-centric-introduction-to-computing.md)
for meaningful data, prediction, and development through examples and revision.
These references inform original teaching material; Ash behavior still comes
from the pinned specification and tool. The project-local
[`writing-ash-documentation` skill](.agents/skills/writing-ash-documentation/SKILL.md)
defines that style for writing agents. [AGENTS.md](AGENTS.md) defines the
repository authority and workflow around it.

## Working here

Read [AGENTS.md](AGENTS.md) before changing the repository. It defines the
authority boundary, context-reconstruction workflow, code and example
discipline, migration model, and verification requirements.

Writing agents must use the project-local
[`writing-ash-documentation` skill](.agents/skills/writing-ash-documentation/SKILL.md)
for tutorials, project prose, reviews, plans, and commit or pull-request
messages. The skill is available for implicit discovery and explicit use as
`$writing-ash-documentation`.

Start new work in the [project documentation index](docs/README.md). Use the
[roadmap](docs/project/roadmap.md) to select one complete outcome and a temporary
plan under [`docs/plans/`](docs/plans/README.md) to implement it. Create a
content family or lesson only when its prose and applicable executable evidence
can land together.

Verification uses the shared Bash helper and Python JSON comparison described
in the verification guide. Translated lessons add
`content/checks/translation/sync.sh`, described in the
[verification guide](docs/project/verification.md#check-translated-lessons).
The approved
[local review book](docs/project/rendering.md) uses Quarto Book and Typst to
select all 68 verified lessons in Learn → Libraries → Effects → Cases order,
with each family's introduction, for responsive HTML, reflowable EPUB 3, and
book and A4 PDFs. Their recorded artifact, EPUB, browser, and PDF reviews
predate the Learn extension and refresh at the next whole-book build.
The default build retains the smaller regression specimen; its static figures
cover Mermaid graphs and interaction sequences, railroad grammar, and sequent
inference rules. Both modes share tools and styles. No CI service or publication
platform is selected.

The [notation renderer report](docs/project/notation-renderer-bugs.md) and
[rendering tool report](docs/project/rendering-tool-bugs.md) contain current
failures, minimal reproducers, passing controls, and bounded development
prompts. Rendering preparation does not publish the edition or change its
Ash checkpoint.
