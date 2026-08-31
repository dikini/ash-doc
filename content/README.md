# Content

This root contains material intended for a coherent, version-pinned Ash
documentation edition. Content explains and tests Ash; it does not define the
language.

The unpublished Lib Ash migration currently contains three active families:

- [`learn/`](learn/README.md) for the complete verified eleven-lesson beginning
  learning path;
- [`cases/`](cases/README.md) for nine verified recursive-algorithm Cases and
  three unavailable slots in numeric order; and
- [`libraries/`](libraries/README.md) for three verified lessons about choosing
  and forwarding evidence and accepting type constructors.

A unit lives at `content/<family>/<unit>/`. Its `README.md` owns the explanation
and links to canonical programs, fixtures, and checks kept inside the same unit.
Create only the internal paths that its examples require.

Start with [*What is an Ash program?*](learn/what-is-an-ash-program/README.md).
After the complete Learn path, continue with
[*Design library abstractions in Ash*](libraries/README.md) or
[*Design recursive algorithms in Ash*](cases/README.md). Cases 9, 10, and 12
link retained compiler-failure evidence from that index; all three remain
available as historical material in the immutable
[`recursive-1` snapshot](https://github.com/dikini/ash-doc/tree/fa870a280c76278361db658ff3952cf18f2b7833/content/cases)
until a bounded migration restores and verifies each one at the active target.

Before creating a unit, follow the [project workflow](../docs/project/workflow.md)
and approve its temporary plan. Keep incomplete work in that plan until the
prose and applicable local evidence can land together. A complete but
unverified unit may enter this root as a draft; a verified unit inherits the
exact Ash milestone and commit recorded by the repository edition. Material
that targets a design experiment belongs in [`lab/`](../lab/README.md), not
here.
