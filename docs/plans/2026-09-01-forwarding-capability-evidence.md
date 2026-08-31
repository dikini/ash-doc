# Forward capability evidence lesson plan

> **For Codex:** Use `superpowers:executing-plans` to execute this plan,
> `superpowers:test-driven-development` for verifier work, and
> `superpowers:verification-before-completion` before success claims or
> commits.

**Goal:** Add the second complete **Design library abstractions in Ash** lesson,
where one facade forwards public names and `Equal<Int>` authorization while a
names-only facade proves that ordinary re-export does not make evidence ambient.

**Architecture:** Keep the first lesson's equality library unchanged. Place two
one-line facades over it: one publicly imports `Equal`, `equal`, `same`, and
`impl Equal`; the other omits only the implementation item. A successful client
selects `impl Equal` through the first facade. A parallel name-only client uses
the second facade and retains the complete `constraint.unsatisfied` boundary.
One lesson verifier owns five sources, exact observations, cross-source
relationships, diagnostic cardinality, and displayed-source agreement. The
existing family aggregate and shared helper remain unchanged.

**Target:** exact Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`.

**Tech Stack:** Markdown, Ash at the exact target, Bash, the existing ash-doc
verification helper, Markdownlint, ShellCheck, Cargo, and Git worktrees.

---

## Status, reader boundary, and authority

Status: approved under the approved
[library abstractions learning-path design](2026-09-01-library-abstractions-design.md).

The reader asks how a facade can forward a capability without redefining it.
The observable boundary crosses two explicit hops: the facade must publicly
authorize the implementation route, and the client must select that route.
Ordinary public name re-export alone leaves the concrete obligation
unsatisfied.

Language claims come only from the exact target's:

- [imports and namespaces](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/name-resolution.md#imports-and-namespaces)
  for public targeted imports, independent name/implementation items,
  authorization routes, identity preservation, and absence of forwarding
  declarations;
- [interfaces and constrained schemes](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#interfaces-and-constrained-schemes)
  for `Equal`, its implementation, and `same`;
- [constraint satisfaction and checked evidence](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
  for route-aware concrete selection and the name-only rejection;
- [interface evidence lowering](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/elaboration.md#interface-evidence-lowering)
  and [generated interface evidence](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/dynamic-semantics.md#generated-interface-evidence)
  only for the static-erasure boundary; and
- the pinned tool guide's [successful output](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md#successful-output)
  and [failures](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md#failures)
  for channels and status.

Pinned `tests/library_imports.rs` and `tests/spec_examples.rs` corroborate the
route and diagnostic observations but do not define language behavior.

## Approaches considered

### Reuse one forwarding facade and omit only the client selector

This would produce the desired success and rejection, but it would repeat the
first lesson's client-selection boundary. It would not show what the facade
must publish.

### Attempt `impl Equal` through a names-only facade

This directly tests the missing public route, but rejection occurs during
import resolution with `resolve.unavailable-export`. That is useful tool
evidence, yet it does not answer the selected lesson question about a
constrained call receiving no ambient transitive evidence.

### Compare forwarding and names-only facades

Selected: two one-line facades differ only by `, impl Equal`. Their clients
differ by the facade path and the matching client selector. Normalizing those
two changes makes the entries identical. This establishes the complete
two-hop route with one accepted observation and shows the names-only path
reaching the intended evidence obligation rather than gaining ambient facts.
It costs two small facade files but no new abstraction or harness.

## Fixed executable observations

The disposable exact-pin canary used these five sources:

`equality.ash` retains lesson 1's public `Equal<A>`, public `Equal<Int>`, and
constrained `same` source unchanged.

```ash
pub import equality (Equal, equal, same, impl Equal)
```

is `capability_facade.ash`, while:

```ash
pub import equality (Equal, equal, same)
```

is `names_only_facade.ash`.

The selected entry is:

```ash
import capability_facade (same, impl Equal)

main : Unit -> Bool
main () = same((21, 21))
```

It exits `0`, writes empty stderr, and writes exactly `true : Bool` plus a
newline.

The name-only entry is:

```ash
import names_only_facade (same)

