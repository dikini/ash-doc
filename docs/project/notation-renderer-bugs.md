# Notation renderer development report

Can a maintainer render the current Ash notation unchanged and carry the result
through responsive HTML, reflowable EPUB 3, and Typst PDF? This report records
the failures and integration gaps found while building ash-doc's first local
rendering specimen. It is a development handoff, not an Ash language proposal.

## Evaluated sources

The observations use these exact source commits:

- Ash `diag-ash`: `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
- [`sequent-md`][sequent]: `21dad3d34b206b7964d2dd7edcab89a7b8f2b612`.
- [`railroad`][railroad]: `366d5eaa937e9e9fbae3bf8d44265ccc2c528067`.

Ash's [formal notation contract][notation] and accepted [AD-0003][decision]
govern the source notation and the obligation to retain source after a rendering
failure. They do not require an SVG backend. The existing renderers' source and
tests govern their observed API behavior. No upstream files were changed.

The current renderer versions accept Ash's `::=` productions and hyphenated rule
and family names. Those earlier AD-0003 conformance gaps are already resolved.
The current corpus has these results:

<!-- markdownlint-disable MD013 -->

| Pinned source | Observation |
| --- | --- |
| `spec/syntax.md` | All 84 productions in its EBNF fence render without errors. |
| `spec/static-semantics.md` | Eight of 22 sequent fences parse; 14 reject continuation indentation. |
| `spec/dynamic-semantics.md` | All fourteen sequent fences parse. |
| `spec/elaboration.md` | No sequent fences occur. |

<!-- markdownlint-enable MD013 -->

The sequent renderer's own seven test suites passed. Its archived source built
successfully with `npm run build`. The railroad renderer's existing tests and
build also passed during evaluation. These checks cover their tested contracts;
they do not establish full Ash notation conformance or standalone export.

## Reproduce the observations

From this ash-doc checkout, set the paths to the evaluated core module, built
railroad bundle, and source repositories. The following paths are examples to
replace with your checkouts:

```sh
export SEQUENT_BUNDLE=/path/to/sequent-md/packages/core/src/index.js
export RAILROAD_BUNDLE=/path/to/railroad/dist/rehype.js
export RAILROAD_REPO=/path/to/railroad
export ASH_REPO=/path/to/ash-lang
node rendering/checks/renderer-conformance.mjs \
    --report /tmp/ash-doc-renderer-report.json
```

Check the renderer checkout hashes against the pins above before selecting the
modules. The probe reads Ash source with `git show` at its exact pinned commit,
so a different Ash working branch does not change the corpus. It writes a JSON
report and uses a temporary npm cache; it changes no renderer source.

The command exits `0` when the recorded behavior and passing controls agree.
It intentionally records known failures as failures, rather than treating them
as successful rendering. `--reproduce` prints the complete minimized sequent
failure and exits `1`. `--expect-fixed` exits `1` while recorded failures or gaps
remain; use it with candidate renderer builds after reviewing their new commits.
The JSON names the original baselines and actual module paths separately.

## SQ-01: continuation indentation rejects current Ash rules

**Classification:** current Ash notation conformance gap. There is no evidence
of an earlier passing renderer version, so this is not classified as a
regression.

The minimized [fixture][continuation] retains the indented quantified judgment
from [kind synthesis][kind-source]. Ash permits unrestricted formula and
judgment text, and its current specification uses this layout:

```sequent
K-Interface-Argument :=
    for each corresponding (argument_i, parameter_i),
      DELTA; OMEGA; XI |- argument_i => kind(parameter_i)
    ===>
    DELTA; OMEGA; XI; IOTA |- constraint Interface(arguments) ok
