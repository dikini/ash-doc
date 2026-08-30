# Implementing a Persistent FIFO Frontier Implementation Plan

<!-- markdownlint-disable MD013 -->
> **For Codex:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.
<!-- markdownlint-enable MD013 -->

Status: approved on 2026-08-31 after independent specification, workflow, and
adversarial plan-quality review; amended before lesson prose after independent
review of the verifier's exact public-operation assertion; corrected after
whole-branch review to require the linear history to start from `empty`; and
corrected after integration review to bind branch checks and cleanup to the
repaired history

**Goal:** Teach and verify an eager persistent two-list queue whose logical
order is the front followed by the reversed rear, including the exact boundary
between start-from-`empty` linear-history amortization and repeated reversal
from retained states.

**Architecture:** Add one self-contained Cases chapter with an opaque
`Queue<A>`, transparent local `List<A>` and `Option<A>` support types, and
exactly `empty`, `enqueue`, and `dequeue` as queue operations. One accepted
entry exposes empty behavior, a pre-transfer state, one eager transfer, and
FIFO order. A second accepted entry calls `dequeue` twice from the same
pre-transfer value. A lesson-local Bash verifier owns the exact source set,
semantic relationships, outputs, hashes, and transclusion.

**Tech Stack:** Markdown, Bash, ShellCheck, pinned Modular Ash at
`dca16039923475c48025c5f17beadeb6bcb6a4bf`, Git worktrees, and the existing
`content/checks/lib.sh` helpers. Add no dependency, fixture, manifest,
renderer, shared queue library, host-language harness, CI service, or
publication mechanism.

---

## Fixed context

Work only in:

```text
/home/dikini/Projects/ash-doc/.worktrees/implementing-persistent-fifo-frontier
```

Feature branch:

```text
implementing-persistent-fifo-frontier
```

Base `main` commit:

```text
1689c2633364299d91c49375a95b3eb6e7e69d1d
```

Approved design commit:

```text
14a7e118f1b66230582ccb04444a5585b52d47f7
```

Clean pinned Ash checkout:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Exact Ash commit:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

Immutable ash-doc tag commit:

```text
e963a1597176f86003926eef827498db2a661b75
```

The exact-pin prototype remains temporary evidence while Case 11 is active:

```text
/tmp/ash-doc-case11-prototype.ELVoxI
```

Its three sources and verifier have these fixed hashes:

```text
6c84f6a799cf322f5569d29533c2dc3387be150a2eaac474cc187c73d7464439  verify.sh
9db0dde1fd8776556ea4f4bad51aacb09fd00a7ed769cf8e457ea20795cfe7bd  queues.ash
38edc257a6e1859b96b40f523ac57199eff14aaa6bccf13176289e4b18dcfc61  01-sequence.ash
6a0981eb6dd63c2cc540983a69bc5e058db0018f670645610d518e8e6ab99d51  02-retained-state.ash
```

The verifier prototype has passed Bash syntax and a complete disposable-tree
GREEN run. Its two intended RED states are fixed:

- before sources exist: `verify: missing canonical source: src/queues.ash`;
- after sources exist but before prose: `verify: missing unit README.md`.

The sources produce the two exact Appendix B observations with status `0` and
empty standard error at the exact pin.

The complete case adds exactly three canonical Case sources. Before reader
navigation exists, the aggregate verifier must report:

```text
11 Learn lessons
11 Cases
50 canonical Case sources
```

Root and Cases navigation continue to report ten verified Cases until closure.
The complete current Case 12 provisional block retains SHA-256:

```text
0ba0cd849dcb728485ef5e5b219fca125a314a37168c18fa4b814c9c0a7c6a22
```

Its question-and-scope payload, excluding the provisional heading, retains
SHA-256:

```text
0560d3f5d09b389c91f1c84fa42b0ce10ce4d19eb77a2d1c4de2296694f79916
```

Retain these focused pinned tests:

<!-- markdownlint-disable MD013 -->
```bash
(
    cd /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
    cargo test --locked --test data_and_adts constructor_tuple_payloads_enter_elements_strictly_left_to_right -- --exact
    cargo test --locked --test module_visibility opaque_constructors_remain_available_inside_their_defining_module -- --exact
    cargo test --locked --test module_elaboration_nominals imported_transparent_parameterized_constructor_checks_at_its_type_argument -- --exact
    cargo test --locked --test spec_examples static_semantics_rank_one_polymorphism_is_executable -- --exact
    cargo test --locked --test spec_examples tool_rank_one_example_has_exact_cli_observation -- --exact
)
```
<!-- markdownlint-enable MD013 -->

## Approval and commit precondition

Do not begin Task 1 from a draft copy. Independent specification and
plan-quality reviewers must approve this complete plan. Then change its status
to approved, change the roadmap link from draft to active approved plan, rerun
Markdownlint, relative-link, Case 12 hash, tag, pin, diff, and status checks,
and commit only the plan and roadmap update unsigned:

```bash
set -euo pipefail
git add -- \
    docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md \
    docs/project/roadmap.md
git diff --cached --check
diff -u \
    <(printf '%s\n' \
        docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md \
        docs/project/roadmap.md | LC_ALL=C sort) \
    <(git diff --cached --name-only | LC_ALL=C sort)
git diff --cached
git commit --no-gpg-sign -m "docs: plan persistent FIFO frontier"
```

The implementation executor records that commit as the second commit after
the fixed base; the approved design commit is first. Tasks 1 through 8 must not
edit that committed plan except for its intentional deletion in Task 7.

## Task 1: Add the failing lesson-local verifier

**Files:**

- Create:
  `content/cases/implementing-persistent-fifo-frontier/checks/verify.sh`

### Step 1: Create only the evidence directories

Run:

```bash
mkdir -p \
    content/cases/implementing-persistent-fifo-frontier/checks \
    content/cases/implementing-persistent-fifo-frontier/src
```

Do not create `README.md` or an Ash source yet.

### Step 2: Add the exact tested verifier

Use `apply_patch` to add Appendix C's complete `verify.sh` byte-for-byte. Do
not copy it from `/tmp` with a filesystem command. Make it executable:

```bash
chmod +x \
    content/cases/implementing-persistent-fifo-frontier/checks/verify.sh
```

Confirm its hash:

```bash
sha256sum \
    content/cases/implementing-persistent-fifo-frontier/checks/verify.sh
```

Require:

```text
6c84f6a799cf322f5569d29533c2dc3387be150a2eaac474cc187c73d7464439
```

The verifier places source and client semantic assertions before hashes and
execution. It owns:

- exactly `queues.ash`, `01-sequence.ash`, and
  `02-retained-state.ash`;
- transparent `Option<A>` and `List<A>` support plus one opaque
  `Queue<A>` over front and rear lists;
- the exact `empty`, `enqueue`, and `dequeue` signatures;
- one rear `More` construction in `enqueue`;
- both `reverse_into` equations, terminal accumulator reuse, and one
  constructor per entered node;
- empty dequeue before the general empty-front equation;
- ordinary front removal with unchanged `rest` and `rear`;
- direct passage of the complete `rear` to `reverse_into`, reset to `End`,
  and recursive dequeue of the transferred front;
- empty observation, enqueue order, pre-transfer state, returned first value,
  post-transfer state, and drain only through returned successors;
- exactly two retained-state calls from `ready`;
- exact source hashes, outputs, channels, statuses, displayed-source
  agreement, and one displayed copy of each output.

### Step 3: Run RED before sources

Run Appendix D's RED capture with expected first standard-error line:

```bash
bash content/cases/implementing-persistent-fifo-frontier/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Require status `1`, empty standard output, and exact first standard-error
line:

```text
verify: missing canonical source: src/queues.ash
```

If the failure is Bash syntax, tool setup, or another assertion, correct only
the verifier until this is the first failure.

## Task 2: Add the three exact canonical sources

**Files:**

- Create:
  `content/cases/implementing-persistent-fifo-frontier/src/queues.ash`
- Create:
  `content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash`
- Create:
  `content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash`

### Step 1: Add Appendix A exactly

Use `apply_patch` to add all three Appendix A files byte-for-byte. Do not copy
the temporary prototype with a filesystem command.

The queue module is a dependency and intentionally has no `main`. The two
entry modules import it and are independently executable.

### Step 2: Confirm the fixed hashes

Run:

```bash
sha256sum \
    content/cases/implementing-persistent-fifo-frontier/src/*.ash
```

Require the three source hashes from the fixed context.

### Step 3: Run both exact observations directly

Run Appendix D's direct-observation command. For each entry, require:

- status `0`;
- exact Appendix B standard output including one trailing newline; and
- empty standard error.

The sequence must expose `Queue(End, More(3, More(2, More(1, End)))` before
the transfer and `Queue(More(2, More(3, End)), End)` afterward. The retained
entry must display the same `Some(1, ...)` result twice.

### Step 4: Run RED before prose

Run Appendix D's RED capture again with expected first standard-error line.
All semantic, hash, and executable assertions must pass before the exact first
failure:

```text
verify: missing unit README.md
```

Require status `1` and empty standard output.

## Task 3: Write the complete chapter and reach GREEN

**Files:**

- Create:
  `content/cases/implementing-persistent-fifo-frontier/README.md`

### Step 1: Follow the approved teaching arc

Use `apply_patch`. Begin from Case 10's LIFO/FIFO transition, not project
administration. Teach in this order:

1. recall why one forward-list enqueue must append and rebuild its prefix;
2. define logical order as `front` followed by `reverse(rear)`;
3. state explicitly that this selected variant has no nonempty-front invariant;
4. derive `empty` and rear-prepending `enqueue` from the relationship;
5. derive the accumulator invariant for `reverse_into`;
6. derive the three ordered `dequeue` equations;
7. predict `None`, the `3, 2, 1` rear, returned `1`, the `2, 3`
   front, and the FIFO drain before running the sequence;
8. explain that the one transfer is eager and complete before return;
9. derive the exact one-operation and start-from-`empty` linear-history
   list-node counts;
10. retain `ready`, predict two repeated transfers, and run the branching
    observation;
11. state persistence, finite-spine, cycle, payload, structural-observation,
    source-reuse, and runtime exclusions; and
12. end by asking how stack and queue frontiers alter graph search.

Before each command, give the reader a causal model and prediction. Explain the
complete output after it appears. Do not render target administration, source
inventories, hashes, mutation records, project status, or a governing-source
list in the chapter.

Retain each of these exact, visible sentences once so the verifier can test
the lesson's promised semantic and cost boundaries independently of source
hashes:

<!-- markdownlint-disable MD013 -->
```text
`Queue(front, rear)` denotes `front ++ reverse(rear)`.
The front may be empty while the rear is nonempty.
The transfer is eager and complete before `dequeue` returns.
One list-node unit is one selected or constructed `More`.
`reverse_into` runs `m + 1` times, and the transfer costs `2m + 1` list-node units.
One linear successor history that starts from `empty` costs at most `3e + d` list-node units.
Retained branching repeats the transfer outside that linear-history bound.
The metric excludes elapsed time, machine instructions, and host-stack behavior.
It also excludes heap bytes, allocation count, pointer identity, physical sharing,
garbage collection, and compiler optimization.
```
<!-- markdownlint-enable MD013 -->

### Step 2: Transclude every source exactly

Include exactly three marked `ash` blocks:

```text
<!-- source: src/queues.ash -->
<!-- source: src/01-sequence.ash -->
<!-- source: src/02-retained-state.ash -->
```

Each displayed block must agree byte-for-byte with its canonical source.
Include each Appendix B output exactly once in a `text` fence.

### Step 3: Derive the complete representation argument

The prose must establish:

- `Queue(front, rear)` denotes `front ++ reverse(rear)`;
- every finite front/rear pair has a meaning, including empty front and
  nonempty rear;
- `More(value, rear)` makes `value` last after reversal;
- ordinary dequeue returns the first front element and preserves the remaining
  logical order;
- transfer reverses the complete rear, clears it, and then removes the oldest
  element; and
- opacity controls client constructor access but neither proves those
  equations nor hides structural output.

Attach every Ash claim to the applicable pinned specification section. Credit
the selected paired-list tradition through the permanent research record
without adapting its prose, figures, code, or proof presentation.

### Step 4: Derive the complete work account

Use the named metric from the design: one list-node unit for a selected or
constructed `More`.

Derive:

- enqueue: one rear `More` construction;
- ordinary successful dequeue: one front `More` selection and no list-node
  construction;
- transfer of rear length `m > 0`: `m + 1` `reverse_into` applications,
  `m` rear selections, `m` new front constructions, then one front
  selection, for `2m + 1` list-node units;
- one eager dequeue can therefore be linear in rear length;
- across a finite linear history that starts from `empty`, with `e` enqueues
  and `d` successful dequeues, each enqueued node has one rear construction,
  at most one transfer selection and corresponding front construction, and at
  most one successful front removal;
- total list-node work is at most `3e + d`, giving amortized constant
  list-node work per operation only on that successor chain; and
- two or `b` calls from one retained pre-transfer queue repeat the same
  transfer two or `b` times and lie outside that bound.

Keep Queue, `Some`, and tuple constructions distinct from the named list-node
metric. State that an empty dequeue performs no `More` work. Exclude elapsed
time, machine instructions, host-stack behavior, heap bytes, allocation count,
pointer identity, physical sharing, garbage collection, and compiler
optimization.

### Step 5: Add practice and transition

Practice asks readers to:

- draw front and rear lists for a mixed sequence;
- predict when the rear transfers;
- count `2m + 1` units for a fixed `m`;
- derive `3e + d` for one linear chain that starts from `empty`; and
- explain why three calls from one retained pre-transfer state count the
  reversal three times.

The final transition asks how a LIFO list stack and this FIFO queue change one
graph-search algorithm. It introduces no Case 12 source or claims.

### Step 6: Run GREEN

Run:

```bash
bash content/cases/implementing-persistent-fifo-frontier/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Require:

```text
Verified 3 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

## Task 4: Prove verifier mutation sensitivity

**Files:**

- Test only:
  `content/cases/implementing-persistent-fifo-frontier/checks/verify.sh`
- Mutate disposable copies only:
  the three canonical sources and `README.md`

### Step 1: Build one disposable content tree

Create a temporary directory with:

```bash
mutation_root=$(mktemp -d /tmp/ash-doc-case11-mutations.XXXXXX)
```

Copy
`content/checks/lib.sh` and the complete Case 11 directory into the matching
temporary `content/` paths. Point each mutation run at the clean pinned Ash
checkout. Do not edit a tracked file.

Record:

- temporary root;
- verifier SHA-256;
- source pre-mutation hashes;
- README pre-mutation hash; and
- exact Ash pin.

### Step 2: Run semantic mutants

For each row below:

1. restore all six disposable files from the unchanged tracked feature files;
2. apply only the named textual mutation;
3. run the disposable verifier;
4. for Q, S, and R rows, require nonzero status and the named source/client
   assertion before any hash or Ash execution failure; for P rows, require the
   named README assertion while all source hashes and observations remain
   unchanged;
5. restore immediately; and
6. run GREEN after each related group.

<!-- markdownlint-disable MD013 -->
| ID | Disposable mutation | Required caught relationship |
| --- | --- | --- |
| Q01 | make `Queue` transparent | opaque representation |
| Q02 | add a third list field to the queue constructor | exact two-field layout |
| Q03 | change `empty` to a nonempty list | empty representation |
| Q04 | enqueue as `Queue(More(value, rear), front)` | front/rear positions |
| Q05 | add recursive append and use it instead of rear-prepend | constant source-level enqueue work |
| Q06 | omit reverse's terminal equation | total finite reversal |
| Q07 | construct from `rest` instead of `first` | entered-node preservation |
| Q08 | recurse without constructing the new `More` | one node per reverse step |
| Q09 | move general empty-front before empty/empty | empty clause ordering |
| Q10 | return `None` from the nonempty-front case | ordinary dequeue |
| Q11 | swap `rest` and `rear` in the successor | state preservation |
| Q12 | pass `End`, the empty front, rather than `rear` to reverse | complete transfer input |
| Q13 | retain `rear` rather than reset to `End` | transfer clearing |
| Q14 | bypass reversal with `let front = rear` | return oldest, not newest |
| Q15 | destructure and reconstruct rear before reverse | exact `2m + 1` transfer work |
| Q16 | rebuild `front` twice during enqueue | one list-node unit per enqueue |
| Q17 | rebuild `rest` twice during ordinary dequeue | no ordinary-dequeue construction |
| Q18 | append a public queue operation | exact three-operation public API |
| S01 | remove the empty dequeue binding | empty observation |
| S02 | change the enqueue order | one-two-three order |
| S03 | hide `ready` in the result | pre-transfer state |
| S04 | hide `later` in the result | post-transfer state |
| S05 | add a client reverse and return reversed `drain later` | FIFO drain order |
| S06 | drain `ready` instead of `later` | returned-successor chain |
| R01 | make the second call from the first call's successor | same-state replay |
| R02 | remove one retained call | exactly two retained futures |
| P01 | reverse the representation equation in prose | front-plus-reversed-rear meaning |
| P02 | claim the front must be nonempty | absence of that invariant |
| P03 | remove the eager-before-return sentence | eager transfer |
| P04 | change `m + 1` or `2m + 1` | exact transfer work |
| P05 | remove the `empty` start or change `3e + d` or linear-history wording | amortized scope |
| P06 | claim retained branching shares the transfer | repeated work outside the bound |
| P07 | remove one runtime-exclusion sentence | named metric exclusions |
| P08 | move one required sentence into an HTML comment | visible teaching prose |
<!-- markdownlint-enable MD013 -->

The exact source hashes remain later defense, not the intended first reason.

### Step 3: Run rendered-evidence mutants

On fresh disposable copies, require the verifier to reject:

- E01: one removed source marker;
- E02, E03, and E04: one changed line inside each of the three displayed
  `ash` blocks;
- E05: one extra unmarked `ash` block;
- E06: a changed sequence output;
- E07: a changed retained-state output; and
- E08: one duplicate exact output line.

Restore after every mutant and run GREEN after the group.

### Step 4: Retain the mutation audit until local merge

Write one temporary log under:

```text
/tmp/ash-doc-case11-mutation-log.XXXXXX
```

The log records every ID, nonzero status, first verifier failure, restoration,
group GREEN result, hashes, and pin. Confirm the feature worktree remains
unchanged apart from intended Case 11 files. Retain the log only through branch
review and merged-main verification; then delete that exact temporary file.

## Task 5: Review and commit the complete content

**Files:**

- Review:
  `content/cases/implementing-persistent-fifo-frontier/README.md`
- Review:
  `content/cases/implementing-persistent-fifo-frontier/checks/verify.sh`
- Review:
  all three `src/*.ash`
- Do not yet modify root navigation, Cases navigation, or the durable roadmap
  summary.

### Step 1: Run complete content verification

Run Appendix D's Markdown, relative-link, script, local/Learn/Cases, count,
Case 12, tag, pin, diff, and status commands. At this pre-navigation boundary,
require the local verifier to pass while root and Cases navigation still list
ten Cases. Also run:

<!-- markdownlint-disable MD013 -->
```bash
mapfile -d '' markdown_files < <(rg --files -0 -g '*.md')
markdownlint-cli2 "${markdown_files[@]}"
bash -n content/cases/implementing-persistent-fifo-frontier/checks/verify.sh
shellcheck -x content/cases/implementing-persistent-fifo-frontier/checks/verify.sh
bash content/cases/implementing-persistent-fifo-frontier/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/learn/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
test "$(find content/cases -type f -path '*/src/*.ash' | wc -l)" -eq 50
git diff --check
git status --short
```
<!-- markdownlint-enable MD013 -->

Run `typos` only if installed; record it as unavailable rather than adding a
dependency.

Require aggregate counts:

```text
11 Learn lessons
11 Cases
50 canonical Case sources
```

Require unchanged ten-case reader navigation and unchanged Case 12 hash.

### Step 2: Run focused pinned tests

Run the five fixed-context tests exactly. Each must pass. Confirm both the Ash
checkout and feature worktree remain clean except the intended content.

### Step 3: Run sequential content reviews

First request an independent specification review of:

- exact API, representation relationship, clause ordering, and eager behavior;
- both values, types, outputs, channels, and statuses;
- `2m + 1` and start-from-`empty` `3e + d` derivations;
- persistent branching, finite/cycle/payload, opacity, and runtime boundaries;
- source/adaptation classification; and
- verifier mutation evidence.

Resolve every finding and rerun verification.

Then request an independent instructional review of:

- continuity from Case 10;
- model/prediction before commands and explanation after outputs;
- smallest sufficient representation derivation;
- cost clarity and the start-from-`empty` linear-history caveat;
- practice quality and Case 12 transition;
- rendered-source agreement and attribution; and
- absence of project administration from lesson prose.

Resolve every finding and rerun verification. Reviews must be sequential so
the second sees specification-corrected prose.

### Step 4: Commit only the complete content boundary

Read every content file fully. Stage only the Case 11 directory. Run cached
diff checks, inspect the staged diff, and commit unsigned:

<!-- markdownlint-disable MD013 -->
```bash
set -euo pipefail
git add -- content/cases/implementing-persistent-fifo-frontier
git diff --cached --check
diff -u <(printf '%s\n' \
    content/cases/implementing-persistent-fifo-frontier/README.md \
    content/cases/implementing-persistent-fifo-frontier/checks/verify.sh \
    content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash \
    content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash \
    content/cases/implementing-persistent-fifo-frontier/src/queues.ash) \
    <(git diff --cached --name-only | LC_ALL=C sort)
git diff --cached
git commit --no-gpg-sign -m "docs: teach persistent FIFO frontier"
```
<!-- markdownlint-enable MD013 -->

Do not push.

## Task 6: Draft and review closure while plans remain active

**Files:**

- Modify: `README.md`
- Modify: `content/cases/README.md`
- Modify: `docs/project/roadmap.md`
- Retain both Case 11 temporary plans during review.

### Step 1: Update root navigation

Change ten verified Cases to eleven and add Case 11 after Case 10. Summarize:

- front plus reversed-rear logical order;
- one eager transfer;
- source-level amortized work only on a linear history that starts from
  `empty`; and
- repeated transfer from retained states.

Do not add Case 12 reader navigation.

### Step 2: Update the Cases index

Add item 11 after Case 10 with the reader question and the same bounded
outcome. Preserve the shared setup and cost vocabulary. Do not introduce graph
search.

### Step 3: Replace the active gate with a durable verified summary

Move Case 11 under `## Verified increments` as item 11. The permanent summary
must retain:

- reader question and crossed boundary;
- exact target and three sources;
- exact successful observations and what each establishes;
- front-plus-reversed-rear relationship and operation equations;
- every finite pair has that meaning and the selected variant has no
  nonempty-front invariant;
- `m + 1`, `2m + 1`, and the start-from-`empty` `3e + d` account;
- worst-case transfer versus start-from-`empty` linear-history amortization;
- repeated work from retained `ready`;
- finite/cycle/payload, opacity, source reuse, and runtime exclusions;
- selected source and conceptual-inspiration classification;
- their status as ash-doc evidence that does not define Ash semantics;
- local/Learn/Cases verification and focused test result;
- aggregate count `11 Learn / 11 Cases / 50 Case sources`.

Keep links to both temporary plans while closure remains under review.

### Step 4: Promote only Case 12

Replace the provisional heading with:

```text
## Next: choosing a search frontier
```

Add this exact bounded gate immediately after the new heading and before
`**Question:**`:

```text
Design and implementation plan approval are required before Case 12 content,
source, checks, or tooling.
```

Preserve the question and scope payload from `**Question:**` through its
trailing blank line byte-for-byte.

No other provisional case remains. Do not create a Case 12 directory or plan
in this branch.

### Step 5: Run closure draft verification

Run Appendix D's complete feature verification commands and Case 12 full-block
and payload extraction. Require:

- Markdownlint and relative links;
- local, Learn, and Cases verifiers;
- five focused pinned tests;
- exact hashes and counts;
- root and Cases navigation at eleven;
- Case 12 as the sole `## Next:` heading;
- unchanged Case 12 question/scope payload;
- both Case 11 plan links live;
- immutable ash-doc tag and exact clean Ash pin;
- `git diff --check`; and
- clean status except the three intended closure files.

### Step 6: Run sequential closure reviews

Request specification/authority review first and instructional/workflow review
second. Resolve findings and rerun the complete closure draft verification.
Neither reviewer may remove the plans yet.

## Task 7: Close Case 11 and commit the verified state

**Files:**

- Modify: `README.md`
- Modify: `content/cases/README.md`
- Modify: `docs/project/roadmap.md`
- Delete:
  `docs/plans/2026-08-31-implementing-persistent-fifo-frontier-design.md`
- Delete:
  `docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md`

### Step 1: Remove temporary plan references and files

After both closure reviews approve, remove the two roadmap plan links. Delete
exactly the two Case 11 plan files with `apply_patch`. Git history retains
them; the permanent research record remains.

### Step 2: Run final closure verification

Repeat the stable Task 6 checks: Markdownlint, relative links, local/Learn/Cases
verifiers, five focused pinned tests, hashes, counts, navigation, the exact
Case 12 bounded gate and payload, tag, pin, and `git diff --check`. Replace the
draft-only plan-link and three-path status assertions with these post-deletion
assertions:

- no live reference to either deleted plan;
- no Case 11 `## Next:` heading;
- no provisional section;
- Case 12 as the only next gate;
- exactly the three navigation/roadmap files modified and the two plan files
  deleted from the content commit; and
- no other changed path.

Read all three permanent changed files fully.

### Step 3: Commit closure

Stage the three navigation/roadmap files and both plan deletions. Inspect the
cached diff, run cached diff checks, and commit unsigned:

```bash
set -euo pipefail
git add -- \
    README.md \
    content/cases/README.md \
    docs/plans/2026-08-31-implementing-persistent-fifo-frontier-design.md \
    docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md \
    docs/project/roadmap.md
git diff --cached --check
diff -u <(printf '%s\n' \
    README.md \
    content/cases/README.md \
    docs/plans/2026-08-31-implementing-persistent-fifo-frontier-design.md \
    docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md \
    docs/project/roadmap.md | LC_ALL=C sort) \
    <(git diff --cached --name-only | LC_ALL=C sort)
git diff --cached
git commit --no-gpg-sign -m "docs: verify persistent FIFO frontier"
```

Do not push.

## Task 8: Review, locally merge, verify, and clean up

### Step 0: Retire superseded correction artifacts

After the corrected official branch reproduces the final reviewed tree and a
new HEAD-bound mutation audit passes, retire the rejected and intermediate
repair state before the final whole-branch review. Preserve the current
prototype and new mutation evidence for merged-main verification.

Run from the main worktree:

<!-- markdownlint-disable MD013 -->
```bash
set -euo pipefail

main_root=/home/dikini/Projects/ash-doc
official_root=$main_root/.worktrees/implementing-persistent-fifo-frontier
repair_root=$main_root/.worktrees/case11-empty-start-repair
teaching_root=$main_root/.worktrees/case11-empty-start-teaching

test "$(git -C "$official_root" branch --show-current)" = \
    implementing-persistent-fifo-frontier
test -z "$(git -C "$official_root" status --short)"
test "$(git -C "$repair_root" rev-parse HEAD)" = \
    3d0a656abe6a407328a7f05ec023bae0196a736b
test -z "$(git -C "$repair_root" status --short)"
test "$(git -C "$teaching_root" rev-parse HEAD)" = \
    06ddf08b3aba45f330cb9317fc04588471fc77dd
test -z "$(git -C "$teaching_root" status --short)"
git -C "$official_root" diff --quiet \
    06ddf08b3aba45f330cb9317fc04588471fc77dd HEAD --
test "$(git -C "$main_root" rev-parse case11-rejected-pre-empty-start)" = \
    c716d84026e7d4172e34b20a3d191818546e56d9

git -C "$main_root" worktree remove "$repair_root"
git -C "$main_root" worktree remove "$teaching_root"
git -C "$main_root" branch -D case11-empty-start-repair
git -C "$main_root" branch -D case11-empty-start-teaching
git -C "$main_root" branch -D case11-rejected-pre-empty-start

remove_superseded_mutation_root() {
    local root=$1
    test -d "$root" && test ! -L "$root"
    test -z "$(find "$root" -type l -print -quit)"
    diff -u <(printf '%s\n' \
        content/cases/implementing-persistent-fifo-frontier/README.md \
        content/cases/implementing-persistent-fifo-frontier/checks/verify.sh \
        content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash \
        content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash \
        content/cases/implementing-persistent-fifo-frontier/src/queues.ash \
        content/checks/lib.sh | LC_ALL=C sort) \
        <(find "$root" -type f -printf '%P\n' | LC_ALL=C sort)
    rm -- \
        "$root/content/cases/implementing-persistent-fifo-frontier/README.md" \
        "$root/content/cases/implementing-persistent-fifo-frontier/checks/verify.sh" \
        "$root/content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash" \
        "$root/content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash" \
        "$root/content/cases/implementing-persistent-fifo-frontier/src/queues.ash" \
        "$root/content/checks/lib.sh"
    rmdir -- \
        "$root/content/cases/implementing-persistent-fifo-frontier/checks" \
        "$root/content/cases/implementing-persistent-fifo-frontier/src" \
        "$root/content/cases/implementing-persistent-fifo-frontier" \
        "$root/content/cases" \
        "$root/content/checks" \
        "$root/content" \
        "$root"
}

remove_superseded_mutation_root \
    /tmp/ash-doc-case11-mutations.Xt0ZcX
remove_superseded_mutation_root \
    /tmp/ash-doc-case11-mutations.17L40D
remove_superseded_mutation_root \
    /tmp/ash-doc-case11-mutations.NamfYi

for obsolete_file in \
    /tmp/ash-doc-case11-mutation-log.ivlvwj \
    /tmp/ash-doc-case11-mutation-log.iHfbrx \
    /tmp/ash-doc-case11-mutation-log.k8NAmz \
    /tmp/ash-doc-case11-plan-verifier.curGF3; do
    test -f "$obsolete_file" && test ! -L "$obsolete_file"
    rm -- "$obsolete_file"
done
```
<!-- markdownlint-enable MD013 -->

### Step 1: Review the whole branch

Request one fresh whole-branch review from base
`1689c2633364299d91c49375a95b3eb6e7e69d1d` through feature `HEAD`. Require:

- exactly the already-approved design and implementation-plan commits,
  followed by content and closure commits in order;
- no unapproved or unrelated changes;
- exact permanent source and navigation state;
- source/adaptation rights boundary;
- mutation log completeness;
- no temporary-plan references;
- clean feature, main, and pinned Ash worktrees; and
- readiness for local merge only.

Resolve every finding and repeat full verification if anything changes.

### Step 2: Run final feature verification

Recover Appendix D from the approved plan commit with Appendix D's exact
history command. Run its full verification and branch-range commands fresh.
Require a clean feature worktree and record the exact reviewed feature `HEAD`.

### Step 3: Merge locally without pushing

Require root `main` to be clean and still at
`1689c2633364299d91c49375a95b3eb6e7e69d1d`. If it advanced, stop and repeat
integration review against the new base. Require feature `HEAD` to equal the
reviewed head, then merge with a non-fast-forward merge and no signing:

```bash
git -C /home/dikini/Projects/ash-doc merge \
    --no-ff --no-gpg-sign \
    -m "Merge branch 'implementing-persistent-fifo-frontier'" \
    implementing-persistent-fifo-frontier
```

Do not push.

### Step 4: Verify merged `main`

Run Appendix D's merged-main verification from `main`, even though the
implementation plan is now absent there. Confirm the merge parents are the
previous main commit and reviewed feature head, the immutable documentation tag
is unchanged, the exact Ash pin is clean, and `main` is clean.

### Step 5: Remove exact temporary evidence and merged worktree

Run Appendix D's exact cleanup commands. They validate the prototype real path,
four-file set, hashes, and verifier syntax before deleting only:

```text
/tmp/ash-doc-case11-prototype.ELVoxI/queues.ash
/tmp/ash-doc-case11-prototype.ELVoxI/01-sequence.ash
/tmp/ash-doc-case11-prototype.ELVoxI/02-retained-state.ash
/tmp/ash-doc-case11-prototype.ELVoxI/verify.sh
```

Remove the now-empty prototype directory without recursion. Validate and remove
the known six-file disposable mutation tree without recursive deletion. Delete
the exact retained mutation log after validating its provenance. Remove the
clean merged feature worktree and delete the merged local feature branch with
`git branch -d`.

Report that temporary evidence is not recoverable, no push occurred, Case 11
is locally merged, and Case 12 is the only outstanding recursive-algorithm
case.

## Appendix A: Exact canonical sources

### `src/queues.ash`

```ash
pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

pub opaque type Queue<A> =
    Queue(List<A>, List<A>)

pub empty : Unit -> Queue<A>
empty () = Queue(End, End)

pub enqueue : A -> Queue<A> -> Queue<A>
enqueue value Queue(front, rear) = Queue(front, More(value, rear))

reverse_into : List<A> -> List<A> -> List<A>
reverse_into End reversed = reversed
reverse_into More(first, rest) reversed = {
    reverse_into rest (More(first, reversed))
}

pub dequeue : Queue<A> -> Option<(A, Queue<A>)>
dequeue Queue(End, End) = None
dequeue Queue(More(first, rest), rear) = {
    Some((first, Queue(rest, rear)))
}
dequeue Queue(End, rear) = {
    let front = reverse_into rear End
    dequeue (Queue(front, End))
}
```

### `src/01-sequence.ash`

```ash
import queues as Queues

drain : Queues.Queue<A> -> Queues.List<A>
drain queue = match Queues.dequeue queue {
    Queues.None => Queues.End
    Queues.Some((first, later)) => Queues.More(first, drain later)
}

main : Unit -> (
    Queues.Option<(Int, Queues.Queue<Int>)>,
    Queues.Queue<Int>,
    Int,
    Queues.Queue<Int>,
    Queues.List<Int>
)
main () = {
    let empty_queue = Queues.empty ()
    let ready = Queues.enqueue 3 (
        Queues.enqueue 2 (
            Queues.enqueue 1 empty_queue
        )
    )
    let empty_result = Queues.dequeue empty_queue
    match Queues.dequeue ready {
        Queues.None => (empty_result, ready, 0, ready, Queues.End)
        Queues.Some((first, later)) => (
            empty_result,
            ready,
            first,
            later,
            drain later
        )
    }
}
```

### `src/02-retained-state.ash`

```ash
import queues as Queues

main : Unit -> (
    Queues.Option<(Int, Queues.Queue<Int>)>,
    Queues.Option<(Int, Queues.Queue<Int>)>
)
main () = {
    let ready = Queues.enqueue 3 (
        Queues.enqueue 2 (
            Queues.enqueue 1 (Queues.empty ())
        )
    )
    (Queues.dequeue ready, Queues.dequeue ready)
}
```

## Appendix B: Exact accepted output

### Sequence

<!-- markdownlint-disable MD013 -->
```text
(None, Queue(End, More(3, More(2, More(1, End)))), 1, Queue(More(2, More(3, End)), End), More(2, More(3, End))) : (Option<(Int, Queue<Int>)>, Queue<Int>, Int, Queue<Int>, List<Int>)
```
<!-- markdownlint-enable MD013 -->

### Retained state

<!-- markdownlint-disable MD013 -->
```text
(Some(1, Queue(More(2, More(3, End)), End)), Some(1, Queue(More(2, More(3, End)), End))) : (Option<(Int, Queue<Int>)>, Option<(Int, Queue<Int>)>)
```
<!-- markdownlint-enable MD013 -->

## Appendix C: Exact lesson-local verifier

<!-- markdownlint-disable MD013 -->
```bash
#!/usr/bin/env bash

set -euo pipefail

unit_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly unit_root
content_root=$(cd "$unit_root/../.." && pwd)
readonly content_root
readonly readme="$unit_root/README.md"
readonly library="$unit_root/src/queues.ash"
readonly sequence_entry="$unit_root/src/01-sequence.ash"
readonly retained_entry="$unit_root/src/02-retained-state.ash"
readonly sources=(
    src/queues.ash
    src/01-sequence.ash
    src/02-retained-state.ash
)

# shellcheck source-path=SCRIPTDIR/../../../checks
# shellcheck source=lib.sh
source "$content_root/checks/lib.sh"

if [[ $# -ne 1 ]]; then
    ash_doc_fail "usage: checks/verify.sh /path/to/pinned/ash-lang"
fi

ash_doc_prepare "$1"

for source in "${sources[@]}"; do
    [[ -f "$unit_root/$source" ]] ||
        ash_doc_fail "missing canonical source: $source"
done

declared_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/declared-sources.XXXXXX")
actual_sources_file=$(mktemp "$ASH_DOC_VERIFY_DIR/actual-sources.XXXXXX")
readonly declared_sources_file actual_sources_file
printf '%s\n' "${sources[@]}" | LC_ALL=C sort > "$declared_sources_file"
find "$unit_root/src" -maxdepth 1 -type f -name '*.ash' \
    -printf 'src/%f\n' | LC_ALL=C sort > "$actual_sources_file"
if ! cmp -s "$declared_sources_file" "$actual_sources_file"; then
    diff -u "$declared_sources_file" "$actual_sources_file" >&2 || true
    ash_doc_fail "canonical source set must contain exactly the three declared paths"
fi

ash_doc_section() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_section requires start and end lines"
    fi

    if ! awk -v section_start="$1" -v section_end="$2" '
        $0 == section_start {
            start_seen = 1
            inside = 1
        }
        inside && section_end != "" && $0 == section_end {
            end_seen = 1
            exit
        }
        inside {
            print
        }
        END {
            if (!start_seen || (section_end != "" && !end_seen)) {
                exit 2
            }
        }
    ' "$library"; then
        ash_doc_fail "ash_doc_section could not find required adjacent signatures"
    fi
}

ash_doc_assert_phrase_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_phrase_count requires source, phrase, count, and claim"
    fi

    local source=$1
    local phrase=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Fo "$phrase" <<< "$source" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_assert_line_count() {
    if [[ $# -ne 4 ]]; then
        ash_doc_fail "ash_doc_assert_line_count requires source, line, count, and claim"
    fi

    local source=$1
    local expected_line=$2
    local expected_count=$3
    local claim=$4
    local actual_count
    actual_count=$(
        { grep -Fx "$expected_line" <<< "$source" || true; } |
            wc -l
    )

    [[ $actual_count -eq $expected_count ]] ||
        ash_doc_fail "$claim (found $actual_count occurrences, expected $expected_count)"
}

ash_doc_assert_contains() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_contains requires source, substring, and claim"
    fi

    [[ $1 == *"$2"* ]] || ash_doc_fail "$3"
}

ash_doc_assert_sha256() {
    if [[ $# -ne 3 ]]; then
        ash_doc_fail "ash_doc_assert_sha256 requires file, hash, and claim"
    fi

    local actual
    actual=$(sha256sum "$1")
    actual=${actual%% *}
    [[ $actual == "$2" ]] ||
        ash_doc_fail "$3 (found $actual, expected $2)"
}

ash_doc_assert_text_line_once() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_assert_text_line_once requires line and claim"
    fi

    local actual_count
    actual_count=$(
        awk -v expected="$1" '
            $0 == "```text" { inside = 1; next }
            inside && $0 == "```" { inside = 0; next }
            inside && $0 == expected { count += 1 }
            END { print count + 0 }
        ' "$readme"
    )
    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail "$2 (found $actual_count occurrences, expected 1)"
}

ash_doc_assert_readme_phrase() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail "ash_doc_assert_readme_phrase requires phrase and claim"
    fi

    local actual_count
    actual_count=$(
        awk '
            /^[[:space:]]*<!--/ { in_comment = 1 }
            !in_comment && /^[[:space:]]*(```|~~~)/ {
                in_fence = !in_fence
                next
            }
            !in_comment && !in_fence { print }
            in_comment && /-->[[:space:]]*$/ { in_comment = 0 }
        ' "$readme" |
            { grep -Fo "$1" || true; } |
            wc -l
    )
    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail "$2 (found $actual_count occurrences, expected 1)"
}

library_source=$(<"$library")
sequence_source=$(<"$sequence_entry")
retained_source=$(<"$retained_entry")
readonly library_source sequence_source retained_source

public_operation_count=$(
    { grep -Ec '^pub [a-z][a-z0-9_]* :' "$library" || true; }
)
readonly public_operation_count
[[ $public_operation_count -eq 3 ]] ||
    ash_doc_fail "queue API must expose exactly three public operations"

# Keep every mutation-facing semantic assertion before hashes and execution.
types_section=$(ash_doc_section 'pub type Option<A> =' 'pub empty : Unit -> Queue<A>')
empty_enqueue_section=$(ash_doc_section 'pub empty : Unit -> Queue<A>' 'reverse_into : List<A> -> List<A> -> List<A>')
reverse_section=$(ash_doc_section 'reverse_into : List<A> -> List<A> -> List<A>' 'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>')
dequeue_section=$(ash_doc_section 'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>' '')
readonly types_section empty_enqueue_section reverse_section dequeue_section

readonly expected_types=$'pub type Option<A> =\n    None\n    | Some(A)\n\npub type List<A> =\n    End\n    | More(A, List<A>)\n\npub opaque type Queue<A> =\n    Queue(List<A>, List<A>)'
[[ $types_section == "$expected_types" ]] ||
    ash_doc_fail "support types and opaque queue must retain their exact representation"

readonly expected_empty_enqueue=$'pub empty : Unit -> Queue<A>\nempty () = Queue(End, End)\n\npub enqueue : A -> Queue<A> -> Queue<A>\nenqueue value Queue(front, rear) = Queue(front, More(value, rear))'
[[ $empty_enqueue_section == "$expected_empty_enqueue" ]] ||
    ash_doc_fail "empty and enqueue must retain empty state and one rear prepend"

readonly expected_reverse=$'reverse_into : List<A> -> List<A> -> List<A>\nreverse_into End reversed = reversed\nreverse_into More(first, rest) reversed = {\n    reverse_into rest (More(first, reversed))\n}'
[[ $reverse_section == "$expected_reverse" ]] ||
    ash_doc_fail "reverse_into must retain its terminal reuse and accumulator step"

readonly expected_dequeue=$'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>\ndequeue Queue(End, End) = None\ndequeue Queue(More(first, rest), rear) = {\n    Some((first, Queue(rest, rear)))\n}\ndequeue Queue(End, rear) = {\n    let front = reverse_into rear End\n    dequeue (Queue(front, End))\n}'
[[ $dequeue_section == "$expected_dequeue" ]] ||
    ash_doc_fail "dequeue must retain empty, front, and rear-transfer equations in order"

readonly signatures=(
    'pub empty : Unit -> Queue<A>'
    'pub enqueue : A -> Queue<A> -> Queue<A>'
    'pub dequeue : Queue<A> -> Option<(A, Queue<A>)>'
)
for signature in "${signatures[@]}"; do
    ash_doc_assert_line_count "$library_source" "$signature" 1 "the queue API must retain every exact signature"
done
ash_doc_assert_phrase_count "$library_source" 'pub reverse_into' 0 "reverse_into must remain private"

readonly expected_drain=$'drain : Queues.Queue<A> -> Queues.List<A>\ndrain queue = match Queues.dequeue queue {\n    Queues.None => Queues.End\n    Queues.Some((first, later)) => Queues.More(first, drain later)\n}'
ash_doc_assert_contains "$sequence_source" "$expected_drain" "the sequence client must drain only returned successor states"
readonly expected_sequence_ready=$'let ready = Queues.enqueue 3 (\n        Queues.enqueue 2 (\n            Queues.enqueue 1 empty_queue\n        )\n    )'
ash_doc_assert_contains "$sequence_source" "$expected_sequence_ready" "the sequence client must enqueue one, two, and three in that order"
ash_doc_assert_line_count "$sequence_source" '    let empty_result = Queues.dequeue empty_queue' 1 "the sequence client must retain one empty dequeue observation"
ash_doc_assert_line_count "$sequence_source" '    match Queues.dequeue ready {' 1 "the sequence client must trigger transfer from the retained ready state"
readonly expected_sequence_result=$'        Queues.Some((first, later)) => (\n            empty_result,\n            ready,\n            first,\n            later,\n            drain later\n        )'
ash_doc_assert_contains "$sequence_source" "$expected_sequence_result" "the sequence result must expose empty, pre-transfer, FIFO, successor, and drain evidence"

readonly expected_retained_ready=$'let ready = Queues.enqueue 3 (\n        Queues.enqueue 2 (\n            Queues.enqueue 1 (Queues.empty ())\n        )\n    )'
ash_doc_assert_contains "$retained_source" "$expected_retained_ready" "the retained client must build the same one, two, three queue"
ash_doc_assert_phrase_count "$retained_source" 'Queues.dequeue ready' 2 "the retained client must branch exactly twice from ready"
ash_doc_assert_line_count "$retained_source" '    (Queues.dequeue ready, Queues.dequeue ready)' 1 "the retained result must contain both calls from the same state"

ash_doc_assert_sha256 "$library" 9db0dde1fd8776556ea4f4bad51aacb09fd00a7ed769cf8e457ea20795cfe7bd "queues.ash must retain its exact complete source"
ash_doc_assert_sha256 "$sequence_entry" 38edc257a6e1859b96b40f523ac57199eff14aaa6bccf13176289e4b18dcfc61 "01-sequence.ash must retain its exact complete source"
ash_doc_assert_sha256 "$retained_entry" 6a0981eb6dd63c2cc540983a69bc5e058db0018f670645610d518e8e6ab99d51 "02-retained-state.ash must retain its exact complete source"

readonly sequence_output='(None, Queue(End, More(3, More(2, More(1, End)))), 1, Queue(More(2, More(3, End)), End), More(2, More(3, End))) : (Option<(Int, Queue<Int>)>, Queue<Int>, Int, Queue<Int>, List<Int>)'
readonly retained_output='(Some(1, Queue(More(2, More(3, End)), End)), Some(1, Queue(More(2, More(3, End)), End))) : (Option<(Int, Queue<Int>)>, Option<(Int, Queue<Int>)>)'

ash_doc_run_accepted "$unit_root" src/01-sequence.ash "$sequence_output"
ash_doc_run_accepted "$unit_root" src/02-retained-state.ash "$retained_output"

[[ -f $readme ]] || ash_doc_fail "missing unit README.md"
ash_doc_check_sources "$unit_root" "$readme" "${sources[@]}"
# The literal Markdown backticks below are intentional evidence text.
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase '`Queue(front, rear)` denotes `front ++ reverse(rear)`.' "README must state the representation relationship"
ash_doc_assert_readme_phrase 'The front may be empty while the rear is nonempty.' "README must state the selected variant has no nonempty-front invariant"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase 'The transfer is eager and complete before `dequeue` returns.' "README must state the eager-transfer boundary"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase 'One list-node unit is one selected or constructed `More`.' "README must define the named work metric"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase '`reverse_into` runs `m + 1` times, and the transfer costs `2m + 1` list-node units.' "README must state the exact one-transfer work"
# shellcheck disable=SC2016
ash_doc_assert_readme_phrase 'One linear successor history that starts from `empty` costs at most `3e + d` list-node units.' "README must state the start-from-empty linear-history bound"
ash_doc_assert_readme_phrase 'Retained branching repeats the transfer outside that linear-history bound.' "README must state the persistent-branching exclusion"
ash_doc_assert_readme_phrase 'The metric excludes elapsed time, machine instructions, and host-stack behavior.' "README must exclude runtime measurements"
ash_doc_assert_readme_phrase 'It also excludes heap bytes, allocation count, pointer identity, physical sharing,' "README must exclude storage and identity measurements"
ash_doc_assert_readme_phrase 'garbage collection, and compiler optimization.' "README must complete the runtime exclusions"
ash_doc_assert_text_line_once "$sequence_output" "README must display the complete sequence output exactly once"
ash_doc_assert_text_line_once "$retained_output" "README must display the retained-state output exactly once"

ash_doc_finish 3
```

## Appendix D: Exact verification and cleanup commands

Run commands from the fixed feature worktree unless a command uses an explicit
`git -C` path. Every temporary path uses the Case 11 prefix and is removed by
explicit file and directory names.

After Task 7 deletes the live plan, recover this appendix read-only from the
approved plan commit before running Task 8:

```bash
set -euo pipefail
base=1689c2633364299d91c49375a95b3eb6e7e69d1d
plan_commit=$(git rev-list --reverse "$base..HEAD" | sed -n '2p')
test "$(git show -s --format=%s "$plan_commit")" = \
    'docs: plan persistent FIFO frontier'
git show \
    "$plan_commit:docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md" \
    | sed -n '/^## Appendix D: Exact verification and cleanup commands$/,$p'
```

### RED capture

Set `expected_red` to the applicable Task 1 or Task 2 line, then run:

```bash
set -euo pipefail

expected_red='verify: missing canonical source: src/queues.ash'
# Task 2 instead uses: expected_red='verify: missing unit README.md'
red_root=$(mktemp -d /tmp/ash-doc-case11-red.XXXXXX)
if bash content/cases/implementing-persistent-fifo-frontier/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    > "$red_root/stdout" 2> "$red_root/stderr"; then
    red_status=0
else
    red_status=$?
fi
test "$red_status" -eq 1
test ! -s "$red_root/stdout"
test "$(sed -n '1p' "$red_root/stderr")" = "$expected_red"
rm -- "$red_root/stdout" "$red_root/stderr"
rmdir -- "$red_root"
```

### Direct accepted observations

```bash
set -euo pipefail

direct_root=$(mktemp -d /tmp/ash-doc-case11-direct.XXXXXX)
pin_root=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
unit_root=content/cases/implementing-persistent-fifo-frontier
(
    cd "$pin_root"
    cargo build --quiet --locked
)

run_direct() {
    local entry=$1
    local stem=$2
    local expected=$3
    local status

    if "$pin_root/target/debug/ash" "$unit_root/$entry" \
        > "$direct_root/$stem.stdout" 2> "$direct_root/$stem.stderr"; then
        status=0
    else
        status=$?
    fi
    printf '%s\n' "$expected" > "$direct_root/$stem.expected"
    test "$status" -eq 0
    test ! -s "$direct_root/$stem.stderr"
    cmp -s "$direct_root/$stem.expected" "$direct_root/$stem.stdout"
    printf '%s status %s\n' "$entry" "$status"
}

run_direct src/01-sequence.ash sequence \
    '(None, Queue(End, More(3, More(2, More(1, End)))), 1, Queue(More(2, More(3, End)), End), More(2, More(3, End))) : (Option<(Int, Queue<Int>)>, Queue<Int>, Int, Queue<Int>, List<Int>)'
run_direct src/02-retained-state.ash retained \
    '(Some(1, Queue(More(2, More(3, End)), End)), Some(1, Queue(More(2, More(3, End)), End))) : (Option<(Int, Queue<Int>)>, Option<(Int, Queue<Int>)>)'

rm -- \
    "$direct_root/sequence.stdout" \
    "$direct_root/sequence.stderr" \
    "$direct_root/sequence.expected" \
    "$direct_root/retained.stdout" \
    "$direct_root/retained.stderr" \
    "$direct_root/retained.expected"
rmdir -- "$direct_root"
```

### Complete repository verification

```bash
set -euo pipefail

mapfile -d '' markdown_files < <(rg --files -0 -g '*.md')
markdownlint-cli2 "${markdown_files[@]}"

checked_links=0
while IFS= read -r -d '' markdown; do
    while IFS= read -r raw; do
        target=${raw#']('}
        target=${target%')'}
        target=${target#'<'}
        target=${target%'>'}
        target=${target%%'#'*}
        case $target in
            ''|'/'*|'http://'*|'https://'*|'mailto:'*|'app://'* ) continue ;;
        esac
        candidate=$(realpath -m "$(dirname "$markdown")/$target")
        if [[ ! -e $candidate ]]; then
            printf 'broken relative link: %s -> %s\n' \
                "$markdown" "$target" >&2
            exit 1
        fi
        checked_links=$((checked_links + 1))
    done < <(rg -o '\]\((<[^>]+>|[^)[:space:]]+)\)' "$markdown" || true)
done < <(rg --files -0 -g '*.md')
printf 'Checked %s relative links.\n' "$checked_links"

bash -n content/cases/implementing-persistent-fifo-frontier/checks/verify.sh
shellcheck -x content/cases/implementing-persistent-fifo-frontier/checks/verify.sh
bash content/cases/implementing-persistent-fifo-frontier/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/learn/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin

learn_count=$(find content/learn -mindepth 2 -maxdepth 2 \
    -type f -name README.md | wc -l)
case_count=$(find content/cases -mindepth 2 -maxdepth 2 \
    -type f -name README.md | wc -l)
case_source_count=$(find content/cases -type f -path '*/src/*.ash' | wc -l)
printf '%s Learn / %s Cases / %s Case sources\n' \
    "$learn_count" "$case_count" "$case_source_count"
test "$learn_count" -eq 11
test "$case_count" -eq 11
test "$case_source_count" -eq 50

audit_root=$(mktemp -d /tmp/ash-doc-case11-audit.XXXXXX)
: > "$audit_root/case12-full"
if rg -q '^### 12\. Choosing a search frontier$' docs/project/roadmap.md; then
    sed -n \
        '/^### 12\. Choosing a search frontier$/,/^## Promotion and verification policy$/p' \
        docs/project/roadmap.md | sed '$d' > "$audit_root/case12-full"
    test "$(sha256sum "$audit_root/case12-full" | cut -d ' ' -f 1)" = \
        0ba0cd849dcb728485ef5e5b219fca125a314a37168c18fa4b814c9c0a7c6a22
fi
awk '
    /^### 12\. Choosing a search frontier$/ ||
    /^## Next: choosing a search frontier$/ { in_case = 1; next }
    in_case && /^\*\*Question:\*\*/ { in_payload = 1 }
    in_payload && /^## Promotion and verification policy$/ { exit }
    in_payload { print }