main : Unit -> Bool
main () = same((21, 21))
```

It exits `1`, writes empty stdout, and reports `constraint.unsatisfied`. Its
sole primary covers the `same` call. Its exactly three related labels cover the
entry's imported `same`, the original equality library's constrained `same`
declaration, and its original `Equal` interface. The facade preserves those
defining identities; the diagnostic does not invent a forwarding declaration
or expose the unselected implementation.

## Files

Create:

- `content/libraries/forwarding-capability-evidence/README.md`
- `content/libraries/forwarding-capability-evidence/checks/verify.sh`
- `content/libraries/forwarding-capability-evidence/src/equality.ash`
- `content/libraries/forwarding-capability-evidence/src/capability_facade.ash`
- `content/libraries/forwarding-capability-evidence/src/names_only_facade.ash`
- `content/libraries/forwarding-capability-evidence/src/01-forwarded.ash`
- `content/libraries/forwarding-capability-evidence/src/02-names-only.ash`

Modify only after the local lesson passes:

- `content/libraries/README.md`
- `README.md`
- `content/README.md`
- `docs/project/roadmap.md`
- this plan

Do not change `AGENTS.md`, `content/checks/lib.sh`, the family aggregate, Ash,
or lesson 1. Delete this plan in the reviewed closure commit.

## Task 1: Approve and commit this plan

Obtain independent authority/specification and instructional/workflow reviews.
Resolve findings, change status to approved, and change the roadmap link to an
approved active plan. Verify exact clean pins, absent lesson directory,
Markdownlint, relative links, and `git diff --check`. Commit:

```bash
test ! -e content/libraries/forwarding-capability-evidence
lib_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
test "$(git -C "$lib_pin" rev-parse HEAD)" = \
  d1e323d23390cdad03202ee3df76cd9100556e1d
test -z "$(git -C "$lib_pin" status --short)"
markdownlint-cli2 '**/*.md' '#.worktrees/**'
git diff --check
git add docs/plans/2026-09-01-forwarding-capability-evidence.md \
  docs/project/roadmap.md
git -c commit.gpgSign=false commit \
  -m "docs: plan capability evidence facade lesson"
