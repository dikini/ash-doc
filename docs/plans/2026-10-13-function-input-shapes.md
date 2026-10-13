# Function input shapes implementation plan

**Goal:** Show how a curried call differs from supplying one tuple, using
the existing Learn examples.

**Approach:** Name the demonstrated curried form in the several-input lesson,
then compare it with the tuple-input form once tuples have been introduced.
Reuse canonical programs and their existing lesson-local checks.

**Tools:** Markdown, Bash verification, and the pinned Ash executable.

## Reader boundary and authority

The reader asks whether `add 20 22` and `sum_pair (20, 22)` differ only in
punctuation. The observable boundary is the shape consumed by each arrow and
the result remaining after one application. Both lessons already introduce
the required values, function arrows, patterns, and examples.

Target Diag Ash commit `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
The pinned specification's functions and application, tuple typing, and
syntax chapters govern the explanation. The pinned tool guide governs the
captured values and types. Use the project's HtDP/DCIC teaching recipe to
compare predictions with existing observations; add no adapted source text.

Compare a new combined program with a comparison of the existing `add` and
`sum_pair` examples. Select the latter: both programs and the partial call
already have canonical sources and checks. Add no lesson, tool, or fixture.

## Execution

1. In `content/learn/using-more-than-one-input/README.md`, name currying and
   partial application after their existing explanations.
2. In `content/learn/values-travel-together/README.md`, compare types, full
   calls, and the result after one input. Explain the equivalent no-space
   pair call. Keep the distinction local to the demonstrated signatures;
   a tuple-input function may itself return a function.
3. Read the changed source and review the teaching sequence. Run both
   lesson-local `checks/verify.sh` scripts against `.build/ash`, sharing one
   clean pinned build. Check the no-space spelling with a temporary copy of
   the canonical pair program. Preserve all canonical source bytes.
4. Run Markdown lint, resolve changed relative links and pinned anchors, and
   run `git diff --check`. These chapters are outside the rendering specimen;
   no PDF regeneration is needed for this clarification.
5. Update the roadmap, remove this completed plan, and commit without GPG
   signing. Keep repair candidates and the active repair lesson unchanged.
