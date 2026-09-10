# Ash Documentation

Ash-doc is the external learning and evidence stream for the Ash programming
language. It teaches Ash through executable programs, adapts durable ideas
from established programming works, and exercises the language with programs
that expose real design pressure.

This repository follows the experiment described by
[DN-0024: Executable Learning and Evidence Stream](https://github.com/dikini/ash-lang/blob/main/docs/design/DN-0024-executable-learning-and-evidence-stream.md).
That design note is informative. This repository explains and tests Ash; it
does not define the language.

## Planned migration to Diag Ash

The tip of this repository plans one forward migration to **`diag-ash`**, at
Ash commit `9231b21228c5ccacbbee0cc0da60b380e5d2dc59`. This is the cumulative
Ash checkpoint: it includes human and JSON diagnostics, the migration fixes,
effects and resource scopes, library abstractions, and modules. The milestone
name identifies the whole target, not a diagnostics-only edition. `effect-ash`
is an included predecessor, not a separate documentation destination.

The [migration plan](docs/plans/2026-09-10-diag-ash-migration.md) owns the next
work. It supersedes the unfinished Lib Ash publication plan and requires all
three content families to move to the same exact Diag Ash commit. No ash-doc
`diag-ash` publication tag exists yet.

**Work and reference have different roles.** All new edition work targets
`diag-ash`. Earlier Ash milestones supply historical reference and
comparison evidence only. Their successful checks do not establish
Diag Ash correctness, and they are not alternative work targets.

### Last verified content baseline

The content and checks have not migrated yet. Their last verified target is
`lib-ash`, Ash commit `d1e323d23390cdad03202ee3df76cd9100556e1d`:

- eleven Learn lessons;
- nine recursive-algorithm Cases, with Cases 9, 10, and 12 unavailable; and
- five library-abstraction lessons.

The setup and source links below still serve that baseline. These verification
records do not establish that the content passes at Diag Ash. The migration
will update the setup, sources, links, diagnostic checks, and coverage together.

The published `modular-ash` documentation tag remains immutable. Its Ash target
is `dca16039923475c48025c5f17beadeb6bcb6a4bf`; `recursive-1` retains the complete
historical Cases. The unfinished Lib Ash edition has no publication tag and
will not receive one as part of this migration. Tags with matching names in
ash-lang and ash-doc identify different commits: compiler and documentation
snapshots respectively.

## Prepare the verified baseline

The learning path uses the `ash` command-line tool. You need Git and a Rust
toolchain that includes Cargo. Clone Ash with its Git URL, select the exact
commit for this historical baseline, and build it:

```text
git clone git@github.com:dikini/ash-lang.git
cd ash-lang
git switch --detach d1e323d23390cdad03202ee3df76cd9100556e1d
cargo build --locked
```

The executable is now `target/debug/ash`. Make the shorter name `ash` available
in the current terminal:

```text
export PATH="$PWD/target/debug:$PATH"
```

Keep this terminal open while you work through the learning path.

## Learn Ash

Begin at [Learn Ash](content/learn/README.md). It contains the one-time tool
setup, the method used throughout the learning path, and all eleven verified
chapters in reading order. The path begins with one source file and one value,
then builds through functions, modules, choices, local bindings, structured and
recursive data, functions as values, and definitions parameterized by types.

The examples use the
[pinned `ash` tool](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md).
When you need the precise language rules, begin with the
[pinned specification overview](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/README.md),
then follow the question into the applicable chapter:

- [lexical structure](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/lexical-structure.md)
  for source text and tokens;
- [syntax](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/syntax.md)
  for modules, declarations, expressions, and patterns;
- [name resolution](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/name-resolution.md)
  for modules, imports, scope, and identity;
- [static semantics](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md)
  for typing and checked programs;
- [elaboration](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/elaboration.md)
  for the connection between checked source and typed Core; and
- [dynamic semantics](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md)
  for values and evaluation.

You do not need to read the specification before the first lesson. Use it when
you want to check an explanation, answer a new question, or understand a result
that surprised you.

## Design library abstractions

After Learn Ash, begin
[Design library abstractions in Ash](content/libraries/README.md). Its first
five verified lessons choose implementation evidence, carry it through a
public facade, use explicit function kinds for type constructors, give an
interface method local type parameters, and let one interface argument
determine another. This planned path is complete.

## Design recursive algorithms

Continue with [Design recursive algorithms in Ash](content/cases/README.md).
Its nine verified Cases derive recursive algorithms from explicit
representations and account for the source work and dependency structure.

Cases 9, 10, and 12 are unavailable at this target and link their retained
compiler-failure evidence from the numbered path. Complete predecessor prose,
canonical programs, and checks for these three slots remain available in the immutable
[`recursive-1` snapshot](https://github.com/dikini/ash-doc/tree/fa870a280c76278361db658ff3952cf18f2b7833/content/cases).
Each Case returns to the active path only after its complete evidence passes at
the selected Diag Ash commit under the migration plan.

## Authority

- Until content cutover, language claims and executable observations remain
  tied to the verified Lib Ash baseline. Migrated material must derive from
  the exact Diag Ash specification; the planned target alone proves no lesson.
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
project-local
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

The indexed roots do not select a renderer, harness, manifest, dependency, CI
service, or publication platform. Establish each choice from a concrete need
and keep the first implementation small enough to replace.
