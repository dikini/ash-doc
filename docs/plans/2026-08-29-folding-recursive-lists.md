# Folding Recursive Lists Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add the first verified Cases chapter, showing how one eager right fold defines several recursive-list algorithms and what source-level work that fold performs.

**Architecture:** Promote the existing Bash verification helper to content-family scope, retain one aggregator per family, and keep shared declarations beside a four-entry-program case. Develop the case from a failing local verifier, then add complete canonical Ash sources and source-matched learning prose before navigation exposes the family.

**Tech Stack:** Markdown, Bash, Git, and the `ash` executable built from Modular Ash commit `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

### Task 1: Record the approved path and active increment

**Files:**
- Create: `docs/plans/2026-08-29-recursive-algorithms-design.md`
- Modify: `docs/project/roadmap.md`
- Create: `docs/plans/2026-08-29-folding-recursive-lists.md`

**Steps:**

1. Record the reader and maintainer problems, exact authority boundary, three
   approaches, selected Cases family, source traditions, verifier promotion,
   and replacement conditions.
2. Mark folding recursive lists **next** and the ten downstream increments
   **provisional**. Preserve the immutable publication tag and defer the
   current-main canary until migration.
3. Run `git diff --check`; expect status `0` and no output.

### Task 2: Promote the shared verifier and add the Cases aggregator

**Files:**
- Move: `content/learn/checks/lib.sh` to `content/checks/lib.sh`
- Modify: `content/learn/checks/verify.sh`
- Modify: every `content/learn/*/checks/verify.sh`
- Create: `content/cases/checks/verify.sh`

**Steps:**

1. Move the existing helper and change only its temporary-directory prefix
   from `ash-doc-learning` to `ash-doc-content`.
2. Update the Learn aggregator to source `../../checks/lib.sh`. Update each
   lesson to resolve `content_root` two directories above `unit_root` and
   source `$content_root/checks/lib.sh`, including its shellcheck path.
3. Add a Cases aggregator with the same one-time preparation and sorted local
   verifier discovery as Learn Ash.
4. Run the Cases aggregator before a case exists. Expect status `1` with
   `verify: no case verifiers found`.
5. Run Bash syntax checks and the complete Learn aggregator at the exact pin.
   Expect all 11 lessons to pass.
6. Commit the planning and mechanical verifier preparation separately with
   `docs: plan eager recursive algorithm cases`.

### Task 3: Record the two source traditions

**Files:**
- Create: `research/how-to-design-programs-recursive-algorithms.md`
- Create: `research/functional-programming-with-bananas.md`

**Steps:**

1. Record the HtDP 2026-02-25 second edition, authors, consulted sections,
   structural and generative recursion, cost, and accumulator contributions.
   Classify use as inspiration and retain the CC BY-NC-ND no-derivatives
   boundary.
2. Record Meijer, Fokkinga, and Paterson's 1991 fold/unfold contribution.
   Exclude lazy semantics, infinite data, CPO results, morphology notation,
   and unqualified fusion laws.
3. Confirm that both records cite consulted material, claim no Ash behavior,
   and require original case prose and code.

### Task 4: Write the failing case verifier

**Files:**
- Create: `content/cases/folding-recursive-lists/checks/verify.sh`

**Steps:**

1. Declare `src/lists.ash`, `src/01-fold.ash`,
   `src/02-map-filter.ash`, `src/03-eager-fold.ash`, and
   `src/04-wrong-combiner.ash` as canonical sources.
2. Check all five source blocks, the three exact successful observations, and
   the rejection's status `1`, `type.argument`, `expected Bool`, and
   `found Int` at the integer base argument.
3. Assert from `src/lists.ash` that `sum`, `length`, `map`, and `filter` call
   `fold`, that `fold` calls itself on `rest` inside the combiner application,
   and that `first_and_visits` obtains its result through `fold`.
4. Run the local verifier before the case README or sources exist. Expect
   status `1` with `verify: missing unit README.md`.

### Task 5: Add the canonical Ash programs

**Files:**
- Create: `content/cases/folding-recursive-lists/src/lists.ash`
- Create: `content/cases/folding-recursive-lists/src/01-fold.ash`
- Create: `content/cases/folding-recursive-lists/src/02-map-filter.ash`
- Create: `content/cases/folding-recursive-lists/src/03-eager-fold.ash`
- Create: `content/cases/folding-recursive-lists/src/04-wrong-combiner.ash`

**Shared declarations:**

```ash
pub type List<A> =
    Empty
    | More(A, List<A>)

pub type Option<A> =
    None
    | Some(A)

pub fold : (A -> B -> B) -> B -> List<A> -> B
fold combine base Empty = base
fold combine base More(first, rest) =
    combine first (fold combine base rest)

pub sum : List<Int> -> Int
sum list = fold (fn(first) {
    fn(total) {
        first + total
    }
}) 0 list

pub length : List<A> -> Int
length list = fold (fn(ignored) {
    fn(count) {
        count + 1
    }
}) 0 list

pub map : (A -> B) -> List<A> -> List<B>
map transform list = fold (fn(first) {
    fn(mapped_rest) {
        More(transform first, mapped_rest)
    }
}) Empty list

pub filter : (A -> Bool) -> List<A> -> List<A>
filter keep list = fold (fn(first) {
    fn(filtered_rest) {
        match keep first {
            true => More(first, filtered_rest)
            false => filtered_rest
        }
    }
}) Empty list

pub first_and_visits : List<A> -> (Option<A>, Int)
first_and_visits list = fold (fn(first) {
    fn(summary) {
        let (ignored, visits) = summary
        (Some(first), visits + 1)
    }
}) (None, 0) list
```

**Entry observations:**

1. `01-fold.ash` imports `lists`, applies `sum` and `length` to
   `More(1, More(2, More(3, Empty)))`, and observes
   `(6, 3) : (Int, Int)`.
2. `02-map-filter.ash` maps an increment and filters for `42` over
   `More(41, More(42, More(43, Empty)))`, observing
   `(More(42, More(43, More(44, Empty))), More(42, Empty)) : (List<Int>, List<Int>)`.
3. `03-eager-fold.ash` calls `first_and_visits` over `42`, `43`, and `44`,
   observing `(Some(42), 3) : (Option<Int>, Int)`.
4. `04-wrong-combiner.ash` supplies a combiner of type
   `Int -> Bool -> Bool`, then supplies integer `0` where the fold base must be
   `Bool`. It is a complete `Unit -> Bool` entry program.

Run all four entries directly with the pinned executable. Expect the three
exact success lines above and then status `1` with the declared rejection
evidence.

### Task 6: Write the chapter and family index

**Files:**
- Create: `content/cases/folding-recursive-lists/README.md`
- Create: `content/cases/README.md`

**Steps:**

1. Continue from the complete Learn Ash path. Establish the
   repeated-equation problem before the first command. Transclude all five
   complete sources with hidden markers.
2. Develop the fold equation, derive the four algorithms, observe the counted
   eager fold, explain the type rejection, and end with practice and the next
   finite-`unfold` question.
3. Explain one combiner call per `More`, linear recursive dependency depth,
   one output `More` per input for `map`, and one output `More` per retained
   element for `filter`. Separate these source-level facts from host stack
   optimization and exact heap bytes.
4. Link language conclusions to the pinned static and dynamic semantics.
5. Write the Cases index with the shared setup link, reading prerequisite,
   edit-predict-run-explain cycle, and cost vocabulary. Do not list the draft
   case before its local verifier passes.
6. Run the local verifier and expect all five canonical source blocks and four
   entry contracts to pass.

### Task 7: Expose and close the verified increment

**Files:**
- Modify: `README.md`
- Modify: `content/README.md`
- Modify: `content/cases/README.md`
- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-29-folding-recursive-lists.md`

**Steps:**

1. After local verification, link the Cases family from the root and content
   indexes and list folding recursive lists as its only verified case.
2. Mark folding recursive lists **verified**, promote finite-list `unfold` to
   **next**, leave the remaining nine cases **provisional**, and remove the
   completed temporary plan link.
3. Run:

   ```text
   bash -n content/checks/lib.sh content/learn/checks/verify.sh content/learn/*/checks/verify.sh content/cases/checks/verify.sh content/cases/folding-recursive-lists/checks/verify.sh
   bash content/learn/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
   bash content/cases/checks/verify.sh /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
   git diff --check
   git status --short
   ```

   Expect all 11 Learn lessons and the one Cases chapter to pass at the exact
   pin, a quiet diff check, and only intended status entries.
4. Read every changed file as source. Check Markdown structure, spelling,
   relative links, source agreement, attribution, license status, semantic
   links, fact/proposal boundaries, and exclusions.
5. Remove this completed implementation plan and commit closure with
   `docs: teach folding recursive lists`.
