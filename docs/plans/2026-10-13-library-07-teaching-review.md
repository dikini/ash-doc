# Library chapter 7: teaching review

## Approved outcome

What does a nominal wrapper change about representation and behavior? The
observable boundary is the chapter's existing accepted entries
and intentional rejections. Continue Learn and the preceding library chapters.
The user approved the eight-chapter design on 2026-10-13. This chapter is the
one active outcome; finish it before beginning the next.

Target `diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
Edit `content/libraries/wrapping-a-representation/README.md`.
The family index owns shared setup and scratch-copy guidance. Project records
own review state; keep that administration outside rendered lessons.

Predict values and reported types separately; connect explicit conversions,
nominal evidence, and constructor access to their boundaries; retain
independent allocation evidence.

Use original explanations informed by the existing Liquid Shplait, DCIC, and
HtDP records. Preserve their adaptation and license boundaries. The existing
examples already establish the requested distinctions. Revising prose and
exercises is smaller than adding programs and their evidence; deferral leaves
predictions after answers and exercises with unclear starting states.

## Governing boundaries

- [static-semantics.md#tuples-and-constructors](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#tuples-and-constructors)
- [name-resolution.md#public-private-and-opaque-declarations](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/name-resolution.md#public-private-and-opaque-declarations)
- [elaboration.md#explicit-rank-1-operations](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/elaboration.md#explicit-rank-1-operations)
- [Tool observations](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/tools/ash.md)

Preserve all 9 canonical sources and displayed Ash blocks, 5 accepted
entry observations, 3 complete English diagnostic captures, semantic JSON
fixtures, source inventories, and causal source checks. Introduce requirements
before fair questions; place predicted answers after observations. Each practice
task starts from a fresh named baseline outside canonical source trees, with
required siblings kept together. Withhold its discovery result.

No Ash APIs, compiler pin, program behavior, checks, tooling, publication,
or additional curriculum changes belong to this outcome.

## Execution and completion

1. Read the complete chapter, verifier, governing sections, and relevant tool
   behavior. Check the first account against its negative examples.
2. Revise prose and exercises while preserving executable fences and captures.
3. Read the whole changed source and review causal explanations, vocabulary,
   continuity, links, attribution, and undisclosed exercise results.
4. Run this chapter's verifier against a separate clean exact-pin Ash checkout.
   For chapter eight, run the family aggregate once instead. Chapter seven
   also runs the focused wrapper allocation test from that checkout.
5. Run Markdown lint and diff checks for the chapter. The completed family
   also requires repository Markdown lint, Bash syntax checks, ShellCheck,
   link and anchor review, source-preservation review, and git status review.
6. Record completion in the roadmap, remove this plan and its index link,
   and commit the verified chapter before advancing.

```sh
bash content/libraries/wrapping-a-representation/checks/verify.sh
/path/to/diag-ash
```

The final aggregate is `bash content/libraries/checks/verify.sh
/path/to/diag-ash`.
The focused test is
`cargo test --locked --lib module_newtype_wrapper_allocates_no_constructor_cell`.
