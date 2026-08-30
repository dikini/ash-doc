# Protecting the dictionary invariant implementation plan

Status: approved on 2026-08-30 after independent specification and execution review

> Execute this plan one task at a time. It is active only while linked from the
> roadmap and leaves the live tree after reviewed repository closure.

## Goal and fixed design

Answer the reader's question: **How can clients use a dictionary without
constructing invalid trees?**

The crossed boundary is a transparent public tree whose constructors importers
can use versus a public opaque dictionary whose nominal identity remains
nameable while its constructors are inaccessible. The public operations must
preserve the global ordering invariant under explicit premises;
`invariant_holds` checks that property over the complete finite dictionary
spine but does not prove it in the type.

The approved bounded design is
[`2026-08-30-protecting-dictionary-invariant-design.md`](2026-08-30-protecting-dictionary-invariant-design.md).
It owns the language, tool, reader-model, architecture, observation, invariant,
cost, regression, attribution, exclusion, and closure decisions. Do not widen
the case beyond it.

Use exactly one new lesson boundary:

```text
content/cases/protecting-dictionary-invariant/
```

It contains:

```text
README.md
checks/verify.sh
src/dictionaries.ash
src/01-public-api.ash
src/02-build.ash
src/03-observe.ash
src/04-construct.ash
src/05-match.ash
```

Do not add a renderer, manifest, fixture, dependency, CI service, shared
dictionary module, or harness change. Use the existing Cases helper.

## Fixed identities and evidence

Feature base before the design commit:

```text
370cd74
```

Approved design commit:

```text
d44dc4be1c4aecf09bc8f7680c818cff0d3717c3
```

Clean pinned Ash checkout:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Set that explicit shell variable before running plan commands:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Exact Ash commit:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

Immutable ash-doc tag commit:

```text
e963a1597176f86003926eef827498db2a661b75
```

Keep the worktree on `protecting-dictionary-invariant`, clean before the first
content change. Confirm:

```bash
git status --short --branch
git rev-parse HEAD
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Expected: the feature branch is clean at the plan commit once this record is
approved and committed; the documentation tag and clean Ash pin match the
fixed commits.

Retain these four focused pinned tests for behavior that the case's CLI runs do
not isolate:

<!-- markdownlint-disable MD013 -->
```bash
(
    cd "$ASH_DOC_PIN"
    cargo test --locked --test module_visibility opaque_constructors_remain_available_inside_their_defining_module -- --exact
    cargo test --locked --test spec_examples overview_opaque_smart_constructor_example_is_executable -- --exact
    cargo test --locked --test interface_modules rejects_external_opaque_constructor_and_pattern_in_impl_body -- --exact
    cargo test --locked --test module_elaboration_nominals imported_opaque_nominal_is_not_an_empty_constructor_family -- --exact
)
```
<!-- markdownlint-enable MD013 -->

They support defining-module access, public-operation composition, external
constructor rejection, and wildcard coverage over an imported opaque value.
They do not define additional Ash behavior.

The exact-pin prototype also minimized this specified tuple-equation form to a
status-`2` `internal.resource.coverage` failure:

```ash
type Tree<K, V> =
    Empty
    | Node(Tree<K, V>, K, V, Tree<K, V>)

keep : Tree<K, V> -> (K, V) -> Tree<K, V>
keep tree (key, value) = tree

