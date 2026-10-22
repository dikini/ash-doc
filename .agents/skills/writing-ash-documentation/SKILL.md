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

Also draw on [Liquid Shplait's documentation][liquid] for explaining a
contract's requirements, a rejection's cause, and the scope of a guarantee.
Use [*A Data-Centric Introduction to Computing*][dcic], edition 2025-08-27,
for developing programs from meaningful data and examples, asking for
predictions, and revising a plausible attempt through a small distinguishing
case. Use these methods where the chapter's question needs them.

The [Liquid Shplait record][liquid-record] and [DCIC record][dcic-record]
retain the consulted sources, contributions, and adaptation boundaries.
These are teaching inspirations. Write original prose and examples, and
derive Ash behavior from the pinned specification and tool.

## Separate the two kinds of prose

Learning prose builds a connected reader model; project prose records targets,
decisions, evidence, state, and exclusions. The root owns the edition target
and the learning index owns setup and order. Lessons assume both and hide
administration. Add YAML metadata only for a concrete consumer.

## Keep work within its scope

Follow the [workflow's task boundary](../../../docs/project/workflow.md#bound-the-task):
state the action and selected lesson, part, book, or shared infrastructure.
Reconstruct only the context needed for that action. Choose executable and
presentation checks from changed inputs and requested outputs; reuse applicable
exact-pin evidence for unchanged inputs. Report shared issues discovered in a
lesson task before expanding its scope.

## Write a learning chapter

- Before the first command, give the reader a reason and a working model,
  perhaps through a familiar idea or earlier chapter. A decorative question
  followed by an order does neither. Do not open with objectives, status, or
  project constraints.
- Shape a conceptual arc: an introduction supplies the model, an exploration
  lets examples create the need for later examples, and a conclusion gathers
  the answer and opens the next question. These parts need no explicit heading.
- Title the chapter with the concept it teaches: a gerund or noun phrase in
  sentence case, no period. Keep a question title only when it voices a
  boundary, permission, or selection question the reader genuinely arrives
  holding — a when, which, or why. The opening poses and motivates the
  chapter's question in its first paragraphs either way; the family index
  repeats the title as its link text.
- Continue earlier chapters and introduce only the next needed idea.
- Use the tool cycle: edit, predict, run `ash`, inspect, and explain.
  Weave these actions into the account; do not repeat the cycle as the prose
  skeleton after every example. Vary the framing of each predict-run-compare
  step so the cycle does not read as a chant.
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

When developing a program, start with the problem and a concrete example, then
describe the data and derive the needed operation types before filling their
bodies. Work from the public goal toward smaller operations and cases. Explain
a novel type or concept in detail; give a familiar idea's new facet only the
explanation it needs. Read the [program-design reference](references/program-design.md)
when calculating a solution, reviewing dense code, or interpreting a large
result. It covers contracts, structural reasoning, explained mnemonics,
grouped inputs, and checked observations without imposing a chapter template.

## Choose formatting for the explanation

Keep the main argument readable in ordinary chapter order. Use a numbered
sidenote for optional detail or credit attached to particular words. Use an
unnumbered margin note for a brief local reminder whose association is clear
without a reference number. Use a full-width aside or figure when its table,
diagram, illustration, or other content needs the body and adjoining note
space. Choose by the relationship to the explanation, rather than note length.
Leave unused margin space when it serves no content need.

Sidenotes and margin notes may include small diagrams or sketches that add
optional intuition. Keep them legible at note-column width and connect them to
the nearby example; required understanding stays in the main reading path.
Judge every note by whether it helps understanding without competing for
attention. Prefer one clear point and familiar vocabulary. Remove a note that
adds a detour, repeats the paragraph, or demands more effort than it saves.

When adding or reviewing these elements, read the
[formatting reference](references/formatting.md) for source examples, diagram
metadata, and the current cross-format bounds. It covers HTML, EPUB 3, the
double-sided book PDF, and the one-sided A4 PDF. Keep layout choices in the
shared renderer and navigation in its chrome. Chapter source owns meaning and
reading order.

For diagrams, begin with the ordinary column and assess label size, aspect
ratio, and printed height at the proposed width. Wider space can help a dense
landscape figure; it cannot replace a readable structure. Verify narrow HTML,
enlarged EPUB text, and both PDF layouts before accepting the choice.

Keep a consistent visual vocabulary for the same kind of structure or
transformation. Define what shapes, markings, links, and arrows represent;
preserve that mapping across figures and align labels with the program's names.
A larger figure can add annotations without introducing another vocabulary.
Place its caption beneath the image and any further explanation below that.
The formatting reference gives the rules and a worked local example.

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
- Name the literature term when a chapter teaches a concept that has an
  established one — *algebraic data type*, *closure*, *base case*,
  *higher-order function*, *strict evaluation*. State it at the observation
  that needs it and use it consistently after. The term links Ash's concrete
  behavior to the literature; it is a reference point, not a theory lesson.
- Let terms stand on their own: assert "X is called Y." Do not hedge with
  "sometimes called" or pad with attribution such as "in the terminology
  of." A note may still record a genuine ambiguity, as the ADT note records
  *abstract data type*.
- Prefer the pinned specification's and design notes' vocabulary when they
  name the concept, and verify claimed source usage before writing it; if
  they do not use a term, present it as general literature vocabulary or
  omit it. Keep theory out of lessons: encodings, dualities, and proofs
  belong in research records, and a concept link is one precise sentence at
  most.
- Teach the words your quoted diagnostics use: when a compiler message
  reports a name is "not in scope," the chapter owns *scope*.
- Prefer nouns and verbs. State concrete properties instead of praise.

## Keep evidence behind the lesson

Before using an `ash` fence, identify its canonical source and check. A hidden
marker may connect them. Explain the example, not its verification machinery.

For adapted work, keep permission, source, license, classification, and Ash
departures in project records. Write original prose and code, with required
attribution.

## Review

Apply these questions to the material affected by the task, within its declared
scope. Check a new formatting choice in the formats it must support; reviewing
one existing PDF layout does not require regenerating every other format.

- Does the chapter work without an assistant?
- Does its opening establish a reason and model before directing the reader?
- Do examples form an exploration and does the ending gather their answer?
- Does each paragraph advance the reader's model rather than administer the
  project?
- Read the prose aloud. Do repeated imperatives, stock transitions, identical
  paragraph shapes, or filler make the teaching method sound mechanical?
- Does the title name the concept the chapter teaches, keeping a question
  title only for a boundary, permission, or selection question?
- Does vocabulary follow the example that needs it?
- Does each chapter name the established literature term for the concept it
  teaches, introduced at the observation that needs it and standing on its
  own?
- Does the chapter teach the vocabulary its quoted diagnostics use?
- Does the ending gather the answer from the concrete work rather than
  restate the rules abstractly?
- Are exercises framed as problems in varied shapes, rather than one
  repeated scaffold of imperatives?
- Can the reader follow the problem through its data, operation types, and
  smaller calculations, with enough explanation for new concepts?
- Do patterns, names, and argument groups expose the wiring? Are compact local
  mnemonics explained and consistent with the prose and diagrams?
- Are premises and preservation arguments stated separately from finite test
  observations? Are selected successful results identified and checked?
- Can the reader predict, run, and explain each observation?
- Does every provided rejection observation show the complete actual human
  message and explain its causal labels and correction, while exercises retain
  the observations the reader must discover?
- Does every runnable block have canonical, tested source?
- Can the main explanation stand without its notes, and does wide material
  remain readable when it returns to one column?
- Does a numbered note have a precise reference, an unnumbered margin note a
  clear local association, and a full-width element a reason to need the space?
- Are diagram labels readable at the chosen width, with aspect ratio and page
  height checked, rather than every diagram receiving the widest layout?
- Do diagrams have captions and descriptions, use the supported top-level
  fences, and preserve the distinction between sequents and sequences?
- Do related figures preserve their visual meanings and code labels, with
  useful explanation below their captions?
- Have new formatting elements been checked in narrow HTML, enlarged EPUB
  text, and both PDF layouts for clipping, page breaks, and note collisions?
- Do project records retain authority, target, and evidence?

[liquid]: https://docs.racket-lang.org/liquid-shplait/
[dcic]: https://dcic-world.org/2025-08-27/index.html
[liquid-record]: ../../../research/liquid-shplait-teaching.md
[dcic-record]: ../../../research/data-centric-introduction-to-computing.md
