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

Learning prose builds a connected reader model; project prose records targets,
decisions, evidence, state, and exclusions. The root owns the edition target
and the learning index owns setup and order. Lessons assume both and hide
administration. Add YAML metadata only for a concrete consumer.

## Write a learning chapter

- Before the first command, give the reader a reason and a working model,
  perhaps through a familiar idea or earlier chapter. A decorative question
  followed by an order does neither. Do not open with objectives, status, or
  project constraints.
- Shape a conceptual arc: an introduction supplies the model, an exploration
  lets examples create the need for later examples, and a conclusion gathers
  the answer and opens the next question. These parts need no explicit heading.
- Continue earlier chapters and introduce only the next needed idea.
- Use the tool cycle: edit, predict, run `ash`, inspect, and explain.
  Weave these actions into the account; do not repeat the cycle as the prose
  skeleton after every example.
- Use needed vocabulary in the opening model; name source parts after
  observation.
- Make one conceptual move at a time. Show calculations that aid prediction.
- Make each paragraph a connected move: establish an idea or question, examine
  evidence, then interpret it or create the next question. Vary sentence length
  and purpose rather than exposing a template.
- Ask only questions the reader can answer from the chapter so far. Give the
  answer nearby unless it is a marked exercise. Use headings for conceptual
  turns, not for every program or workflow step.
- Use a contrast or rejection only to answer a reader question. Show the
  actual complete human diagnostic beside its command when the lesson provides
  the observation. Connect its explanation and source labels to the cause and
  correction; a reason code alone does not teach the failure. Codes remain
  useful secondary identifiers when comparing classifications.
- Capture with explicit human format, English locale, a stated working
  directory, and plain output. Normalize only the documented checkout prefix;
  never invent or shorten a transcript. Keep exact-edition transcript agreement
  separate from semantic JSON checks and from the language contract.
- Keep discovery exercises intact: do not disclose the result or diagnostic
  the reader is asked to discover. End with practice and the next question.

Exercises use only introduced concepts and tools. Name what the reader should
make or explain, not what project coverage it supplies.

## Support a learning assistant

The chapter must work without an assistant. Add sparse, product-neutral prompts
only where dialogue helps. Ground them in the lesson, repository, and observed
`ash` output. Ask one question at a time, use introduced concepts, and withhold
solutions until the learner reasons. The CLI observation tests behavior.

## Use Ash's voice

- Write plain, active sentences. Remove words that add no information.
- Use `you` for reader actions and `we` only for genuine shared work.
- Never call an idea easy, obvious, trivial, magical, or intuitive. Explain it.
- Introduce an Ash term only when the reader needs it, define it through
  the example, and then use it consistently.
- Prefer nouns and verbs. State concrete properties instead of praise.

## Keep evidence behind the lesson

Before using an `ash` fence, identify its canonical source and check. A hidden
marker may connect them. Explain the example, not its verification machinery.

For adapted work, keep permission, source, license, classification, and Ash
departures in project records. Write original prose and code, with required
attribution.

## Review

- Does the chapter work without an assistant?
- Does its opening establish a reason and model before directing the reader?
- Do examples form an exploration and does the ending gather their answer?
- Does each paragraph advance the reader's model rather than administer the
  project?
- Read the prose aloud. Do repeated imperatives, stock transitions, identical
  paragraph shapes, or filler make the teaching method sound mechanical?
- Does vocabulary follow the example that needs it?
- Can the reader predict, run, and explain each observation?
- Does every provided rejection observation show the complete actual human
  message and explain its causal labels and correction, while exercises retain
  the observations the reader must discover?
- Does every runnable block have canonical, tested source?
- Do project records retain authority, target, and evidence?