' docs/project/roadmap.md > "$audit_root/case12-payload"
test "$(sha256sum "$audit_root/case12-payload" | cut -d ' ' -f 1)" = \
    0560d3f5d09b389c91f1c84fa42b0ce10ce4d19eb77a2d1c4de2296694f79916
rm -- "$audit_root/case12-full" "$audit_root/case12-payload"
rmdir -- "$audit_root"

test "$(git rev-parse 'refs/tags/modular-ash^{commit}')" = \
    e963a1597176f86003926eef827498db2a661b75
test "$(git -C \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    rev-parse HEAD)" = dca16039923475c48025c5f17beadeb6bcb6a4bf
test -z "$(git -C \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
    status --short)"
git diff --check
git status --short
```

Run the five exact focused tests from Fixed context after this block. At Task
5, require exactly the five intended untracked Case 11 files and no Case 11
reader navigation:

```bash
set -euo pipefail

diff -u <(printf '%s\n' \
    '?? content/cases/implementing-persistent-fifo-frontier/README.md' \
    '?? content/cases/implementing-persistent-fifo-frontier/checks/verify.sh' \
    '?? content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash' \
    '?? content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash' \
    '?? content/cases/implementing-persistent-fifo-frontier/src/queues.ash') \
    <(git status --short --untracked-files=all | LC_ALL=C sort)
