# Chapter title style

Date: 2026-10-20. Bounded repository decision: replace question-form chapter
titles with concept titles across the four content families.

## Decision

A chapter H1 names the concept the chapter teaches — a gerund or noun phrase
in sentence case, no period. A question title remains only when it voices a
boundary, permission, or selection question the reader genuinely arrives
holding (a when, which, or why; the first lesson's defining "What is…"). The
chapter's opening poses and motivates its question in the first paragraphs
either way. Prose questions inside a chapter, including the closing forward
question, are unaffected by this rule.

Approved in conversation on 2026-10-20. The durable rule lives in the
[writing skill](../../.agents/skills/writing-ash-documentation/SKILL.md);
this plan records the one-time application and leaves the tree on completion.

## Scope

- 61 chapter H1s under `content/learn/`, `content/effects/`,
  `content/libraries/`, and `content/cases/`: 43 converted, 18 kept.
- The four family indexes repeat each converted title as its link text.
- `docs/project/roadmap.md` outcome headers and hook-pipeline link text;
  `docs/project/beginning-learning-path.md` Learn entries.
- `rendering/checks/browser.test.mjs` smart-punctuation fixture repointed to
  the current order-prices title; the old fixture quoted a retired title.

Out of scope: directory slugs; forward-reference prose questions; chapter
openings (all 61 reviewed — each opening poses its need independently of the
title, so no opening changed).

## Verification

- Every retired title string has zero grep hits in the working tree.
- Each converted unit's H1 equals its family-index link text.
- `node --test rendering/checks/browser.test.mjs` passes.
- `git diff --check` is clean.
- Presentation-only change: no executable lesson checks, builds, or renders
  are required; displayed code, observations, and transcripts are untouched.

## Completion

Remove this plan after verification. The writing skill retains the rule;
Git history retains this record.
