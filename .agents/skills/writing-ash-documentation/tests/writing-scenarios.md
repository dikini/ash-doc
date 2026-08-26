# Writing Skill Scenarios

These scenarios test discovery, retrieval, and application. Run them with a
fresh agent from the repository root without naming the skill in the request.

## Baseline

Before this skill existed, three agents found the relevant rules by combining
`AGENTS.md`, the Ash writing guide, source artifacts, and other skills. None
could prefer a project writing skill. The tutorial agent also produced two
runnable-looking `ash` fences during a read-only draft, although it could not
create canonical source files or executable checks.

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
