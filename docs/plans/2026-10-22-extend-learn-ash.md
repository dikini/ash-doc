# Extend Learn Ash plan

Owning outcome: [Extend Learn Ash](roadmap.md#extend-learn-ash-outcome),
approved 2026-10-22.

The Learn path's main sequence grows from eleven lessons toward a
beginner-to-intermediate arc. The two continuation chapters remain the
advanced close. Every lesson targets the pinned FFI Base baseline at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`; every displayed program is
transcluded from or checked against canonical, runnable source. This plan
defines no Ash semantics and no permanent repository architecture.

## Sequencing sources

The arc adapts three sequencing traditions recorded in
[research](../../research/sequencing-three-traditions.md); each contributes
method, not wording, and none defines Ash behavior.

- *How to Design Programs* — a concrete problem introduces each concept;
  data definitions precede the functions that follow them; the reader
  predicts before running. Learn already follows this shape; the extension
  keeps it.
- *Structure and Interpretation of Computer Programs* — name the process
  shape when recursion changes it: structural recursion builds results on
  the way back; an accumulator computes on the way down. The
  ordering-from-data lesson carries both shapes. The edges lesson treats
  the language's smallness as a feature, as SICP treats Scheme's.
- *Algorithms + Data Structures = Programs* — the algorithm follows the
  representation; change the representation and the algorithm changes with
  it. The extension states this where a lesson changes representation.

Deferred decision: whether Learn makes its design method visible as its own
lesson (the HtDP design recipe). The option is recorded here; the outcome
owner decides before candidate authoring begins.

## Candidates

Lessons are numbered by their proposed slot in the main sequence; the
existing lessons 1–11 keep their order, and the continuation chapters stay
last. Slot numbers shift as lessons land. Landed so far: candidate 1 as
lesson 7, Working with text (`cc1b041`); candidate 2 as lesson 10, Patterns
in depth (`2791a53`); candidate 3 as lesson 12, The edges of the language.

1. **Strings and bytes (surface)** — proposed slot 7, after the tuple lesson.
   `String` literals and escapes, display of string values, one or two
   verified `@builtin.string` operations. Flagged `volatile: strings-bytes`;
   no later lesson may build on its operations. Pressure: P-04.
2. **Patterns in depth** — proposed slot 9. Wildcard `_`, nested constructor
   patterns, literal patterns for `Bool`/`Unit`, typed patterns as a checked
   surface form. Pressure: P-02 shapes its exercises.
3. **The edges of the language** — proposed slot 10. Runnable rejections:
   no comments (`lex.comment`), no negative literals, no subtraction or
   ordering operators, `type.operator-operand`; each absence paired with the
   idiom that covers it. Pressure: P-01, P-03, P-05.
4. **Ordering from data** — proposed slot 11. A unary `Natural` type and
   comparison by structural recursion, replacing the operators this edition
   omits; the intermediate threshold of the book. Pressure: P-01.
5. **Module channels** — proposed slot 12. Targeted imports and `pub import`
   re-export, extending the second lesson. No open pressure.
6. **Opaque types (surface)** — proposed slot 13. `pub opaque type` and the
   client/provider split. No open pressure.
7. **Where Ash goes next** — closing lesson after the continuation chapters.
   Three runnable teasers: one interface requirement with selected evidence,
   one `perform`/`handle`, one resource cell, each explicitly deferred to the
   Libraries and Effects paths. No open pressure.

## Authoring rules

- Each lesson lands complete: prose, canonical `src/` programs, fixtures,
  and lesson-local checks, in the existing unit layout.
- Lessons teach the current pinned behavior only; workarounds are taught as
  idioms, never presented as defects. Surface details are enough; no theory.
- Each authoring session ends by updating the
  [language-pressure register](../project/language-pressure.md): a new entry
  for every newly discovered gap or cost, an updated entry whenever a lesson
  touches a logged idiom.
- Terminology follows the writing skill: name established literature terms
  at the observation, let them stand alone, keep theory out, and match
  coverage to the family's beginner-to-intermediate readers.

## Commands

Batched lesson verification reuses the prepared executable, per the
[verification guide](../project/verification.md):

```sh
export ASH_DOC_VERIFY_DIR=/path/to/prepared
export ASH_DOC_ASH_BIN=/path/to/prepared/target/debug/ash
export ASH_DOC_PREPARED_PIN=354c76b391fe4af665cf6a03479a9874a57cb3e3
bash content/learn/<lesson>/checks/verify.sh /path/to/ffi-base
```

Also run `markdownlint` on changed files, `bash
content/checks/language-pressure-sync.sh`, and `git diff --check` before each
commit. A new lesson also updates the Learn index's contents list in the same
commit.

## Completion conditions

- Every approved candidate above is landed or explicitly deferred by a
  recorded decision, with the Learn index and reading order current.
- Every new lesson's checks pass at the declared pin; displayed programs
  agree with canonical sources; diagnostics match complete pinned captures.
- The language-pressure register names every new lesson that touches a
  logged boundary, and the sync check passes.
- This plan leaves the working tree; the register and the sync check remain.
