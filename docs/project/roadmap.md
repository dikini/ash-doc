# Roadmap

The roadmap records the current baseline and the next complete increment. It
is not a curriculum, publication promise, or source of Ash semantics.

## Current baseline

Ash-doc targets `diag-ash` at
`9231b21228c5ccacbbee0cc0da60b380e5d2dc59`. This cumulative checkpoint includes
diagnostics, effects and resources, library abstractions, modules, and the
earlier language foundation.

All content is verified at this baseline:

- [Learn Ash](../../content/learn/README.md): eleven lessons, 43 sources.
- [Recursive algorithms](../../content/cases/README.md): twelve Cases,
  53 sources.
- [Library abstractions](../../content/libraries/README.md): five lessons,
  17 sources.

The [verification guide](verification.md) names the commands and checks.
Code, prose, and verifiers use the same exact baseline. Obsolete evidence and
records leave the working tree; Git retains earlier states.

## Next increment

The approved increment is to teach every demonstrated rejection through its
complete English human diagnostic at the exact baseline above. Readers should
connect the explanation and source labels to the cause and correction, with
reason codes serving as secondary identifiers. Audit all active lessons and
project guidance, preserve exercises and semantic JSON checks, and add only
lesson-local transcript agreement through the existing helpers. The
[execution plan](../plans/2026-09-10-human-diagnostics.md) owns the work.

The documentation is unpublished; no ash-doc `diag-ash` publication tag exists.
Publication tooling and additional learning topics require their own outcome.

## Selecting work

Select one complete reader outcome under the [project workflow](workflow.md).
State its prerequisites, governing baseline, canonical sources, positive and
negative observations, and completion checks. Keep its temporary execution
plan under [plans](../plans/README.md) while work remains active. Remove the
plan after verification and update this roadmap.

A unit is verified only when its prose, displayed code, canonical sources, and
observations agree at the declared baseline. A compiler failure or unresolved
semantic question keeps the affected unit incomplete; it does not authorize
changing Ash or weakening the unit's promised observation.