main : Unit -> Int
main () = 0
```

The selected body-match form accepts. Preserve that workaround in canonical
source and the verifier, classify the failure only as an Ash regression
candidate, and keep it outside rendered lesson prose. Do not add a durable lab
or upstream record until the completed case has an immutable commit.

## Task 1: Create the local verifier and prove the first RED

### Step 1: Confirm the boundary remains unmaterialized

Run:

```bash
test ! -e content/cases/protecting-dictionary-invariant
git status --short --branch
```

Expected: the lesson boundary does not exist and the worktree is clean.

### Step 2: Add the concrete directories and verifier first

Create only the approved concrete directories:

```bash
mkdir -p content/cases/protecting-dictionary-invariant/src
mkdir -p content/cases/protecting-dictionary-invariant/checks
```

Use `apply_patch` to add
`content/cases/protecting-dictionary-invariant/checks/verify.sh`. Follow the
existing local verifier pattern and source:

```text
content/cases/checks/lib.sh
```

The script must:

- require one clean pinned checkout at the exact Ash commit;
- declare exactly the six canonical source paths in the fixed order;
- reject a missing declared source and any extra top-level `src/*.ash` file;
- require `README.md` before displayed-block checks;
- defer the shared exact block-agreement check until all focused whole-source
  and entry assertions have run;
- build and invoke only the pinned `ash` executable;
- use fixed-string or exact-count assertions for every causal source
  relationship named below;
- run `dictionaries.ash` plus the three accepted importing entries with exact
  value/type output, empty standard error, and status `0`; and
- run the two rejected entries with exact channel/status and derived causal
  member-token and declaration-token spans.

Add local helpers only where the shared helper cannot express a requirement.
Keep them inside this verifier. Do not add a new shared abstraction for one
case.

Make it executable and check its shell form:

```bash
chmod +x content/cases/protecting-dictionary-invariant/checks/verify.sh
bash -n content/cases/protecting-dictionary-invariant/checks/verify.sh
shellcheck -x content/cases/protecting-dictionary-invariant/checks/verify.sh
```

Expected: Bash and ShellCheck pass.

### Step 3: Run the first RED

Run:

```bash
bash content/cases/protecting-dictionary-invariant/checks/verify.sh "$ASH_DOC_PIN"
```

Expected: status `1` and exactly the focused missing-source message for
`src/dictionaries.ash`. If the script reaches the README or tool checks first,
fix verifier ordering before adding source.

## Task 2: Add all six canonical programs

### Step 1: Add the opaque dictionary module

Use `apply_patch` to add `src/dictionaries.ash` exactly as follows:

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

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Dictionary<K, V>, K, V, Dictionary<K, V>)

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
lookup query Node(left, current_key, current_value, right) = match compare query current_key {
    Less => lookup query left
    Equal => Some(current_value)
    Greater => lookup query right
}

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value Empty = Node(Empty, key, value, Empty)
insert key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert key value right)
}

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
valid_between lower upper Node(left, key, ignored_value, right) = {
    let respects_lower = above_lower lower key
    let respects_upper = below_upper key upper
    let left_valid = valid_between lower (Some(key)) left
    let right_valid = valid_between (Some(key)) upper right
    both respects_lower (both respects_upper (both left_valid right_valid))
}

pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>
invariant_holds dictionary = valid_between None None dictionary

main : Unit -> Bool
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let malformed = Node(
        Node(Empty, one, 10, Node(Empty, three, 30, Empty)),
        two,
        20,
        Empty
    )
    invariant_holds malformed
}
```
<!-- markdownlint-enable MD013 -->

Its SHA-256 must be:

```text
ed7a29ee1007751e54840e7ccfc3017589b2126ff20f1e2a3b7f0729027c7e28
```

Before any importing entry exists, run the file directly:

```bash
"$ASH_DOC_PIN/target/debug/ash" \
    content/cases/protecting-dictionary-invariant/src/dictionaries.ash
```

Expected exact output, empty standard error, and status `0`:

```text
false : Bool
```

Require focused source assertions for:

- exactly one `pub opaque type Dictionary<K, V>` and its `Empty`/`Node` family;
- the one-method public `Order<A>` and public Natural implementation;
- exact public signatures for `empty`, `lookup`, `insert`, `build`, and
  `invariant_holds`;
- left/right constrained recursion and stored-representative-key replacement;
- accumulator-first strict `fold_left` with the recursive call final;
- the accepted body tuple match in `insert_entry` and its call to `insert`;
- `build` as `fold_left insert_entry (empty ()) entries`;
- lower comparison as `compare lower key` and upper comparison as
  `compare key upper`;
- left recursion with `(lower, Some(key))` and right recursion with
  `(Some(key), upper)` after both recursive results are bound;
- three Boolean combinations after the four validation values exist;
- `invariant_holds` starting with `None None`; and
- the exact deeper malformed topology under private `main` and its final
  `invariant_holds malformed` call.

### Step 2: Add the three importing success entries

Add `src/01-public-api.ash`:

<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries

main : Unit -> (Bool, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let four = Dictionaries.Next(three)
    let with_three = Dictionaries.insert three 30 empty
    let with_one = Dictionaries.insert one 10 with_three
    let with_two = Dictionaries.insert two 20 with_one
    let dictionary = Dictionaries.insert four 40 with_two
    (
        Dictionaries.invariant_holds dictionary,
        Dictionaries.lookup one dictionary,
        Dictionaries.lookup two dictionary,
        Dictionaries.lookup three dictionary,
        Dictionaries.lookup four dictionary,
        Dictionaries.lookup Dictionaries.Zero dictionary
    )
}
```
<!-- markdownlint-enable MD013 -->

Add `src/02-build.ash`:

```ash
import dictionaries as Dictionaries

main : Unit -> (Bool, Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More((two, 99), Dictionaries.End)
        )
    )
    let dictionary = Dictionaries.build entries
    (
        Dictionaries.invariant_holds dictionary,
        Dictionaries.lookup two dictionary,
        Dictionaries.lookup one dictionary
    )
}
```

Add `src/03-observe.ash`:

```ash
import dictionaries as Dictionaries

main : Unit -> Dictionaries.Dictionary<Dictionaries.Natural, Int>
main () = Dictionaries.empty()
```

Their hashes in that order must be:

```text
1808caaf7655f3c0d32a549d2413cc0f10d03fe56cc3a4cd84cbb87ed4bff820
48163c2b60775f84573f555811ccb5f1792f0b07f4abf9d6fe582b59d7a8944a
24372051e76bdd4ce1df1a4219287bdfa2457b8dc7ef9876624e4c3d66d1d2ed
```

Run and assert exact status `0`, empty standard error, and these complete
standard-output lines:

<!-- markdownlint-disable MD013 -->
```text
(true, Some(10), Some(20), Some(30), Some(40), None) : (Bool, Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>)
(true, Some(99), Some(10)) : (Bool, Option<Int>, Option<Int>)
Empty : Dictionary<Natural, Int>
```
<!-- markdownlint-enable MD013 -->

Require exact source relationships for the annotated `empty`, insertion order
`three`, `one`, `two`, `four`, all four lookups plus absence, the build entry's
three ordered pairs and single `Dictionaries.build entries` call, later equal
value `99`, and the observe entry's opaque result annotation and public
`empty()` call.

### Step 3: Add both source rejections

Add `src/04-construct.ash`:

```ash
import dictionaries as Dictionaries

main : Unit -> Dictionaries.Dictionary<Dictionaries.Natural, Int>
main () = Dictionaries.Empty
```

Add `src/05-match.ash`:

```ash
import dictionaries as Dictionaries

inspect : Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Int
inspect Dictionaries.Empty = 0

main : Unit -> Int
main () = inspect(Dictionaries.empty())
```

Their hashes in order must be:

```text
6a1a58bb82cbbddfb2dd02e23585e6a150c3fade181bd4ebd2eef8deceb0e97d
37af6eb991b11e8ea9663d81b10c1b5a87c4b081b14904cfdf72c47954e01f15
```

For each source, derive the unique full qualified occurrence, then derive the
`Empty` member-token byte range inside it under `LC_ALL=C`. Derive the unique
withheld `Empty` declaration-token range in `dictionaries.ash`. Run the pinned
tool and assert:

- status `1`;
- empty standard output;
- first standard-error line `resolve.opaque-constructor`;
- one `primary: source 0 START..END:` line matching the member-token range; and
- one `related: source 1 START..END:` line matching the declaration-token
  range.

Do not hardcode numeric offsets or assert remaining diagnostic prose.

### Step 4: Confirm the second RED

After all six sources and focused assertions exist, run the local verifier.

Expected: status `1` and exactly the missing `README.md` message. It must not
fail earlier for a source, hash, focused relationship, accepted observation, or
rejected observation.

## Task 3: Write the chapter and reach GREEN

### Step 1: Add the reader-facing README

Use `apply_patch` to add
`content/cases/protecting-dictionary-invariant/README.md`. Follow the approved
teaching sequence. Begin in the subject, not with an administrative header.

Use exactly six displayed `ash` blocks with hidden source markers, in canonical
source order. Display complete `dictionaries.ash`, including its private
`main`; explain that the same file can be run directly and imported, while its
private entry is unavailable to importers.

The chapter must:

1. recall the malformed transparent-tree boundary from case 7 without rerunning
   that old source;
2. explain public opaque nameability, defining-module constructor access, and
   importer constructor inaccessibility from the pinned rules;
3. predict the 3/1/2/4 valid shape, both branch searches, both-bound descendant,
   exact result, and source-level preservation premises before running it;
4. derive strict `build` from the private left fold, predict later-equal
   replacement, and run the exact build entry;
5. derive lower/upper propagation and distinguish local-child checks from the
   private deeper malformed example before observing `false`;
6. predict and run the separate value and pattern rejections, teaching only the
   stable reason and causal source locations;
7. run the accepted `Empty : Dictionary<Natural, Int>` observation and explain
   why structural output is not source constructor access or secrecy;
8. state build and validator work with `n`, `m_j`, `B`, `C_j(i)`, `C_r`, and
   conditional `Cmax` bounds without collapsing recursive comparison work;
9. distinguish the finite acyclic spines produced by the selected operations
   from possible defining-module dictionary-spine cycles or bad public
   operations and from independent cycles in generic key or value payloads;
   keep each return consequence explicit; and
10. end by asking how the hidden representation itself can prevent height from
    degenerating.

Every semantic conclusion must link to the applicable pinned specification
section. Tool output and failure claims must link to the pinned tool guide.
Keep the exact target, source inventory, governing-source list, regression
candidate, and project state out of rendered lesson prose.

Practice must ask the reader to predict three repeated-key replacements,
identify the bounds for one left and one right recursive call, and explain one
deeper violation that immediate-child checks miss. Do not add unchecked Ash
fragments.

### Step 2: Run the first GREEN

Run:

```bash
bash -n content/cases/protecting-dictionary-invariant/checks/verify.sh
shellcheck -x content/cases/protecting-dictionary-invariant/checks/verify.sh
bash content/cases/protecting-dictionary-invariant/checks/verify.sh "$ASH_DOC_PIN"
```

Expected exact local completion line:

```text
Verified 6 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

### Step 3: Prove the focused assertions fail

Record the six canonical hashes. Use `apply_patch` for one mutation at a time,
run the local verifier, require status `1` and the intended focused message,
restore with `apply_patch`, and require GREEN before the next mutation. Never
use `git checkout`, `git restore`, or a bulk destructive rewrite.

Prove at least these nineteen failures:

1. remove `opaque` from the dictionary declaration;
2. change lookup's `Less` arm to enter `right`;
3. replace `current_key` with incoming `key` in insert's `Equal` arm;
4. change `fold_left` to pass `first` before `accumulated`;
5. move work after the recursive `fold_left` call;
6. replace the body tuple match in `insert_entry` with a non-inserting result;
7. change build's initial `(empty ())` value;
8. change build's combiner away from `insert_entry`;
9. reverse `compare lower key`;
10. reverse `compare key upper`;
11. give left recursion the wrong upper bound;
12. give right recursion the wrong lower bound;
13. move key `three` out of the private malformed descendant position;
14. replace private `main`'s final `invariant_holds malformed` result so the
    exact `false` contract changes independently of the topology;
15. change the public API insertion order or one of its five lookups;
16. change one build pair or remove the later equal value `99`;
17. change the observe entry away from its exact public `empty()` result;
18. move the value rejection away from its unique `Dictionaries.Empty`; and
19. move the pattern rejection away from its unique `Dictionaries.Empty`.

After the matrix, require all six hashes to equal the fixed values and rerun
GREEN. Record the exact intended failure messages for review.

### Step 4: Run pre-review verification

Run Markdownlint, optional `typos`, the exact relative-link loop used by prior
cases, Bash syntax, ShellCheck, the local verifier, all Learn checks, all Cases
checks, the four focused pinned tests, `git diff --check`, tag/pin checks, and
status. Read the README, verifier, and all six sources fully as source.

Before navigation exists, the aggregate Cases verifier discovers the lesson
directory directly. Expected counts are already:

```text
11 Learn lessons
8 Cases
39 canonical Case sources
```

The clean pin and immutable tag must retain their fixed commits.

### Step 5: Obtain sequential chapter reviews

Give one independent high-rigor specification reviewer the approved design and
plan, pinned sources, exact outputs, both diagnostics, focused test outputs,
mutation transcript, chapter, verifier, and repository status. Require
authority, opacity, access, evidence, invariant, build, cost, return, cycle,
diagnostic, regression, attribution, and exclusion findings in severity order.

After specification approval, give a different high-rigor instructional
reviewer the same evidence. Require continuity from case 7, prediction before
execution, opacity-versus-secrecy clarity, local-versus-global invariant
teaching, practice, and prose quality.

Apply technically verified findings with `apply_patch`, rerun the affected
checks, and obtain re-review until both approve.

### Step 6: Commit the complete case

Stage only:

```text
content/cases/protecting-dictionary-invariant/
```

Run:

```bash
git diff --cached --check
git status --short
git commit --no-gpg-sign -m "docs: teach opaque dictionary boundary"
```

Expected: one narrow case commit. The approved design, active implementation
plan, and roadmap links remain outside that content commit only if they were
already committed; the worktree is otherwise clean.

## Task 4: Satisfy the case-9 source gate

Case 9 cannot be promoted until a focused research record selects a persistent
red-black-tree tradition and records its license. This is a separate project
record, not case-8 lesson prose.

Use authoritative primary source and publisher or institutional records.
Compare at least two credible traditions or presentations. Record:

- exact source identity, authorship, edition/publication, and stable links;
- the contribution used for persistent insertion, the four balance
  configurations, root blackening, and logarithmic invariants;
- whether the contribution is conceptual inspiration or direct adaptation;
- the explicit license when one exists, or ordinary-copyright restrictions
  when no reuse license is granted;
- the requirement that Ash programs, names, prose, derivations, diagrams, and
  exercises remain original unless a license permits more;
- Ash-specific departures and deliberate exclusions; and
- why the selected record is sufficient to plan case 9 but cannot define Ash
  behavior.

Add the smallest focused permanent record under `research/`. Obtain independent
source-integrity and license-boundary review. Run Markdownlint, relative links,
optional spelling, `git diff --check`, and status. Commit it separately with:

```text
research: select persistent red-black tree source
```

Do not promote case 9 before that commit exists.

## Task 5: Draft, review, and close repository integration

### Step 1: Draft permanent integration

Update only:

```text
README.md
content/cases/README.md
docs/project/roadmap.md
```

Root and Cases navigation must report eight verified cases and link the new
chapter in sequence.

Move case 8 under verified increments with a durable summary that retains:

- the six canonical sources and four accepted/two rejected runs;
- public opaque nameability and constructor inaccessibility;
- defining-module constructor access and the private deeper invalid
  observation;
- public API behavior and strict build order with later equal replacement;
- the global invariant, ordering-law, return, and dictionary-spine boundaries;
- exact `B`, per-comparison, and conditional cost distinctions;
- structural observation without a secrecy claim;
- the stable rejection reason and causal token locations; and
- attribution, regression quarantine, and exclusions without turning the
  regression candidate into durable language behavior.

Only after the case-9 research commit exists, promote case 9 to
`## Next: guaranteeing logarithmic retrieval` and link its selected research
record. Require its own approved bounded design and active implementation plan
before content. Preserve cases 10 through 12 byte-for-byte; their fixed block
hash from `370cd74` is:

```text
03a07e5067abf6de0d7b0890ceec1f3da2128ceb3610f56961e2708429f0edf6
```

Retain temporary roadmap links to both case-8 records while integration review
is active.

### Step 2: Verify the integration draft

Run:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
bash -n content/cases/protecting-dictionary-invariant/checks/verify.sh
shellcheck -x content/cases/protecting-dictionary-invariant/checks/verify.sh
bash content/cases/protecting-dictionary-invariant/checks/verify.sh "$ASH_DOC_PIN"
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
```

Also run the exact relative-link loop, four focused pinned tests, cases-10-
through-12 byte comparison, `git diff --check`, status, exact tag and pin, and
clean-pin checks. Require exactly 11 Learn lessons, 8 Cases, and 39 canonical
Case sources.

### Step 3: Run sequential closure reviews

Give a fresh high-rigor specification reviewer the approved design and plan,
complete case commit, research record, mutation transcript, exact outputs,
focused tests, integration diff, full roadmap, and byte-preservation evidence.
Require language/tool authority, opacity, invariants, costs, research status,
durable summary, case-9 gate and promotion, later non-authorization, and active
temporary links.

Only after specification approval, give a different high-rigor quality
reviewer the same payload and all changed permanent project files. Require
clear navigation, complete durable evidence, accurate research attribution,
and workflow compliance.

Apply verified feedback and obtain re-review.

### Step 4: Cross the deletion boundary

Only after both closure reviewers approve:

1. remove the temporary roadmap links;
2. delete exactly this implementation plan and the approved case-8 design with
   `apply_patch`; and
3. confirm no live file references either completed record.

Read every changed permanent file fully as source. Rerun Markdownlint, optional
spelling, relative links, Bash, ShellCheck, local/Learn/Cases verification,
focused tests, 11/8/39 counts, cases-10-through-12 byte equality, tag/pin,
`git diff --check`, status, and no-live-reference checks.

Commit closure:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md \
    docs/plans/2026-08-30-protecting-dictionary-invariant-design.md \
    docs/plans/2026-08-30-protecting-dictionary-invariant.md
git commit --no-gpg-sign -m "docs: verify opaque dictionary case"
```

The research record remains permanent in its earlier separate commit.

## Task 6: Final review, local merge, and cleanup

### Step 1: Review the closed branch

Give one fresh high-rigor whole-branch reviewer base `370cd74`, feature HEAD,
the full diff, deleted records recovered from their commits, final content and
project files, all exact outputs, two diagnostics, four focused tests,
nineteen mutation failures, research evidence, byte hash, counts, tag, and
pin. Require correctness, regressions, tests, writing, authority, attribution,
and workflow findings ordered by severity.

Apply technically verified feedback only within authorized paths, obtain
re-review, and create a correction commit only if a file changes.

### Step 2: Run final feature verification

Run Bash syntax, ShellCheck, Markdownlint, optional spelling, exact relative
links, local/Learn/Cases checks, four focused tests, 11/8/39 counts,
cases-10-through-12 byte equality, no-live-record references, branch diff,
clean branch/pin, and exact tag/pin resolution. Read the full branch diff and
every changed file as source.

### Step 3: Merge without pushing and verify local `main`

Confirm local `main` is clean and still contains base `370cd74` plus no
unexpected movement. Merge with a no-fast-forward, unsigned local merge commit:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    -m "Merge branch 'protecting-dictionary-invariant'" \
    protecting-dictionary-invariant
```

Do not push.

From merged `main`, rerun the complete checks while excluding `.worktrees/**`
from repository-wide Markdown and relative-link discovery. Require 11 Learn
lessons, 8 Cases, 39 Case sources, exact focused tests, clean `main`, clean pin,
and the fixed tag/pin commits.

Remove the clean feature worktree and delete the merged feature branch. Then
begin case 9's bounded design from its reviewed research record; do not create
case-9 content before that design and its implementation plan are approved.
