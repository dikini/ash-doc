# Abstracting key order implementation plan

Status: approved on 2026-08-30 after independent specification and execution review

> Implement this plan one task at a time. It is active only while linked from
> the roadmap and leaves the live tree after reviewed repository closure.

## Goal and fixed design

Implement the approved
[Abstracting key order design](2026-08-30-abstracting-key-order-design.md) as
the seventh sequential recursive-algorithm case. Replace the explicit
comparator value arguments from the preceding case with a public `Order<A>`
interface, a public `Order<Natural>` implementation, and explicit
`where Order<K>` requirements on `lookup`, `insert`, and `lookup_counted`.

Preserve all three accepted case-6 observations byte for byte after removing
the explicit `Trees.compare_natural` arguments. Add one complete `Int`-key
entry that is rejected because the direct dependency provides no `Order<Int>`
implementation.

The implementation is lesson-local. It adds no manifest, renderer, shared tree
library, new dependency, CI service, publication mechanism, research record,
or laboratory case. The split-module
`evidence.validation.unknown-identity` result remains a quarantined Ash
regression candidate and must not enter lesson prose as language behavior.

## Reader question and observable boundary

The reader asks: How can modules reuse an ordering capability without passing
it manually?

The observable boundary crosses from an explicit comparator source argument to
an interface obligation selected during checking. Successful CLI output proves
that the complete selected program checks, evaluates, and preserves the prior
value and type. The negative CLI observation proves that a missing
implementation rejects at the constrained `Trees.lookup` occurrence with
`constraint.unsatisfied`. CLI output cannot identify the selected
implementation or isolate evidence lowering; those claims remain grounded in
the pinned elaboration and dynamic semantics and three retained exact-pin
tests.

## Authority and fixed evidence

All language, tool, and test observations use the clean Ash checkout:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Its required `HEAD` is:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

The immutable ash-doc tag `modular-ash` must continue to peel to:

```text
e963a1597176f86003926eef827498db2a661b75
```

Use the authority links and preserved invariant, cost, return, and exclusion
boundaries in the approved design. Do not import behavior from current
`ash-lang/main` or from the minimized split-module regression prototype.

The exact feasibility sources are retained temporarily under:

```text
/tmp/ash-order-interface-feasibility.D0lg7O
```

Their hashes are:

```text
d0614a78b861e68cecf56b477fde6eab0ae18113c860880e18ffb89dfeb8ac2e  ordered_trees.ash
930c3fee7dd21464e9e05f748ea04b7958f7a12ce039eaf8652b6b4d70be8a6a  01-lookup.ash
a9df09b4bdcc772ffdbbee9225d09595d58f4e1ee928eb749e7dd7ae74e5a716  02-replace-and-malformed.ash
86acde221897f576ba5ce3cd9a8f3349b5ef91cb69fc6a2608fbd9dffb2b5321  03-ascending.ash
32f09f0fe53774d4a9104b13e1741101385fe40dfae53554453ac65a44843818  04-missing-order.ash
```

The implementation must not depend on those temporary files existing. The
exact source is repeated below and becomes canonical only after it is added to
the case.

## Files and final counts

Create:

- `content/cases/abstracting-key-order/README.md`;
- `content/cases/abstracting-key-order/checks/verify.sh`;
- `content/cases/abstracting-key-order/src/ordered_trees.ash`;
- `content/cases/abstracting-key-order/src/01-lookup.ash`;
- `content/cases/abstracting-key-order/src/02-replace-and-malformed.ash`;
- `content/cases/abstracting-key-order/src/03-ascending.ash`; and
- `content/cases/abstracting-key-order/src/04-missing-order.ash`.

Modify during reviewed integration only:

- `README.md`;
- `content/cases/README.md`; and
- `docs/project/roadmap.md`.

Delete after closure review only:

- `docs/plans/2026-08-30-abstracting-key-order-design.md`; and
- `docs/plans/2026-08-30-abstracting-key-order.md`.

The completed repository must report 11 Learn lessons, 7 Cases, and 33
canonical Case sources.

## Task 1: Establish the verifier's first RED

**Files:**

- Create:
  `content/cases/abstracting-key-order/checks/verify.sh`
- Do not create any `src/` file or case README yet.

### Step 1: Create the executable verifier

Use `apply_patch` to add one Bash verifier modeled on the current
`searching-ordered-tree` verifier and the shared
`content/checks/lib.sh`. It must declare exactly these sources in order:

```bash
readonly sources=(
    src/ordered_trees.ash
    src/01-lookup.ash
    src/02-replace-and-malformed.ash
    src/03-ascending.ash
    src/04-missing-order.ash
)
```

The verifier must call `ash_doc_prepare "$1"`, check for the library before
calling `ash_doc_check_sources`, and finish with `ash_doc_finish 5`.

Retain focused helpers equivalent to the case-6 verifier for extracting an
adjacent source section, counting words and fixed phrases, checking a suffix or
substring, and requiring exact text lines in README text fences. The permanent
verifier does not run Cargo tests; Task 3 and closure verification run the
three focused retained tests separately.

Order source assertions so a focused causal claim fails before the final
complete-source equality. Assert at least:

- exact transparent `Tree`, `Ordering`, `Option`, and `Natural`
  representations;
- one exact public `Order<A>` interface whose only method is
  `compare : A -> A -> Ordering`;
- one exact public `Order<Natural>` implementation with the four equations in
  Task 2;
- `Zero` before `Next`, `Next` after `Zero`, and recursive comparison of both
  `Next` payloads;
- the recursive implementation call is exactly `compare left right`;
- exact `where Order<K>` signatures for `lookup`, `insert`, and
  `lookup_counted`;
- exactly one `compare query key` occurrence in each lookup `Node` equation
  and one `compare key current_key` occurrence in insertion;
- the intended selected left and right recursive calls with no comparator
  value argument;
- `Equal` returns the current value in lookup and retains the stored
  representative key and both branches in insertion;
- counted lookup returns zero at `Empty`, one at `Equal`, and adds one after
  each selected recursive branch;
- exact private `maximum` and public `height` equations;
- complete-library byte equality after all focused library assertions;
- all three accepted entries retain their exact case-6 tree shapes and calls
  after removing `Trees.compare_natural`;
- no accepted entry contains `Trees.compare_natural` or supplies a comparator
  as a tree-operation argument;
- the negative entry constructs exactly one `Int`-key node and has exactly one
  failing line `Trees.lookup 1 tree`;
- complete byte equality for all four entries after focused entry assertions;
- each of the three exact accepted output lines appears once in a text fence;
  and
- the README contains one fenced transcript whose first line is
  `constraint.unsatisfied` and whose causal prose identifies `Trees.lookup`.

Run accepted entries with `ash_doc_run_accepted`. Add a local
`ash_doc_run_missing_order` helper for the negative entry. It must capture both
channels and status, require status `1`, empty standard output, and first
standard-error line `constraint.unsatisfied`, and require related labels for
the constrained declaration, direct import, and `Order` interface.

The helper must derive the unique byte range of `Trees.lookup` from the
canonical `04-missing-order.ash` source rather than copying prototype offsets.
Run byte-oriented matching under `LC_ALL=C`, require exactly one occurrence,
compute its exclusive end from the matched spelling length, and assert that
the diagnostic's primary line begins with:

```text
primary: source 0 <derived-start>..<derived-end>:
```

This directly proves that the emitted diagnostic points to the intended
constrained occurrence while allowing its position to follow canonical-source
edits. The README may display the observed diagnostic, but neither lesson
prose nor verifier logic treats colors, gutters, hard-coded byte offsets, or
the remaining presentation prose as the contract.

### Step 2: Make the verifier executable and check its shell

Run:

```bash
chmod +x content/cases/abstracting-key-order/checks/verify.sh
bash -n content/cases/abstracting-key-order/checks/verify.sh
shellcheck -x content/cases/abstracting-key-order/checks/verify.sh
```

Expected: all three commands succeed with no findings.

### Step 3: Prove the first RED

Run:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/abstracting-key-order/checks/verify.sh "$ASH_DOC_PIN"
```

Expected: status `1`, empty standard output, and exactly:

```text
verify: missing canonical source: src/ordered_trees.ash
```

### Step 4: Review the RED contract

Give a fresh high-reasoning reviewer the approved design, complete verifier,
first RED transcript, case-6 verifier, and shared helper. Require it to check
the five-source boundary, assertion ordering, exact accepted/rejected channel
contracts, mutation feasibility, and absence of implementation content.

The same implementer fixes findings. The reviewer rechecks every correction.
Do not commit Task 1 separately.

## Task 2: Add exact canonical programs and reach the second RED

**Files:**

- Create: all five files under
  `content/cases/abstracting-key-order/src/`
- Do not create the case README yet.

### Step 1: Add the exact shared module

Use `apply_patch` to add exactly:

<!-- markdownlint-disable MD013 -->
```ash
pub type Tree<K, V> =
    Empty
    | Node(Tree<K, V>, K, V, Tree<K, V>)

