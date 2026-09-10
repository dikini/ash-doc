# Teach through complete human diagnostics

The user approved this bounded outcome and implementation. Target `diag-ash`
at exactly `9231b21228c5ccacbbee0cc0da60b380e5d2dc59`.

The reader needs to compare a rejection with the terminal, connect the words
and source labels to the program, and understand the demonstrated correction.
The pinned specification governs language claims; `docs/tools/ash.md`, the
renderer, and executions at that commit govern observations.

## Execution

1. Read every active `content/{learn,cases,libraries}/**/README.md`, project
   guidance and the writing skill. Preserve the five existing library edits.
   Identify observed failures separately from discovery exercises.
2. Run each demonstrated canonical rejection with explicit human output and
   English locale. Verify rendering controls and capture complete stderr,
   normalizing only the absolute checkout prefix. Keep sources unchanged.
3. Replace legacy/code-only observations with marked text fences beside exact
   commands. Explain the message's causal labels and correction in lesson prose.
4. Extend `content/checks/lib.sh` with a bounded human capture function and a
   standard-library fence comparison. Each affected `checks/verify.sh` names
   its own transcripts; retain every JSON expectation and rejection assertion.
   Update family setup, `AGENTS.md`, the writing skill and
   `docs/project/verification.md` narrowly.
5. Run all three `content/*/checks/verify.sh` suites against the exact clean
   checkout, Markdown lint, Bash syntax checks, ShellCheck, source/transcript
   agreement, relative-link checks and `git diff --check`. Read all changed
   files and review teaching continuity and exercise boundaries.
6. Update the roadmap, remove this completed plan, and integrate local changes.
   Do not publish, tag, push, or modify ash-lang.

Direct fences checked against executions keep the lesson readable and avoid
separate duplicate transcript fixtures. Separate fixture files would add a
second copy without serving another consumer. Deferring agreement would leave
this edition's examples vulnerable to drift. These checks prove this exact
edition's observations, not a language guarantee about wording or layout.
