# Accept type constructors lesson plan

Status: approved under the approved
[library abstractions design](2026-09-01-library-abstractions-design.md).

## Outcome and authority

The reader asks how a reusable definition can accept a type constructor such
as `Option`, rather than only a completed type such as `Option<Int>`. The exact
boundary is one binder annotation: `F : Type -> Type` permits `F<A>`; omitted
declaration kinds are fixed to `Type`, so applying an omitted-kind `F` rejects
with `kind.not-applicable`.

Language claims come from the exact Lib Ash commit
`d1e323d23390cdad03202ee3df76cd9100556e1d`, especially
[kinds, monotypes, and schemes](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#kinds-monotypes-and-schemes)
and the [kind grammar](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/syntax.md#grammar).
The pinned tool guide governs channels and status. Pinned kind and
specification-example tests corroborate observations but define no semantics.

The exact-pin canary established:

- `keep<F : Type -> Type, A> : F<A> -> F<A>` applied to `Some(42)` exits `0`,
  writes empty stderr, and reports `Some(42) : Option<Int>`;
- the otherwise identical `keep<F, A>` program exits `1`, writes empty stdout,
  and reports `kind.not-applicable`, with its primary on `F<A>`, a related label
  on binder `F`, `expected Type -> _`, and `found Type`.

This lesson teaches explicit monomorphic function kinds, right-associative
`->`, constructor application, and the fixed omitted-kind default. It excludes
kind inference, kind polymorphism, type lambdas, interfaces, and higher-order
unification.

## Files and implementation

Create one complete unit:

- `content/libraries/accepting-type-constructors/README.md`
- `content/libraries/accepting-type-constructors/checks/verify.sh`
- `content/libraries/accepting-type-constructors/src/01-explicit-kind.ash`
- `content/libraries/accepting-type-constructors/src/02-omitted-kind.ash`

Use strict RED/GREEN order:

1. Create the verifier with a two-source exact inventory; observe each missing
   source before adding empty files.
2. Install positive source-relationship and exact output/channel/status checks,
   observe RED, then add the explicit-kind program and require GREEN.
3. Install the parallel-source comparison and complete negative diagnostic
   checks while the negative source is empty; observe RED, then add the omitted-
   kind program and require GREEN. Derive byte ranges and require the exact
   stable reason, expected/found kinds, one primary, and one related label.
4. Install displayed-source agreement before the README; observe missing-README
   RED, then write the lesson and require two exact displayed blocks GREEN.
5. Run the unchanged family aggregate at three verifiers/two links RED; add one
   lesson link and require three/three GREEN.

The lesson begins from completed types, shows why `Option` alone has kind
`Type -> Type`, derives why `F<A>` needs the same input kind, contrasts the
omitted binder, and ends with exercises on partial application and the
right-associative `Type -> Type -> Type`. Keep project state out of lesson prose.

Update root/content counts to three library lessons, and the roadmap to
`3 library lessons / 10 sources`. Promote method-local type parameters as the
sole next outcome. Record RED/GREEN observations in this plan, then commit the
complete lesson.

## Verification and closure

Run the lesson verifier, library aggregate, Learn aggregate, Cases aggregate,
and retained eight-failure lab once from clean implementation HEAD. Run Bash
syntax, ShellCheck, Markdownlint, relative links, exact clean pins, old-pin
audit, counts, `git diff --check`, and clean status. Run focused exact-pin kind
and specification-example tests.

```bash
lib_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-lib-pin
modular_pin=/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash content/libraries/accepting-type-constructors/checks/verify.sh "$lib_pin"
bash content/libraries/checks/verify.sh "$lib_pin"
bash content/learn/checks/verify.sh "$lib_pin"
bash content/cases/checks/verify.sh "$lib_pin"
bash lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
  "$modular_pin" "$lib_pin"
bash -n content/libraries/accepting-type-constructors/checks/verify.sh
shellcheck -x -P SCRIPTDIR \
  content/libraries/accepting-type-constructors/checks/verify.sh
markdownlint-cli2 '**/*.md' '#.worktrees/**'
test "$(git -C "$lib_pin" rev-parse HEAD)" = \
  d1e323d23390cdad03202ee3df76cd9100556e1d
test "$(git -C "$modular_pin" rev-parse HEAD)" = \
  dca16039923475c48025c5f17beadeb6bcb6a4bf
test -z "$(git -C "$lib_pin" status --short)"
test -z "$(git -C "$modular_pin" status --short)"
! rg -n 'dca16039923475c48025c5f17beadeb6bcb6a4bf|modular-ash' \
  content/learn content/cases content/libraries
test "$(find content/libraries -type f -name '*.ash' | wc -l)" -eq 10
test "$(grep -Ec '^[0-9]+\. \[' content/libraries/README.md)" -eq 3
git diff --check
test -z "$(git status --short)"
```

Run the read-only link audit:

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

From the exact Lib checkout run:

```bash
cargo test --locked --test kinds \
  applying_a_type_kinded_binder_reports_not_applicable -- --exact
cargo test --locked --test kinds \
  omitted_lists_do_not_infer_arrow_kinds_in_this_phase -- --exact
cargo test --locked --test polymorphism \
  higher_kinded_instantiation_preserves_fixed_kinds -- --exact
cargo test --locked --test spec_examples \
  tool_higher_kinded_example_has_exact_cli_observation -- --exact
```

Obtain one combined authority/instructional review. Correct findings, delete
this temporary plan and its roadmap link, commit closure, and obtain one fresh
whole-branch review. Fast-forward local `main`, run the library aggregate plus
repository cleanliness/count checks, and remove the worktree and branch.

Do not modify Ash, tag, push, create lesson-4 content, or resume blocked Cases.
