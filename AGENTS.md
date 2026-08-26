# Working on Ash Documentation

> Teach the reader how to design and understand Ash programs without turning
> an explanation into language truth.

Ash-doc is a separate, version-pinned learning and evidence stream governed by
the experiment in
[DN-0024](https://github.com/dikini/ash-lang/blob/main/docs/design/DN-0024-executable-learning-and-evidence-stream.md).
It may discover language, tool, library, diagnostic, and application pressure.
It cannot define Ash semantics or accept Ash architecture.

## Authority and target

The first edition targets `modular-ash` at commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`.
DN-0024 proposed Mini-Ash for the first pilot edition. Project direction
deliberately replaces that target with the completed Modular Ash checkpoint;
the note's other experiment boundaries still apply.

Use sources according to the claim you are making:

1. The
   [specification at the pinned commit](https://github.com/dikini/ash-lang/tree/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec)
   is the only authority for language behavior in published material.
2. The pinned implementation, its tests, and the
   [pinned tool guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
   govern tool behavior and executable observations.
3. Accepted architectural decisions in `ash-lang` govern the non-language
   choices within their scope and retained version.
4. Change proposals describe proposed transitions. Tasks authorize work.
   Design notes explore ideas and uncertainty. None defines current Ash.
5. Historical Ash and documentation experiments are evidence only.

Use current `ash-lang/main` for current project process, future pressure, and
the latest
[Ash writing guide](https://github.com/dikini/ash-lang/blob/main/docs/project/writing.md).
Do not import language behavior from `main` into the pinned edition.

Every published view must display both its Ash milestone and resolved commit.
An upstream canary may test a newer exact commit, but it does not change the
publication target.

## Reconstruct enough context

Begin every task by stating the reader's question and the observable boundary
it crosses. Then reconstruct the smallest causal model that answers it:

1. Read [README.md](README.md) and identify whether the work is published,
   experimental, migratory, or project-level.
2. Read the pinned specification overview, then only the chapters that govern
   the language claims in the task.
3. Read the pinned tool guide and relevant tests or implementation when the
   task describes commands, output, failures, or diagnostics.
4. Read current design or project artifacts only when the task concerns future
   pressure, evidence exchange, or repository workflow. Preserve each
   artifact's stated authority.
5. Challenge the first explanation. Look for a negative case, an interaction
   with another feature, or a simpler account through existing Ash semantics.
6. Stop when you can explain current behavior, crossed boundaries, relevant
   evidence, downstream pressure, simplification opportunities, and intentional
   exclusions.

Do not replace this model with a reading list. Link each semantic conclusion to
the pinned specification section that supports it. Label unknown or proposed
behavior instead of filling the gap from memory, implementation accidents, or
historical Ash.

## Writing and teaching style

Apply the current Ash writing guide to all prose, code review, plans, commit
messages, and agent communication. In particular, use plain language and active
voice, remove words that add no information, name concrete properties, and
label facts, decisions, proposals, experiments, and uncertainty by their real
status.

Ash-doc extends that foundation with teaching techniques derived from a brief
analysis of the
[*How to Design Programs* preface](https://htdp.org/2026-2-25/Book/part_preface.html),
[prologue](https://htdp.org/2026-2-25/Book/part_prologue.html), and
[function-design material](https://htdp.org/2026-2-25/Book/part_one.html).
Use the techniques below; do not imitate or copy the book's prose, exercises,
examples, or distinctive turns of phrase.

### Voice

- Address the reader as `you` when asking them to observe, predict, compare,
  write, or run something. Name the responsible actor in factual explanations.
- Use `we` only for work the text and reader genuinely perform together. Do not
  use it to hide who made a design choice.
- Sound calm, exact, and encouraging. Treat a mistake as evidence about the
  reader's model or the program, not as a failure of intelligence.
- Use humor and analogy sparingly. State where an analogy stops matching the
  language.
- Do not call an idea easy, obvious, trivial, magical, or intuitive. Show the
  small steps that make it understandable.

### Vocabulary

- Introduce a technical term at the first example that needs it. Define it in
  plain words before relying on it.
- Use the pinned specification's terms for Ash concepts. Do not alternate among
  near-synonyms merely for variety.
- Distinguish the problem-domain information from the Ash data that represents
  it. State how to interpret the representation.
- Prefer names that reveal purpose and relationships. Avoid unexplained
  abbreviations, overloaded metaphors, and adjectives that promise qualities
  no example tests.
- Keep nearby concepts visibly distinct: language versus tool behavior,
  specified behavior versus observation, publication versus laboratory work,
  and correctness versus machine-specific measurements.

### Exposition

- Start a unit with a concrete problem, the reader's reason for solving it, and
  the observation that will show success.
- Move from a worked example to its concept and then to the general rule. Add a
  contrast or boundary case before claiming the rule is understood.
- Make one conceptual move at a time. When the next move repairs a limitation,
  show that limitation with a program or question first.
- Alternate prose with small examples and observations. Explain what each
  example contributes; do not use code as decoration.
- Ask prediction and reflection questions only when the reader has enough
  information to answer. Supply the answer nearby unless the question is a
  clearly marked exercise.
- Keep paragraphs focused. Use short imperatives at action points: predict the
  value, run the program, compare the reason code, or revise the representation.
- End a section by connecting the observation to the idea it established and
  the next question it makes possible.

### Ash teaching recipe

Scale this recipe to the unit. An elementary example may need only a few steps;
an adapted algorithm or application case needs the complete account.

1. State the problem and the observable outcome.
2. Identify the relevant information, its Ash representation, and the
   representation invariant.
3. State the program's purpose and the important type signatures.
4. Work through representative, boundary, and rejected examples before hiding
   them behind an implementation.
5. Derive the program structure from the data, operations, and examples. Name
   choices and rejected alternatives when they teach something transferable.
6. Run executable checks, interpret the observations, and explain cost or
   limitations at the scale relevant to the lesson.

Exercises must state the expected artifact and the knowledge they practice.
Avoid exercises that require unintroduced syntax, libraries, or domain facts.

## Code and executable examples

Write Ash for the pinned milestone, not from memory and not for
`ash-lang/main`.

- Follow the source style used by the pinned specification: descriptive
  `snake_case` term names, `PascalCase` type and constructor names, signatures
  adjacent to their global definitions, and consistent four-space indentation
  inside declarations and branches.
- Choose names from the problem domain. Keep `main` focused on the observation
  the unit promises. Remove unrelated language features from small examples.
- Keep a runnable program in a canonical source file. A displayed runnable
  block must be transcluded from that file or checked for exact agreement with
  it.
- Test successful examples for the applicable value, type, standard output,
  and exit status. Test intentional rejections for the stable reason and
  relevant source location on which the explanation depends. Also assert any
  causal source relationship that the explanation teaches.
- Present the smallest negative example that still establishes the boundary.
  Do not teach incidental diagnostic prose, colors, or layout as a contract.
- Label pseudocode, transcripts, future Ash, and incomplete fragments as
  non-executable. Do not place them in an `ash` fence.
- Keep tests deterministic and hermetic. Use checked-in inputs and controlled
  time, randomness, temporary storage, and loopback services when those
  facilities become relevant.

Execution is necessary but insufficient. Explain the representation,
invariant, derivation, and cost when they carry the idea being taught.

The repository has not selected a host language, formatter, renderer, or test
harness. Do not introduce local coding conventions for hypothetical tooling.
When the project selects a tool, adopt its formatter and linter and record any
additional rules that evidence requires.

## Source and adaptation integrity

For every adapted unit, record the source, edition, intellectual contribution,
material used, and applicable license. Review what the license permits before
redistributing protected expression.

Write original exposition and Ash code by default. Preserve an established
work's problem-solving idea, invariant, derivation, or comparison—not its
wording, exercise statement, or solution text. Explain departures required by
Ash and distinguish inspiration from direct adaptation.

## Repository workflow

Keep project choices behind concrete needs. A new directory layout, renderer,
harness, manifest, dependency, CI service, or publication mechanism requires a
bounded design before implementation:

1. State the reader or maintainer problem.
2. Identify the authority and version boundaries involved.
3. Compare at least two credible approaches and the cost of deferring the
   choice.
4. Select the smallest replaceable choice that supports the next complete
   unit.
5. State its verification and removal or migration condition.
6. Obtain project approval, then implement and verify it in one narrow change.

Do not create empty structure for anticipated work. Keep unit prose, programs,
fixtures, metadata, and checks together once the project accepts a unit layout.
Do not establish a second specification, duplicate every tutorial program in
`ash-lang`, or add compatibility machinery for old Ash editions.

The repository has one active forward line on `main`. Preserve a published
edition with an immutable documentation tag. During a future migration, move
`main` to one exact Ash commit, expose incomplete coverage, and restore units
only after their examples pass. Do not backport new work or maintain an old
edition branch.

## Classify discoveries

When text and its source of truth disagree:

- correct an ash-doc mistake against the pinned specification or tool contract;
- minimize a failure of specified behavior as an Ash regression candidate;
- return an unspecified semantic question to Ash design or proposal work; and
- retain library, tooling, diagnostic, performance, and application pressure
  as evidence without presenting it as a language obligation.

An upstream evidence candidate identifies the ash-doc case and exact commits,
the reader or user task, its source tradition, executable observations, the
blocked or costly boundary, and why the finding matters beyond one example.
One case may expose pressure; it does not accept a new language mechanism.

## Verification

Before completing a change:

1. Read every changed file as source, not only as rendered output.
2. Check Markdown structure, spelling, and relative links. Run the repository's
   Markdown checks when they exist.
3. Verify every language claim against the pinned specification and every tool
   claim against the pinned tool behavior.
4. Run every affected executable example against its declared exact Ash target.
5. Confirm that displayed code agrees with its canonical source and that
   positive and negative observations assert the promised boundary.
6. Review attribution, adaptation notes, and license constraints.
7. Confirm that facts, proposals, experiments, and unknowns retain their actual
   status.
8. Run `git diff --check` and inspect `git status --short` before committing.

The initial repository contains only `README.md` and `AGENTS.md`. It
intentionally selects no content directories, renderer, harness, manifest,
dependency, CI service, publication platform, or license.
