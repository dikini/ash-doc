# Content

This root contains material intended for a coherent, version-pinned Ash
documentation edition. Content explains and tests Ash; it does not define the
language.

Add a family only when its first approved unit is ready:

- `learn/` for focused tutorials and prerequisite-based learning paths;
- `cases/` for structures, algorithms, and techniques adapted from established
  work; and
- `applications/` for deterministic application slices that exercise several
  boundaries together.

A unit lives at `content/<family>/<unit>/`. Its `README.md` owns the explanation
and links to canonical programs, fixtures, and checks kept inside the same unit.
Create only the internal paths that its examples require.

Before creating a unit, follow the [project workflow](../docs/project/workflow.md)
and approve its temporary plan. A verified unit targets the exact Ash milestone
and commit recorded in its prose. Material that targets a design experiment or
does not yet meet the publication boundary belongs in [`lab/`](../lab/README.md),
not here.
