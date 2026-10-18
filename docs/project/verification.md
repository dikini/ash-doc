# Verify the documentation

Every active program, language claim, and tool observation targets Ash
`ffi-base`, commit `354c76b391fe4af665cf6a03479a9874a57cb3e3`.

## Select the affected checks

Follow the [task boundary](workflow.md#bound-the-task): choose checks from the
action, scope, and changed inputs. For a lesson edit affecting programs,
observations, or executable promises, run that lesson's local verifier:

```sh
bash content/cases/resuming-tree-traversal/checks/verify.sh /path/to/ffi-base
```

For a part task, run its affected lesson checks; use the family aggregate when
the whole family's executable evidence needs verification. Reuse retained
exact-pin evidence for unchanged inputs during prose or layout review. Do not
rerun every program because one caption or print layout changed.

## Run the content checks

Use a clean Ash checkout at that exact commit. For complete-edition verification
or a baseline migration, run all four family aggregates from ash-doc:

```text
bash content/learn/checks/verify.sh /path/to/ffi-base
bash content/cases/checks/verify.sh /path/to/ffi-base
bash content/libraries/checks/verify.sh /path/to/ffi-base
bash content/effects/checks/verify.sh /path/to/ffi-base
```

The shared Bash helper checks the compiler pin, builds the executable with
locked dependencies, and runs the lesson-local verifiers. Its temporary build
and observation directory lives under ignored `.build/`, or `TMPDIR` when
explicitly supplied, and is removed on exit. Native debug dependencies need
several GiB; use a filesystem with sufficient space rather than a small tmpfs.
Verification needs Bash, Cargo with the pinned toolchain, ordinary Unix text
tools, and Python 3
for JSON comparison. No third-party Python packages are required.

The four aggregates cover thirteen Learn lessons / 56 sources, twenty-eight
Cases / 141 sources, eight library lessons / 43 sources, and twelve effects
lessons / 71 sources. They check successful values, types, stdout, stderr, and
exit status; agreement between displayed and canonical code; and the source
properties each Case teaches.

### Native buffer observations

Thirteen positive entries use the imported source buffer library. Their local
verifiers call `ash_doc_run_native_accepted` with separate expected value and
type strings. `native-observe.rs` compiles each entry once, reads the checked
`CompiledProgram::type_display()`, builds from that same compiled program, and
captures its generated host. The Bash helper asserts the exact type, complete
value-only stdout, empty stderr, and status zero. Observer/build logs cannot
substitute for child output; a failed build cannot reuse a previous executable.
Each observation has a fresh directory, removed on success or failure.

`native_prepare.py` builds the test-only observer once per prepared run. Its
generated manifest
uses the supplied exact checkout as a path dependency and seeds its lock from
that checkout. Offline Cargo metadata selects the supported Linux x86-64 GNU
platform; every selected package's name, version, source and checksum must
match the upstream lock, except the observer itself. Unused workspace/dev
packages may be omitted. The final observer build uses `--locked --offline`.
No third-party dependency is added by ash-doc. One temporary dependency cache
is shared by its native hosts; completed executables and generated projects
are removed after each observation, avoiding accumulation of large debug hosts.

Python 3.11 or later supplies the standard-library TOML reader for this lock
check. Native checks also require the supported Linux x86-64 GNU host and its
Rust/native linker toolchain. Ordinary lessons retain the interpreter route.
Buffer escape rejections remain on the actual CLI, with the pinned
`--root ffi=...` added. Their displayed commands use `"$ASH_LIBRARIES"` from the
root setup; the capture helper expands that variable to the verified checkout
without normalizing another path in the diagnostic.

Run the comparison and command controls with:

```sh
python3 -m unittest discover -s content/checks -p 'test_native_observe.py'
```

The real observer refusal controls additionally use `ASH_DOC_TEST_OBSERVER`,
`ASH_DOC_TEST_LIBRARIES`, `ASH_DOC_TEST_CACHE`, and `ASH_DOC_TEST_SCRATCH` to
select a prepared observer, the exact library directory, its build cache, and
scratch directory. Without those inputs the four real controls are skipped;
the thirteen canonical positive observations remain mandatory in their lessons.
The controls cover wrong type/value, unexpected stderr, child failure, failed
build, fresh-output refusal, source rejection, and unsupported target.

Rejection checks request `--message-format json`. Each lesson's
`checks/<entry>.diagnostic.json` records the expected diagnostic data, including
reason, responsibility, facts, label order, source paths, and byte ranges.
The comparison parses JSON and normalizes only the absolute checkout prefix;
it does not assert human wording. Compiler-owned virtual paths such as
`@builtin.cell` remain unchanged in fixtures and comparisons. Read changed
expectations against the source
and specification before accepting them. Never regenerate expectations merely
to make a failing check pass.

Human transcript checks supplement those semantic assertions. Each affected
lesson calls `ash_doc_check_human` in its own `checks/verify.sh` with its entry
and working directory. The helper reruns that entry with
`--message-format human --locale en`, requires status `1` and empty stdout,
and compares complete stderr with the marked `text` fence in its README.
The fence includes the command, so agreement also checks the invocation.
There are 72 active captures: fifteen Learn, twenty Cases, sixteen Libraries,
and 21 in Effects. Effects checks cover row contracts, exact handler selection,
continuation use, provider evidence, resource escape, cleanup completion and
context, hook qualification, and the final entry contract. Labels retain each
explanation's source boundary.

The shared [reading notes](../../README.md#read-a-diagnostic) document the
working-directory and path conventions. The pinned tool's
[format controls](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#diagnostic-formats-and-locales)
select English human output. Its `src/presentation.rs::write_human` emits plain
text without terminal styling, so no unsupported color flag is used. The
comparison rejects ANSI output and JSON fallback. It replaces only the
canonical absolute ash-doc prefix with `/path/to/ash-doc/`; source lines,
explanations, label order, repeated multiline labels, notes, and reason lines
remain intact. No separate expected-transcript files are needed.

Transcript agreement is evidence for this documentation edition, not a promise
that wording, layout, or localization is immutable Ash semantics. On a future
baseline change, inspect fresh output and its teaching explanation together;
retain the structured checks for the actual semantic boundary. Do not insert
captured answers into exercises that ask readers to discover a failure.

The opaque dictionary and iterator rejections preserve their source-access
boundaries. The ordering and library lessons reject missing implementation
evidence. Successful dictionary clients explicitly select `impl Order`.

The wrapper lesson also relies on the pinned compiler's focused allocation
test. Run it from its checkout. This tests the heap claim that source output
alone cannot prove:

```text
cargo test --locked --lib module_newtype_wrapper_allocates_no_constructor_cell
```

The test builds a validated wrap around an ordinary constructor and checks that
only the representation's constructor cell is allocated. Keep this evidence
separate from the lesson's source observations.

## FFI Base executable evidence

On 2026-10-17 all four family aggregates passed at
`354c76b391fe4af665cf6a03479a9874a57cb3e3`: Learn 13/56 canonical sources,
Libraries 8/43, Effects 12/71, and Cases 21/74. All 54 indexed lessons retain
244 sources and 60 complete English captures. The eight native positives
matched their checked result types and value-only host output, with status
zero and empty stderr. The escape rejection retains `type.resource-escape`;
its primary label now covers the body returning access and its related label
identifies acquisition. Callback mismatch output names `Bonus` rather than
an internal effect spelling; its semantic rejection is unchanged.

All 16 harness controls passed with the real observer configured, including
an intentionally wrong type for an otherwise matching native value. The pinned
wrapper allocation test also passed (one selected test). These observations
establish this edition's checked boundaries; they neither verify every possible
Ash program nor establish a native allocation guarantee.

The local-pricing Case passed its lesson verifier on 2026-10-18 at the same
exact FFI Base target, adding fourteen canonical sources and three complete
human captures. That addition brought the inventory to 55 lessons, 258 sources,
and 63 captures.

The immutable-world Case passed its lesson verifier on 2026-10-18 at the same
exact target, adding ten canonical sources and two complete human captures.
That addition brought the inventory to 56 lessons, 268 sources, and 65 captures.

The cancellable-journal Case passed its lesson verifier on 2026-10-18 at the
same exact target, adding eight canonical sources and one complete human
capture. That addition brought the inventory to 57 lessons, 276 sources,
and 66 captures.

The event-redaction Case passed its lesson verifier on 2026-10-18 at the
same exact target, adding eight canonical sources and two complete human
captures. That addition brought the inventory to 58 lessons, 284 sources,
and 68 captures.

The controlled-edits Case passed its lesson verifier on 2026-10-18 at the
same exact target, adding eleven canonical sources and two complete human
captures. That addition brought the inventory to 59 lessons, 295 sources,
and 70 captures.

The stable-sort Case passed its lesson verifier on 2026-10-18 at the
same exact target, adding eight canonical sources and one complete human
capture. That addition brought the inventory to 60 lessons, 303 sources,
and 71 captures.

The tagged-frame Case passed its lesson verifier on 2026-10-18 at the
same exact target, adding eight canonical sources and one complete human
capture. The active inventory now has 61 lessons, 311 sources, and 72 captures.
Unchanged lessons retain their migration evidence above.

## Review the rest

The [rendering guide](rendering.md#verify-the-affected-scope) gives separate
checks for local HTML, EPUB 3, a double-sided book PDF, and a one-sided A4 PDF.
The complete review book includes thirteen Learn, eight Libraries, twelve Effects,
and twenty-eight Cases lessons, in that order, plus four family introductions.
Retained book outputs cover 54 lessons, including the cleanup-reporting Case.
The local-pricing, immutable-world, cancellable-journal, event-redaction,
controlled-edits, stable-sort, and tagged-frame Cases await presentation
checks. The
default build retains the smaller specimen and its notation regressions.

Build the selected scope and requested formats through the guide, then run
`verify.py` and, for HTML or EPUB, `browser.mjs` on that generated project. Run
EPUBCheck only for selected EPUB output. A PDF-only review needs no browser.

For a shared rendering task that needs both book and specimen regressions,
the complete commands are:

```sh
python3 -m unittest discover -s rendering/checks -p 'test_*.py'
node --test --test-isolation=none rendering/checks/browser.test.mjs
python3 rendering/checks/verify.py .build/book
node rendering/checks/browser.mjs .build/book
python3 rendering/checks/verify.py
node rendering/checks/browser.mjs
java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar \
    .build/book/output/ash-doc-review.epub
java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar \
    .build/specimen/output/ash-doc-specimen.epub
```

The no-argument artifact and browser commands select `.build/specimen/`.
Each build retains its browser screenshots and structured observations under
`qa-browser/`. Checks derive coverage and order from the canonical family
indexes, compare source hashes, and retain complete chapter code and transcripts
in HTML and EPUB. Both PDFs check actual chapter order, paper size, fixed or
mirrored margins, and note placement. The specimen's full-width aside must
preserve its formatted paragraph and table, remain on one print page, clear
sidenotes and navigation, and reflow in narrow previews. Both builds retain the
search-tree layout regressions. These presentation checks supplement the
executable lesson checks above. The linked development reports retain upstream
notation and conversion failures separately.

Lint changed Markdown and, when Bash changes, check its syntax and run
ShellCheck. For a repository-wide verification task, use:

```sh
git ls-files -z '*.md' | xargs -0 markdownlint
git ls-files -z '*.sh' | xargs -0 -n1 bash -n
git ls-files -z '*.sh' | xargs -0 shellcheck -x -P SCRIPTDIR
```

Also check relative links and pinned specification anchors, source attribution,
and the accuracy of explanations. Finish with `git diff --check` and inspect
`git status --short`.

A green run establishes this baseline only. When the baseline changes, update
code, prose, and checks together, verify every active unit, and remove obsolete
plans, observations, and comparison harnesses.