pub type Ordering =
    Less
    | Equal
    | Greater

pub type Option<A> =
    None
    | Some(A)

pub type Natural =
    Zero
    | Next(Natural)

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(left, key, value, right) = match compare query key {
    Less => lookup query left
    Equal => Some(value)
    Greater => lookup query right
}

pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>
insert key value Empty = Node(Empty, key, value, Empty)
insert key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert key value right)
}

pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>
lookup_counted query Empty = (None, 0)
lookup_counted query Node(left, key, value, right) = match compare query key {
    Less => {
        let (found, later_comparisons) = lookup_counted query left
        (found, later_comparisons + 1)
    }
    Equal => (Some(value), 1)
    Greater => {
        let (found, later_comparisons) = lookup_counted query right
        (found, later_comparisons + 1)
    }
}

maximum : Natural -> Natural -> Natural
maximum Zero right = right
maximum left Zero = left
maximum Next(left) Next(right) = Next(maximum left right)

pub height : Tree<K, V> -> Natural
height Empty = Zero
height Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))
```
<!-- markdownlint-enable MD013 -->

Confirm its SHA-256 is:

```text
d0614a78b861e68cecf56b477fde6eab0ae18113c860880e18ffb89dfeb8ac2e
```

### Step 2: Add the exact accepted entries

Add `src/01-lookup.ash`:

```ash
import ordered_trees as Trees

main : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let valid = Trees.Node(
        Trees.Node(Trees.Empty, one, 10, Trees.Empty),
        two,
        20,
        Trees.Node(Trees.Empty, three, 30, Trees.Empty)
    )
    (
        Trees.lookup_counted three valid,
        Trees.lookup_counted Trees.Zero valid
    )
}
```

Add `src/02-replace-and-malformed.ash`:

```ash
import ordered_trees as Trees

main : Unit -> (Trees.Option<Int>, Trees.Option<Int>, Trees.Option<Int>)
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let with_two = Trees.insert two 20 Trees.Empty
    let original = Trees.insert one 10 with_two
    let replaced = Trees.insert one 99 original
    let malformed = Trees.Node(
        Trees.Node(Trees.Empty, two, 20, Trees.Empty),
        one,
        10,
        Trees.Empty
    )
    (
        Trees.lookup one original,
        Trees.lookup one replaced,
        Trees.lookup two malformed
    )
}
```

Add `src/03-ascending.ash`:

<!-- markdownlint-disable MD013 -->
```ash
import ordered_trees as Trees

main : Unit -> (Trees.Tree<Trees.Natural, Int>, Trees.Natural, (Trees.Option<Int>, Int))
main () = {
    let one = Trees.Next(Trees.Zero)
    let two = Trees.Next(one)
    let three = Trees.Next(two)
    let after_one = Trees.insert one 10 Trees.Empty
    let after_two = Trees.insert two 20 after_one
    let after_three = Trees.insert three 30 after_two
    (
        after_three,
        Trees.height after_three,
        Trees.lookup_counted three after_three
    )
}
```
<!-- markdownlint-enable MD013 -->

Confirm their hashes in order are:

```text
930c3fee7dd21464e9e05f748ea04b7958f7a12ce039eaf8652b6b4d70be8a6a
a9df09b4bdcc772ffdbbee9225d09595d58f4e1ee928eb749e7dd7ae74e5a716
86acde221897f576ba5ce3cd9a8f3349b5ef91cb69fc6a2608fbd9dffb2b5321
```

### Step 3: Add the exact rejected entry

Add `src/04-missing-order.ash`:

```ash
import ordered_trees as Trees

