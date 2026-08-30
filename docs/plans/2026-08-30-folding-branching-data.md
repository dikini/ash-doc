# Folding branching data implementation plan

<!-- markdownlint-disable-next-line MD013 -->
> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Publish one verified Cases chapter that extends a strict fold from
one recursive list tail to two tree branches, makes equal-size shapes and
different heights observable, and contrasts whole-tree folding with selective
pre-order search.

**Architecture:** Add one lesson-local transparent tree module with a strict
`fold_tree`, derived size and map operations, executable node-and-height
measurement, and direct and folded counted search. Three complete entries
observe size with mapped shape, balanced and skewed heights, and one selective
predicate application versus three strict-fold applications.

**Tech stack:** Markdown, Ash, Bash, ShellCheck, Git, and the `ash` executable
built from exact Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Execution boundary

Work only in the `folding-branching-data` branch and its existing worktree at
`/home/dikini/Projects/ash-doc/.worktrees/folding-branching-data`. Use the clean
pinned checkout at
`/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin` for
every executable observation. Do not change `ash-lang`, the edition target,
the immutable `modular-ash` tag, or shared content infrastructure.

The reader asks how the data-directed method extends from lists to trees. The
observable boundary crosses both branch fields of
`Node(Tree<A>, A, Tree<A>)`: the strict fold obtains complete left and right
results before its combiner body runs. A direct pre-order search tests the
current value first: a current match avoids both branches, while a mismatch
enters left and enters right only after left absence. The case counts source
visits and pending recursive results; it does not turn those counts into
native-stack, elapsed-time, storage, or optimization claims.

Use `@superpowers:subagent-driven-development` to execute Tasks 1 through 4 in
order. Dispatch one fresh implementer per task; do not run implementation
tasks in parallel because they share one uncommitted case. Tasks 1 through 3
form one test-first complete-case cycle: Task 1 establishes the missing-README
RED, Task 2 adds canonical sources while preserving that RED, and Task 3 adds
the README to turn GREEN before ten causal mutation REDs. Those three
implementers must use `@superpowers:test-driven-development`. Task 4 integrates
already-green documentation and is exempt from strict TDD; it uses the explicit
verification and review gates instead. Every implementer receives its complete
task text rather than being asked to read this plan. Use high reasoning for the
bounded verifier and canonical-source implementers in Tasks 1 and 2. Use xhigh
reasoning for the chapter implementer in Task 3 and the repository-integration
implementer in Task 4.

After each of Tasks 1 through 4, dispatch a fresh specification reviewer. Only
after specification compliance passes may a different fresh quality reviewer
begin. Use high reasoning for the Task 1 and 2 quality reviews and xhigh for
all semantic specification reviews, chapter review, integration review, and
their quality reviews. If a reviewer finds an issue, the same implementer
fixes it and the same reviewer rechecks it. Do not proceed while either review
has an open finding. The implementer's self-review does not replace either
independent review. The project keeps Tasks 1 and 2 uncommitted so the complete
case's prose, sources, and checks can land together; Task 4 likewise keeps its
integration draft uncommitted through review. These complete-outcome boundaries
override any per-task commit assumed by a generic review template. Reviewers
must inspect the working-tree diff and untracked files against the task
contract, not rely only on `BASE_SHA...HEAD_SHA`.

Before drafting or reviewing the chapter, navigation, roadmap, review prose,
or commit messages, use the project-local
`@writing-ash-documentation` skill. Use
`@superpowers:verification-before-completion` before every commit and before
integration. Task 5 uses a fresh xhigh whole-branch reviewer and
`@superpowers:requesting-code-review`; apply feedback through
`@superpowers:receiving-code-review` and re-review every change.

The approved design and this plan stay linked from the roadmap through the
reviewed repository-closure draft. Do not delete either record as soon as the
case becomes locally green.

Execution begins only after an independent planning review and a clean
planning checkpoint in which the approved design, this implementation plan,
and their roadmap links are all tracked:

```bash
npx --yes markdownlint-cli2 \
    docs/plans/2026-08-30-folding-branching-data-design.md \
    docs/plans/2026-08-30-folding-branching-data.md \
    docs/project/roadmap.md
if command -v typos >/dev/null 2>&1; then
    typos docs/plans/2026-08-30-folding-branching-data-design.md \
        docs/plans/2026-08-30-folding-branching-data.md \
        docs/project/roadmap.md
fi
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
git diff --check
git status --short
git add docs/plans/2026-08-30-folding-branching-data-design.md \
    docs/plans/2026-08-30-folding-branching-data.md \
    docs/project/roadmap.md
git commit --no-gpg-sign -m "docs: plan folding branching data"
```

Expected before staging: only the reviewed design correction, implementation
plan, and roadmap link are uncommitted; every check has no findings. Expected
after the commit: the feature worktree is clean.

## Task 1: Add the case verifier and establish RED

**Files:**

- Create: `content/cases/folding-branching-data/checks/verify.sh`

### Step 1: Create the executable verifier

Add a Bash verifier with `set -euo pipefail`. Derive `unit_root` and
`content_root` like the dictionary case, source `content/checks/lib.sh`,
require one pinned Ash checkout argument, call `ash_doc_prepare`, and declare
these four canonical sources in order:

```bash
readonly sources=(
    src/trees.ash
    src/01-size-and-map.ash
    src/02-balanced-and-skewed.ash
    src/03-selective-and-fold.ash
)
```

