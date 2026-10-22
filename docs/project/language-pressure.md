# Language pressure register

This register records friction the documentation stream discovers against the
pinned Ash baseline: places where teaching a natural reader task required an
idiom heavier than the language needs to demand, or where the design remains
unsettled. Entries are pressure and evidence, not language obligations; no
lesson presents them as defects.

One record per finding, numbered permanently. Statuses: `open`,
`addressed-upstream`, `accepted-exclusion`, `obsolete`. Each entry names the
exact pin where its observation was verified, the reader task, the source
tradition, an executable observation or checked lesson anchor, the blocked
boundary, the cost beyond one example, and the affected lessons.

Recording and synchronisation rules:

- Reference lessons by content path, never by line number.
- A commit that revises a lesson touching a logged idiom updates its entry in
  the same commit; a commit that adds a new workaround adds an entry.
- Every lesson with a `volatile` front-matter key names this register, and
  every lesson path named here exists and stays flagged. The
  `content/checks/language-pressure-sync.sh` check enforces that agreement.
- On a pin migration, re-verify every `open` entry against the new baseline
  and close or update it. When an upstream change addresses a finding,
  record the resolving commit and queue the affected lessons for revision.

## P-01: Integer arithmetic and comparison operators

- Status: open. Recorded 2026-10-22, verified at pin
  `354c76b391fe4af665cf6a03479a9874a57cb3e3`.
- Reader task: counting down, comparing values, and dividing in beginner
  lessons and exercises.
- Source tradition: every introductory programming text provides subtraction,
  ordering comparison, and division.
- Executable observation: the pinned primitive-operation family contains
  exactly `+`, `*`, and `==` (`spec/static-semantics.md`,
  family `primitive-operation-typing`); `spec/lexical-structure.md` states
  that ordinary negative integer expressions remain outside the syntax. The
  checked anchor for the current idiom is
  `content/cases/searching-ordered-tree/`, which derives ordering by
  structural recursion over a unary `Natural` type.
- Blocked boundary: arithmetic and ordering examples must either stay within
  `+` and `*` or define a unary numeral type first.
- Why it matters beyond one example: lesson candidates on comparison and on
  the language's edges both need this; application cases repeatedly define
  comparators where one operator would do.
- Affected lessons: future counting and comparison lessons.

## P-02: Integer literal patterns

- Status: open. Recorded 2026-10-22, verified at the same pin.
- Reader task: matching on small numeric states in exercises, such as
  days-in-month tables or exit-code dispatch.
- Source tradition: numeric literal patterns appear in every introductory
  pattern-matching treatment.
- Executable observation: the pinned pattern grammar admits identifiers,
  `_`, boolean literals, the unit literal, constructor patterns, and
  typed patterns — no integer literal patterns (`spec/syntax.md`, production
  `pattern`).
- Blocked boundary: a numeric state machine needs a constructor wrapper or
  equality-then-branch chains.
- Why it matters beyond one example: it shapes how exercises in several
  future lessons are phrased.
- Affected lessons: none yet.

## P-03: Boolean operators

- Status: open. Recorded 2026-10-22, verified at the same pin.
- Reader task: combining conditions such as "nonempty and permitted."
- Source tradition: `and`, `or`, and `not` are standard vocabulary.
- Executable observation: derivable from the same three-rule
  primitive-operation family as P-01; conditions compose through `match`,
  named functions, or curried `choose`.
- Blocked boundary: none — expressible, but at a teaching cost in every
  condition lesson.
- Why it matters beyond one example: recurring small cost across conditional
  examples, not one blocked lesson.
- Affected lessons: none yet.

## P-04: Strings and Bytes design unsettled

- Status: open. Recorded 2026-10-22, verified at the same pin.
- Reader task: any lesson whose examples process text, from greetings to
  parsing.
- Source tradition: strings are the first non-numeric type in most
  introductions.
- Executable observation: `String` and `Bytes` are primitive with literals
  and escapes, but the operation set lives in `@builtin.string` and
  `@builtin.bytes` with only `to_utf8`, `from_utf8`, and `byte_length`
  observed in the pinned tests; there is no concatenation or string
  equality in the baseline. Literal syntax, the operation sets, curriculum
  placement, and representation all remain open upstream.
- Blocked boundary: text-processing lessons must stay surface-level and
  flagged volatile.
- Why it matters beyond one example: files, memory, and library-level memory
  management are the active implementation focus, so this area will move.
- Affected lessons: the future strings-and-bytes lesson, flagged
  `volatile: strings-bytes` when it lands.

## P-05: Source comments excluded

- Status: accepted-exclusion. Recorded 2026-10-22, verified at the same pin.
- Reader task: annotating example programs for teaching.
- Source tradition: comments are near-universal; their absence surprises
  both audiences.
- Executable observation: `//` text rejects with `lex.comment`
  (`spec/lexical-structure.md`); the spec states Ash has no comments.
- Blocked boundary: none — a deliberate exclusion, accepted; lessons
  explain programs through prose instead.
- Why it matters beyond one example: teaching-material tooling may keep
  requesting annotations; this entry records that the exclusion is settled.
- Affected lessons: the future edges-of-the-language lesson records the
  exclusion honestly.

## P-06: No shipped prelude for common data types

- Status: open. Recorded 2026-10-22, verified at the same pin.
- Reader task: reusing `Option` and list types instead of redefining them.
- Source tradition: standard libraries ship common data types.
- Executable observation: the Learn path defines its own `Result` and
  `IntList`; the shipped `libraries/` tree is FFI-oriented
  (`arena.ash`, `native_buffer.ash`, `sqlite.ash`). Lesson 11 publishes its
  own `List<A>` and `map`.
- Blocked boundary: every path that needs a list or optional value carries
  its own definition first.
- Why it matters beyond one example: lessons 7 and 11, the cases, and the
  libraries path all pay the repetition cost.
- Affected lessons: `content/learn/defining-data/`,
  `content/learn/definitions-for-many-types/`.