! rg -q 'implementing-persistent-fifo-frontier' \
    README.md content/cases/README.md
```

At Task 6, require both plan links, the Case 11 reader links, the sole promoted
Case 12 gate, and exactly three unstaged paths:

```bash
set -euo pipefail

test -f docs/plans/2026-08-31-implementing-persistent-fifo-frontier-design.md
test -f docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md
rg -q '2026-08-31-implementing-persistent-fifo-frontier-design.md' \
    docs/project/roadmap.md
rg -q '2026-08-31-implementing-persistent-fifo-frontier.md' \
    docs/project/roadmap.md
rg -q 'content/cases/implementing-persistent-fifo-frontier/' README.md
rg -q 'implementing-persistent-fifo-frontier/' content/cases/README.md
test "$(rg -c '^## Next:' docs/project/roadmap.md)" -eq 1
rg -q '^## Next: choosing a search frontier$' docs/project/roadmap.md
diff -u <(printf '\n%s\n%s\n\n' \
    'Design and implementation plan approval are required before Case 12 content,' \
    'source, checks, or tooling.') \
    <(awk '
        $0 == "## Next: choosing a search frontier" { in_gate = 1; next }
        in_gate && /^\*\*Question:\*\*/ { exit }
        in_gate { print }
    ' docs/project/roadmap.md)
diff -u \
    <(printf '%s\n' README.md content/cases/README.md docs/project/roadmap.md) \
    <(git diff --name-only | LC_ALL=C sort)
```

At Task 7, require exactly these changes from the content commit:

```bash
set -euo pipefail

diff -u <(printf '%s\n' \
    'M README.md' \
    'M content/cases/README.md' \
    'D docs/plans/2026-08-31-implementing-persistent-fifo-frontier-design.md' \
    'D docs/plans/2026-08-31-implementing-persistent-fifo-frontier.md' \
    'M docs/project/roadmap.md' | LC_ALL=C sort) \
    <(git diff --name-status | LC_ALL=C sort)
! rg -n \
    '2026-08-31-implementing-persistent-fifo-frontier(-design)?\.md' \
    --glob '*.md'
test "$(rg -c '^## Next:' docs/project/roadmap.md)" -eq 1
rg -q '^## Next: choosing a search frontier$' docs/project/roadmap.md
diff -u <(printf '\n%s\n%s\n\n' \
    'Design and implementation plan approval are required before Case 12 content,' \
    'source, checks, or tooling.') \
    <(awk '
        $0 == "## Next: choosing a search frontier" { in_gate = 1; next }
        in_gate && /^\*\*Question:\*\*/ { exit }
        in_gate { print }
    ' docs/project/roadmap.md)
! rg -q '^## Provisional' docs/project/roadmap.md
```

### Branch range and local merge

Run on the clean feature branch after closure:

```bash
set -euo pipefail

base=1689c2633364299d91c49375a95b3eb6e7e69d1d
test "$(git rev-list --count "$base..HEAD")" -eq 4
test "$(git rev-list --reverse "$base..HEAD" | sed -n '1p')" = \
    14a7e118f1b66230582ccb04444a5585b52d47f7
diff -u <(printf '%s\n' \
    'docs: design persistent FIFO frontier' \
    'docs: plan persistent FIFO frontier' \
    'docs: teach persistent FIFO frontier' \
    'docs: verify persistent FIFO frontier') \
    <(git log --format=%s --reverse "$base..HEAD")
git merge-base --is-ancestor "$base" HEAD
test -z "$(git rev-list --min-parents=2 "$base..HEAD")"
test -z "$(git status --short)"
review_record=$(mktemp /tmp/ash-doc-case11-reviewed-head.XXXXXX)
git rev-parse HEAD > "$review_record"
grep -Eq '^[0-9a-f]{40}$' "$review_record"
printf 'Reviewed feature HEAD: %s\n' "$(<"$review_record")"
printf 'Review record: %s\n' "$review_record"
```

Record the reviewed feature head and perform the merge and parent check in one
shell session. If the shell session changes, set `review_record` to the exact
path printed above; do not create a new record or recompute an approved head:

```bash
set -euo pipefail

main_root=/home/dikini/Projects/ash-doc
feature_root=/home/dikini/Projects/ash-doc/.worktrees/implementing-persistent-fifo-frontier
previous_main=$(git -C "$main_root" rev-parse HEAD)
case "$(realpath -- "$review_record")" in
    /tmp/ash-doc-case11-reviewed-head.*) ;;
    *) exit 1 ;;
