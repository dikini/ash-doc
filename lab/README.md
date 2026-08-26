# Laboratory

This root contains bounded executable experiments and pressure cases. A lab
case tests a named question; it is evidence, not published Ash instruction or
language truth.

Create a case at `lab/<case>/` only when it has:

- a governing Ash design note and a question within that note's scope;
- an immutable, fetchable executable target and build instructions;
- comparison criteria and expected observations;
- canonical programs, fixtures, and checks local to the case; and
- a retention, graduation, or disposal condition.

Record observations against the exact target. If Ash retains the capability,
rewrite the useful teaching idea for the current pinned edition before moving
it to [`content/`](../content/README.md). If the experiment ends, preserve the
result in its governing evidence and remove obsolete laboratory code when its
retention condition requires it.

Source selection, licensing, and adaptation questions without an executable
Ash experiment belong in [`research/`](../research/README.md).
