# Guaranteeing logarithmic retrieval implementation plan

Status: approved on 2026-08-30 after independent specification and execution
review

> Execute this plan one task at a time. It is active only while linked from the
> roadmap and leaves the live tree after reviewed repository closure.

## Goal and fixed design

Answer the reader's question: **How can the representation prevent a search
tree from degenerating?**

The crossed boundary is case 8's opaque but height-unconstrained dictionary
versus an opaque persistent red-black dictionary whose public insertion
preserves global ordering, a black root, no red parent with a red child, and
equal black-height under explicit premises. Every selected insertion prefix
must remain valid and retain its exact key-value associations. The source
equations and invariant argument establish the general height bound; finite
executions expose the named failures but do not prove the theorem.

The approved bounded design is
[`2026-08-30-guaranteeing-logarithmic-retrieval-design.md`](2026-08-30-guaranteeing-logarithmic-retrieval-design.md).
It owns the authority, representation, API, algorithm, invariant, evidence,
cost, regression, attribution, exclusion, and closure decisions. Do not widen
the case beyond it.

Create exactly one lesson boundary:

```text
content/cases/guaranteeing-logarithmic-retrieval/
```

It contains exactly:

```text
README.md
checks/verify.sh
src/dictionaries.ash
src/01-prefix-matrix.ash
src/02-build-and-persistence.ash
```

Do not add a fixture, renderer, manifest, dependency, CI service, shared
dictionary module, diagnostic entry, or harness change. Use the existing
Cases helper.

## Fixed identities and executable evidence

Feature base before the design commit:

```text
46ea960a2f078fbe64a5c5c3d76e96ac83b93668
```

Approved design commit:

```text
d48da4a2efc138cbded9700b9189a6a9fce508cc
```

Clean pinned Ash checkout:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Use this task-specific shell variable in plan commands:

