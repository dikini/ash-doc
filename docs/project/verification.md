# Verify the documentation

Every active program, language claim, and tool observation targets Ash
`diag-ash`, commit `40c964c69c007ba81ec6bdbac34e31ad24fec9c7`.

## Run the content checks

Use a clean Ash checkout at that exact commit. From ash-doc, run:

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

The four aggregates cover eleven Learn lessons / 43 sources, twelve Cases /
53 sources, five library lessons / 17 sources, and three effects lessons / 14
sources. They check successful values, types, stdout, stderr, and exit status;
agreement between displayed
and canonical code; and the source properties each Case teaches.

Rejection checks request `--message-format json`. Each lesson's
`checks/<entry>.diagnostic.json` records the expected diagnostic data, including
reason, responsibility, facts, label order, source paths, and byte ranges.
The comparison parses JSON and normalizes only the absolute checkout prefix;
it does not assert human wording. Read changed expectations against the source
and specification before accepting them. Never regenerate expectations merely
to make a failing check pass.

Human transcript checks supplement those semantic assertions. Each affected
lesson calls `ash_doc_check_human` in its own `checks/verify.sh` with its entry
and working directory. The helper reruns that entry with
`--message-format human --locale en`, requires status `1` and empty stdout,
and compares complete stderr with the marked `text` fence in its README.
The fence includes the command, so agreement also checks the invocation.
There are 28 captures: eleven Learn, seven Cases, five Libraries, and five
in Effects. Effects checks cover an unhandled entry, an omitted caller effect,
an effectful callback supplied to a pure parameter, an unknown row union, and
a callback that violates a row-tail exclusion. Labels retain each
explanation's source boundary.

The shared [reading notes](../../README.md#read-a-diagnostic) document the
working-directory and path conventions. The pinned tool's
[format controls](https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/docs/tools/ash.md#diagnostic-formats-and-locales)
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

## Review the rest

From the repository root, run Markdown lint and shell checks:

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