```

Run the complete failure capture:

```sh
node rendering/checks/renderer-conformance.mjs --reproduce
```

Standard output is the fixture path and complete source above. Standard error
is exactly:

```text
Line 3, column 1: Unexpected indentation outside a bracketed derivation.
```

The command exits `1`. The underlying `render` API returns this diagnostic
instead of throwing, and its diagnostic HTML retains the complete source.
The [control][sequent-control] extracts `K-Value-Type` from the same
specification with unchanged judgment text; it parses without diagnostics and
produces an inference bar.

The source cause is the core's [`validateBodyIndentation`][sequent-core], which
rejects every deeper formula line outside brackets. The failure is at a formula
continuation, not a rule header or bracketed derivation. The full source probe
finds the same diagnostic in these static-semantics fences:

| Fence opening line | Diagnostic lines within the fence |
| --- | --- |
| 121 | 48 |
| 231 | 6, 12, 20 |
| 472 | 23 |
| 513 | 8, 12, 15 |
| 1027 | 5, 6, 7, 11, 19 |
| 1472 | 7, 9, 10, 15, 23, 26 |
| 1516 | 3, 4, 8, 9, 10 |
| 1575 | 9, 11, 12 |
| 1667 | 6, 9, 13, 15, 17, 20, 23 |
| 1729 | 12, 20, 22, 25 |
| 1807 | 7 |
| 1974 | 7, 15, 23, 30, 33, 36 |
| 2161 | 6, 9, 19, 20, 24, 27, 31, 33, 41, 43, 46 |
| 2262 | 8, 10, 24, 27, 29, 30, 37 |

These locations refer to [the pinned static semantics][static-source]. Add a
diagnostic's fence-relative line to the fence opening line to get its source
line. The JSON report captures every diagnostic, including its column.

**Development prompt:** add the minimized case and unchanged real Ash fences
to the shared core's conformance tests. Define how deeper formula text remains
associated with its premise; accepting it as unrelated sibling premises would
lose the source grouping. Preserve named-rule alignment, nested derivations,
and meaningful indentation diagnostics. Repair the shared core so VS Code and
rehype receive the same behavior. Do not flatten or rewrite Ash source to make
the parser pass.

**Completion condition:** all 36 unchanged pinned sequent fences parse, and a
rendering check confirms that quantified and continued premises retain their
grouping. Existing malformed-layout and nesting tests must still pass. Remove
this failure record after adopting a verified renderer commit; retain the
positive conformance checks.

## RR-03: a malformed EBNF fence loses its source

**Classification:** current Ash failure-presentation conformance gap.

The [invalid fixture][railroad-invalid] contains:

```ebnf
rule ::= ( "x" ;
```

The plugin reports and renders this complete message:

<!-- markdownlint-disable MD013 -->

```text
Railroad diagram error: EBNF error at 1:16: expected a terminal, nonterminal, or grouped expression
```

<!-- markdownlint-enable MD013 -->

The plugin returns normally; the catalogue command exits `0` after confirming
the observation. It generates an `rrd-error` block containing only that message
and removes the original `language-ebnf` code block. The error location remains
available, but the reader cannot inspect the complete rejected source there.
The [control][railroad-control], `rule ::= "x" ;`, produces one SVG without a
message.

The catch branch in [`transformChildren`][railroad-rehype] replaces the fence
with `errorNode(error)`. That function receives no source. This violates the
pinned notation contract's requirement to preserve a failed fence for
correction.

**Development prompt:** retain the invalid original fence beside the escaped
error and source location in the rehype result. Test multiline input, escaping,
and successful replacement separately. Keep failures observable to a build
caller; a rendered error block must not look like a successful diagram.

**Completion condition:** the invalid input emits the same bounded diagnostic
and retains its complete source, while the passing control still becomes one
diagram. Remove the gap record after verified adoption.

## RR-02: npm packaging omits declared entry points

**Classification:** package publication defect. A local built checkout works,
but its prospective npm archive omits both declared executable entry points.

From the built railroad checkout, run:

```sh
npm pack --dry-run --json --ignore-scripts --cache /tmp/ash-doc-pack-cache
```

The command exits `0`. Its file list contains neither `dist/rehype.js`, declared
by `exports["./rehype"]`, nor `dist/extension.cjs`, declared by `main` in
[`package.json`][railroad-package]. The conformance probe checks both entries
and records:

```json
{
  "name": "rrd-preview",
  "version": "0.1.0",
  "absentEntries": ["dist/rehype.js", "dist/extension.cjs"]
}
```

`dist/` is Git-ignored and the package has no `files` allowlist or npm ignore
override. The archive also omits the generated librrd API. The rehype bundle
contains that API after building, so its missing entry is the immediate failure;
shipping the generated API separately is not required for this bundled design.

**Development prompt:** make the npm package include its documented entry
points and necessary supporting assets. Add a package-content test that builds,
packs into a temporary directory, installs the archive into a clean consumer,
and imports `rrd-preview/rehype`. Checking the manifest alone does not test an
installed package. Keep VSIX packaging covered separately.

**Completion condition:** the archive includes the declared entries and a
clean consumer renders the passing EBNF control without access to the source
checkout. Remove this defect record after verified adoption.

## Integration gaps and feature requests

### RR-01: railroad SVG relies on host bounds and CSS

The successful `rule ::= "x" ;` control returns SVG properties `width="800"`,
`role="img"`, `aria-label="Railroad diagram"`, and `xmlns`. It has no `height`
or `viewBox`; its station and rail shapes carry no painting styles. The styles
live in [editor CSS][railroad-css] and use VS Code color variables. Extracting
the SVG into an image therefore loses the bounds and styling supplied by its
host. This is a standalone-export feature gap, not an EBNF parser failure.

The specimen adapter measures the generated geometry and adds bounds and fixed
paint styles to a derived asset. It leaves the upstream output and parser
unchanged. A native exporter could instead return a self-contained SVG with
dimensions, a `viewBox`, explicit strokes and fills, labels, and no editor
variable dependency. Test it as an external image in a browser, EPUB, and Typst.
Remove the local export compensation when that verified API is available.

### SQ-02: additional environment names stay literal

The [alias fixture][aliases] confirms that `GAMMA` and `DELTA` normalize while
`OMEGA`, `XI`, `IOTA`, `PHI`, and `MU` remain literal. These additional uppercase
names occur in current Ash rules, but they are outside the required alias list
in the pinned notation contract. This is an optional vocabulary extension,
not a violation of that contract. The existing `symbols` option can map them
without changing the core. Any expansion needs documented aliases and
word-boundary controls; no Ash semantic change follows from it.

### SQ-03: sequent output has no static vector backend

The reusable core exports `parse`, `render`, `renderHast`, and `styles`.
Its output uses HTML grid and flex layouts. The upstream project promises HTML
integration, so the absence of an SVG API is a portability feature gap.

The specimen renders that existing HTML with a pinned browser, measures text
and deduction bars, and emits plain SVG text and lines. It reuses the original
parser, symbol normalization, and layout. Nested derivations and the primitive
typing family were captured successfully. The resulting SVG has no
`foreignObject`, script, or runtime dependency. Its text still depends on the
selected font; accessibility descriptions retain the canonical notation.

A native SVG backend would need the same source semantics and geometry tests.
Remove browser capture only after native output passes the same nested,
grouped, symbol, overflow, EPUB, and Typst checks.

### RR-04: the vendored build has no tracked sbt pin

`git ls-files vendor/librrd-main/project/build.properties` produces no output.
`git check-ignore -v` identifies:

<!-- markdownlint-disable MD010 -->

```text
vendor/librrd-main/.gitignore:4:/project/*	vendor/librrd-main/project/build.properties
```

<!-- markdownlint-enable MD010 -->

The evaluated local file contains `sbt.version=1.11.2`, but it is ignored.
The build invokes an external `sbt` command, so that local file does not make
the source checkout reproducible. This is a build reproducibility gap; it does
not establish that every clean build fails.

Track a reviewed build pin or document an externally pinned launcher and test
the clean-checkout build. The specimen supplies its own pinned sbt launcher.
Remove that compensation only after the upstream checkout declares and verifies
the build version it requires.

## Scope and retention

The user task is portable formal notation inside a book specimen. Its source
tradition is the existing Ash formal notation and the user's own renderer
projects. The failures matter beyond one figure because a whole specification
corpus rejects valid source, an error erases the text needed to correct it, or
an installed package cannot reach its declared API.

These are documentation-tool findings. They authorize no compiler repair or
change to ash-doc's Ash checkpoint. The specimen's export adapters compensate
for integration gaps locally; they are not upstream fixes. Browser launch
restrictions and sandbox subprocess failures were environment observations and
are excluded from the renderer defects.

Railroad declares MIT licensing. No license file or package license field was
found in `sequent-md`; this evaluation consumes the user's checkout and does
not vendor its source. The small sequent excerpts above and the fixtures name
their exact Ash source. Revisit distribution permissions before redistributing
renderer source or dependencies with a published edition.

Remove resolved entries after a verified renderer update. Keep current
positive controls and artifact checks; Git retains the superseded evidence.

[sequent]: https://github.com/dikini/sequent-md/tree/21dad3d34b206b7964d2dd7edcab89a7b8f2b612
[railroad]: https://github.com/dikini/railroad/tree/366d5eaa937e9e9fbae3bf8d44265ccc2c528067
[notation]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/project/notation.md#rendering-and-ports
[decision]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/decisions/AD-0003-formal-notation-fences.md#consequences
[kind-source]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#kinds-monotypes-and-schemes
[static-source]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md
[sequent-core]: https://github.com/dikini/sequent-md/blob/21dad3d34b206b7964d2dd7edcab89a7b8f2b612/packages/core/src/index.js
[railroad-rehype]: https://github.com/dikini/railroad/blob/366d5eaa937e9e9fbae3bf8d44265ccc2c528067/src/rehype.js
[railroad-package]: https://github.com/dikini/railroad/blob/366d5eaa937e9e9fbae3bf8d44265ccc2c528067/package.json
[railroad-css]: https://github.com/dikini/railroad/blob/366d5eaa937e9e9fbae3bf8d44265ccc2c528067/media/rrd.css
[continuation]: ../../rendering/fixtures/conformance/sequent-continuation.sequent
[sequent-control]: ../../rendering/fixtures/conformance/sequent-control.sequent
[aliases]: ../../rendering/fixtures/conformance/sequent-additional-aliases.sequent
[railroad-invalid]: ../../rendering/fixtures/conformance/railroad-invalid.ebnf
[railroad-control]: ../../rendering/fixtures/conformance/railroad-control.ebnf
