# Method-local type parameters implementation plan

Status: approved by the library-abstractions design

## Outcome and boundary

The reader asks how one interface method can work at unrelated element types.
This crosses from the preceding lesson's `F : Type -> Type` parameter to a
`Functor<F>` method whose own ordered `A` and `B` parameters are instantiated
independently at each occurrence.

The exact target is Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`. The governing rules are the
method-binder rules in `spec/name-resolution.md`, interfaces and constrained
schemes in `spec/static-semantics.md`, generated interface evidence in
`spec/elaboration.md` and `spec/dynamic-semantics.md`, and the pinned `ash`
tool guide.

The lesson will observe:

- a three-module `Functor<Box>` program producing
  `(Box(true), Box(42)) : (Box<Bool>, Box<Int>)`; and
- an otherwise representative interface that omits `<A, B>` rejecting with
  status `1`, empty stdout, and `interface.method-parameter` at the unbound
  method type variable.

It excludes higher-rank values, polymorphic recursion, runtime type inspection,
and new evidence machinery.

## Smallest teaching shape

A single-module program would make the positive result shorter, but would not
show that the method scheme survives the library boundary established by the
previous lessons. The selected shape retains the pinned specification's small
`api.ash`, `carrier.ash`, and entry program, plus one isolated rejected source.
It uses the existing lesson-local Bash verifier and creates no new tooling.

## Execution

1. Add `content/libraries/giving-method-local-type-parameters/checks/verify.sh`
   first. It declares the four-source inventory, requires the exact target,
   checks the positive value and type, checks the negative reason and causal
   spans, checks the source relationships, and checks displayed-source
   agreement. Run it and confirm it fails because the sources do not exist.
2. Add `src/api.ash`, `src/carrier.ash`, `src/01-map-pair.ash`, and
   `src/02-missing-method-parameters.ash`. Run the local verifier and confirm
   both observations.
3. Add the lesson `README.md`, then link lesson 4 from
   `content/libraries/README.md`. Run the lesson and family verifiers.
4. Update `README.md`, `content/README.md`, and `docs/project/roadmap.md` to
   record four lessons and promote only the relational-determination lesson.
5. Run the affected content checks, the complete repository verification set,
   Markdown and shell checks, relative-link and target audits,
   `git diff --check`, and `git status --short`. Review changed files against
   the pinned specification and tool observations.
6. Remove this completed plan and its roadmap link in the closure commit.

Completion means the prose, four canonical sources, navigation, counts, and
checks pass together at the exact target. A compiler failure is recorded as
upstream evidence and is not repaired in ash-doc.
