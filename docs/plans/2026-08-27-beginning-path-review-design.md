# Beginning Path Review Design

## Reader question

Does the eleven-lesson beginning path work as one course, from the first
integer expression through a parameterized list transformation?

The observable boundary lies between eleven lessons that pass their local and
family checks and a connected reader experience in which each lesson relies
only on ideas established earlier.

## Decision

Review, revise, and close the beginning-path review increment through a
two-pass course audit. Establish the executable baseline first. Then read the
learning index and all lessons in order while tracing prerequisites,
vocabulary, prediction and explanation opportunities, exercises, assistant
prompts, and lesson handoffs.

Use the lesson text, canonical programs, and executable observations as the
evidence for changes. Correct concrete continuity and teaching problems with
the smallest edits that preserve the intended outcome. Change canonical
programs and checks only when an observable claim needs correction. Split or
reorder lessons only when local revisions cannot repair the reader journey.

This approach keeps the course-level question visible without adding a
permanent review format or new project machinery. Independent lesson audits
would miss cross-lesson dependencies. An external learner study could provide
additional usability evidence, but it requires participants and a research
process that this increment does not need.

## Authority and target

The review remains project-level work for the first edition. The edition
targets `modular-ash` at commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`.

The specification at that commit governs language claims. The pinned tool
guide, implementation, and tests govern commands, output, failures, and
diagnostics. The repository policy, learning-path record, and writing skill
govern course continuity and teaching form without defining Ash behavior.

## Review flow

1. Run the complete learning-family verifier against a clean checkout at the
   exact target before editing.
2. Read the learning index and lessons in order. For each lesson, record the
   ideas it assumes, the vocabulary it introduces, the prediction and
   explanation work it offers, the prerequisites of its exercise, the value
   of any assistant prompt, and the question handed to the next lesson.
3. Compare the resulting model with the intended beginning-path outcome: a
   learner can design, run, and explain a pure multi-file Ash program over data
   they define, including structural recursion and parametric reuse.
4. Revise evidence-backed gaps. Prefer local prose corrections. Change code
   and checks only with the observable boundary they support, and consider a
   split or reorder only after local correction proves insufficient.
5. Read every changed file, verify affected claims at the pinned sources, and
   run the complete course checks.
6. Record the completed review in the roadmap, select the next separately
   justified outcome, and remove the temporary design and execution plans.

Git history retains the review design and execution record after those plans
leave the current tree.

## Discovery routing

- Correct an ash-doc error against the pinned specification or tool contract.
- Minimize specified behavior that fails as an Ash regression candidate.
- Return unspecified semantics to Ash design or proposal work.
- Retain library, tooling, diagnostic, performance, and application pressure
  as evidence without presenting it as a language obligation.

The review does not fill gaps from current `ash-lang/main`, historical Ash, or
implementation accidents.

## Verification

- Run all eleven lesson verifiers through
  `content/learn/checks/verify.sh` against the exact clean Ash target.
- Check Bash syntax for the family helper and lesson verifiers when any check
  or canonical program changes.
- Check Markdown structure, spelling, and every changed relative link.
- Confirm each displayed executable block agrees with canonical source.
- Verify every changed language or tool claim against its governing pinned
  source.
- Read every changed file as source, run `git diff --check`, and inspect
  `git status --short`.

## Exclusions

This increment introduces no new Ash topic, renderer, manifest, registry,
shared harness, dependency, CI service, publication mechanism, or permanent
review-report format. It does not select an external learner-study process.
Later project work must justify those choices from its own concrete need.
