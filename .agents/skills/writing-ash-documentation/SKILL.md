---
name: writing-ash-documentation
description: Use when drafting, editing, reviewing, or planning any ash-doc prose, including tutorials, learning paths, adapted algorithms, application cases, exercises, research records, project documentation, and commit or pull-request messages.
---

# Writing Ash Documentation

## Purpose

Write to reduce uncertainty and teach through observable programs. Use this
preferred skill for every ash-doc writing task. Read
[AGENTS.md](../../../AGENTS.md) first; it owns version, authority, executable
example, and verification rules.

Extend Ash's direct writing with the problem-first method of
[*How to Design Programs*](https://htdp.org/2026-2-25/Book/). Adapt the method,
not its wording or exercises.

## Voice and vocabulary

- Use plain language, active voice, and focused paragraphs. Delete words that
  add no information.
- Address the reader as `you` for actions and observations. Use `we` only when
  text and reader genuinely act together.
- Be calm and exact. Never call an idea easy, obvious, trivial, magical, or
  intuitive; show the steps that explain it.
- Use the pinned specification's term for an Ash concept. Define it at the
  first example that needs it, then use it consistently.
- Distinguish information from its Ash representation. Label facts, decisions,
  proposals, experiments, and unknowns by their real status.

## Shape the explanation

- Begin with a concrete problem, its value to the reader, and the observation
  that will show success.
- Move from a worked example to its concept, then to the general rule. Test the
  rule with a contrast, boundary, or rejection.
- Make one conceptual move at a time. Show a limitation before introducing the
  idea that repairs it.
- Ask only questions the reader can answer. Give the answer nearby unless it is
  a marked exercise.
- End by naming what the observation established and the next question it
  enables.

## Teaching recipe

Use the full recipe for teaching content. Scale it down for project prose,
reviews, plans, and commit messages.

1. State the problem and observable outcome.
2. Name the information, Ash representation, and invariant.
3. State the purpose and important type signatures.
4. Work through representative, boundary, and rejected examples.
5. Derive the program from the data, operations, and examples.
6. Run checks; interpret the observations, cost, and limitations.

## Examples and sources

- Before opening an `ash` fence, identify its canonical source and executable
  check. Otherwise label the material as a draft or pseudocode and do not use
  an `ash` fence.
- Explain what each example contributes. Do not use code as decoration.
- For adapted work, record its source, edition, contribution, material used,
  and license. Preserve the idea or derivation, not protected wording or
  solutions.

## Quick review

- Does every claim keep its real authority and version?
- Does vocabulary match the pinned specification?
- Does every runnable block have canonical, tested source?
- Does each paragraph advance the reader's model?

Avoid promotional adjectives and vague claims. For example, replace “Ash has a
powerful modular system” with the concrete property the lesson establishes,
such as “A complete import places a dependency's public names behind one local
alias.”
