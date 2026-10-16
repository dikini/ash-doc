# Verify the documentation

Every active program, language claim, and tool observation targets Ash
`diag-ash`, commit `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

## Select the affected checks

Follow the [task boundary](workflow.md#bound-the-task): choose checks from the
action, scope, and changed inputs. For a lesson edit affecting programs,
observations, or executable promises, run that lesson's local verifier:

```sh
bash content/cases/resuming-tree-traversal/checks/verify.sh /path/to/diag-ash
```

For a part task, run its affected lesson checks; use the family aggregate when
the whole family's executable evidence needs verification. Reuse retained
exact-pin evidence for unchanged inputs during prose or layout review. Do not
rerun every program because one caption or print layout changed.

## Run the content checks

Use a clean Ash checkout at that exact commit. For complete-edition verification
or a baseline migration, run all four family aggregates from ash-doc:

```text
bash content/learn/checks/verify.sh /path/to/diag-ash
bash content/cases/checks/verify.sh /path/to/diag-ash
bash content/libraries/checks/verify.sh /path/to/diag-ash
bash content/effects/checks/verify.sh /path/to/diag-ash
```

The shared Bash helper checks the compiler pin, builds the executable with
locked dependencies, and runs the lesson-local verifiers. Verification needs
Bash, Cargo with the pinned toolchain, ordinary Unix text tools, and Python 3
for JSON comparison. No third-party Python packages are required.

The four aggregates cover thirteen Learn lessons / 57 sources, twenty-one
Cases / 74 sources, eight library lessons / 43 sources, and twelve effects
lessons / 71 sources. They check successful values, types, stdout, stderr, and
exit status; agreement between displayed and canonical code; and the source
properties each Case teaches.

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
There are 61 active captures: sixteen Learn, eight Cases, sixteen Libraries,
and 21 in Effects. Effects checks cover row contracts, exact handler selection,
continuation use, provider evidence, resource escape, cleanup completion and
context, hook qualification, and the final entry contract. Labels retain each
explanation's source boundary.

The shared [reading notes](../../README.md#read-a-diagnostic) document the
working-directory and path conventions. The pinned tool's
[format controls](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/tools/ash.md#diagnostic-formats-and-locales)
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

## Review the rest

The [rendering guide](rendering.md#verify-the-affected-scope) gives separate
checks for local HTML, EPUB 3, a double-sided book PDF, and a one-sided A4 PDF.
The complete review book includes thirteen Learn, eight Libraries, twelve Effects,
and twenty-one Cases lessons, in that order, plus four family introductions.
Retained book outputs cover the earlier 53-lesson inventory; the added
cleanup-reporting Case awaits final rendering integration. The default build
retains the smaller specimen and its notation regressions.

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
