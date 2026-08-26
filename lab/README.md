# Laboratory

This root contains bounded executable experiments and pressure cases. A lab
case tests a named question; it is evidence, not published Ash instruction or
language truth.

Create a case at `lab/<case>/` only when it has:

- a pinned specification or tool boundary for a versioned pressure case, or a
  governing Ash design note for a design experiment;
- an immutable, fetchable executable target and build instructions;
- comparison criteria and expected observations;
- canonical programs, fixtures, and checks local to the case; and
- a retention, graduation, or disposal condition.

Record observations against the exact target. An experimental compiler target
requires a governing design note, comparison criteria, and disposal condition.
If a case becomes useful for teaching, rewrite the idea for the current pinned
edition before moving it to [`content/`](../content/README.md). If an experiment
ends, preserve its result in the governing evidence and remove obsolete code
when its retention condition requires it.

Source selection, licensing, and adaptation questions without an executable
Ash experiment belong in [`research/`](../research/README.md).