esac
test -f "$review_record" && test ! -L "$review_record"
reviewed_feature=$(<"$review_record")
grep -Eq '^[0-9a-f]{40}$' <<< "$reviewed_feature"
test "$previous_main" = 1689c2633364299d91c49375a95b3eb6e7e69d1d
test "$(git -C "$main_root" branch --show-current)" = main
test -z "$(git -C "$main_root" status --short)"
test -z "$(git -C "$feature_root" status --short)"
test "$(git -C "$feature_root" rev-parse HEAD)" = "$reviewed_feature"
test "$(git -C "$main_root" rev-parse implementing-persistent-fifo-frontier)" = \
    "$reviewed_feature"
git -C "$main_root" merge \
    --no-ff --no-gpg-sign \
    -m "Merge branch 'implementing-persistent-fifo-frontier'" \
    implementing-persistent-fifo-frontier
read -r merge_commit first_parent second_parent extra < <(
    git -C "$main_root" rev-list --parents -n 1 HEAD
)
test -z "$extra"
test "$merge_commit" = "$(git -C "$main_root" rev-parse HEAD)"
test "$first_parent" = "$previous_main"
test "$second_parent" = "$reviewed_feature"
```

Run the complete repository verification and five focused tests from
`/home/dikini/Projects/ash-doc` after the merge. Also require clean `main` and
the same four-commit first-parent feature range through the merge's second
parent.

```bash
set -euo pipefail