```bash
ASH_DOC_CASE9_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Exact Ash commit:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

Immutable ash-doc tag commit:

```text
e963a1597176f86003926eef827498db2a661b75
```

The disposable exact-pin prototype is retained only while this case is active
at:

```text
/tmp/ash-doc-case9-final-prototype
```

Its three accepted entries exit `0`, write empty standard error, and produce
the exact values in Appendix D. Their fixed SHA-256 values are:

```text
9406176b03322ce58d415b08064ccb8adf05bb0529a2280b9c4f71255e03105d  dictionaries.ash
eb56359bf329db9cf8e0c35ecad85efd9c39129b1da59f8024d577703d45282e  01-prefix-matrix.ash
71303da79f31bf9d0071c3c8ffe698d76318a29b9e76865fb862ab67af3edeab  02-build-and-persistence.ash
```

Retain these focused pinned tests for the source-access boundary inherited
from case 8:

<!-- markdownlint-disable MD013 -->
```bash
(
    cd "$ASH_DOC_CASE9_PIN"
    cargo test --locked --test module_visibility opaque_constructors_remain_available_inside_their_defining_module -- --exact
    cargo test --locked --test spec_examples overview_opaque_smart_constructor_example_is_executable -- --exact
    cargo test --locked --test interface_modules rejects_external_opaque_constructor_and_pattern_in_impl_body -- --exact
    cargo test --locked --test module_elaboration_nominals imported_opaque_nominal_is_not_an_empty_constructor_family -- --exact
)
```
<!-- markdownlint-enable MD013 -->

The equation-level tuple-pattern failure retained from case 8 remains a
specified-behavior regression candidate. Preserve the accepted one-arm body
match in `insert_entry`; do not teach or re-record the regression.

The exact-pin prototype also minimizes a client-owned implementation of an
imported public interface to status `2`, empty standard output, and
`evidence.validation.unknown-identity`. Use only the module-owned public
`Order<Natural>` fact and exact repeated Natural keys. Do not publish a
workaround or a durable evidence record unless the completed immutable case
later supplies wider upstream value.

## Task 1: Add the verifier first and prove RED

### Step 1: Confirm the content boundary is absent

Run:

```bash
test ! -e content/cases/guaranteeing-logarithmic-retrieval
git status --short --branch
git rev-parse HEAD
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_CASE9_PIN" rev-parse HEAD
git -C "$ASH_DOC_CASE9_PIN" status --short
```

Expected: no lesson boundary; a clean feature branch at the committed plan;
the fixed documentation tag; and the clean exact Ash pin.

### Step 2: Create only the selected directories and verifier

Run:

```bash
mkdir -p content/cases/guaranteeing-logarithmic-retrieval/src
mkdir -p content/cases/guaranteeing-logarithmic-retrieval/checks
```

Use `apply_patch` to add
`content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh`. Follow the
local verifier pattern and source the existing `content/checks/lib.sh`.

The verifier must:

- require one clean checkout at the fixed pin;
- declare exactly the three fixed canonical sources in their displayed order;
- reject any missing source or additional top-level `src/*.ash` file;
- keep focused whole-source assertions ahead of fixed hashes and executions;
- run all three entries with status `0`, empty standard error, and Appendix D's
  exact complete output;
- check all three hashes after mutation-facing assertions;
- require one marked executable block per source and exact byte agreement with
  the canonical file; and
- require the three exact output lines once each in rendered `text` fences.

Keep local assertion helpers inside this verifier. Do not generalize the shared
helper for one case. Make the file executable, then run:

```bash
chmod +x content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh
bash -n content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh
shellcheck -x content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh
```

Expected: Bash and ShellCheck pass.

### Step 3: Run the first RED

Run:

```bash
bash content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh \
    "$ASH_DOC_CASE9_PIN"
```

Expected: status `1` and the focused missing-source message for
`src/dictionaries.ash`. If README or tool checks run first, correct verifier
ordering before adding source.

## Task 2: Add the three exact canonical programs

### Step 1: Add the red-black dictionary module

Use `apply_patch` to add
`content/cases/guaranteeing-logarithmic-retrieval/src/dictionaries.ash`
byte-for-byte from Appendix A.

The verifier must independently assert:

- one private two-form `Color`, one private `BalanceCheck`, and one public
  opaque `Dictionary<K, V>` with the color payload;
- the unchanged public representations, interface, Natural implementation,
  and exact signatures of `empty`, `lookup`, `insert`, `build`, and
  `invariant_holds`;
- both lookup branches and the stored value result;
- one `restore_three` whose increasing key-value associations occupy one red
  middle root and two black children;
- four separately identifiable `restore Black` nested-pattern orientations
  and exactly one one-node fallback;
- a red leaf, constrained left and right insertion, and equal replacement that
  retains the stored key, color, and branches;
- `blacken_root` returning `Empty` and an already-black dictionary unchanged,
  with one construction only for a red root;
- public `insert` composing `insert_colored` and `blacken_root`;
- accumulator-first strict `fold_left`, the accepted tuple body match, and
  `build entries = fold_left insert_entry (empty ()) entries`;
- both global ordering comparisons, propagated lower and upper bounds, both
  bound results, and both recursive results before Boolean combination;
- both child balance summaries before their tuple match, immediate red-child
  checks, one child-height equality, red height reuse, black height increment,
  and the separate root-color check;
- three explicitly bound public validation results before combination; and
- the exact five private fixtures and their ordered result tuple.

Run the dictionary entry directly. Its exact output is Appendix D.1.

### Step 2: Add the complete prefix matrix

Use `apply_patch` to add `src/01-prefix-matrix.ash` byte-for-byte from
Appendix B.

Require source assertions for:

- the exact `PrefixCheck` and `Scenario` observable shapes;
- the empty-prefix validity field;
- every nonempty prefix's invariant, exact new association, exact retained
  association, and fixed absence;
- final exact association checks ending in the fixed absence;
- ascending `1..7`, descending `7..1`, and the LL, LR, RL, RR sequences in
  that order, with distinct values tied to each key; and
- all six calls with their correct first retained association and `Zero`
  absence.

Run the entry directly. Its exact output is Appendix D.2.

### Step 3: Add build and persistence evidence

Use `apply_patch` to add `src/02-build-and-persistence.ash` byte-for-byte from
Appendix C.

Require source assertions for:

- the old two-entry dictionary, equal-key replacement, extension of only the
  newer value, and independent finite build;
- the input order `(two, 20)`, `(one, 10)`, `(two, 99)`, `(three, 30)`;
- all four invariant observations;
- old/replaced/built lookup of key `two`; and
- old/extended/built lookup of key `three`.

Run the entry directly. Its exact output is Appendix D.3.

### Step 4: Confirm fixed programs and the second RED

Run:

```bash
sha256sum content/cases/guaranteeing-logarithmic-retrieval/src/*.ash
"$ASH_DOC_CASE9_PIN/target/debug/ash" \
    content/cases/guaranteeing-logarithmic-retrieval/src/dictionaries.ash
"$ASH_DOC_CASE9_PIN/target/debug/ash" \
    content/cases/guaranteeing-logarithmic-retrieval/src/01-prefix-matrix.ash
"$ASH_DOC_CASE9_PIN/target/debug/ash" \
    content/cases/guaranteeing-logarithmic-retrieval/src/02-build-and-persistence.ash
bash content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh \
    "$ASH_DOC_CASE9_PIN"
```

Expected: the fixed hashes and exact accepted outputs pass; the local verifier
then stops only at the focused missing-README condition.

## Task 3: Write one complete case and reach GREEN

### Step 1: Draft the chapter around causal observations

Use `apply_patch` to add
`content/cases/guaranteeing-logarithmic-retrieval/README.md`. Do not render an
administrative target, source inventory, governing-source list, or evidence
report. Continue directly from case 8.

Use this teaching order:

1. reopen the ascending-chain `h = n` boundary left by opacity;
2. introduce the private color field and distinguish recursive ordering,
   red-child, and black-height conditions from the public black-root condition;
3. explain the strict two-pass validator and predict the five private cases;
4. explain why a red leaf preserves black-height but may create red-red;
5. derive exactly four repairs from the two left/right choices and use one
   original association-preserving normalization diagram;
6. explain that reconstruction removes red-red and final blackening restores
   only the root-color condition;
7. display the complete marked dictionary module, predict, run, and reflect on
   Appendix D.1;
8. predict, display, and run the complete six-scenario prefix matrix, then
   reflect that finite evidence catches named mutations while source reasoning
   supports the general preservation claim;
9. predict, display, and run build, replacement, extension, retained older
   values, and colored structural observation;
10. derive `h <= 2 * (q - 1)`, the minimum-node recurrence,
    `h <= 2 * log2(n + 1)`, exact comparison-method subwork, absent-insertion
    `Node` applications, equal replacement, and the separate validator work;
11. state the finite-return, cycle, source-reuse, and non-runtime boundaries;
    and
12. give the fixed practice prompts and end at the eager-iterator question.

Use prose and original labeled `text` diagrams before the complete executable
blocks. Do not put incomplete Ash in an `ash` fence. Mark the three canonical
blocks exactly:

```text
<!-- source: src/dictionaries.ash -->
<!-- source: src/01-prefix-matrix.ash -->
<!-- source: src/02-build-and-persistence.ash -->
```

Link semantic claims to the exact pinned specification sections selected by
the design. Attribute persistent red-black insertion only as conceptual
inspiration through the permanent research record; do not reproduce Okasaki or
Software Foundations equations, figures, prose, names, or exercise order.

### Step 2: Fix the explanations and practice

The prose must explicitly retain these distinctions:

- opacity prevents importing modules from constructing malformed values; it
  does not prove the defining module's operations or representation laws;
- a recursively consistent subtree may have a red root, while a completed
  public dictionary may not;
- every repair keeps each value paired with its key and passes four surrounding
  subtrees unchanged into new constructors;
- the output's `Red` and `Black` spellings do not export private constructors;
- the prefix matrix and private fixtures are finite evidence, not exhaustive
  proof;
- the general guarantee assumes one fixed lawful, returning comparator and
  finite valid input produced through completed public operations;
- `m + 1 + 2r + b` counts evaluated source `Node` applications for absent
  insertion, not allocations;
- equal replacement constructs exactly `m` nodes after entering `m` existing
  nodes and does not repair;
- two validation passes are linear outside comparison-method subwork and are
  excluded from the lookup/insertion bound; and
- no pointer identity, physical sharing, heap, mutation, elapsed-time,
  native-stack, tail-call, garbage-collection, or compiler claim is made.

Practice asks the reader to:

1. predict the repair and colors for `5, 3, 4`;
2. explain why equal replacement creates no red leaf;
3. derive the constructor count from `m`, `r`, and `b`;
4. explain why root blackening changes every path's black count equally; and
5. connect equal black-height and no adjacent red nodes to the minimum-node
   recurrence and final height bound.

### Step 3: Run the first complete GREEN

Run:

```bash
bash content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh \
    "$ASH_DOC_CASE9_PIN"
```

Expected:

```text
Verified 3 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

## Task 4: Prove mutation-facing evidence and review the chapter

### Step 1: Run the focused mutation matrix

For every mutation below, use `apply_patch`, run the local verifier, record its
focused failure message and status, restore with `apply_patch`, and rerun
GREEN. Do not rely on the final hash as the first failure.

1. remove `opaque`, then separately make `Color` public;
2. point the `Less` lookup branch at `right`, then separately point `Greater`
   at `left`;
3. construct the new leaf as black;
4. disable each LL, LR, RL, and RR repair pattern independently;
5. swap one key-value association in `restore_three`;
6. change the restore fallback's supplied color or one supplied branch;
7. reconstruct equal replacement with the incoming key or old value;
8. reconstruct an already-black root, then separately leave a red root red;
9. change public `insert` to omit either private phase;
10. change `fold_left` argument order, the initial dictionary, the
    `insert_entry` body match, or the build combiner;
11. reverse either ordering-bound comparison and each propagated bound in
    turn;
12. remove either recursive ordering result from the final combination;
13. remove either child balance summary binding;
14. accept a red child, skip child-height equality, skip the black increment,
    or accept a red root;
15. alter each private valid/invalid fixture independently, then alter its
    corresponding result position;
16. alter each scenario's empty validity, a prefix invariant, new association,
    retained association, absence, or final association group;
17. change each of the six insertion sequences independently;
18. change one old/replaced/extended/built construction step;
19. change one build input pair or its order; and
20. remove one invariant or lookup observation from the persistence result.

After the matrix, require all three fixed hashes and rerun GREEN. Retain the
mutation transcript for reviewers; do not commit disposable mutant files.

### Step 2: Run pre-review verification

Run:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
bash -n content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh
shellcheck -x content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh
bash content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh \
    "$ASH_DOC_CASE9_PIN"
bash content/learn/checks/verify.sh "$ASH_DOC_CASE9_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_CASE9_PIN"
```

Run the exact relative-link loop in Appendix E, the four focused pinned tests,
all three hashes, `git diff --check`, exact pin/tag checks, and status. Read the
chapter, verifier, and all three sources fully as source.

Before navigation exists, the aggregate Cases verifier discovers the directory
and must report:

```text
11 Learn lessons
9 Cases
42 canonical Case sources
```

### Step 3: Obtain sequential chapter reviews

Give one independent high-rigor specification reviewer the approved design,
plan, pinned specification and tool guide, three complete sources and outputs,
four focused tests, mutation transcript, chapter, verifier, research record,
and status. Require findings by severity for authority, representation access,
all four invariants, insertion preservation, exact association retention,
validator strictness, cost derivations, return/cycle limits, regression
classification, attribution, exclusions, and verifier adequacy.

Only after specification approval, give a different high-rigor instructional
reviewer the same evidence. Require continuity from case 8, prediction before
observation, the recursive-versus-root distinction, the four-case derivation,
association-preserving normalization, proof readability, finite-evidence
reflection, practice, and transition to case 10.

Apply technically verified findings with `apply_patch`, rerun affected checks,
and obtain re-review until both approve.

### Step 4: Commit the complete case

Stage only:

```text
content/cases/guaranteeing-logarithmic-retrieval/
```

Run:

```bash
git diff --cached --check
git status --short
git commit --no-gpg-sign -m "docs: teach logarithmic dictionary retrieval"
```

Expected: one narrow content commit and a clean worktree. The approved design,
implementation plan, and roadmap links are already committed separately.

## Task 5: Integrate, review, and close the case

### Step 1: Draft permanent navigation and roadmap state

Update only:

```text
README.md
content/cases/README.md
docs/project/roadmap.md
```

Root and Cases navigation must report nine verified cases and link the new
chapter in sequence.

Replace the active case-9 roadmap section with a durable verified summary that
retains:

- the three sources and three successful exact observations;
- the private color field, opaque public identity, unchanged API, and module
  ownership boundary;
- recursive ordering/red-child/black-height and top-level black-root
  conditions;
- red leaf, four repairs, association retention, root blackening, build,
  replacement, and persistent older values;
- the complete prefix matrix and what finite evidence does not prove;
- height, comparator-method, absent-insertion, equal-replacement, and validator
  work accounts;
- ordering-law, return, cycle, structural observation, and source-reuse
  boundaries;
- source-tradition classification and both quarantined regression candidates;
  and
- deliberate exclusions without turning evidence into Ash semantics.

Promote case 10 only to `## Next: resuming tree traversal`. Require its own
bounded design and implementation plan before content. Preserve the provisional
case-11 and case-12 block byte-for-byte; its fixed current hash is:

```text
2c4b5d51e942c43c2819c36e6918202d0d84b97bb356e960956bd2e9f35486b2
```

Reproduce it before and after integration with:

```bash
awk '
    /^### 11\. / { keep = 1 }
    /^## Promotion and verification policy/ { keep = 0 }
    keep { print }
' docs/project/roadmap.md | sha256sum
```

Retain temporary links to both case-9 plans while closure review is active.

### Step 2: Verify the integration draft

Rerun Markdownlint, optional spelling, Appendix E's relative links, Bash,
ShellCheck, the local/Learn/Cases verifiers, four focused pinned tests, hashes,
11/9/42 counts, the case-11/12 byte hash, exact tag and pin, clean pin,
`git diff --check`, and status. Read all three permanent integration files.

### Step 3: Run sequential closure reviews

Give a fresh high-rigor specification reviewer the approved records, complete
case commit, mutation transcript, exact evidence, integration diff, full
roadmap, and byte-preservation result. Require authority, invariant and cost
accuracy, source classification, durable summary completeness, case-10 gate,
later non-authorization, and temporary-link findings.

Only after approval, give a different high-rigor quality reviewer the same
payload. Require clear navigation, coherent evidence summary, accurate
attribution, workflow compliance, and a reviewable deletion boundary.

Apply verified feedback and obtain re-review.

### Step 4: Cross the temporary-record deletion boundary

Only after both closure reviewers approve:

1. remove the temporary roadmap links;
2. delete exactly this implementation plan and the approved case-9 design with
   `apply_patch`; and
3. confirm no live file references either completed record.

Read every changed permanent file fully. Rerun the complete verification set,
including 11/9/42, the case-11/12 hash, no-live-reference checks, exact tag and
pin, and clean pin.

Commit closure:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md \
    docs/plans/2026-08-30-guaranteeing-logarithmic-retrieval-design.md \
    docs/plans/2026-08-30-guaranteeing-logarithmic-retrieval.md
git diff --cached --check
git commit --no-gpg-sign -m "docs: verify logarithmic retrieval case"
```

## Task 6: Review the closed branch, merge locally, and clean up

### Step 1: Obtain a whole-branch review

Give one fresh high-rigor reviewer base `46ea960`, feature HEAD, full diff,
deleted plans recovered from their commits, final content/project files, exact
outputs, focused tests, mutation transcript, source record, hashes, counts,
tag, and pin. Require correctness, regression, evidence, writing, authority,
attribution, and workflow findings by severity.

Apply technically verified feedback only within authorized paths, obtain
re-review, and create a correction commit only if a file changes.

### Step 2: Run final feature verification

Run the full Markdown, optional spelling, relative-link, Bash, ShellCheck,
local/Learn/Cases, focused-test, hash, 11/9/42, no-live-record, case-11/12,
tag/pin, clean-pin, diff, and status checks. Read the full branch diff and every
changed file as source.

### Step 3: Merge without pushing and verify `main`

Confirm local `main` is clean and still contains base `46ea960`. Merge with an
unsigned no-fast-forward local commit:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    -m "Merge branch 'guaranteeing-logarithmic-retrieval'" \
    guaranteeing-logarithmic-retrieval
```

Do not push.

From merged `main`, rerun the complete verification set while excluding
`.worktrees/**` from repository-wide Markdown and relative-link discovery.
Require 11 Learn lessons, 9 Cases, 42 Case sources, exact focused tests, clean
`main`, clean pin, and fixed tag/pin commits.

Remove the clean feature worktree and delete the merged branch. Begin case 10
only at its bounded design gate; do not create its content before design and
implementation-plan approval. Then dispose of the exact temporary prototype:

From `/home/dikini/Projects/ash-doc`, validate the target before deleting any
file:

```bash
test "$(pwd)" = /home/dikini/Projects/ash-doc
test -d /tmp/ash-doc-case9-final-prototype
test "$(realpath /tmp/ash-doc-case9-final-prototype)" = \
    /tmp/ash-doc-case9-final-prototype
diff -u \
    <(printf '%s\n' \
        01-prefix-matrix.ash \
        02-build-and-persistence.ash \
        dictionaries.ash) \
    <(find /tmp/ash-doc-case9-final-prototype \
        -mindepth 1 -maxdepth 1 -type f -printf '%f\n' | LC_ALL=C sort)
```

Use `apply_patch` from that confirmed working directory to delete exactly:

```text
../../../../tmp/ash-doc-case9-final-prototype/dictionaries.ash
../../../../tmp/ash-doc-case9-final-prototype/01-prefix-matrix.ash
../../../../tmp/ash-doc-case9-final-prototype/02-build-and-persistence.ash
```

Then run:

```bash
test -z "$(find /tmp/ash-doc-case9-final-prototype -mindepth 1 -print -quit)"
rmdir /tmp/ash-doc-case9-final-prototype
test ! -e /tmp/ash-doc-case9-final-prototype
```

## Appendix A: exact dictionary module

Copy this block byte-for-byte.

<!-- markdownlint-disable MD013 -->
```ash
pub type Ordering =
    Less
    | Equal
    | Greater

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

type Color =
    Red
    | Black

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)

type BalanceCheck =
    Invalid
    | Valid(Int)

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(ignored_color, left, current_key, current_value, right) = match compare query current_key {
    Less => lookup query left
    Equal => Some(current_value)
    Greater => lookup query right
}

restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth = Node(
    Red,
    Node(Black, first, first_key, first_value, second),
    middle_key,
    middle_value,
    Node(Black, third, last_key, last_value, fourth)
)

restore : Color -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore Black Node(
    Red,
    Node(Red, first, first_key, first_value, second),
    middle_key,
    middle_value,
    third
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black Node(
    Red,
    first,
    first_key,
    first_value,
    Node(Red, second, middle_key, middle_value, third)
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    Node(Red, second, middle_key, middle_value, third),
    last_key,
    last_value,
    fourth
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    second,
    middle_key,
    middle_value,
    Node(Red, third, last_key, last_value, fourth)
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore color left key value right = Node(color, left, key, value, right)

insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert_colored key value Empty = Node(Red, Empty, key, value, Empty)
insert_colored key value Node(color, left, current_key, current_value, right) = match compare key current_key {
    Less => restore color (insert_colored key value left) current_key current_value right
    Equal => Node(color, left, current_key, value, right)
    Greater => restore color left current_key current_value (insert_colored key value right)
}

blacken_root : Dictionary<K, V> -> Dictionary<K, V>
blacken_root dictionary = match dictionary {
    Empty => Empty
    Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) => dictionary
    Node(Red, left, key, value, right) => Node(Black, left, key, value, right)
}

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value dictionary = blacken_root (insert_colored key value dictionary)

fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated End = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>
insert_entry dictionary entry = match entry {
    (key, value) => insert key value dictionary
}

pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>
build entries = fold_left insert_entry (empty ()) entries

above_lower : Option<K> -> K -> Bool where Order<K>
above_lower None key = true
above_lower Some(lower) key = match compare lower key {
    Less => true
    Equal => false
    Greater => false
}

below_upper : K -> Option<K> -> Bool where Order<K>
below_upper key None = true
below_upper key Some(upper) = match compare key upper {
    Less => true
    Equal => false
    Greater => false
}

both : Bool -> Bool -> Bool
both true right = right
both false right = false

valid_between : Option<K> -> Option<K> -> Dictionary<K, V> -> Bool where Order<K>
valid_between lower upper Empty = true
valid_between lower upper Node(ignored_color, left, key, ignored_value, right) = {
    let respects_lower = above_lower lower key
    let respects_upper = below_upper key upper
    let left_valid = valid_between lower (Some(key)) left
    let right_valid = valid_between (Some(key)) upper right
    both respects_lower (both respects_upper (both left_valid right_valid))
}

is_black : Dictionary<K, V> -> Bool
is_black Empty = true
is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

children_colors_hold : Color -> Dictionary<K, V> -> Dictionary<K, V> -> Bool
children_colors_hold Black left right = true
children_colors_hold Red left right = both (is_black left) (is_black right)

add_black : Color -> Int -> Int
add_black Red height = height
add_black Black height = height + 1

balance_summary : Dictionary<K, V> -> BalanceCheck
balance_summary Empty = Valid(1)
balance_summary Node(color, left, ignored_key, ignored_value, right) = {
    let left_result = balance_summary left
    let right_result = balance_summary right
    let children_hold = children_colors_hold color left right
    match (left_result, right_result) {
        (Invalid, ignored_right_result) => Invalid
        (Valid(ignored_left_height), Invalid) => Invalid
        (Valid(left_height), Valid(right_height)) => match children_hold {
            false => Invalid
            true => match left_height == right_height {
                false => Invalid
                true => Valid(add_black color left_height)
            }
        }
    }
}

balance_holds : Dictionary<K, V> -> Bool
balance_holds dictionary = match balance_summary dictionary {
    Invalid => false
    Valid(ignored_height) => true
}

root_is_black : Dictionary<K, V> -> Bool
root_is_black Empty = true
root_is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
root_is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>
invariant_holds dictionary = {
    let ordered = valid_between None None dictionary
    let balanced = balance_holds dictionary
    let black_root = root_is_black dictionary
    both ordered (both balanced black_root)
}

main : Unit -> (Bool, Bool, Bool, Bool, Bool)
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let four = Next(three)
    let valid = Node(Black, Empty, one, 10, Empty)
    let invalid_order = Node(
        Black,
        Node(Black, Empty, one, 10, Node(Red, Empty, three, 30, Empty)),
        two,
        20,
        Node(Black, Empty, four, 40, Empty)
    )
    let red_root = Node(Red, Empty, one, 10, Empty)
    let red_red = Node(
        Black,
        Node(
            Red,
            Node(Red, Empty, one, 10, Empty),
            two,
            20,
            Node(Red, Empty, three, 30, Empty)
        ),
        four,
        40,
        Empty
    )
    let uneven_black_height = Node(
        Black,
        Node(Black, Empty, one, 10, Empty),
        two,
        20,
        Empty
    )
    (
        invariant_holds valid,
        invariant_holds invalid_order,
        invariant_holds red_root,
        invariant_holds red_red,
        invariant_holds uneven_black_height
    )
}
```

## Appendix B: exact prefix matrix

Copy this block byte-for-byte.

```ash
import dictionaries as Dictionaries

type PrefixCheck =
    PrefixCheck(Bool, Bool, Bool, Bool)

type Scenario =
    Scenario(Bool, Dictionaries.List<PrefixCheck>, Dictionaries.List<Bool>)

type PrefixRun =
    PrefixRun(
        Dictionaries.List<PrefixCheck>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>
    )

has_value : Int -> Dictionaries.Option<Int> -> Bool
has_value expected Dictionaries.None = false
has_value expected Dictionaries.Some(actual) = expected == actual

is_none : Dictionaries.Option<A> -> Bool
is_none Dictionaries.None = true
is_none Dictionaries.Some(ignored_value) = false

prefix_run : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> PrefixRun
prefix_run Dictionaries.End retained_key retained_value absent_key dictionary = PrefixRun(
    Dictionaries.End,
    dictionary
)
prefix_run Dictionaries.More(entry, rest) retained_key retained_value absent_key dictionary = match entry {
    (key, value) => {
        let next_dictionary = Dictionaries.insert key value dictionary
        let current_check = PrefixCheck(
            Dictionaries.invariant_holds next_dictionary,
            has_value value (Dictionaries.lookup key next_dictionary),
            has_value retained_value (Dictionaries.lookup retained_key next_dictionary),
            is_none (Dictionaries.lookup absent_key next_dictionary)
        )
        let later_run = prefix_run rest retained_key retained_value absent_key next_dictionary
        match later_run {
            PrefixRun(later_checks, final_dictionary) => PrefixRun(
                Dictionaries.More(current_check, later_checks),
                final_dictionary
            )
        }
    }
}

lookup_checks : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Dictionaries.List<Bool>
lookup_checks Dictionaries.End absent_key dictionary = Dictionaries.More(
    is_none (Dictionaries.lookup absent_key dictionary),
    Dictionaries.End
)
lookup_checks Dictionaries.More(entry, rest) absent_key dictionary = match entry {
    (key, value) => Dictionaries.More(
        has_value value (Dictionaries.lookup key dictionary),
        lookup_checks rest absent_key dictionary
    )
}

scenario : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Scenario
scenario entries retained_key retained_value absent_key = {
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let run = prefix_run entries retained_key retained_value absent_key empty
    match run {
        PrefixRun(checks, final_dictionary) => Scenario(
            Dictionaries.invariant_holds empty,
            checks,
            lookup_checks entries absent_key final_dictionary
        )
    }
}

main : Unit -> (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let four = Dictionaries.Next(three)
    let five = Dictionaries.Next(four)
    let six = Dictionaries.Next(five)
    let seven = Dictionaries.Next(six)
    let ascending = Dictionaries.More(
        (one, 10),
        Dictionaries.More(
            (two, 20),
            Dictionaries.More(
                (three, 30),
                Dictionaries.More(
                    (four, 40),
                    Dictionaries.More(
                        (five, 50),
                        Dictionaries.More(
                            (six, 60),
                            Dictionaries.More((seven, 70), Dictionaries.End)
                        )
                    )
                )
            )
        )
    )
    let descending = Dictionaries.More(
        (seven, 70),
        Dictionaries.More(
            (six, 60),
            Dictionaries.More(
                (five, 50),
                Dictionaries.More(
                    (four, 40),
                    Dictionaries.More(
                        (three, 30),
                        Dictionaries.More(
                            (two, 20),
                            Dictionaries.More((one, 10), Dictionaries.End)
                        )
                    )
                )
            )
        )
    )
    let left_left = Dictionaries.More(
        (three, 30),
        Dictionaries.More((two, 20), Dictionaries.More((one, 10), Dictionaries.End))
    )
    let left_right = Dictionaries.More(
        (three, 30),
        Dictionaries.More((one, 10), Dictionaries.More((two, 20), Dictionaries.End))
    )
    let right_left = Dictionaries.More(
        (one, 10),
        Dictionaries.More((three, 30), Dictionaries.More((two, 20), Dictionaries.End))
    )
    let right_right = Dictionaries.More(
        (one, 10),
        Dictionaries.More((two, 20), Dictionaries.More((three, 30), Dictionaries.End))
    )
    (
        scenario ascending one 10 Dictionaries.Zero,
        scenario descending seven 70 Dictionaries.Zero,
        scenario left_left three 30 Dictionaries.Zero,
        scenario left_right three 30 Dictionaries.Zero,
        scenario right_left one 10 Dictionaries.Zero,
        scenario right_right one 10 Dictionaries.Zero
    )
}
```

## Appendix C: exact build and persistence entry

Copy this block byte-for-byte.

```ash
import dictionaries as Dictionaries

main : Unit -> (
    (
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>
    ),
    (Bool, Bool, Bool, Bool),
    (
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>
    )
)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let with_two = Dictionaries.insert two 20 empty
    let older = Dictionaries.insert one 10 with_two
    let replaced = Dictionaries.insert two 99 older
    let extended = Dictionaries.insert three 30 replaced
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More(
                (two, 99),
                Dictionaries.More((three, 30), Dictionaries.End)
            )
        )
    )
    let built = Dictionaries.build entries
    (
        (older, replaced, extended, built),
        (
            Dictionaries.invariant_holds older,
            Dictionaries.invariant_holds replaced,
            Dictionaries.invariant_holds extended,
            Dictionaries.invariant_holds built
        ),
        (
            Dictionaries.lookup two older,
            Dictionaries.lookup two replaced,
            Dictionaries.lookup two built,
            Dictionaries.lookup three older,
            Dictionaries.lookup three extended,
            Dictionaries.lookup three built
        )
    )
}
```

## Appendix D: exact successful outputs

### D.1 Dictionary module

```text
(true, false, false, false, false) : (Bool, Bool, Bool, Bool, Bool)
```

### D.2 Prefix matrix

```text
(Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))))))), More(true, More(true, More(true, More(true, More(true, More(true, More(true, More(true, End))))))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))))))), More(true, More(true, More(true, More(true, More(true, More(true, More(true, More(true, End))))))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End)))))) : (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)
```

### D.3 Build and persistence

```text
((Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 20, Empty), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Empty), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Node(Red, Empty, Next(Next(Next(Zero))), 30, Empty)), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Node(Red, Empty, Next(Next(Next(Zero))), 30, Empty))), (true, true, true, true), (Some(20), Some(99), Some(99), None, Some(30), Some(30))) : ((Dictionary<Natural, Int>, Dictionary<Natural, Int>, Dictionary<Natural, Int>, Dictionary<Natural, Int>), (Bool, Bool, Bool, Bool), (Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>))
```

## Appendix E: exact relative-link check

Run without adding a dependency or script:

```bash
while IFS= read -r file; do
    while IFS= read -r target; do
        link_path=${target%%#*}
        [[ -z $link_path || $link_path == http://* ]] && continue
        [[ $link_path == https://* || $link_path == \#* ]] && continue
        [[ -e "$(dirname "$file")/$link_path" ]] || {
            printf 'broken relative link: %s -> %s\n' "$file" "$target" >&2
            exit 1
        }
    done < <(
        awk '
            /^```/ { fenced = !fenced; next }
            !fenced {
                remaining = $0
                while (match(remaining, /\]\([^)]*\)/)) {
                    print substr(remaining, RSTART + 2, RLENGTH - 3)
                    remaining = substr(remaining, RSTART + RLENGTH)
                }
            }
        ' "$file"
    )
done < <(rg --files -g '*.md')
```

<!-- markdownlint-enable MD013 -->
