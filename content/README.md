# Content

This root contains material intended for a coherent, version-pinned Ash
documentation edition. Content explains and tests Ash; it does not define the
language.

All three families are verified at the current Diag Ash target declared by the
[repository](../README.md#current-edition-diag-ash). Code, prose, and
checks share that exact baseline:

- [`learn/`](learn/README.md) for the complete verified eleven-lesson beginning
  learning path;
- [`cases/`](cases/README.md) for twelve verified recursive-algorithm Cases in numeric order; and
- [`libraries/`](libraries/README.md) for five verified lessons about choosing
  and forwarding evidence, accepting type constructors, and polymorphic
  and relational interface methods.

A unit lives at `content/<family>/<unit>/`. Its `README.md` owns the explanation
and links to canonical programs, fixtures, and checks kept inside the same unit.
Create only the internal paths that its examples require.

Start with [*What is an Ash program?*](learn/what-is-an-ash-program/README.md).
After the complete Learn path, continue with
[*Design library abstractions in Ash*](libraries/README.md) or
[*Design recursive algorithms in Ash*](cases/README.md). The [verification guide](../docs/project/verification.md) names the checks
for every family.

Before creating a unit, follow the [project workflow](../docs/project/workflow.md)
and approve its temporary plan. Keep incomplete work in that plan until the
prose and applicable local evidence can land together. A complete but
unverified unit may enter this root as a draft; a verified unit inherits the
exact Ash milestone and commit recorded by the repository edition. Material
that targets a design experiment belongs in [`lab/`](../lab/README.md), not
here.