main_root=/home/dikini/Projects/ash-doc
base=1689c2633364299d91c49375a95b3eb6e7e69d1d
feature_parent=$(git -C "$main_root" rev-parse 'HEAD^2')
test "$(git -C "$main_root" rev-list --count \
    "$base..$feature_parent")" -eq 4
test "$(git -C "$main_root" rev-list --reverse \
    "$base..$feature_parent" | sed -n '1p')" = \
    14a7e118f1b66230582ccb04444a5585b52d47f7
test -z "$(git -C "$main_root" status --short)"
```

### Validated exact cleanup

Set `review_record` to the Task 8 path and `mutation_root` and `mutation_log` to
the exact retained paths recorded by Task 4. Validate and remove the reviewed
head record after confirming it is the merge's second parent:

```bash
set -euo pipefail

case "$(realpath -- "$review_record")" in
    /tmp/ash-doc-case11-reviewed-head.*) ;;
    *) exit 1 ;;
esac
test -f "$review_record" && test ! -L "$review_record"
reviewed_feature=$(<"$review_record")
test "$reviewed_feature" = "$(git -C /home/dikini/Projects/ash-doc \
    rev-parse 'HEAD^2')"
rm -- "$review_record"
```

Validate and remove the prototype:

```bash
set -euo pipefail

