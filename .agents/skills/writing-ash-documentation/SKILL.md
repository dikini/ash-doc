---
name: writing-ash-documentation
description: Use when writing, editing, reviewing, or planning ash-doc lessons, exercises, research, project records, or change messages.
---

# Writing Ash Documentation

## Purpose

This is the preferred skill for ash-doc prose. Read
[AGENTS.md](../../../AGENTS.md) first for authority, version, examples, and
verification.

Extend Ash's direct writing with the method of
[*How to Design Programs*](https://htdp.org/2026-2-25/Book/), not its wording.

## Separate the two kinds of prose

Learning prose builds a connected reader model. Project prose records targets,
sources, decisions, evidence, state, and exclusions. The repository root
declares the edition target; the learning index owns setup and reading order.
Lessons assume both and do not render project administration. Put page-local
metadata in YAML front matter only when a concrete consumer needs it.

## Write a learning chapter

- Begin with an action, example, or question, not objectives, prerequisites,
  status, or project constraints.
- Continue the model established by earlier chapters. Introduce only the next
  idea the reader needs.
- Use the current tool cycle: edit, predict, run `ash`, inspect, and explain.
- Let the reader observe a program before introducing words for its parts.
- Make one conceptual move at a time. Show calculations that aid prediction.
- Ask questions the reader can answer. Give the answer nearby unless it is a
  marked exercise.
- Use a contrast or rejection only to answer a reader question. End with
  practice and the next question.

Exercises use only introduced concepts and tools. Name what the reader should
make or explain, not what project coverage it supplies.

## Support a learning assistant

The chapter must work without an assistant. Use sparse, product-neutral prompts
only where dialogue helps. Ground the assistant in the lesson, repository, and
observed `ash` output. Ask one question at a time, use concepts introduced so
far, and withhold exercise solutions until the learner has reasoned. The CLI
observation, not the assistant, tests behavior.

## Use Ash's voice

- Write plain, active sentences. Remove words that add no information.
- Use `you` for reader actions and `we` only for genuine shared work.
- Never call an idea easy, obvious, trivial, magical, or intuitive. Explain it.
- Introduce a stable Ash term only when the reader needs it, define it through
  the current example, and then use it consistently.
- Prefer nouns and verbs. State concrete properties instead of praise.

## Keep evidence behind the lesson

Before using an `ash` fence, identify its canonical source and check. A hidden
marker may connect them; the reader does not need a visible source link. Explain
the example, not its verification machinery.

For adapted work, keep permission, source, license, classification, and Ash
departures in project records. Write original prose and code, with required
attribution.

## Review

- Does the chapter work without an assistant?
- Does each paragraph advance the reader's model rather than administer the
  project?
- Does vocabulary follow the example that needs it?
- Can the reader predict, run, and explain each observation?
- Does every runnable block have canonical, tested source?
- Do project records retain authority, target, and evidence?