main : Unit -> Trees.Option<Int>
main () = {
    let tree = Trees.Node(Trees.Empty, 1, 10, Trees.Empty)
    Trees.lookup 1 tree
}
```

Confirm its SHA-256 is:

```text
32f09f0fe53774d4a9104b13e1741101385fe40dfae53554453ac65a44843818
```

### Step 4: Run all entries directly at the exact pin

Run the three accepted entries with the pinned binary and assert status `0`,
empty standard error, and these exact lines:

<!-- markdownlint-disable MD013 -->
```text
((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))
(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)
(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : (Tree<Natural, Int>, Natural, (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

Run the negative entry and assert status `1`, empty standard output, and this
stable first standard-error line:

```text
constraint.unsatisfied
```

Inspect the complete diagnostic and confirm the primary label covers exactly
`Trees.lookup`; related labels retain the constrained declaration, direct
import, and `Order` interface. Do not carry prototype byte offsets into the
lesson contract.

### Step 5: Prove the verifier advances to its second RED

Run the local verifier. Expected: status `1`, empty standard output, and:

```text
verify: missing unit README.md
```

### Step 6: Review the sources and second RED

Give a fresh xhigh specification reviewer the approved design, exact sources,
all direct transcripts, verifier, and second RED. Require it to check interface
well-formedness, implementation ownership and visibility, abstract and current
evidence reuse, direct call-site selection, preserved behavior/cost, and the
negative obligation owner.

Only after specification review passes, give a different high-reasoning
quality reviewer the same payload. Require focused names, source style,
complete entries, deterministic observations, and readable verifier failures.
The same implementer fixes findings; each reviewer rechecks its own findings.
Do not commit Task 2 separately.

## Task 3: Write, verify, review, and commit the complete case

**Files:**

- Create: `content/cases/abstracting-key-order/README.md`
- Modify if review requires: the case-local verifier and five sources only.

### Step 1: Write one connected chapter

Use the approved design's teaching sequence and the project writing skill.
Begin with the repeated comparator argument from the preceding chapter, not
with project metadata or a specification inventory. The chapter must:

- state the question and the source-argument-to-checking-evidence boundary;
- introduce the public one-method interface and Natural implementation;
- explain why the implementation must be public for direct dependents;
- rewrite each tree API signature with explicit `where Order<K>`;
- trace one imported Natural call through ordinary type determination and
  concrete evidence selection;
- explain abstract evidence reuse inside constrained recursive globals and
  exact current evidence in recursive implementation methods;
- display and run all five complete canonical sources;
- preserve the three accepted outputs and their case-6 interpretations;
- explain that `Order<A>` does not establish order laws, tree validity,
  finiteness, return, balance, or opacity;
- retain the exact `C`, `m`, `h`, `Cmax`, insertion, cycle, and height premises
  from the approved design;
- distinguish what successful CLI output observes from what the pinned
  elaboration and retained tests establish;
- explain ordinary evidence binders/applications and erasure without using
  runtime dictionary, registry, lookup, or dynamic-dispatch language;
- predict and run the missing `Order<Int>` rejection, teaching stable reason
  and causal source location rather than diagnostic presentation;
- keep the split-module regression candidate out of rendered lesson prose;
- include bounded practice about call-site obligations, implementation
  visibility, and an unsupported key type; and
- end by asking how opacity can prevent clients from constructing malformed
  trees.

Link each semantic conclusion to the nearest governing pinned section. Cite
the retained tests by their exact names where the lowering boundary is taught,
while stating that they inspect compiler structure unavailable through CLI
output.

### Step 2: Reach GREEN and run the focused upstream tests

Run:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/abstracting-key-order/checks/verify.sh
shellcheck -x content/cases/abstracting-key-order/checks/verify.sh
bash content/cases/abstracting-key-order/checks/verify.sh "$ASH_DOC_PIN"
```

Expected local result:

```text
Verified 5 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

Use one fresh temporary Cargo target and run the three exact focused test
commands from the design. Expected: one test passes in each invocation, no
failure, and the clean pin remains at the exact commit.

### Step 3: Prove focused assertions fail

Record the original hashes of every canonical source. Use `apply_patch` for one
mutation at a time, run the local verifier, record status `1` and the intended
message, restore with `apply_patch`, and require GREEN before the next mutation.
Never use `git checkout`, `git restore`, or a bulk destructive rewrite.

Prove at least these fourteen failures:

1. remove `pub` from `interface Order<A>`;
2. change the method signature away from `A -> A -> Ordering`;
3. remove `pub` from `impl Order<Natural>`;
4. change `compare Zero Next(right) = Less`;
5. change recursive `compare left right` to retain one outer operand;
6. remove `where Order<K>` from `lookup`;
7. change lookup's `Less` arm to enter `right`;
8. add an explicit comparator argument to one recursive lookup call;
9. remove `where Order<K>` from `insert`;
10. replace `current_key` with the incoming key in the `Equal` insertion arm;
11. remove `where Order<K>` from `lookup_counted`;
12. remove the `+ 1` from the counted `Less` arm;
13. add `Trees.compare_natural` to one accepted tree-operation call; and
14. move the negative call away from the exact `Trees.lookup 1 tree` line.

After the matrix, require all five hashes to equal their originals and rerun
GREEN. The verifier's final whole-file assertions supplement rather than
replace these focused causal messages.

### Step 4: Run pre-review verification

Run Markdownlint, optional `typos`, the exact relative-link loop already used
by earlier cases, Bash syntax, ShellCheck, the local verifier, all Learn checks,
all Cases checks, `git diff --check`, and `git status --short`. Read the README,
verifier, and all five sources fully as source.

Expected before integration: the local verifier reports five sources; 11 Learn
lessons pass; the aggregate discovers and reports 7 Cases and 33 sources even
though the Cases index still lists six. Only the new case directory differs
from the already committed design-and-plan state.

### Step 5: Review the complete GREEN case

First give a fresh xhigh specification reviewer the complete case, approved
design and plan, direct output, focused test output, mutation transcripts, and
exact pin. Require review of every language/tool claim, evidence selection and
lowering boundary, invariant and cost premise, negative diagnostic ownership,
and source/check agreement.

Only after specification approval, give a different high-reasoning quality
reviewer the complete files and evidence. Require a connected lesson, precise
vocabulary, readable examples, continuity, attribution status, practice, and
intentional exclusions. Apply technically verified feedback and obtain
re-review from the reviewer that raised it.

### Step 6: Commit the complete case

Run fresh local, Markdown, shell, focused-test, and aggregate verification.
Then commit only the complete case directory:

```bash
git add content/cases/abstracting-key-order
git commit --no-gpg-sign -m "docs: teach abstracting key order"
git diff --check HEAD^..HEAD
git status --short --branch
```

Expected: the case commit succeeds. Only the already committed design/plan and
roadmap links remain outside that commit; the worktree is otherwise clean.

## Task 4: Draft, review, and close repository integration

**Files:**

- Modify: `README.md`
- Modify: `content/cases/README.md`
- Modify: `docs/project/roadmap.md`
- Delete only after closure approval: the two case-7 temporary records.

### Step 1: Preserve later provisional text

Before integration edits, extract cases 9 through 12 from the roadmap and
record this SHA-256:

```text
ac255510168d24816a7efc0aff7ae6dba7f3481f34cd15ddc5523d041dc927bc
```

Use the section from `### 9. Guaranteeing logarithmic retrieval` up to but not
including `## Promotion and verification policy`. After every roadmap edit,
require byte equality with the preserved section.

### Step 2: Draft integration while both records remain active

Update root navigation from six to seven verified unpublished Cases and add a
compact summary of interface-based ordering after the ordered-tree case.

Add item 7 to the Cases index using the exact reader question and a concise
description of selected ordering evidence, unchanged tree behavior, and the
missing-implementation boundary.

Move `Abstracting key order` under `Verified increments` as item 7. Record:

- five canonical sources;
- the same three accepted outputs at the exact pin;
- the public `Order<A>` interface and public Natural implementation;
- constrained APIs without comparator value arguments;
- concrete evidence selection at imported Natural calls, abstract reuse inside
  constrained globals, and exact-current reuse in the recursive method;
- CLI limits and the specified/test-inspected ordinary Core lowering;
- `Order<Int>` rejection at `Trees.lookup`, empty stdout, reason
  `constraint.unsatisfied`, and status `1`;
- preserved comparator-law, global-invariant, insertion, cost, finiteness,
  cycle, transparency, malformation, height, and no-balance boundaries;
- runtime-registry, dispatch, zero-overhead, machine-cost, and later-feature
  exclusions; and
- exact verification at the pinned Ash commit.

Retain one temporary sentence linking both active case-7 records while closure
review remains in progress.

Promote case 8 to `## Next: protecting the dictionary invariant`. Preserve its
audited question and content, then add the standard gate requiring an approved
bounded design and active temporary implementation plan before content or
source materialization. Keep cases 9 through 12 provisional, in the same order,
and byte-for-byte unchanged.

Do not place the split-module regression candidate in the durable verified-case
summary. It is an avoided implementation defect, not part of the reader-facing
outcome. Do not create an upstream record without a separate bounded decision.

### Step 3: Verify the integration draft

Run:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
bash -n content/cases/abstracting-key-order/checks/verify.sh
shellcheck -x content/cases/abstracting-key-order/checks/verify.sh
bash content/cases/abstracting-key-order/checks/verify.sh "$ASH_DOC_PIN"
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
```

Also run the exact relative-link loop, the three focused pinned tests, the
cases-9-through-12 byte comparison, `git diff --check`, status, tag, pin, and
clean-pin checks. Count local verifiers and Case sources.

Expected: 11 Learn lessons, 7 Cases, and 33 canonical Case sources pass; the
documentation tag and Ash pin match the fixed commits; only the three
integration files are modified; both temporary records remain tracked and
linked; cases 9 through 12 retain the fixed hash.

### Step 4: Run sequential closure reviews

Give a fresh xhigh specification reviewer the approved records, case commit,
all exact observations, focused tests, mutations, integration diff, full
roadmap, and byte-preservation evidence. Require language/tool authority,
evidence/lowering boundaries, exact counts, durable case summary, case-8
promotion, later non-authorization, and both active links.

Only after specification approval, give a different xhigh quality reviewer the
same payload and all changed project files. Require clear prose, working
navigation, complete durable evidence, exact later-case preservation, and a
reviewable deletion boundary. Apply verified findings and have each reviewer
recheck its own changes. Rerun Step 3 after every correction.

### Step 5: Delete exactly the temporary records and close

After both reviews and a fresh GREEN, use `apply_patch` to remove the active
review sentence and delete exactly:

```text
docs/plans/2026-08-30-abstracting-key-order-design.md
docs/plans/2026-08-30-abstracting-key-order.md
```

Require no live reference to either filename. Read the three permanent
integration files fully as source and rerun every Step 3 check. Commit:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md \
    docs/plans/2026-08-30-abstracting-key-order-design.md \
    docs/plans/2026-08-30-abstracting-key-order.md
git commit --no-gpg-sign -m "docs: verify abstracting key order case"
git diff --check HEAD^..HEAD
git status --short --branch
```

Expected: the closure commit is clean and history retains both removed records.

## Task 5: Final review, local merge, and cleanup

### Step 1: Review the closed branch

Give one fresh xhigh whole-branch reviewer base `9de839d`, feature HEAD, the
full branch diff, recovered deleted design/plan, all final files, direct and
aggregate outputs, focused tests, fourteen mutation transcripts, cases-9-
through-12 byte evidence, and exact tag/pin. Require correctness, regression,
test, writing, authority, and workflow findings ordered by severity.

Apply technically verified feedback only within the authorized paths. Obtain
re-review. Commit a review correction only if a file actually changes:

```text
docs: address abstracting key order review
```

### Step 2: Run final feature verification

Run Bash syntax, ShellCheck, Markdownlint, optional spelling, relative links,
the local verifier, all Learn and Cases checks, three focused pinned tests,
11/7/33 counts, cases-9-through-12 byte equality, live-record reference check,
branch diff check, clean branch and pin checks, and exact tag/pin resolution.

Read `git diff 9de839d...HEAD` and every changed file as source. Do not claim
success from an earlier transcript.

### Step 3: Merge locally without pushing

Confirm local `main` is clean and still descends from `9de839d`. Inspect any
unexpected movement before merging. Merge with:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    -m "Merge branch 'abstracting-key-order'" abstracting-key-order
```

Do not push.

From local `main`, rerun the complete merged-state checks while excluding
`.worktrees/**` from repository-wide Markdown and link discovery. Require 11
Learn lessons, 7 Cases, 33 sources, exact focused tests, clean `main`, clean
pin, and the fixed tag/pin commits.

Only after merged verification passes, confirm the feature worktree is clean,
remove it, and delete the merged branch:

```bash
git -C /home/dikini/Projects/ash-doc worktree remove \
    /home/dikini/Projects/ash-doc/.worktrees/abstracting-key-order
git -C /home/dikini/Projects/ash-doc branch -d abstracting-key-order
```

Keep the autonomous remaining-cases goal active. Begin case 8's bounded design
only after this checkpoint.
