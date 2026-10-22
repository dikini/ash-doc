# Sequencing traditions for the Learn extension

## Question

What can the Learn Ash extension retain from the content sequencing of
*How to Design Programs*, *Structure and Interpretation of Computer
Programs*, and *Algorithms + Data Structures = Programs* when the target
book is shorter than all three, starts from beginners, and must target one
pinned Ash edition?

## Source consulted

- Matthias Felleisen, Robert Bruce Findler, Matthew Flatt, and Shriram
  Krishnamurthi, [*How to Design Programs*, second edition](https://htdp.org/2026-2-25/Book/),
  MIT Press, 2018. The consulted edition and the
  [existing record](how-to-design-programs-recursive-algorithms.md) retain
  its treatment of recursion from data definitions.
- Harold Abelson, Gerald Jay Sussman, and Julie Sussman,
  [*Structure and Interpretation of Computer Programs*, second edition](https://mitp-content-server.mit.edu/books/full_pdfs/SICP.pdf),
  MIT Press, 1996.
- Niklaus Wirth, *Algorithms + Data Structures = Programs*, Prentice-Hall,
  1976.

## Contribution to ash-doc

Each source contributes sequencing method, not wording; none defines Ash
behavior, which remains the pinned specification's role.

- HtDP introduces each concept through a concrete problem that needs it,
  derives the function from the data definition, and has the reader predict
  before running. Learn already follows this shape; the extension keeps it.
- SICP names the process shape when recursion changes it: structural
  recursion builds its result on the way back from the base case, while an
  accumulator computes on the way down. The extension's
  ordering-from-data lesson carries both shapes so the distinction is
  observed, not defined. SICP also treats a small language as a feature —
  the extension's edges-of-the-language lesson does the same for Ash.
- Wirth's recurrence — the algorithm follows the representation — is the
  Learn data lessons' existing rule and the Cases path's contract: change
  the representation and the algorithm changes with it. The extension
  states this where a lesson changes representation.

## Adaptation boundaries

The three works are inspiration, not direct adaptation: examples and prose
remain original, derived from the pinned specification and tool; the sources
inform order and method only. Bibliographic citation carries no licensing
constraint; no text, figures, or code are redistributed.

The Learn book stays far shorter than any source, serves readers new to
programming and experienced readers reviewing Ash, and stops at the
intermediate threshold; generative recursion, mutation, metacircular
evaluation, and language implementation are outside its arc.
