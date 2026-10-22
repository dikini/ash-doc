# Content

This root contains material intended for a coherent, version-pinned Ash
documentation edition. Content explains and tests Ash; it does not define the
language.

The shared [cover illustration](ash-cover.png) is retained for PDF, ebook,
and HTML use. Its [project record](../docs/project/cover-illustration.md)
contains the generation prompt, provenance, and placement guidance.

All four families are verified at the current FFI Base target declared by the
[repository](../README.md#current-edition-ffi-base). Code, prose, and
checks share that exact baseline:

- [`learn/`](learn/README.md) for fourteen verified lessons covering the beginning
  path, local generalization, and local recursion;
- [`cases/`](cases/README.md) for twenty-eight verified algorithm and effect Cases
  in numeric order;
- [`libraries/`](libraries/README.md) for eight verified lessons about choosing
  and forwarding evidence, accepting type constructors, and polymorphic
  and relational interface methods, generic element prerequisites, newtypes,
  and scoped exact evidence; and
- [`effects/`](effects/README.md) for twelve verified lessons on effects, control,
  scoped resources, cleanup, hooks, and their composition.

A unit lives at `content/<family>/<unit>/`. Its `README.md` owns the explanation
and links to canonical programs, fixtures, and checks kept inside the same unit.
Create only the internal paths that its examples require.

Start with [*An Ash program*](learn/what-is-an-ash-program/README.md).
After the complete Learn path, continue with
[*Working with effects and scoped resources*](effects/README.md),
[*Design library abstractions in Ash*](libraries/README.md) or
[*Explore algorithms and effects in Ash*](cases/README.md). The
[verification guide](../docs/project/verification.md) names the checks
for every family.

Before creating a unit, follow the [project workflow](../docs/project/workflow.md)
and approve its temporary plan. Keep incomplete work in that plan until the
prose and applicable local evidence can land together. A complete but
unverified unit may enter this root as a draft; a verified unit inherits the
exact Ash milestone and commit recorded by the repository edition. Material
that targets a design experiment belongs in [`lab/`](../lab/README.md), not
here.
