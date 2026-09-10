# Effect row tail exclusion at a generic call

## Question and status

Does a generic function call preserve an exclusion established by a known
member beside its row tail? This is a **regression candidate**, discovered
while implementing E3's explanation of callback effect rows. It is evidence,
not language truth or an accepted semantic change.

The target is Ash `diag-ash`, commit
`9231b21228c5ccacbbee0cc0da60b380e5d2dc59`. The ash-doc starting point was
`b895201`; this case and the accompanying lesson work supply the reproducer.
The example is original and uses only integer arithmetic and one source effect.

## Expected boundary

The pinned [row formation and substitution rules][rows] state that a written
known member is absent from its tail, and that substitution rejects a
replacement containing an instance forbidden by those facts.

`add_bonus` takes a callback with row `{| R}` and produces a result with row
`{Bonus | R}`. Its result row establishes that `R` excludes the exact `Bonus`
instance. A pure callback satisfies that restriction. A callback requiring
`Bonus` would substitute `{Bonus}` for `R` and should be rejected. No particular
diagnostic code is asserted here: upstream must determine failure ownership.

## Reproduction and observations

Use the clean pinned checkout prepared by the repository setup. From ash-doc:

```text
bash lab/effect-row-tail-exclusion/checks/verify.sh /path/to/diag-ash
```

The script checks the exact clean target, builds it with locked dependencies,
and runs both canonical programs. They differ only in the callback passed to
`add_bonus`:

| Program | Callback row | Observed stdout | Status |
| --- | --- | --- | --- |
| [control](src/control.ash) | Empty | `43 : Int` | 0 |
| [excluded callback](src/excluded-callback.ash) | `{Bonus}` | `44 : Int` | 0 |

Both runs have empty stderr. The control agrees with the expected contract;
the second is unexpected acceptance. A passing case verifier means the
observation has been reproduced, not that the behavior conforms to Ash.

## Scope and disposition

The mismatch crosses a global scheme's row instantiation boundary. The
underlying row substitution implementation contains an exclusion check, but
this observation does not establish where the generic checking path loses or
bypasses that obligation. No compiler fix is proposed by this record.

The result affects explanations of reusable helpers beyond this scoring
example: a written exclusion cannot yet be presented as reliably enforced at
every generic call. E3's pure callback and known-row union examples remain
separate observations; they do not prove this rejected-instantiation boundary.

Retain this case while the current baseline has the mismatch. After upstream
resolution and an authorized baseline change, rerun both examples, update the
lesson against the new baseline, and remove this superseded record and its
observation checks. Git retains prior evidence; do not maintain an alternate
compiler pin or teach the accepted program as permission to violate the rule.

[rows]: https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#computation-types-and-effect-rows
