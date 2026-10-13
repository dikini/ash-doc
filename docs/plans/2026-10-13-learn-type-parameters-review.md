# Learn lesson 11 teaching review

## Approved outcome

Reader question:
Which types change while a definition's structure remains the same?
The observable boundary is
type instantiation and complete value types.
The [roadmap outcome](../project/roadmap.md#selecting-work) owns this plan.
Implement the approved thirteen-chapter review one complete lesson at a time.

Target `diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
Use an isolated ash-doc worktree and a separate clean exact-pin Ash checkout.
Preserve unrelated upstream edits.

## Design and authority

Revise existing examples and exercises. Replacing programs would require new
evidence and disrupt the progression; deferral leaves results before useful
predictions. Write original prose using the existing
[DCIC](../../research/data-centric-introduction-to-computing.md) and
[Liquid Shplait](../../research/liquid-shplait-teaching.md) inspiration records.
The pinned [static rules][static], [evaluation rules][dynamic], and
[tool contract][tool] govern Ash claims.

Preserve 5 canonical sources, 3 accepted entries, and
1 complete rejection capture, plus their fixtures and checks.
Keep all canonical Ash fences exact. Retain canonical observations and complete
diagnostics; the lesson 1 and 2 exercise answers are the approved exclusions.
Do not change the compiler target, programs, tooling, or publication choices.

## Execution

Revise `content/learn/definitions-for-many-types/README.md`.

Identify each substitution before showing observations. Derive map from list
structure and the supplied transformation. Establish the complete-type rule
before the bare-List rejection. Continue into lesson 12 and keep lists.ash
beside a fresh entry for the element-type exercise.

Keep the thirteen-lesson order and shared setup. Introduce the model before a
question needs it and interpret the observation nearby. Start exercises from
fresh scratch programs outside canonical source trees; copy required sibling
modules together. Keep assistant prompts sparse and optional.

Review every changed file as source, including claims, prerequisite vocabulary,
links, attribution, and undisclosed exercise observations. Verify before
committing. Update the chapter's description in
`docs/project/beginning-learning-path.md` and the roadmap as applicable.
Remove this plan and its active index link before advancing.

## Verification

Run with a clean exact-pin checkout at `/path/to/diag-ash`:

```sh
env RUSTC_WRAPPER= bash \
    content/learn/definitions-for-many-types/checks/verify.sh \
    /path/to/diag-ash
git ls-files -z '*.md' | xargs -0 markdownlint
git ls-files -z '*.sh' | xargs -0 -n1 bash -n
git ls-files -z '*.sh' | xargs -0 shellcheck -x -P SCRIPTDIR
git diff --check
```

The existing helper permits a prepared exact-pin binary and verification
directory to be reused through its exported state. Build it once with locked
dependencies. Keep semantic JSON checks separate from complete English human
agreement. Retain the first eleven lessons' diagnostic working directory and
the continuation chapters' lesson-local directory. Check relative links and
pinned anchors. At lesson 13, run the Learn aggregate once for all 57 sources,
39 accepted entries, and sixteen rejection captures.

[static]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#kinds-monotypes-and-schemes
[dynamic]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#type-instantiation-and-erasure
[tool]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/tools/ash.md
