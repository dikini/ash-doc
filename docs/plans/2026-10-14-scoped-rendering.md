# Scoped rendering implementation plan

**Goal:** Make the approved lesson, part, book, and specimen scopes govern
preparation, rendering, artifact checks, and browser review. Editing and review
follow the same task boundary in project instructions.

**Scope and action:** Book infrastructure; implement shared scope selection and
format selection. Review only affected infrastructure and policy. Do not edit
lesson prose, canonical Ash programs, the separate cover draft, or upstream
tools. Target `diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.

**Architecture:** Extend `rendering/build.py` and its existing generated records.
Use the current indexes to select one lesson, one complete family part, the
whole book, or the specimen. Keep Quarto Book, Typst, fonts, styles, diagram
adapters, and immutable source-link behavior shared. Scope-specific output
folders preserve other review drafts. Formats default to the existing four
outputs; explicit selection prepares and verifies only requested outputs.

An incremental whole-book cache is a credible alternative, but it requires
additional invalidation rules and still assembles unrelated chapters. Select
scopes first. Reconsider caching only after measurements expose remaining
cost inside the selected scope. No general task runner or content registry is
selected. A full-book build still establishes complete-book pagination.

1. Check the clean renderer baseline in `.worktrees/scoped-rendering`, with
   bundled toolchain links. Preserve the existing primary working changes.
2. Add failing selection and dispatch tests in `rendering/checks/test_build.py`
   and implement mutually exclusive `--lesson`, `--part`, and `--whole-book`
   selection plus independent `--formats` in `rendering/build.py`. Reject
   unindexed inputs and conflicting reuse of generated output directories.
3. Add failing identity/format coverage checks in
   `rendering/checks/test_verify.py`; adapt `rendering/checks/verify.py` to
   verify exactly the declared scope and outputs. Keep strict whole-book and
   selected search-tree/specimen regression checks.
4. Add browser planning tests in `rendering/checks/browser.test.mjs`; adapt
   `rendering/checks/browser.mjs` for actual HTML/EPUB outputs and selected
   source chapters, without requiring a search-tree lesson in every scope.
5. Document task action/scope and affected-check rules in `AGENTS.md`,
   `docs/project/workflow.md`, and the writing skill. Update
   `docs/project/rendering.md` with scoped commands and verification.
6. Run affected Python and Node renderer tests, Markdown checks, and diff
   checks. Build the traversal lesson in both PDFs, a part in selected
   formats, and specimen/book regression outputs needed for the changed
   shared paths. Measure preparation, rendering, and verification phases;
   verify selected outputs and inspect representative print pages.
7. Record observed coverage and timings in the roadmap/rendering guide,
   remove this temporary plan, and leave the implementation and review
   artifacts on the isolated branch for user review. Use unsigned commits.

Success means a lesson request never prepares or checks unrelated lessons,
a part retains its indexed order and introduction, requested formats alone
are required, and the existing book/specimen contracts remain verifiable.
