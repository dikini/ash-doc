---
name: writing-ash-documentation
description: Use when drafting, editing, reviewing, or planning any ash-doc prose, including tutorials, learning paths, adapted algorithms, application cases, exercises, research records, project documentation, and commit or pull-request messages.
---

# Writing Ash Documentation

## Purpose

Teach through observable programs. Use this preferred skill for every ash-doc
writing task. Read [AGENTS.md](../../../AGENTS.md) first; it owns version,
authority, executable-example, and verification rules.

Extend Ash's direct writing with the problem-first method from
[*How to Design Programs*](https://htdp.org/2026-2-25/Book/). Adapt the method,
not its expression.

## Voice and vocabulary

- Use plain, active language and focused paragraphs. Delete words that add no
  information.
- Use `you` for reader actions and observations; use `we` only for genuine
  shared work.
- Be calm and exact. Never call an idea easy, obvious, trivial, magical, or
  intuitive; show the steps that explain it.
- Use pinned specification terms. Define each at the first example that needs
  it, then remain consistent.
- Distinguish information from its Ash representation. Keep facts, decisions,
  proposals, experiments, and unknowns explicit.

## Shape the explanation

- Begin with a concrete problem, its reader value, and an observable success.
- Move from a worked example to its concept and rule; test the rule with a
  contrast, boundary, or rejection.
- Make one conceptual move at a time. Show a limitation before its repair.
- Ask only questions the reader can answer. Give the answer nearby unless it is
  a marked exercise.
- End by naming what the observation established and the next question it
  enables.

## Teaching recipe

Scale the recipe to the unit; adapted algorithms and application cases usually
need every step.

1. State the problem and observable outcome.
2. Name the information, Ash representation, and invariant.
3. State the purpose and important type signatures.
4. Work through representative, boundary, and rejected examples.
5. Derive the program from the data, operations, and examples.
6. Run checks; interpret the observations, cost, and limitations.

Exercises name the expected artifact and knowledge practiced. They require no
unintroduced syntax, libraries, or domain facts.

## Examples and sources

- Before opening an `ash` fence, identify its canonical source and executable
  check. Otherwise label the material as a draft or pseudocode and do not use
  an `ash` fence.
- Explain what each example contributes. Do not use code as decoration.
- For adapted work, review the license before redistribution. Record its source,
  edition, contribution, material used, license, Ash-required departures, and
  whether it is inspired or directly adapted. Write original prose and Ash code
  by default; preserve ideas or derivations, not protected wording, exercises,
  or solutions.

## Quick review

- Does every claim keep its real authority and version?
- Does vocabulary match the pinned specification?
- Does every runnable block have canonical, tested source?
- Does each paragraph advance the reader's model?

Avoid promotional adjectives and vague claims. For example, replace “Ash has a
powerful modular system” with the established property: “A complete import binds
the dependency's public namespaces under one uppercase alias.”
