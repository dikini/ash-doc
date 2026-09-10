# Verify the documentation

Every active program, language claim, and tool observation targets Ash
`diag-ash`, commit `9231b21228c5ccacbbee0cc0da60b380e5d2dc59`.

## Run the content checks

Use a clean Ash checkout at that exact commit. From ash-doc, run:

```text
bash content/learn/checks/verify.sh /path/to/diag-ash
bash content/cases/checks/verify.sh /path/to/diag-ash
bash content/libraries/checks/verify.sh /path/to/diag-ash
```

The shared Bash helper checks the compiler pin, builds the executable with
locked dependencies, and runs the lesson-local verifiers. Verification needs
Bash, Cargo with the pinned toolchain, ordinary Unix text tools, and Python 3
for JSON comparison. No third-party Python packages are required.

The three aggregates cover eleven Learn lessons / 43 sources, twelve Cases /
53 sources, and five library lessons / 17 sources. They check successful
values, types, stdout, stderr, and exit status; agreement between displayed
and canonical code; and the source properties each Case teaches.

Rejection checks request `--message-format json`. Each lesson's
`checks/<entry>.diagnostic.json` records the expected diagnostic data, including
reason, responsibility, facts, label order, source paths, and byte ranges.
The comparison parses JSON and normalizes only the absolute checkout prefix;
it does not assert human wording. Read changed expectations against the source
and specification before accepting them. Never regenerate expectations merely
to make a failing check pass.

The opaque dictionary and iterator rejections preserve their source-access
boundaries. The ordering and library lessons reject missing implementation
evidence. Successful dictionary clients explicitly select `impl Order`.

## Review the rest

Run shell syntax checks and ShellCheck on changed verifiers. Check Markdown
structure, relative links and pinned specification anchors, source attribution,
and the accuracy of explanations. Finish with `git diff --check` and inspect
`git status --short`.

A green run establishes this baseline only. When the baseline changes, update
code, prose, and checks together, verify every active unit, and remove obsolete
plans, observations, and comparison harnesses.
