# Calculate insertion-prefix observations implementation plan

**Goal:** Let the reader design the prefix-observation program and interpret
its results without a large listing or nested transcript interrupting the
explanation.

**Architecture:** Keep all four canonical Ash programs unchanged. Develop
`01-prefix-matrix.ash` through exact, labelled non-executable excerpts. Retain
the complete captured stdout as a fixture and verify labelled components and
a six-run summary against that capture. Keep the existing renderer and checks
for complete programs; extend only this lesson's local comparisons.

**Tools:** Markdown, pinned Ash, Bash, Python standard library, Quarto Book,
Typst, EPUBCheck, and the existing browser and PDF checks.

## Approved outcome and boundaries

The user requested the same problem, data, operation-type, top-down program
recipe for “Check every selected insertion prefix”, smaller explained
observations, and both regenerated PDFs. This continues the approved rendering
teaching trial. The target remains `diag-ash` at
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`; publication has not occurred.

A shared helper module plus short runnable clients would produce separate CLI
observations but require refactoring and repeated input setup. Keeping the
complete canonical matrix and displaying checked components of its successful
result needs no program change. Select that smaller approach. Label every
component as part of the one returned value, rather than a separate CLI run,
and preserve the complete value and type in its capture fixture.

The reader already knows dictionary insertion, its invariants, recursive
lists, tuples, function application, and Option. Introduce the observation
roles of PrefixCheck, PrefixRun, and Scenario with detail. Calculate operation
inputs/results before bodies, then proceed from scenario into prefix_run,
lookup_checks, and the small Option predicates. Explain the selected-report
premises: first association retained, absent key outside the input, distinct
keys for the final original-association checks. The six scenarios contain
26 nonempty prefix checks, six empty-prefix checks, and 32 final flags.
These finite observations do not prove general preservation.

## Execution

1. Retain accepted PDF comparisons under ignored QA output. Verify the
   unchanged baseline lesson and exact tool target. Read the pinned tuples,
   functions, bindings, matches, globals, and successful tool-output rules.
2. Add failing tests for exact prefix-source excerpts and successful-capture
   components: altered code/indentation, missing markers, incorrectly selected
   components, malformed capture, wrong shape/count, and stale summary. Extend
   the lesson-local checks with a closed set of source regions and a small
   structural reader for the captured constructor/tuple forms. Do not evaluate
   captured expressions or generalize this into a registry or Ash parser.
3. Rewrite only the prefix section, ending before “Retain build, replacement,
   and older values”. Begin with the three-key problem. Describe input and
   observation data, calculate operation types, then derive public scenario
   composition and smaller recursive jobs. Show short canonical setup/assembly
   portions and labelled components of the actual three-key result. Compare
   all six selected runs in a checked summary.
4. Keep the four Ash files byte for byte and preserve existing causal checks,
   hashes, outputs, and exact compiler pin. Replace only the matrix's inline
   whole-block/transcript agreement with local excerpt/projection agreement.
   Check the complete captured stdout, type, empty stderr, and status zero.
5. Build all four formats and verify artifact, browser, EPUB, and both PDF
   layouts. Use wider code only where wrapping hides structure; keep each wide
   block on one page, at the same type size, clear of notes. Inspect all revised
   pages and earlier/later boundaries. Do not change renderer geometry.
6. Read every changed source, review semantic and teaching claims, run Markdown
   lint, relevant ShellCheck, local comparisons, and diff/status checks. Remove
   this completed plan and active links. Commit without GPG signing on the
   rendering branch and refresh the same privately authorized phone PDFs.

## Verification

<!-- markdownlint-disable MD013 -->

```sh
RUSTC_WRAPPER= bash content/cases/guaranteeing-logarithmic-retrieval/checks/verify.sh .build/ash
python3 -m unittest discover -s content/cases/guaranteeing-logarithmic-retrieval/checks -p 'test_*.py'
python3 rendering/build.py
python3 rendering/checks/verify.py
node rendering/checks/browser.mjs
java -jar .build/toolchain/epubcheck-5.4.0/epubcheck.jar .build/specimen/output/ash-doc-specimen.epub
git ls-files -z '*.md' | xargs -0 markdownlint
git diff --check
```

<!-- markdownlint-enable MD013 -->

The removal condition is a verified prefix-teaching revision with exact source
and complete-capture agreement and legible output. Revisit the local excerpt
and projection check only when another complete lesson needs the mechanism.
