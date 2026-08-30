# Ash Documentation

Ash-doc is the external learning and evidence stream for the Ash programming
language. It teaches Ash through executable programs, adapts durable ideas
from established programming works, and exercises the language with programs
that expose real design pressure.

This repository follows the experiment described by
[DN-0024: Executable Learning and Evidence Stream](https://github.com/dikini/ash-lang/blob/main/docs/design/DN-0024-executable-learning-and-evidence-stream.md).
That design note is informative. This repository explains and tests Ash; it
does not define the language.

## Initial Ash target

The first repository-source documentation edition targets the completed
Modular Ash milestone:

- documentation tag: `modular-ash`;
- Ash milestone tag: `modular-ash`;
- resolved Ash commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

DN-0024 proposed Mini-Ash as the pilot's first published target. This project
deliberately starts at the later Modular Ash checkpoint while retaining the
note's authority, execution, evidence, and forward-migration boundaries.

The matching tags live in different repositories and identify different
source commits. The `ash-lang` tag and resolved commit identify the language
and tool behavior taught by the edition. The ash-doc tag identifies this
documentation source snapshot. `ash-lang/main` has moved beyond the checkpoint;
newer behavior must not enter published examples until ash-doc begins an
explicit forward migration.

## Prepare Ash

The learning path uses the `ash` command-line tool. You need Git and a Rust
toolchain that includes Cargo. Clone Ash with its Git URL, select the exact
commit for this edition, and build it:

```text
git clone git@github.com:dikini/ash-lang.git
cd ash-lang
git switch --detach dca16039923475c48025c5f17beadeb6bcb6a4bf
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
setup, the method used throughout the learning path, and the chapters in
reading order. The first chapter begins with one source file and one value,
then introduces expressions, functions, function calls, and composition.

The examples use the
[pinned `ash` tool](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md).
When you need the precise language rules, begin with the
[pinned specification overview](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/README.md),
then follow the question into the applicable chapter:

- [lexical structure](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/lexical-structure.md)
  for source text and tokens;
- [syntax](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md)
  for modules, declarations, expressions, and patterns;
- [name resolution](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md)
  for modules, imports, scope, and identity;
- [static semantics](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md)
  for typing and checked programs;
- [elaboration](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/elaboration.md)
  for the connection between checked source and typed Core; and
- [dynamic semantics](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md)
  for values and evaluation.

You do not need to read the specification before the first lesson. Use it when
you want to check an explanation, answer a new question, or understand a result
that surprised you.

## Design recursive algorithms

After completing all eleven Learn Ash lessons, continue with
[Design recursive algorithms in Ash](content/cases/README.md). This sequential
Cases path uses the same tool setup and asks how recursive traversal,
representation, invariants, and source-level costs shape an algorithm.

The eleven verified cases progress from consumption to production, retained
knowledge, selective retrieval, branching traversal, invariant-guided branch
selection, checking-time selection of a reusable capability, then an opaque
construction boundary, a height-preserving representation, and explicit
resumable traversal state, followed by a persistent paired-list frontier.
[Folding recursive lists](content/cases/folding-recursive-lists/README.md)
consumes a finite list through a strict right fold. [Building finite
lists](content/cases/building-finite-lists/README.md) produces one from finite
state and exposes the producer's structural termination boundary.
[Accumulating list
results](content/cases/accumulating-list-results/README.md) compares repeated
rebuilding through append with accumulator state that retains knowledge from
earlier elements, then accounts for their different source work. [A dictionary
encoded as a list](content/cases/dictionary-as-list/README.md) uses explicit
equality to compare selective lookup with a strict fold and keeps older
dictionary versions observable after front insertion. [Folding branching
data](content/cases/folding-branching-data/README.md) extends the fold to two
tree branches, separates equal node counts from different dependency depths,
and contrasts direct selective search with whole-tree folding. [Searching an
ordered tree](content/cases/searching-ordered-tree/README.md) uses a valid
global ordering invariant and explicit comparison to justify one-branch
lookup, then shows an accepted malformed miss and the degenerate height
produced by ascending insertion. [Abstracting key
order](content/cases/abstracting-key-order/README.md) replaces the repeated
comparator argument with selected `Order` evidence, preserves the tree
observations, and exposes the missing-implementation boundary. [Protecting the
dictionary
invariant](content/cases/protecting-dictionary-invariant/README.md) makes the
dictionary name public while withholding its constructors, then tests the
public construction routes, whole-tree invariant, and separate value and
pattern rejection boundaries. [Guaranteeing logarithmic
retrieval](content/cases/guaranteeing-logarithmic-retrieval/README.md) replaces
the hidden tree with a persistent red-black representation, derives its four
insertion repairs, and connects its maintained invariants to logarithmic
height. [Resuming tree
traversal](content/cases/resuming-tree-traversal/README.md) exposes an opaque
eager iterator whose private frames retain unfinished in-order work, then
separates one step's worst-case cost from the amortized frame work of one
linear traversal. [A persistent FIFO
frontier](content/cases/implementing-persistent-fifo-frontier/README.md) splits
queue order between a front and reversed rear, accounts for one eager
transfer over a linear successor history that starts from empty, and shows why
retained older states can repeat that transfer.

## Authority

- Language behavior in the first edition comes from the specification at the
  pinned Modular Ash commit.
- `ash` invocation, output, and failures come from the tool guide and executable
  at the same commit.
- Ash project status and possible future behavior come from current `ash-lang`
  artifacts, read according to their stated authority.
- Explanations and learning paths belong to this repository and remain
  subordinate to the pinned specification and tool behavior.

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