prototype=/tmp/ash-doc-case11-prototype.ELVoxI
test "$(realpath -- "$prototype")" = /tmp/ash-doc-case11-prototype.ELVoxI
test -d "$prototype" && test ! -L "$prototype"
diff -u <(printf '%s\n' \
    01-sequence.ash 02-retained-state.ash queues.ash verify.sh) \
    <(find "$prototype" -mindepth 1 -maxdepth 1 -type f \
        -printf '%f\n' | LC_ALL=C sort)
sha256sum --check <<'HASHES'
38edc257a6e1859b96b40f523ac57199eff14aaa6bccf13176289e4b18dcfc61  /tmp/ash-doc-case11-prototype.ELVoxI/01-sequence.ash
6a0981eb6dd63c2cc540983a69bc5e058db0018f670645610d518e8e6ab99d51  /tmp/ash-doc-case11-prototype.ELVoxI/02-retained-state.ash
9db0dde1fd8776556ea4f4bad51aacb09fd00a7ed769cf8e457ea20795cfe7bd  /tmp/ash-doc-case11-prototype.ELVoxI/queues.ash
6c84f6a799cf322f5569d29533c2dc3387be150a2eaac474cc187c73d7464439  /tmp/ash-doc-case11-prototype.ELVoxI/verify.sh
HASHES
bash -n "$prototype/verify.sh"
rm -- \
    "$prototype/01-sequence.ash" \
    "$prototype/02-retained-state.ash" \
    "$prototype/queues.ash" \
    "$prototype/verify.sh"
