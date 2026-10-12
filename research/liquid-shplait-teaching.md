# Teaching contracts and boundaries with Liquid Shplait

## Question

How can Liquid Shplait's documentation help ash-doc explain a program's
requirements, a checker's evidence, and the boundary of a guarantee?

## Source consulted

Shriram Krishnamurthi's [Liquid Shplait manual][manual], consulted on
2026-10-12, describes an educational extension of Shplait with refinement
types checked statically using Z3. The opening introduces a predicate on an
integer, changes the calculation until that predicate fails, and repairs the
parameter requirement.

The review also consulted these sections:

- [Refinements][refinements]: reading the notation and explaining the names
  available in a predicate.
- [What Liquid Shplait Proves][proved]: assumptions at function entry,
  obligations at calls and returns, and information supplied by branches.
- [Rejections][rejections]: counterexamples, prover limits, and constructs
  outside the checker's model.
- [Checks at the Boundary][boundary]: explicit checks on incoming values.
- [Limitations][limitations]: the scope of checking and guarantees.

The [Racket package catalogue][package] identified source commit
`2e3e29e3ca76e94d48de03480476eb792d2e9fdd`. Its [package metadata][metadata]
declares version `0.3`; the [manual source][source] retains the reviewed
explanations at that revision. The live documentation URL is not an immutable
edition link. Later revisions need a fresh review before replacing this source
boundary.

## Contribution to ash-doc

The opening makes a type claim consequential before expanding its notation.
One small calculation connects the input restriction, the promised output,
the failed case, and a repair. The transferable method is to keep the reader's
question stable while changing only the detail that determines acceptance.

The proof-model section gives each participant a responsibility: a function
uses its input assumptions, a caller establishes them, and the body establishes
its result claim. This suggests explaining an Ash contract by tracing what
each boundary requires and what information is available there. The particular
requirements must come from Ash's specification.

The rejection section distinguishes a counterexample from a claim the prover
cannot establish and a construct it cannot model. The useful writing habit is
to explain what the observation actually establishes. A rejection needs its
cause and applicable boundary, not an unqualified statement that the intended
program is wrong.

The boundary section motivates explicit input checks through values that the
program cannot assume are valid. It connects each test to the requirement of
the next operation. This can inform later Ash application teaching when a
complete, supported example needs input validation.

The proof-model and limitations sections qualify the guarantee in concrete
terms. Liquid Shplait proves partial correctness, assumes termination for a
returned result, and does not check values arriving from unchecked module
callers. They also explain why a refinement on an older value cannot prevent
that value's later reuse. Ash-doc should likewise state the scope of evidence
where it affects the reader's conclusion, using Ash's own boundaries.

## Adaptation classification and license

This use is **teaching inspiration**, not direct adaptation. The pinned
[MIT license][license] covers the software and associated documentation and
requires its copyright and permission notice in copies or substantial portions.

The selected contribution needs original explanations, programs, exercises,
and diagnostics. Cite the manual and retain this record. Any later direct
adaptation must identify the reused material and retain the applicable notice;
this review selects no copied passage, program, or transcript.

## Ash-specific departures and exclusions

Ash language claims remain governed by `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. Liquid Shplait's predicates,
proof obligations, solver behavior, module rules, and diagnostics describe
Liquid Shplait. They neither describe current Ash nor propose an Ash extension.

Use the explanatory method only where an Ash lesson needs it. Capture Ash's
actual diagnostics and keep semantic checks separate from transcript agreement.
Do not import Shplait syntax, Z3, refinement types, installation steps, examples,
or chapter order into the active learning path. This addition selects no new
lesson, compiler target, or verification mechanism.

[manual]: https://docs.racket-lang.org/liquid-shplait/
[refinements]: https://docs.racket-lang.org/liquid-shplait/refinements.html
[proved]: https://docs.racket-lang.org/liquid-shplait/proved.html
[rejections]: https://docs.racket-lang.org/liquid-shplait/rejection.html
[boundary]: https://docs.racket-lang.org/liquid-shplait/boundary.html
[limitations]: https://docs.racket-lang.org/liquid-shplait/limitations.html
[package]: https://pkgs.racket-lang.org/package/liquid-shplait
[metadata]: https://github.com/shriram/liquid-shplait/blob/2e3e29e3ca76e94d48de03480476eb792d2e9fdd/info.rkt
[source]: https://github.com/shriram/liquid-shplait/blob/2e3e29e3ca76e94d48de03480476eb792d2e9fdd/shplait/liquid/scribblings/liquid-shplait.scrbl
[license]: https://github.com/shriram/liquid-shplait/blob/2e3e29e3ca76e94d48de03480476eb792d2e9fdd/LICENSE