Declare `readme`, `library`, and all three entry paths before sourcing the
shared helper. Call `ash_doc_check_sources` before extracting sections.

Copy the hardened lesson-local section, word-count, phrase-count, and suffix
helpers from `content/cases/dictionary-as-list/checks/verify.sh`. The section
helper must fail when its start marker or its nonempty end marker is absent;
it must not let an empty extraction make a count assertion pass vacuously.

Use these exact adjacent section boundaries:

<!-- markdownlint-disable MD013 -->
```text
representations:
    pub type Tree<A> =
    -> pub fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B
fold_tree:
    pub fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B
    -> pub size : Tree<A> -> Int
size:
    pub size : Tree<A> -> Int
    -> pub map_tree : (A -> B) -> Tree<A> -> Tree<B>
map_tree:
    pub map_tree : (A -> B) -> Tree<A> -> Tree<B>
    -> maximum : Natural -> Natural -> Natural
maximum:
    maximum : Natural -> Natural -> Natural
    -> pub nodes_and_height : Tree<A> -> (Int, Natural)
nodes_and_height:
    pub nodes_and_height : Tree<A> -> (Int, Natural)
    -> pub find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_counted:
    pub find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
    -> choose_counted : (A -> Bool) -> (Option<A>, Int) -> A -> (Option<A>, Int) -> (Option<A>, Int)
choose_counted:
    choose_counted : (A -> Bool) -> (Option<A>, Int) -> A -> (Option<A>, Int) -> (Option<A>, Int)
    -> pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
fold wrapper:
    pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
    -> end of file
```
<!-- markdownlint-enable MD013 -->

Add a transcript helper that counts an expected complete line only inside a
`text` fence and requires exactly one occurrence:

```bash
ash_doc_assert_text_line_once() {
    if [[ $# -ne 2 ]]; then
        ash_doc_fail \
            "ash_doc_assert_text_line_once requires expected line and claim"
    fi

    local expected_line=$1
    local claim=$2
    local actual_count
    actual_count=$(
        awk -v expected="$expected_line" '
            $0 == "```text" { inside = 1; next }
            inside && $0 == "```" { inside = 0; next }
            inside && $0 == expected { count += 1 }
            END { print count + 0 }
        ' "$readme"
    )

    [[ $actual_count -eq 1 ]] ||
        ash_doc_fail \
            "$claim (found $actual_count occurrences, expected 1)"
}
```

The counts below were calculated mechanically from the exact feasibility
snapshot in `/tmp/ash-fold-tree-feasibility.h55Awh`. Every exact phrase below
occurs once in its bounded section except where a different count is stated,
and every named suffix is the exact final text of its section. Preserve those
mechanically checked relationships exactly.

Assert the complete representation section equals:

```text
pub type Tree<A> =
    Empty
    | Node(Tree<A>, A, Tree<A>)

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)
```

Assert these bounded causal relationships in the stated order:

- `fold_tree` contains exactly five `fold_tree`, five `combine`, five `base`,
  two `folded_left`, and two `folded_right` words. Require exactly one each of
  `fold_tree combine base Empty = base`,
  `let folded_left = fold_tree combine base left`,
  `let folded_right = fold_tree combine base right`, and
  `combine folded_left value folded_right`. Assert the complete `Node`
  equation as the section suffix so left completes before right and both
  complete before the final combiner call. Use these failure claims, in order:
  `fold_tree must fold left exactly once before folding right`,
  `fold_tree must fold right exactly once before combining`, and
  `fold_tree must bind left then right before its final combine`.
- `size` contains exactly two `size`, one `fold_tree`, two `left_size`, and two
  `right_size` words. Require exactly one
  `left_size + right_size + 1` and the suffix `}) 0 tree`. The phrase failure
  claim is `size must add the current Node exactly once`.
- `map_tree` contains exactly two `map_tree`, one `fold_tree`, two `transform`,
  two `mapped_left`, two `mapped_right`, one `Node`, and one `Empty` word.
  Require exactly one
  `Node(mapped_left, transform value, mapped_right)` and the suffix
  `}) Empty tree`. The phrase failure claim is
  `map_tree must preserve left and right mapped positions`.
- `maximum` contains exactly five `maximum`, three `Natural`, two `Zero`, three
  `Next`, four `left`, and four `right` words. Require exactly one of each
  equation:
  `maximum Zero right = right`,
  `maximum left Zero = left`, and
  `maximum Next(left) Next(right) = Next(maximum left right)`.
  Compare the whole bounded section to those three equations and their
  signature. Put the recursive-equation phrase assertion before the complete
  section comparison and word counts. Its failure claim is
  `maximum must decrease both nonzero heights together`.
- `nodes_and_height` contains exactly two `nodes_and_height`, one `fold_tree`,
  two each of `left_summary`, `right_summary`, `left_nodes`, `right_nodes`,
  `left_height`, and `right_height`, and one each of `Next`, `maximum`, `Zero`,
  and `ignored`. Require exactly one
  `left_nodes + right_nodes + 1`, one
  `Next(maximum left_height right_height)`, and the suffix
  `}) (0, Zero) tree`. Put the `Next(maximum ...)` phrase assertion before the
  suffix and word counts. Use the height failure claim
  `nodes_and_height must add one level above the greater branch height`.
- `find_counted` contains exactly five `find_counted`, five `matches`, two
  `left_found`, two `right_found`, three `left_visits`, two `right_visits`,
  three `Some`, and two `None` words. Require the base
  `find_counted matches Empty = (None, 0)`, then exactly one each of
  `match matches value {`, `true => (Some(value), 1)`,
  `let (left_found, left_visits) = find_counted matches left`,
  `Some(found) => (Some(found), left_visits + 1)`,
  `let (right_found, right_visits) = find_counted matches right`, and
  `(right_found, left_visits + right_visits + 1)`. Assert the complete `Node`
  equation as the section suffix. Put the base assertion first and use
  `direct search must return absence with zero visits at Empty`. Put the
  current-predicate assertion before word counts and use
  `direct search must apply its predicate at the current Node`. Put the
  left-hit assertion before word counts and use
  `direct search must count the current mismatch before returning a left match`.
  Put the suffix assertion before word counts and use
  `direct search must recurse right only after left absence`. These source
  assertions deliberately cover current mismatch, left hit, and right search,
  which the root-hit executable entry does not enter.
- `choose_counted` contains exactly two `choose_counted`, two `matches`, two
  each of `left_found`, `right_found`, `left_visits`, and `right_visits`, four
  `visits`, three `Some`, and one `None` word. Require exactly one each of
  `let visits = left_visits + right_visits + 1`, `match matches value {`,
  `true => (Some(value), visits)`,
  `Some(found) => (Some(found), visits)`, and
  `None => (right_found, visits)`. Assert the complete equation as the section
  suffix. This preserves current-left-right result priority even though the
  runtime observation exercises only the current match. Put the visit,
  predicate, and left-priority phrase assertions before the suffix and word
  counts. Their failure claims are `folded search must count the current Node`,
  `folded search must apply its predicate at every current Node`, and
  `folded search must prefer a found left result after a current mismatch`,
  respectively.
- `find_through_fold_counted` contains exactly two wrapper-name, one
  `fold_tree`, one `choose_counted`, two `matches`, and one `None` word.
  Require exactly one
  `fold_tree (choose_counted matches) (None, 0) tree` and compare the complete
  two-line wrapper section.

Read the three complete entries into variables. Assert:

- `01-size-and-map.ash` contains exactly three `Node`, four `Empty`, three
  `tree`, one `size`, one `map_tree`, and three `increment` words. Require one
  exact balanced-tree binding, one `Trees.size tree`, one
  `Trees.map_tree increment tree`, and final tuple
  `(Trees.size tree, Trees.map_tree increment tree)`.
- `02-balanced-and-skewed.ash` contains exactly six `Node`, eight `Empty`, two
  `balanced`, two `skewed`, and two `nodes_and_height` words. Require the exact
  balanced three-node binding, the exact right-skewed three-node binding, and
  one call on each named tree in balanced-then-skewed order. Assert the exact
  skewed binding before its word counts, with failure claim
  `the skewed entry must retain its exact three-node right chain`.
- `03-selective-and-fold.ash` contains exactly three `Node`, four `Empty`, three
  `tree`, four `is_42`, one `find_counted`, and one
  `find_through_fold_counted` word. Require exactly one
  `is_42 value = value == 42`, the exact root-`42` tree with one leaf in each
  branch, and one call of each search with the same `is_42` and `tree` values.

Use exact multiline string comparisons or phrase assertions for each tree
binding; do not reduce them to counts that would accept a different shape or
value order.

Name these exact outputs, require each exactly once inside a README `text`
fence, and pass the same values to three accepted runs:

<!-- markdownlint-disable MD013 -->
```bash
readonly size_map_output='(3, Node(Node(Empty, 2, Empty), 3, Node(Empty, 4, Empty))) : (Int, Tree<Int>)'
readonly shapes_output='((3, Next(Next(Zero))), (3, Next(Next(Next(Zero))))) : '\
'((Int, Natural), (Int, Natural))'
readonly search_output='((Some(42), 1), (Some(42), 3)) : '\
'((Option<Int>, Int), (Option<Int>, Int))'
```
<!-- markdownlint-enable MD013 -->

Finish with `ash_doc_finish 4`. This case has no rejected program; its semantic
negative is the accepted folded count of three after a root match.

### Step 2: Make the verifier executable and check its shell syntax

Run:

```bash
chmod +x content/cases/folding-branching-data/checks/verify.sh
bash -n content/cases/folding-branching-data/checks/verify.sh
shellcheck -x content/cases/folding-branching-data/checks/verify.sh
```

Expected: every command exits `0` without findings.

### Step 3: Run the verifier and confirm RED

Run:

```bash
bash content/cases/folding-branching-data/checks/verify.sh \
    /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: status `1` with `verify: missing unit README.md`. Confirm that this
is the expected missing-content failure, not a shell, pin, or helper error. Do
not commit the deliberately red state.

### Step 4: Review the RED contract

Dispatch a fresh xhigh specification reviewer with the complete verifier
contract, exact feasibility sources, approved design, and expected RED. After
it passes, dispatch a different fresh high quality reviewer. Both must inspect
the uncommitted script, executable mode, shell checks, non-vacuous section
boundaries, mechanical counts, transcript helper, unobserved search-path
assertions, mutation failure ordering, and compatibility with Task 2. The same
implementer fixes findings; the same reviewer rechecks each fix. Leave the
reviewed verifier uncommitted for the complete case.

## Task 2: Add and directly observe the canonical Ash programs

**Files:**

- Create: `content/cases/folding-branching-data/src/trees.ash`
- Create: `content/cases/folding-branching-data/src/01-size-and-map.ash`
- Create: `content/cases/folding-branching-data/src/02-balanced-and-skewed.ash`
- Create: `content/cases/folding-branching-data/src/03-selective-and-fold.ash`

### Step 1: Add the exact tested tree module

Copy `/tmp/ash-fold-tree-feasibility.h55Awh/trees.ash` verbatim. The complete
file must be:

<!-- markdownlint-disable MD013 -->
```ash
pub type Tree<A> =
    Empty
    | Node(Tree<A>, A, Tree<A>)

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B
fold_tree combine base Empty = base
fold_tree combine base Node(left, value, right) = {
    let folded_left = fold_tree combine base left
    let folded_right = fold_tree combine base right
    combine folded_left value folded_right
}

pub size : Tree<A> -> Int
size tree = fold_tree (fn(left_size) {
    fn(ignored) {
        fn(right_size) {
            left_size + right_size + 1
        }
    }
}) 0 tree

pub map_tree : (A -> B) -> Tree<A> -> Tree<B>
map_tree transform tree = fold_tree (fn(mapped_left) {
    fn(value) {
        fn(mapped_right) {
            Node(mapped_left, transform value, mapped_right)
        }
    }
}) Empty tree

maximum : Natural -> Natural -> Natural
maximum Zero right = right
maximum left Zero = left
maximum Next(left) Next(right) = Next(maximum left right)

pub nodes_and_height : Tree<A> -> (Int, Natural)
nodes_and_height tree = fold_tree (fn(left_summary) {
    fn(ignored) {
        fn(right_summary) {
            let (left_nodes, left_height) = left_summary
            let (right_nodes, right_height) = right_summary
            (
                left_nodes + right_nodes + 1,
                Next(maximum left_height right_height)
            )
        }
    }
}) (0, Zero) tree

pub find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_counted matches Empty = (None, 0)
find_counted matches Node(left, value, right) = match matches value {
    true => (Some(value), 1)
    false => {
        let (left_found, left_visits) = find_counted matches left
        match left_found {
            Some(found) => (Some(found), left_visits + 1)
            None => {
                let (right_found, right_visits) = find_counted matches right
                (right_found, left_visits + right_visits + 1)
            }
        }
    }
}

choose_counted : (A -> Bool) -> (Option<A>, Int) -> A -> (Option<A>, Int) -> (Option<A>, Int)
choose_counted matches (left_found, left_visits) value (right_found, right_visits) = {
    let visits = left_visits + right_visits + 1
    match matches value {
        true => (Some(value), visits)
        false => match left_found {
            Some(found) => (Some(found), visits)
            None => (right_found, visits)
        }
    }
}

pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_through_fold_counted matches tree = fold_tree (choose_counted matches) (None, 0) tree
```
<!-- markdownlint-enable MD013 -->

Keep `maximum` and `choose_counted` private. Do not add ordering, insertion,
balancing, opacity, shared tree infrastructure, generic instrumentation, or a
computed-time benchmark.

### Step 2: Add the three exact tested entries

Copy `/tmp/ash-fold-tree-feasibility.h55Awh/01-size-and-map.ash` verbatim:

```ash
import trees as Trees

increment : Int -> Int
increment value = value + 1

main : Unit -> (Int, Trees.Tree<Int>)
main () = {
    let tree = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        2,
        Trees.Node(Trees.Empty, 3, Trees.Empty)
    )
    (Trees.size tree, Trees.map_tree increment tree)
}
```

Copy `/tmp/ash-fold-tree-feasibility.h55Awh/02-balanced-and-skewed.ash`
verbatim:

```ash
import trees as Trees

main : Unit -> ((Int, Trees.Natural), (Int, Trees.Natural))
main () = {
    let balanced = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        2,
        Trees.Node(Trees.Empty, 3, Trees.Empty)
    )
    let skewed = Trees.Node(
        Trees.Empty,
        1,
        Trees.Node(
            Trees.Empty,
            2,
            Trees.Node(Trees.Empty, 3, Trees.Empty)
        )
    )
    (
        Trees.nodes_and_height balanced,
        Trees.nodes_and_height skewed
    )
}
```

Copy `/tmp/ash-fold-tree-feasibility.h55Awh/03-selective-and-fold.ash`
verbatim:

<!-- markdownlint-disable MD013 -->
```ash
import trees as Trees

is_42 : Int -> Bool
is_42 value = value == 42

main : Unit -> ((Trees.Option<Int>, Int), (Trees.Option<Int>, Int))
main () = {
    let tree = Trees.Node(
        Trees.Node(Trees.Empty, 1, Trees.Empty),
        42,
        Trees.Node(Trees.Empty, 2, Trees.Empty)
    )
    (
        Trees.find_counted is_42 tree,
        Trees.find_through_fold_counted is_42 tree
    )
}
```
<!-- markdownlint-enable MD013 -->

Do not adapt or reformat the feasibility sources. Task 3 will copy the same
bytes into marked chapter blocks.

### Step 3: Build inside the exact checkout and run every entry directly

Run from the repository worktree:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
(
    cd "$ASH_DOC_PIN"
    cargo build --locked
)
(
    cd content/cases/folding-branching-data
    "$ASH_DOC_PIN/target/debug/ash" src/01-size-and-map.ash
    "$ASH_DOC_PIN/target/debug/ash" src/02-balanced-and-skewed.ash
    "$ASH_DOC_PIN/target/debug/ash" src/03-selective-and-fold.ash
)
```

Building from inside the verified checkout makes the resulting
`target/debug/ash` provenance explicit and prevents Cargo workspace or target
selection from drifting to ash-doc or another Ash checkout. It also lets the
pin's `rust-toolchain.toml` select the declared Rust toolchain before Cargo
resolves the manifest. `--locked` requires the pin's lockfile resolution.

The exact outputs are:

<!-- markdownlint-disable MD013 -->
```text
(3, Node(Node(Empty, 2, Empty), 3, Node(Empty, 4, Empty))) : (Int, Tree<Int>)
((3, Next(Next(Zero))), (3, Next(Next(Next(Zero))))) : ((Int, Natural), (Int, Natural))
((Some(42), 1), (Some(42), 3)) : ((Option<Int>, Int), (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

Every `ash` invocation must exit `0`, write its one expected line to standard
output, and leave standard error empty. `rev-parse` must report
`dca16039923475c48025c5f17beadeb6bcb6a4bf`, and the pin status must be empty.
If the build or observation differs, stop and classify the difference before
changing the approved contract.

### Step 4: Review the canonical programs

Dispatch a fresh xhigh specification reviewer with all four uncommitted
sources, the approved design, verifier contract, pinned specification
sections, and direct observations. After it passes, dispatch a different fresh
high quality reviewer. They must independently compare every file with the
feasibility snapshot, run the entries at the exact pin, check generic types,
pattern coverage, strict left-then-right fold dependencies, natural-height
recursion, direct pre-order selectivity, folded result priority, source style,
and exclusions. Apply and re-review every finding. Do not commit before prose,
programs, and checks are green together.

## Task 3: Write the chapter, turn GREEN, and audit mutations

**Files:**

- Create: `content/cases/folding-branching-data/README.md`
- Test: `content/cases/folding-branching-data/checks/verify.sh`
- Test: all files under `content/cases/folding-branching-data/src/`

### Step 1: Write the chapter as one conceptual progression

Use `@writing-ash-documentation`. Title the chapter
`How does the data-directed method extend from lists to trees?` Begin from the
dictionary chapter's closing model: a list offered one possible `rest`, while
each `Node` offers two recursive branches. Establish the finite structural
expansion and returning-operation assumptions before the first general count.

Build this progression:

1. Introduce `Tree`, `Natural`, `Option`, and `fold_tree`. Derive `Empty` as the
   base and `Node` as left result, current value, and right result. Explain that
   the explicit bindings complete left, then right, before evaluation of the
   complete `combine folded_left value folded_right` expression begins. State
   that this is an ordinary rank-1 Ash function, not built-in syntax.
2. Transclude `src/01-size-and-map.ash` after the shared module. Ask the reader
   to predict size `3` and the mapped shape, run the named command, then explain
   two primitive integer `+` operations, one transform application, and one
   output `Node` constructor application per input `Node`. Preserve the input
   branch shape in the explanation.
3. Transclude `src/02-balanced-and-skewed.ash`. Define `n` as `Node`
   encounters in the finite structural expansion and `h` as the greatest
   number of `Node` forms on a root-to-`Empty` path. Predict `(3, 2)` for the
   balanced shape and `(3, 3)` for the skewed shape in unary form. Explain
   exactly `n` completed node combiners, `h` pending `Node` results, and
   `h + 1` source calls only when the active terminal `Empty` call is included.
   Keep host-stack claims out.
4. Explain `nodes_and_height` and private `maximum`. Make the executable height
   worth its extra helper, but account for `maximum` recursion and `Next`
   construction separately. Exclude that internal helper work from the
   structural fold's `n` combiner and `h` pending-result counts. Do not
   summarize the complete measurement as linear work without deriving that
   helper's cost. State that arbitrary-precision integer additions also have
   unmeasured internal work.
5. Transclude `src/03-selective-and-fold.ash`. Explain direct current-left-right
   pre-order control: the current predicate runs before recursion, a left hit
   skips right, and only left absence enters right. Then explain that
   `choose_counted` can preserve the same result priority but receives both
   folded branches after their complete traversal. Predict and observe one
   predicate application versus three.
6. Explain finite expansion, sharing, and cycles. A shared acyclic subtree
   placed in both fields is followed and counted through both structural
   occurrences; structural output does not reveal physical identity. A cyclic
   `Tree` may prevent these functions from returning.
7. Give practice that defines `sum_tree` through `fold_tree`, compares equal
   sums and node-combiner counts across the two shapes, and explains their
   different dependency depths. A second exercise moves the target into the
   left child and predicts why direct search avoids right while folded search
   does not. End by asking how an ordering invariant could choose one branch
   before recursion.

Transclude all four canonical sources with unique
`<!-- source: src/... -->` markers. Every displayed `ash` block must be
byte-for-byte identical to its canonical file. Use `text` fences for commands,
outputs, calculations, and non-executable notation. Place prediction before
each command and interpret the complete observed value and type afterward.

Keep language authority claim-local. Link the approved pinned sections where
the chapter first needs parameterized constructors, global recursive scope,
constructor and function typing, exhaustive equations and matches, sequential
bindings, strict application, match-arm selection, primitive additions and
equality, structural observation, and exact successful tool output. Do not
render a governing-source inventory or edition target in the chapter.

Use these exact authority targets, distributing them beside the claims they
support:

- pinned [syntax
  grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  and [global function
  presentations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#global-function-presentations)
  for parameterized data, constructor patterns, and curried equations;
- pinned [imports and
  namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces),
  [type and constructor
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#type-and-constructor-scope),
  and [global
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#global-scope)
  for the shared module and recursive types and globals;
- pinned static [tuples and
  constructors](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors),
  [functions and
  application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application),
  [patterns, matches, and
  coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage),
  [blocks](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks),
  [recursive block
  groups](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups),
  [primitive
  operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#primitive-operations),
  and [globals and
  modules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  for the accepted module's types, functions, matches, bindings, arithmetic,
  equality, and cyclic-value boundary;
- pinned dynamic [bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
  [recursive
  bindings](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#recursive-bindings),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  [tuples, constructors, and
  matches](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches),
  [primitive
  operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#primitive-operations),
  and [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
  for sequential recursive results, strict calls, selected arms, counts, and
  printed structural values; and
- the pinned tool guide's [successful-output
  contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  for each exact output line, empty standard error, and status `0`.

Link the [HtDP research
record](../../research/how-to-design-programs-recursive-algorithms.md) and
credit it only for inspiration from designing with self-referential data and
naming source operations. Link the [recursion-operator research
record](../../research/functional-programming-with-bananas.md) and credit it
only for the idea of separating a traversal from the operations that replace
data forms. In the case README, each target needs one additional `..` path
component. Write original prose, programs, shapes, calculations, and exercises.
Do not import HtDP teaching-language behavior, the paper's lazy semantics,
notation, fusion results, or examples.

State these preconditions beside the claims they govern:

- finite structural expansion and returning combiner for a completed generic
  fold;
- returning transform for `n` transform applications and `n` constructed
  output `Node` forms; and
- returning predicates along the chosen direct path, or at every node for the
  completed folded search.

Keep these exclusions explicit: ordering, ordered insertion and lookup,
duplicates, balancing, opacity, mutation, laziness, infinite-tree claims,
generic tree infrastructure, elapsed time, machine instructions, native stack
size, tail-call optimization, exact heap bytes, garbage collection, pointer
identity, physical sharing, arbitrary-precision integer bit cost, and compiler
representation and optimization.

### Step 2: Read and verify the complete case

Read the README, verifier, and all four sources fully. Run:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/cases/folding-branching-data/checks/verify.sh "$ASH_DOC_PIN"
npx --yes markdownlint-cli2 \
    content/cases/folding-branching-data/README.md
bash -n content/cases/folding-branching-data/checks/verify.sh
shellcheck -x content/cases/folding-branching-data/checks/verify.sh
if command -v typos >/dev/null 2>&1; then
    typos content/cases/folding-branching-data
fi
git diff --check
git status --short
```

Expected local verifier output:

```text
Verified 4 canonical sources and displayed blocks at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

The status contains only the uncommitted complete case; both planning records
remain present and tracked. Do not call the case complete before the mutation
audit and reviews.

### Step 3: Prove all ten focused assertions can fail

After the complete case first passes, perform these ten mutations one at a
time. Use `apply_patch` for every change and restoration. For source mutations,
change both the canonical file and its marked README `ash` block so source
agreement stays green and the intended causal assertion is reached. Run the
local verifier, require status `1` and the exact named failure below, restore
the exact text with `apply_patch`, rerun the local verifier, and require its
exact green summary before starting the next mutation. Retain the ten failure
messages for review.

1. Replace
   `let folded_right = fold_tree combine base right` with
   `let folded_right = fold_tree combine base left`.
   Expect `verify: fold_tree must fold right exactly once before combining`.
2. Restore, then swap the complete `folded_left` and `folded_right` binding
   lines while leaving each initializer unchanged.
   Expect
   `verify: fold_tree must bind left then right before its final combine`.
3. Replace
   `Node(mapped_left, transform value, mapped_right)` with
   `Node(mapped_right, transform value, mapped_left)`.
   Expect
   `verify: map_tree must preserve left and right mapped positions`.
4. Replace
   `let visits = left_visits + right_visits + 1` with
   `let visits = left_visits + right_visits`.
   Expect `verify: folded search must count the current Node`.
5. In `02-balanced-and-skewed.ash`, replace the nested right subtree rooted at
   value `2` with `Trees.Node(Trees.Empty, 2, Trees.Empty)`, reducing the
   skewed tree from three nodes to two. Make the identical block change in the
   README. Expect
   `verify: the skewed entry must retain its exact three-node right chain`.
6. Move the right recursion before `match left_found`, replacing the direct
   search's false path with this type-correct but non-selective arrangement:

   ```text
   let (left_found, left_visits) = find_counted matches left
   let (right_found, right_visits) = find_counted matches right
   match left_found {
       Some(found) => (Some(found), left_visits + 1)
       None => (right_found, left_visits + right_visits + 1)
   }
   ```

   Expect
   `verify: direct search must recurse right only after left absence`.
7. Replace `find_counted matches Empty = (None, 0)` with
   `find_counted matches Empty = (None, 1)`.
   Expect
   `verify: direct search must return absence with zero visits at Empty`.
8. Replace
   `Some(found) => (Some(found), left_visits + 1)` with
   `Some(found) => (Some(found), left_visits)`.
   Expect
   <!-- markdownlint-disable-next-line MD013 -->
   `verify: direct search must count the current mismatch before returning a left match`.
9. Replace `match matches value {` with `match true {` only inside
   `choose_counted`.
   Expect
   `verify: folded search must apply its predicate at every current Node`.
10. Replace
    `Some(found) => (Some(found), visits)` with
    `Some(found) => (right_found, visits)` only inside `choose_counted`.
    Expect
    `verify: folded search must prefer a found left result after a current mismatch`.

These ten include every mutation named by the design: wrong right input,
reversed branch-binding order, swapped mapped children, a missing visit
increment, a shortened skewed shape, right recursion outside the left-absence
arm, the unobserved direct base and non-root increment, the folded predicate,
and folded left-result priority. End with no mutation diff and one final green
local verifier run.

### Step 4: Review the complete GREEN case

Dispatch a fresh xhigh specification reviewer over the complete uncommitted
case. Give it the approved design, exact chapter contract, canonical sources,
direct outputs, verifier, ten red messages, and final green output. It must
review every semantic conclusion against its claim-local pinned authority,
then check size and map counts, `n` and `h`, `h + 1` terminal-call wording,
strict both-branch evaluation, direct unobserved branches, `maximum` separation,
finite and returning preconditions, sharing and cycle caveats, attribution,
continuity, and exclusions.

Only after specification compliance passes, dispatch a different fresh xhigh
quality reviewer. Require source/display agreement, teaching arc, prediction
cycle, prose rhythm, exact outputs, non-vacuous shell assertions, failure
ordering, local scope, and maintainability. The same chapter implementer fixes
findings; each reviewer rechecks its own findings. Rerun the complete Step 2
checks after all review fixes.

### Step 5: Commit the complete verified case

Use `@superpowers:verification-before-completion`, then run the local verifier,
Markdownlint, Bash syntax, ShellCheck, optional spelling, `git diff --check`,
and `git status --short` again. Read every case file as source. Commit only
when prose, canonical sources, and checks are green together:

```bash
git add content/cases/folding-branching-data
git commit --no-gpg-sign -m "docs: teach folding branching data"
```

## Task 4: Draft, review, and close repository integration

**Files:**

- Modify: `content/cases/README.md`
- Modify: `README.md`
- Modify: `docs/project/roadmap.md`
- Delete after review:
  `docs/plans/2026-08-30-folding-branching-data-design.md`
- Delete after review: `docs/plans/2026-08-30-folding-branching-data.md`

### Step 1: Draft navigation and roadmap closure with both records active

Add the branching-data chapter as item 5 under `Cases in order`. Summarize the
strict two-branch fold, equal node counts with different heights, and direct
search versus whole-fold work. Extend the root recursive-algorithm summary
from four to five verified cases without repeating setup or the edition target.

Draft the roadmap transition while both temporary records still exist and are
linked. Move `Folding branching data` under `Verified increments` as item 5.
Record four canonical sources, three accepted outputs, size and map behavior,
balanced height `2` versus skewed height `3`, `n` completed node combiners,
`h` pending `Node` results, the `h + 1` terminal-call distinction, one direct
predicate application versus three folded applications, exact-pin evidence,
preconditions, `maximum` separation, sharing and cycle caveats, and runtime and
storage exclusions.

Promote case 6 to `## Next: searching an ordered tree`, preserve its audited
content, add the standard bounded-design and temporary-plan gate, and retain
cases 7 through 12 as provisional with their numbering and dependencies.
Update the repository state to five verified unpublished Cases chapters.

In the draft verified increment, keep one temporary sentence linking both the
folding-branching-data design and implementation plan and saying repository
closure review remains active. Do not delete either record yet. Their roadmap
links own the work through the reviewed repository closure.

### Step 2: Verify the complete integration draft

Run Markdown and spelling checks:

```bash
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
```

Run this exact manual relative-link check; do not add a dependency, script, or
harness:

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

Then run:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/folding-branching-data/checks/verify.sh
shellcheck -x content/cases/folding-branching-data/checks/verify.sh
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
git diff --check
git status --short
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Expected: Markdown, spelling when available, shell, and relative-link checks
have no findings; 11 Learn lessons pass; 5 Cases and 24 canonical Case sources
pass at the exact pin; only `README.md`, `content/cases/README.md`, and
`docs/project/roadmap.md` appear in status; the documentation tag peels to
`e963a1597176f86003926eef827498db2a661b75`; and the Ash checkout reports
`dca16039923475c48025c5f17beadeb6bcb6a4bf` with empty status.

### Step 3: Review the draft before closure

Dispatch a fresh xhigh specification reviewer over the committed case and the
uncommitted navigation and roadmap draft while both temporary records remain
linked. Give it the design and plan from the worktree, Task 3 mutation audit,
case commit diff, draft integration diff, exact-pin output, and complete
provisional roadmap. Require exact counts, authority, status, navigation,
preconditions, exclusions, successor promotion, and no accidental acceptance
of later cases.

Only after specification compliance passes, dispatch a different fresh xhigh
quality reviewer. Require clear project prose, valid navigation, durable
roadmap state, correct relative links, and a reviewable deletion boundary. The
same integration implementer fixes findings; each reviewer rechecks its own
findings. Run all Step 2 checks again after review changes. Do not call closure
complete or remove either record until both reviews and fresh verification
pass.

### Step 4: Remove the records and commit reviewed closure

Remove the draft's temporary active-review sentence. Use `apply_patch` to
delete exactly:

```text
docs/plans/2026-08-30-folding-branching-data-design.md
docs/plans/2026-08-30-folding-branching-data.md
```

Confirm no live file names either record. Read all changed files as source.
Rerun Markdownlint, optional spelling, the exact relative-link loop, Bash
syntax, ShellCheck, both exact-pin content aggregators, tag and pin checks,
`git diff --check`, and `git status --short`. Then commit:

```bash
git add README.md content/cases/README.md docs/project/roadmap.md docs/plans
git commit --no-gpg-sign -m "docs: verify folding branching data case"
git diff --check HEAD^..HEAD
git status --short --branch
```

Expected: the closure commit succeeds, its diff check is empty, and the
feature worktree is clean. Git history retains the removed design and plan.

## Task 5: Review, verify, merge locally, and clean up

**Files:**

- Review: all changes from `main...folding-branching-data`

### Step 1: Review the complete closed branch

Use `@superpowers:requesting-code-review` for one fresh xhigh whole-branch
review. The reviewer must recover the deleted design and plan from Git history,
compare the final files against them line by line, read every changed file,
rerun exact-pin evidence, inspect all ten mutation records, and verify roadmap
closure. Apply technically verified feedback with
`@superpowers:receiving-code-review`; re-review every fix before final
verification. If review changes a file, rerun the affected local verifier and
static checks, obtain reviewer approval for the uncommitted fix, then commit
the reviewed correction:

```bash
git add README.md content/cases/README.md \
    content/cases/folding-branching-data docs/project/roadmap.md
git commit --no-gpg-sign -m \
    "docs: address folding branching data review"
git diff --check HEAD^..HEAD
git status --short --branch
```

Do not create an empty review-fix commit when the reviewer approves the branch
without changes. Any finding outside these authorized files requires a bounded
scope decision before editing.

### Step 2: Run exact final feature-branch verification

Use `@superpowers:verification-before-completion`. Run from the feature
worktree:

```bash
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/cases/folding-branching-data/checks/verify.sh
shellcheck -x content/cases/folding-branching-data/checks/verify.sh
npx --yes markdownlint-cli2 '**/*.md'
if command -v typos >/dev/null 2>&1; then
    typos
fi
bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
git diff --check main...HEAD
git status --short --branch
git rev-parse 'modular-ash^{commit}'
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Rerun the exact manual relative-link loop from Task 4. Read
`git diff main...HEAD` and every changed file as source. Expected:

- 11 Learn lessons pass;
- 5 Cases and 24 canonical Case sources pass at the exact pin;
- all static and relative-link checks have no findings;
- the feature branch and pinned checkout are clean;
- `modular-ash` peels to
  `e963a1597176f86003926eef827498db2a661b75`; and
- the pin is `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

### Step 3: Merge without pushing and verify local `main`

The autonomous integration request selects the local-merge option from
`@superpowers:finishing-a-development-branch`. Confirm local `main` is clean
and inspect any movement since the feature base. Do not push. Merge:

```bash
git -C /home/dikini/Projects/ash-doc merge --no-ff --no-gpg-sign \
    -m "Merge branch 'folding-branching-data'" folding-branching-data
```

From local `main`, run the complete merged-state verification. Exclude the
still-present feature worktree from repository-wide file discovery so every
tracked file is checked once:

```bash
ASH_DOC_ROOT=/home/dikini/Projects/ash-doc
ASH_DOC_PIN=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n "$ASH_DOC_ROOT/content/cases/folding-branching-data/checks/verify.sh"
shellcheck -x \
    "$ASH_DOC_ROOT/content/cases/folding-branching-data/checks/verify.sh"
(
    cd "$ASH_DOC_ROOT"
    npx --yes markdownlint-cli2 '**/*.md' '#.worktrees/**'
    if command -v typos >/dev/null 2>&1; then
        typos --exclude '.worktrees/**'
    fi
    bash content/learn/checks/verify.sh "$ASH_DOC_PIN"
    bash content/cases/checks/verify.sh "$ASH_DOC_PIN"
    while IFS= read -r file; do
        while IFS= read -r target; do
            link_path=${target%%#*}
            [[ -z $link_path || $link_path == http://* ]] && continue
            [[ $link_path == https://* || $link_path == \#* ]] && continue
            [[ -e "$(dirname "$file")/$link_path" ]] || {
                printf 'broken relative link: %s -> %s\n' \
                    "$file" "$target" >&2
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
    done < <(rg --files -g '*.md' -g '!.worktrees/**')
    git diff --check origin/main...main
    git status --short --branch
    git rev-parse 'modular-ash^{commit}'
)
git -C "$ASH_DOC_PIN" rev-parse HEAD
git -C "$ASH_DOC_PIN" status --short
```

Expected: Bash syntax, ShellCheck, Markdown, optional spelling, relative links,
and diff checks have no findings; 11 Learn lessons pass; 5 Cases and 24
canonical Case sources pass at the exact pin; local `main` and the pin are
clean; and the tag and pin report the exact commits above.

Only after the merged result passes, remove the worktree and delete the merged
branch:

```bash
git -C /home/dikini/Projects/ash-doc worktree remove \
    /home/dikini/Projects/ash-doc/.worktrees/folding-branching-data
git -C /home/dikini/Projects/ash-doc branch -d folding-branching-data
```

Do not push. Keep the autonomous remaining-cases goal active and begin the
newly promoted ordered-tree-search design after this local merge checkpoint.
