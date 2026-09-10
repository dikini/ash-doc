# Opaque newtype name and scheme import conflict

This case records a compiler regression candidate at `diag-ash`, commit
`40c964c69c007ba81ec6bdbac34e31ad24fec9c7`. It blocks L2's complete-import
opaque client in the selected functions and libraries continuation. It is
current compiler evidence, not a source restriction or a second Ash baseline.
The sources and prose are original minimal examples.

## Required boundary

The [specification overview][overview] permits opaque newtype names and public
functions using those types to cross module boundaries while hiding the
constructor. A complete import should admit both the public type name and the
function scheme. Merely importing those facts must not conflict. Each entry
below should return `42 : Int`, with empty stderr and status zero.

## Reproduce

Use a clean Ash checkout at the exact commit above:

```text
bash lab/opaque-newtype-import/checks/verify.sh /path/to/diag-ash
```

The verifier records the current failure, not semantic success. The commands
below run from `lab/opaque-newtype-import/src`. All entries share this module:

<!-- source: src/tickets.ash -->
```ash
pub opaque newtype Ticket = Ticket(Int)

pub issue : Int -> Ticket
issue value = Ticket(value)
```

<!-- source: src/01-complete-import.ash -->
```ash
import tickets as Tickets

main : Unit -> Int
main () = 42
```

<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 01-complete-import.ash
The compiler's name-resolution state contains conflicting information for nominal metadata from imported routes.
  --> /path/to/ash-doc/lab/opaque-newtype-import/src/01-complete-import.ash:1:1
1 | import tickets as Tickets
  | ^ The compiler's name-resolution state contains conflicting information for nominal metadata from imported routes.
reason: resolve.internal-state
```
<!-- markdownlint-enable MD013 -->

<!-- source: src/02-type-and-function.ash -->
```ash
import tickets (Ticket, issue)

main : Unit -> Int
main () = 42
```

<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-type-and-function.ash
The compiler's name-resolution state contains conflicting information for nominal metadata from imported routes.
  --> /path/to/ash-doc/lab/opaque-newtype-import/src/02-type-and-function.ash:1:25
1 | import tickets (Ticket, issue)
  |                         ^ The compiler's name-resolution state contains conflicting information for nominal metadata from imported routes.
reason: resolve.internal-state
```
<!-- markdownlint-enable MD013 -->

Both failures have status `2`, empty stdout, reason `resolve.internal-state`,
compiler responsibility, and facts identifying `imported-nominal-metadata`
with a `mismatch`. The importer does not even need to call the function.

## Controls

Selecting only the function works, including a call to it:

<!-- source: src/03-function-only.ash -->
```ash
import tickets (issue)

main : Unit -> Int
main () = {
    let ignored = issue 42
    42
}
```

```text
$ ash 03-function-only.ash
42 : Int
```

Selecting only the type name also works:

<!-- source: src/04-type-only.ash -->
```ash
import tickets (Ticket)

main : Unit -> Int
main () = 42
```

```text
$ ash 04-type-only.ash
42 : Int
```

Additional isolation checks found that a complete import of the same module
with transparent `pub newtype`, or with `pub opaque type`, succeeds. A bare
opaque newtype export without the function also succeeds. The intersection
of an opaque newtype's named route and its scheme-retained metadata is the
failing boundary. These controls do not replace the intended complete import.

## Upstream investigation

At the pinned source, `resolve.rs::scheme_nominal_fact` retrieves the canonical
representation for an opaque newtype appearing in a function scheme.
`retain_scheme_nominal_fact` retains that closure with hidden source access.
`retain_imported_nominal` instead prepares an opaque named projection without
a representation and retains the canonical representation separately.
`resolved.rs::validate_nominal_merge_metadata` rejects a `Some` versus `None`
representation or provenance comparison. This is the leading causal account;
an upstream regression test must establish the exact merge path and repair.

The existing `tests/module_newtypes.rs` opaque tests exercise bare opaque type
exports, while the resolver's scheme test exercises scheme retention alone.
Extend coverage to their combination, both import orders, complete imports,
and facade routes. Preserve constructor inaccessibility and the separation
between canonical compiler facts and source-visible access. Do not make an
opaque wrapper transparent merely to satisfy the merge comparison.

The expected repair restores successful imports and retains ordinary
`resolve.opaque-constructor` rejection when a client explicitly constructs
an opaque value. Verify L2's unchanged `06-opaque-client.ash` and
`07-hidden-constructor.ash` at the updated baseline. Ash owns the implementation
repair and any checkpoint update.

## Upstream agent prompt

> Debug and fix the opaque-newtype import regression discovered by ash-doc L2.
> Start from Ash `diag-ash` at
> `40c964c69c007ba81ec6bdbac34e31ad24fec9c7`. Follow ash-lang's artifact and
> context rules; this is a repair of specified behavior, not a semantic change.
>
> The ash-doc reproduction is at
> `/home/dikini/Projects/ash-doc/.worktrees/functions-libraries/lab/opaque-newtype-import/`.
> Read its README and run its verifier against the pinned compiler. The
> verifier confirms the current bug, so its success does not mean the bug is
> fixed. A complete import, and a targeted import of both `Ticket` and `issue`,
> fail with status 2 and `resolve.internal-state`. Selecting either the type
> alone or the function alone succeeds. The failing client need not call it.
>
> Add an upstream regression test for the combined named and function-scheme
> routes before changing product code. Investigate opaque named projections,
> canonical newtype representations retained by schemes, and nominal-metadata
> merge validation. The README's cause is a hypothesis to verify, not a
> prescribed patch. Preserve source opacity and canonical representation
> authentication; do not expose constructors or bypass metadata validation.
>
> Cover complete imports, targeted imports in both orders, and facade routes.
> Confirm that ordinary opaque data and transparent newtypes keep working.
> Check that opaque constructor use still reports the source-owned
> `resolve.opaque-constructor` diagnostic rather than a compiler failure.
> Follow the repository's required verification for the actual repair scope.
>
> Then verify the unchanged ash-doc L2 files in
> `content/libraries/wrapping-a-representation/src/` in the same worktree:
> `06-opaque-client.ash` must return `42 : Int` with status 0 and empty stderr;
> `07-hidden-constructor.ash` must reject constructor access with status 1.
> Report the root cause, exact fixed commit, tests, and any remaining limits.
> Leave ash-doc's pin and lesson state unchanged. Do not move `diag-ash`
> without explicit user authorization; ash-doc will migrate when the updated
> checkpoint is supplied.

## Retention

Keep this case only while the current baseline reproduces the failure. Once
an updated `diag-ash` fixes it, migrate all active documentation to that exact
commit, verify the full edition, finish the unchanged opaque examples, and
remove this case and its fixtures. Git retains the superseded evidence.

[overview]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/README.md#current-ash