```

Use the read-only Ruby relative-link audit from Task 6 before this commit;
expected result is zero missing links.

## Task 2: Build the five-source inventory RED

Create only the lesson verifier. Reuse `content/checks/lib.sh`, require one
exact Ash checkout, call `ash_doc_prepare`, and declare these sources in
teaching order:

```text
src/equality.ash
src/capability_facade.ash
src/names_only_facade.ash
src/01-forwarded.ash
src/02-names-only.ash
```

Require the actual sorted `src/*.ash` set to equal a separately sorted expected
set while retaining declared order for source agreement. Run RED naming each
missing source in order as empty files are added, then require inventory GREEN.

Every verifier run uses:

```bash
bash content/libraries/forwarding-capability-evidence/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

The five RED messages name the next missing declared source. Inventory GREEN
has status `0` and no completion message until observation checks exist.

## Task 3: Add source and observation checks RED/GREEN

Install each check before its source content:

1. Before adding its content, require byte identity between this lesson's
   `equality.ash` and
   `content/libraries/choosing-implementation-evidence/src/equality.ash`.
   Run RED, copy that exact canonical source through `apply_patch`, and rerun
   GREEN. Retain structural assertions as local explanatory relationships; byte
   identity owns the unchanged-source claim.
2. Assert each facade is exactly its one public targeted import, that the two
   differ only by `, impl Equal`, that only the forwarding facade contains one
   implementation item, and that neither defines a declaration or body. Run
   RED, add both facade lines one at a time, and retain earlier checks.
3. Assert the forwarded entry imports only through `capability_facade`, selects
   one `impl Equal`, calls `same` once, never imports `equality` or calls
   `equal`, and observes exact `true : Bool`/channels/status. Run RED, add the
   source, and rerun GREEN.
4. While `02-names-only.ash` is still empty, install both its source-relationship
   and executable rejection checks. Require that it imports only through
   `names_only_facade`, has no implementation selector, otherwise equals the
   forwarded entry after normalizing facade path and selector, and never
   imports `equality` or calls `equal`. Capture status/channels/reason and derive
   byte ranges from canonical spelling; require exactly one primary globally on
   the `same` call and exactly three related labels matching the import,
   original constrained declaration, and original interface. Run RED naming
   the first unsatisfied entry assertion, add the complete source, and require
   GREEN.
5. After that production RED/GREEN, add controlled extra-primary and
   extra-related mutations separately to prove both cardinality checks RED.
   Remove each mutation and require final GREEN:

```text
Verified 5 canonical source observations at d1e323d23390cdad03202ee3df76cd9100556e1d.
```

Do not assert colors, gutters, all prose, or a facade diagnostic label that the
exact tool does not produce.

## Task 4: Write the lesson after source-agreement RED

Add `ash_doc_check_sources` for all five sources before the README exists and
require `missing unit README.md`. Then write:

```text
# How can a facade forward a capability without redefining it?
```

Use this sequence:

1. Continue from lesson 1's independent name and implementation channels.
2. Show the unchanged equality owner, then the names-only one-line facade.
   Predict why public names alone do not create ambient evidence downstream.
3. Show the name-only client and its causal rejection, emphasizing that the
   labels retain original identities through the facade.
4. Add `impl Equal` to the facade and the matching selector to the client.
   Explain the two-hop authorization route and exact success.
5. State that re-export preserves identities and creates no forwarding
   declaration, runtime module object, registration, or dynamic lookup.
6. Account for representation, invariant, derivation, and cost: a facade adds
   an explicit route but no duplicate implementation body.
7. Practice private versus public facade items, importing `Equal` as a name,
   and predicting the separate unavailable-selector boundary without teaching
   its diagnostic prose as this lesson's main contract.

Transclude all five exact sources with hidden markers. Keep target and project
administration out of rendered prose. Link semantic conclusions to exact
pinned sections. Require final local GREEN:

```text
Verified 5 canonical sources and displayed blocks at d1e323d23390cdad03202ee3df76cd9100556e1d.
```

## Task 5: Activate lesson 2 through the existing family gate

Before adding navigation, the unchanged family aggregate must fail at two
lesson verifiers versus one indexed link. Add one numbered lesson-2 link and
require GREEN at two and two. Do not list or create lessons 3 through 5.

Run the gate with:

```bash
bash content/libraries/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
```

Expected RED includes `active library verifier count 2 differs from indexed
lesson count 1`. Expected GREEN ends with:

```text
Verified 2 library lesson(s) at d1e323d23390cdad03202ee3df76cd9100556e1d.
```

Update root/content navigation from one to two verified library lessons. Update
the roadmap to `11 Learn / 9 Cases / 2 library lessons` and
`43 / 42 / 8` sources. Mark lesson 2 verified and promote **Accept a type
constructor** as the sole next bounded outcome. Keep blocked Cases and final
publication state unchanged. Record every RED/GREEN and classified discovery
in this plan.

Commit the complete lesson and activation:

```bash
git add README.md content docs/project/roadmap.md \
  docs/plans/2026-09-01-forwarding-capability-evidence.md
git -c commit.gpgSign=false commit \
  -m "docs: teach capability evidence facades"
```

## Execution record

Implementation followed the approved RED/GREEN order at the exact target:

- the inventory named all five missing sources in declared order before the
  empty five-file inventory passed;
- byte comparison rejected the empty equality source before lesson 1's exact
  source was added;
- each facade assertion rejected its empty source before the corresponding
  one-line public import was added;
- the forwarded-entry assertion rejected its empty source before exact
  `true : Bool` observation passed;
- the complete names-only relationship and diagnostic checks rejected its
  empty source before the exact `constraint.unsatisfied` observation passed;
- controlled extra-primary and extra-related labels each failed their global
  cardinality checks before the unmodified diagnostic passed;
- source agreement rejected the missing README before all five exact displayed
  blocks and lesson prose passed; and
- family navigation rejected two verifiers against one link before lesson 2
  was indexed.

ShellCheck exposed a split quoted assignment in the lesson-1 source path. The
path was rewritten as one quoted assignment and all executable observations
remained green. This is an ash-doc verifier correction, not an Ash discovery.

## Task 6: Verify, review, close, and integrate

From clean implementation HEAD run:

```bash
lib_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
modular_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/libraries/forwarding-capability-evidence/checks/verify.sh "$lib_pin"
bash content/libraries/checks/verify.sh "$lib_pin"
bash content/learn/checks/verify.sh "$lib_pin"
bash content/cases/checks/verify.sh "$lib_pin"
bash lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
  "$modular_pin" "$lib_pin"
lesson_shell=(
  content/libraries/forwarding-capability-evidence/checks/verify.sh
)
bash -n "${lesson_shell[@]}"
shellcheck -x -P SCRIPTDIR "${lesson_shell[@]}"
markdownlint-cli2 '**/*.md' '#.worktrees/**'
test "$(git -C "$lib_pin" rev-parse HEAD)" = \
  d1e323d23390cdad03202ee3df76cd9100556e1d
