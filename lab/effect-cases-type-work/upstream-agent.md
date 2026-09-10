# Upstream agent prompt

Investigate the ash-doc effect Cases regression candidate against Ash
`diag-ash`, commit `57eec5bbadae885e49c323e0a05e7a01b9ce8a36`.
Read `lab/effect-cases-type-work/README.md` in ash-doc and run its verifier
against a clean compiler at that exact baseline.

`src/minimal.ash` exits with status 2 and
`internal.resource.type-work`; its intended result is `0 : Int`. Removing only
the cell acquisition or replacing the second recursive call with zero passes.
The failing recursive branch is not executed by this entry. Four larger drafts
in this lab case exhibit the same failure and retain their derived expected
outputs in `checks/*.expected.txt`.

Trace the type-work exhaustion from the reduced case. Determine whether the
scoped-resource analysis, recursive summary convergence, or another type phase
repeats or charges work incorrectly; these are investigation leads, not proven
causes. Establish the failing phase and causal path before selecting a repair.
Preserve bounded work accounting, sound resource-dependency checks, exact effect
rows, and single-use continuation obligations. Do not merely remove checks or
increase limits to make these examples pass.

Add a focused upstream regression test for the reduced case and relevant
positive and negative controls. Verify all four unchanged draft programs against
their derived expected outputs. If any has an independent source error or a
separate compiler cause, report it explicitly rather than assuming one repair
covers all symptoms. Run the relevant upstream test suites and report the exact
repair commit, commands, results, and remaining limitations.

Do not move `diag-ash` or change ash-doc's baseline in this investigation. Return
a concrete migration handoff for ash-doc after the upstream fix. Ash-doc will
verify and promote the blocked lessons at the newly authorized baseline and
remove this superseded case.