rmdir -- "$prototype"
```

Validate and remove the known mutation tree and log:

```bash
set -euo pipefail

case "$(realpath -- "$mutation_root")" in
    /tmp/ash-doc-case11-mutations.*) ;;
    *) exit 1 ;;
esac
test -d "$mutation_root" && test ! -L "$mutation_root"
diff -u <(printf '%s\n' \
    content/cases/implementing-persistent-fifo-frontier/README.md \
    content/cases/implementing-persistent-fifo-frontier/checks/verify.sh \
    content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash \
    content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash \
    content/cases/implementing-persistent-fifo-frontier/src/queues.ash \
    content/checks/lib.sh) \
    <(find "$mutation_root" -type f -printf '%P\n' | LC_ALL=C sort)
rm -- \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier/README.md" \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier/checks/verify.sh" \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier/src/01-sequence.ash" \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier/src/02-retained-state.ash" \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier/src/queues.ash" \
    "$mutation_root/content/checks/lib.sh"
rmdir -- \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier/checks" \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier/src" \
    "$mutation_root/content/cases/implementing-persistent-fifo-frontier" \
    "$mutation_root/content/cases" \
    "$mutation_root/content/checks" \
    "$mutation_root/content" \
    "$mutation_root"

case "$(realpath -- "$mutation_log")" in
    /tmp/ash-doc-case11-mutation-log.*) ;;
    *) exit 1 ;;
esac
test -f "$mutation_log" && test ! -L "$mutation_log"
grep -Fq dca16039923475c48025c5f17beadeb6bcb6a4bf "$mutation_log"
for mutation_id in \
    Q01 Q02 Q03 Q04 Q05 Q06 Q07 Q08 Q09 Q10 Q11 Q12 Q13 Q14 Q15 Q16 Q17 Q18 \
    S01 S02 S03 S04 S05 S06 R01 R02 P01 P02 P03 P04 P05 P06 P07 P08 \
    E01 E02 E03 E04 E05 E06 E07 E08; do
    grep -Fq "$mutation_id" "$mutation_log"
done
rm -- "$mutation_log"
```

Finally validate merged ancestry, then remove the clean worktree and merged
branch:

```bash
set -euo pipefail

main_root=/home/dikini/Projects/ash-doc
feature_root=/home/dikini/Projects/ash-doc/.worktrees/implementing-persistent-fifo-frontier
feature_head=$(git -C "$feature_root" rev-parse HEAD)
test "$(realpath -- "$feature_root")" = \
    /home/dikini/Projects/ash-doc/.worktrees/implementing-persistent-fifo-frontier
test -z "$(git -C "$feature_root" status --short)"
git -C "$main_root" merge-base --is-ancestor "$feature_head" main
git -C "$main_root" worktree remove "$feature_root"
git -C "$main_root" branch -d implementing-persistent-fifo-frontier
```
<!-- markdownlint-enable MD013 -->