test "$(git -C "$modular_pin" rev-parse HEAD)" = \
  dca16039923475c48025c5f17beadeb6bcb6a4bf
test -z "$(git -C "$lib_pin" status --short)"
test -z "$(git -C "$modular_pin" status --short)"
! rg -n 'dca16039923475c48025c5f17beadeb6bcb6a4bf|modular-ash' \
  content/learn content/cases content/libraries
test "$(find content/learn -type f -name '*.ash' | wc -l)" -eq 43
test "$(find content/cases -type f -name '*.ash' | wc -l)" -eq 42
test "$(find content/libraries -type f -name '*.ash' | wc -l)" -eq 8
test "$(grep -Ec '^[0-9]+\. \[' content/libraries/README.md)" -eq 2
git diff --check
test -z "$(git status --short)"
```

Run this exact read-only relative-link audit:

```bash
ruby <<'RUBY'
missing = []
Dir.glob('**/*.md').each do |file|
  File.read(file).scan(/\[[^\]]*\]\(([^)]+)\)/).flatten.each do |raw|
    target = raw.split('#', 2)[0]
    next if target.empty? || target.match?(/\A(?:[a-z][a-z0-9+.-]*:|\/)/i)

    path = File.expand_path(target, File.dirname(file))
    missing << "#{file}: #{raw}" unless File.exist?(path)
  end
end
abort missing.join("\n") unless missing.empty?
RUBY
```

Run focused exact-pin tests from the Lib Ash checkout:

```bash
cargo test --locked --test library_imports \
  public_implementation_selector_crosses_a_three_module_facade -- --exact
cargo test --locked --test spec_examples \
  overview_three_module_implementation_facade_is_executable -- --exact
cargo test --locked --test spec_examples \
  overview_name_only_import_has_structured_unsatisfied_constraint -- --exact
cargo test --locked --test spec_examples \
  resolution_targeted_public_name_reexport_is_executable -- --exact
```

Obtain independent authority and instructional reviews; correct findings with
test-first regression checks and repeat affected reviews. Delete this plan and
its roadmap link only after both approve, commit:

```bash
git add -u docs/plans/2026-09-01-forwarding-capability-evidence.md \
  docs/project/roadmap.md
git -c commit.gpgSign=false commit \
  -m "docs: close capability evidence facade lesson"
```

Rerun the full suite at closure HEAD and obtain a fresh whole-branch review.
Fast-forward clean local `main`, rerun the full merged-main suite, then remove
the feature worktree and branch with exact validated paths:

```bash
git -C /home/dikini/Projects/ash-doc merge --ff-only add-capability-facade
git -C /home/dikini/Projects/ash-doc worktree remove \
  /home/dikini/Projects/ash-doc/.worktrees/add-capability-facade
git -C /home/dikini/Projects/ash-doc branch -d add-capability-facade
```

Do not tag, push, modify Ash, create lesson-3 content, or resume blocked Cases.

## Completion conditions

- Five canonical sources and displayed blocks pass at the exact target.
- The forwarding route observes `true : Bool`; names-only retains the exact
  one-primary/three-related `constraint.unsatisfied` boundary.
- Prose separates name re-export, implementation authorization, client
  selection, defining identity, and runtime evaluation.
- Exactly two library lessons are indexed and verified.
- All active documentation and retained failure evidence pass together.
- The temporary plan leaves merged `main`; no tag, push, Ash change, future
  lesson content, or blocked-Case resumption occurs.
