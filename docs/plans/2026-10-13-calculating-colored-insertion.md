# Calculate colored insertion implementation plan

**Goal:** Let the reader derive colored insertion from a motivating example,
the representation, operation signatures, and small expected calculations.

**Architecture:** Revise the opening and insertion portion of the existing
search-tree lesson. Keep the canonical algorithm unchanged, display checked
definition excerpts as non-executable fragments, and add one small complete
public client for the motivating repair. Keep the existing comprehensive
clients and their complete observations for this bounded trial.

**Tools:** Markdown, pinned Ash, lesson-local Bash and Python standard-library
checks, Quarto Book, and Typst.

## Approved boundary

The user approved the sequence: problem and example, data and invariants,
operations with types and purposes, derivation of each operation, then an
assembled program and explained observation. HtDP and DCIC supply teaching
methods, while Ash semantics remain governed by `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`. Use original exposition and the
existing original Ash algorithm. This trial does not redesign the algorithm,
publish the edition, or revise every long result in the specimen.

An annotated whole-module listing would retain the reader's assembly view but
still separate the needed equations from their explanations. Checked excerpts
beside the calculations make those relationships local; the complete source
remains available as a runnable companion. Select that smaller teaching change
and keep its excerpt check local until another lesson needs the same mechanism.

## Execution

1. Establish the clean rendering worktree at `eaec825`, retain the current
   generated PDFs as the accepted comparison, and run the affected baseline
   lesson check against the exact Ash checkpoint.
2. Add meaningful failing tests for exact lesson-local excerpt agreement:
   altered code, an unknown or orphaned marker, and a complete successful
   definition/signature excerpt. Implement only the local comparison needed by
   this lesson; retain the shared whole-program check for complete clients.
3. Revise
   `content/cases/guaranteeing-logarithmic-retrieval/README.md` through the end
   of the defining-module observation. Introduce the concrete degeneration
   problem, the actual `Color` and `Dictionary` declarations, the operation
   inventory and its stated premises, then derive `restore_three`, `restore`,
   `insert_colored`, `blacken_root`, and public `insert`. Use expected examples
   before code and show each meaningful case. Distinguish local repair from
   final root blackening. Retain the three note forms and the wide diagram.
4. Add `src/03-repair.ash` as a small complete public client inserting the
   associations `(3, 30)`, `(2, 20)`, and `(1, 10)`. Check its complete value,
   type, and exit status, including the final black root and retained
   associations. Preserve the original three canonical sources byte for byte.
5. Adjust the lesson-local verifier's source inventory, excerpt comparison,
   small observation, and displayed-client checks. Preserve every existing
   source relationship assertion and complete captured observation. Update
   source counts in the project verification records where necessary.
6. Build all four specimen outputs, run artifact/browser checks and EPUBCheck,
   inspect the revised derivation in both PDFs and narrow/reflowable outputs,
   and fix layout problems without shrinking code or altering captures.
7. Review the prose against the approved teaching sequence and the program
   against the pinned specification. Run Markdown lint, relevant ShellCheck,
   lesson checks, local excerpt tests, and `git diff --check`. Remove this
   completed plan and its active links when all work is verified. Commit
   without GPG signing and deliver both PDFs for review; preserve the worktree
   and its ignored output/toolchain files.

## Verification commands

From the rendering worktree, run:

<!-- markdownlint-disable MD013 -->

```text
RUSTC_WRAPPER= bash content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh .build/ash
python3 -m unittest discover -s content/cases/guaranteeing-logarithmic-retrieval/checks -p 'test_*.py'
python3 rendering/build.py
python3 rendering/checks/verify.py
node rendering/checks/browser.mjs
java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar .build/specimen/output/ash-doc-specimen.epub
git diff --check
```

<!-- markdownlint-enable MD013 -->

The removal condition is a verified lesson trial with readable output in both
PDFs and preserved source/capture agreement. Revisit the local excerpt form
when another complete lesson needs it; do not generalize its checker now.
