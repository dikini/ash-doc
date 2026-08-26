# Writing Skill Scenarios

These scenarios test discovery, retrieval, and application. Run them with a
fresh agent from the repository root without naming the skill in the request.

## Baseline

Before this skill existed, three agents found the relevant rules by combining
`AGENTS.md`, the Ash writing guide, source artifacts, and other skills. None
could prefer a project writing skill. The tutorial agent also produced two
runnable-looking `ash` fences during a read-only draft, although it could not
create canonical source files or executable checks.

For the learning-core correction, a baseline agent began directly with the
program but explained `Unit` and `Int` before the learner ran it. Its optional
assistant prompt asked for guided reasoning and withheld the final answer, but
it grounded the assistant only in pasted code, not in the lesson, repository,
or observed `ash` output. The revised skill must preserve the direct opening
while correcting those two gaps.

## Tutorial opening

### Tutorial request

Draft the opening of a learning unit that teaches private complete imports at
the pinned Modular Ash milestone. Include a short plan and a sample opening.

### Tutorial passing condition

The agent discovers and uses `writing-ash-documentation`, verifies claims
against the pinned specification, starts from a concrete problem and
observation, and does not use an `ash` fence until canonical source and an
executable check exist.

## Project prose

### Project-prose request

Review and rewrite this README sentence:

> Ash is an intuitive, robust, and extensible language whose amazing modular
> system makes large applications easy.

### Project-prose passing condition

The agent discovers and uses `writing-ash-documentation`, rejects promotional
and untestable adjectives, preserves the authority boundary, and replaces the
sentence with a concrete property supported by the pinned specification.

## Review and commit prose

### Review request

A change adds a tutorial that presents `ash-lang/main` behavior as part of the
pinned `modular-ash` edition. Write a concise review finding and a commit-message
subject for the correction.

### Review passing condition

The agent discovers and uses `writing-ash-documentation` for non-tutorial
prose, treats the version mismatch as blocking, explains the authority failure,
and writes a direct commit subject without promotional or vague language.

## Exercise design

### Exercise request

Add an exercise after an introductory complete-import example. Ask the reader to
practice the concept without introducing new syntax or libraries.

### Exercise passing condition

The agent discovers and uses `writing-ash-documentation`, names the artifact the
reader must produce and the knowledge it practices, and requires only concepts
and tools already introduced.

## Source adaptation

### Adaptation request

Plan an Ash learning unit inspired by an algorithm exercise from a published
programming book.

### Adaptation passing condition

The agent discovers and uses `writing-ash-documentation`, checks redistribution
permission, records the source and edition, distinguishes inspiration from
direct adaptation, explains Ash-required departures, and plans original prose
and Ash code without reproducing the exercise or its solution.

## Sequential lesson

### Sequential-lesson request

Rewrite the opening of the first Ash lesson. It follows a shared setup page and
must teach through the existing literal and arithmetic programs.

### Sequential-lesson passing condition

The agent discovers and uses `writing-ash-documentation`, begins with reader
activity, and introduces vocabulary after an observation creates a need for it.
The lesson continues a learning sequence and renders no state, target,
specification inventory, canonical-source link, evidence report, or project
limitation. Any required page-local metadata uses YAML front matter.

## Assistant-supported exercise

### Assistant request

Add optional chat or coding-agent help to an exercise about nested function
calls. The lesson must remain useful to a learner working without an agent.

### Assistant passing condition

The agent discovers and uses `writing-ash-documentation`. It preserves a
complete no-agent path and adds a short, product-neutral prompt grounded in the
lesson, repository, and observed `ash` output. The prompt asks one question at
a time, uses only concepts introduced so far, and initially withholds a
finished solution. It treats the CLI observation, not the assistant, as the
test of program behavior.
