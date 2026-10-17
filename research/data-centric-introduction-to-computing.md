# Teaching program design with DCIC

## Question

How can *A Data-Centric Introduction to Computing* help ash-doc develop a
reader's model through meaningful data, concrete examples, prediction, and
revision?

## Source consulted

Kathi Fisler, Shriram Krishnamurthi, Benjamin S. Lerner, and Joe Gibbs Politz,
[*A Data-Centric Introduction to Computing*][book] (DCIC), edition
2025-08-27, consulted on 2026-10-12. Retain this dated edition rather than
silently following the site's current release.

The review consulted these passages:

- [Overview][overview], especially the perspective on data, explanatory models
  of execution, and the conversational development of programs.
- [From Repeated Expressions to Functions][functions]: motivating abstraction
  from concrete calculations and explaining function evaluation.
- [Processing Lists][lists], especially the alternating-elements example:
  deriving code, testing a plausible attempt, and finding a discriminating
  small input.
- [Introduction to Structured Data][data]: explaining the represented values
  before developing operations over them.
- [Examples, Testing, and Program Checking][testing]: choosing illustrative
  examples, broadening checks, and interpreting disagreement with a test.

## Contribution to ash-doc

DCIC treats data as part of the problem, with a meaning that motivates the
calculation. It also develops explicit models of execution so readers can
predict behavior. Ash-doc can begin with a concrete domain question, state what
the input represents, and use a small trace to connect source to result.

The function chapter starts with repeated calculations, identifies what varies,
and introduces parameters to express that variation. The resulting function
answers a need the reader has already seen. This strengthens the existing
ash-doc rule to introduce one idea when the exploration needs it.

The list chapter makes a plausible attempt useful by finding the input that
exposes its missing case. Its alternating-elements calculation initially
handles even-length lists but loses the final element of an odd-length list;
a singleton reveals the cause. The transferable method is to choose a small
case that distinguishes competing explanations, then show why the correction
follows. Original Ash examples must establish their own observations.

The structured-data chapter connects the meaning of components and alternatives
to the operations that consume them. This supports explaining representation
choices before presenting the completed function. A reader should be able to
say what a value represents and why its structure supports the calculation.

The testing chapter distinguishes examples that clarify intended behavior from
checks that exercise a wider range of cases. It also treats a failed check as
disagreement requiring interpretation: the implementation, expectation, or
choice of comparison may need correction. Ash-doc can select a few examples
for explanation while keeping fuller executable evidence behind the lesson.

## Adaptation classification and license

This use is **teaching inspiration**, not direct adaptation. An open-content
adaptation license was not identified in the consulted edition's HTML pages.
The authors' [public repository][repository] is an issue tracker and describes
the book source as private; it does not establish reuse permission for the book.

Write original prose, programs, exercises, data, traces, and ordering. Credit
the source and retain this evaluation. Do not reproduce its named examples,
activity wording, diagrams, or passages. Any later direct adaptation needs a
separate rights review for the specific material; public access alone does not
establish permission.

## Ash-specific departures and exclusions

All Ash claims remain governed by `ffi-base` at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`. DCIC's Pyret and Python behavior,
libraries, testing syntax, and execution models are not Ash semantics. An Ash
trace must agree with the pinned specification and actual tool observations.

Keep the existing sequential Learn path. Adopt guided development and useful
prediction questions where they answer the chapter's question. Clearly identify
an incomplete or failed attempt and resolve its boundary before the chapter
ends. Keep answered exploration distinct from exercises whose observations the
reader must discover.

Meaningful data need not require a live service or a large dataset. Ash examples
retain small checked-in inputs and deterministic observations. This reference
selects no tables library, data-science curriculum, Python bridge, web tool,
renderer, or new lesson. It informs future writing and review when a concrete
chapter needs its methods.

[book]: https://dcic-world.org/2025-08-27/index.html
[overview]: https://dcic-world.org/2025-08-27/booklet_intro.html
[functions]: https://dcic-world.org/2025-08-27/From_Repeated_Expressions_to_Functions.html
[lists]: https://dcic-world.org/2025-08-27/processing-lists.html
[data]: https://dcic-world.org/2025-08-27/intro-struct-data.html
[testing]: https://dcic-world.org/2025-08-27/testing.html
[repository]: https://github.com/data-centric-computing/dcic-public
