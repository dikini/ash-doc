# Ash Documentation

Ash-doc is the external learning and evidence stream for the Ash programming
language. It will teach Ash through executable programs, adapt durable ideas
from established programming works, and exercise the language with programs
that expose real design pressure.

This repository follows the experiment described by
[DN-0024: Executable Learning and Evidence Stream](https://github.com/dikini/ash-lang/blob/main/docs/design/DN-0024-executable-learning-and-evidence-stream.md).
That design note is informative. This repository explains and tests Ash; it
does not define the language.

## Initial Ash target

The first documentation edition will target the completed Modular Ash
milestone:

- milestone tag: `modular-ash`;
- resolved commit: `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

DN-0024 proposed Mini-Ash as the pilot's first published target. This project
deliberately starts at the later Modular Ash checkpoint while retaining the
note's authority, execution, evidence, and forward-migration boundaries.

The tag and commit together identify the language and tool behavior taught by
the edition. `ash-lang/main` has moved beyond this checkpoint. Newer behavior
must not enter published examples until ash-doc begins an explicit forward
migration.

## Learn Ash from its source of truth

Begin with the
[pinned specification overview](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/README.md).
It introduces the language boundary and includes complete modular programs.
Then use the
[pinned `ash` tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
to build and run a small program.

When a question needs more precision, follow it into the applicable
specification chapter:

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

You do not need to read every chapter before writing a program. Start with one
observable question, read the sections that govern it, predict the result, and
run the program. Return to the specification when the observation surprises
you.

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
being presented as ordinary Ash lessons. The project will choose directories,
unit metadata, executable-example tooling, rendering, and automation only when
the first concrete work needs them.

The teaching approach combines Ash's plain, status-conscious writing with
techniques visible in
[*How to Design Programs*, second edition](https://htdp.org/2026-2-25/Book/):
start from a concrete problem, make intermediate design reasoning visible,
introduce vocabulary as it becomes useful, and turn examples into checks. The
local rules for applying that approach live in [AGENTS.md](AGENTS.md).

## Working here

Read [AGENTS.md](AGENTS.md) before changing the repository. It defines the
authority boundary, context-reconstruction workflow, teaching voice, code and
example discipline, source-integrity rules, migration model, and verification
requirements.

This bootstrap intentionally selects no content layout, renderer, harness,
manifest, dependency, CI service, or publication platform. Establish each
choice from a concrete need and keep the first implementation small enough to
replace.
