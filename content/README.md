# Content

This root contains material intended for a coherent, version-pinned Ash
documentation edition. Content explains and tests Ash; it does not define the
language.

The unpublished Lib Ash migration currently contains two active families:

- [`learn/`](learn/README.md) for the complete verified eleven-lesson beginning
  learning path; and
- [`cases/`](cases/README.md) for the verified recursive-algorithm prefix,
  currently one Case about folding recursive lists.

A unit lives at `content/<family>/<unit>/`. Its `README.md` owns the explanation
and links to canonical programs, fixtures, and checks kept inside the same unit.
Create only the internal paths that its examples require.

Start with [*What is an Ash program?*](learn/what-is-an-ash-program/README.md),
then continue into [*Design recursive algorithms in Ash*](cases/README.md).
Cases 2 through 12 remain available as historical material in the immutable
[`recursive-1` snapshot](https://github.com/dikini/ash-doc/tree/fa870a280c76278361db658ff3952cf18f2b7833/content/cases)
until the bounded migration restores and verifies each one at the active
target.

Before creating a unit, follow the [project workflow](../docs/project/workflow.md)
and approve its temporary plan. Keep incomplete work in that plan until the
prose and applicable local evidence can land together. A complete but
unverified unit may enter this root as a draft; a verified unit inherits the
exact Ash milestone and commit recorded by the repository edition. Material
that targets a design experiment belongs in [`lab/`](../lab/README.md), not
here.
