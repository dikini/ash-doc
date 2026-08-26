# Beginning Lessons Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Complete and verify lessons 2 through 11 of the beginning Ash
learning path.

**Architecture:** Each lesson owns its prose, canonical sources, and local
verifier. A small family-level Bash helper removes repeated source-agreement and
CLI plumbing after lesson 2 demonstrates the shared need. Project indexes and
planning states advance only after the applicable complete suite passes.

**Tech Stack:** Markdown, Ash at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`, Bash, Git, Cargo, and
`markdownlint-cli2`.

---

## Commit rule

Every commit in this worktree uses:

```bash
git -c commit.gpgsign=false commit --no-gpg-sign -m "<message>"
```

Do not merge or push the branch.

## Tasks

### Task 1: Share repeated learning checks

Create `content/learn/checks/lib.sh` and `content/learn/checks/verify.sh`.
First change lesson 1's verifier to call the intended missing helper and run it
to observe failure. Then implement the helper and migrate lesson 1 to green.

The helper must validate the exact clean Ash checkout, build or reuse one
`ash` binary, compare marked blocks with canonical sources, check exact accepted
output, and check rejected status, reason, and causal source evidence. The
family verifier discovers lesson-local verifiers and builds Ash once.

Verify with `bash -n` and the migrated lesson 1 check. Commit as
`test: share learning lesson verification`.

### Task 2: Teach source modules

Create `content/learn/using-another-source-file/` with:

- an accepted `main.ash` and `arithmetic.ash` producing `42 : Int` through a
  complete relative import, public function, alias, and qualified call;
- a private helper used inside `arithmetic.ash`; and
- a rejected program that calls the private helper and reports
  `resolve.unavailable-export`.

Write a narrative that starts from the size of the first lesson's one-file
program, explains the two files through the running example, and ends by asking
how one function can receive more than one input. Add the module-splitting
exercise and one assistant prompt for import diagnosis.

Run the local and family checks, then update the learning index, beginning path,
and roadmap. Commit as `docs: teach source modules`.

### Task 3: Teach functions with several inputs

Create `content/learn/using-more-than-one-input/` with canonical programs for:

- `add 20 22`, producing `42 : Int`;
- `add 20`, producing `<function> : Int -> Int`;
- a named use of the partial call, producing `42 : Int`; and
- `add 20 true`, rejected with `type.argument`.

Explain right-associated arrows and left-associated calls through evaluation,
without introducing tuple inputs. End by asking how a program chooses among
results. Run all checks and advance indexes and planning state. Commit as
`docs: teach functions with several inputs`.

Record the three-lesson pilot review in `docs/project/workflow.md`: retain the
unit-local layout and shared Bash helper; defer renderer, manifest, CI, and
publication choices. Commit as `docs: review three-lesson workflow`.

### Task 4: Teach Boolean choice

Create `content/learn/choosing-a-result/` with integer equality, an exhaustive
Boolean match, a calculated choice, and a missing arm rejected with
`coverage.non-exhaustive`. Include one assistant prompt about the uncovered
Boolean value. End with the need to name steps inside a calculation.

Run all checks, advance indexes and state, and commit as
`docs: teach Boolean choice`.

### Task 5: Teach intermediate bindings

Create `content/learn/naming-intermediate-values/` with a one-binding block, a
sequential two-binding calculation producing `42 : Int`, and a forward
reference rejected with `resolve.unknown-name`. Explain the final expression and
left-to-right scope. End with the need to move several related values together.

Run all checks, advance indexes and state, and commit as
`docs: teach intermediate bindings`.

### Task 6: Teach tuples

Create `content/learn/values-travel-together/` with a heterogeneous tuple
observation, a pair passed as one function input, local tuple destructuring,
and a triple rejected where a pair is required with `type.argument`. Contrast
one tuple input with the chained inputs from lesson 3. End with the need to name
problem-specific forms of data.

Run all checks, advance indexes and state, and commit as `docs: teach tuples`.

### Task 7: Teach nominal data

Create `content/learn/defining-data/` with a nullary `Signal`, a
`Result = Missing | Found(Int)`, and two same-shaped nominal types whose values
cannot be exchanged. The rejection uses `type.argument`. Teach constructors as
the ways to build values without yet inspecting them. End with the need to
handle each form.

Run all checks, advance indexes and state, and commit as
`docs: teach nominal data`.

### Task 8: Teach constructor patterns and coverage

Create `content/learn/handling-data-forms/` with one complete explicit match,
the equivalent equational function, and a missing constructor rejected with
`coverage.non-exhaustive`. Explain payload binding and complete coverage through
`Missing` and `Found`. End with the question raised by data that contains more
of itself.

Run all checks, advance indexes and state, and commit as
`docs: teach data forms`.

### Task 9: Teach structural recursion

Create `content/learn/following-recursive-data/` with `IntList`, a finite list
observation, recursive `sum` producing `42 : Int`, and a missing `Empty` case
rejected with `coverage.non-exhaustive`. Derive the function from the data
definition and include one assistant prompt for tracing the recursive calls.
Do not introduce local recursive initialization.

Run all checks, advance indexes and state, and commit as
`docs: teach structural recursion`.

### Task 10: Teach functions as values

Create `content/learn/functions-as-values/` with a named function passed to
`apply_twice`, a contextually typed anonymous function, `make_adder` returning a
capturing function, and a non-function argument rejected with `type.argument`.
End with the repeated shape visible in functions and data that do not inspect
one particular element type.

Run all checks, advance indexes and state, and commit as
`docs: teach functions as values`.

### Task 11: Teach parametric polymorphism

Create `content/learn/definitions-for-many-types/` with:

- `identity : A -> A` used at `Int` and `Bool`;
- `Box<A>` constructed at two element types;
- a multi-file public `List<A>` and recursive `map`, imported by `main.ash` and
  producing `More(42, Empty) : List<Int>`; and
- an unsaturated `List` rejected with `resolve.type-argument-count`.

Explain implicit rank-1 parameters through the examples. Include one assistant
prompt for tracing `A` and `B`. Do not mention interfaces or ad-hoc
polymorphism in the lesson. End by gathering the complete beginner model.

Run all checks, mark every beginning entry verified, update the learning index,
and replace the roadmap increment with a review of the complete beginner path.
Commit as `docs: teach parametric definitions`.

### Task 12: Close and audit the beginning slice

Read every lesson aloud and review narrative continuity, vocabulary, exercises,
assistant prompts, and transitions. Check every new relative link. Remove this
plan and its design record, and remove their active roadmap links.

Run:

```bash
content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/learn/checks/*.sh content/learn/*/checks/verify.sh
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
git diff --check docs/beginning-learning-path...HEAD
git status --short --branch
git log --format='%h %G? %s' docs/beginning-learning-path..HEAD
```

Require 11 indexed lessons, 11 verified path entries, no remaining provisional
or next beginner entry, no temporary plan, a clean branch, and `N` for every
commit signature. Commit plan removal as `docs: close beginning lesson plans`.
