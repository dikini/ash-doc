# Add teaching references

## Approved outcome and boundary

The user requested Liquid Shplait and the 2025-08-27 edition of *A Data-Centric
Introduction to Computing* as references for style and teaching approach.
The contributor's question is which explanatory methods transfer to ash-doc
without importing another language's behavior or reproducing its material.

This is a bounded project-writing decision. Ash claims remain governed by
`diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

## Choice

A source list alone would preserve the URLs but leave their contribution and
adaptation boundaries implicit. Detailed research records with short links
from the writing skill and repository README make those distinctions available
when a contributor needs them. Rewriting lessons now would broaden the request
before a particular lesson exposes a need.

Use the existing research layout and the second approach. Revisit a record
when a contributor proposes direct adaptation or selects a newer source
edition. This change adds no Ash examples, curriculum outcome, or tooling.

## Execution and completion

1. Read the requested manuals and selected teaching passages; resolve source
   attribution, edition or immutable revision, and reuse constraints.
2. Add `research/liquid-shplait-teaching.md` and
   `research/data-centric-introduction-to-computing.md` with contributions,
   Ash-specific departures, and exclusions.
3. Link both from `research/README.md`,
   `.agents/skills/writing-ash-documentation/SKILL.md`, and `README.md`.
4. Read all changed files as source. Run Markdown lint, validate the skill,
   check local link targets and consulted source links, and inspect
   `git diff --check` and status. No executable Ash material changes.
5. Remove this completed plan and its index entry.
