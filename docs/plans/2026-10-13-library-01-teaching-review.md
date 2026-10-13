# Library chapter 1: teaching review

## Approved outcome

Which names and evidence does the comparison client need? The observable
boundary is the chapter's existing accepted entries
and intentional rejections. Continue Learn and the preceding library chapters.
The user approved the eight-chapter design on 2026-10-13. This chapter is the
one active outcome; finish it before beginning the next.

Target `diag-ash` at `9ec5920e8c395f9a36125805ee93b7f58c0f4764`.
Edit `content/libraries/choosing-implementation-evidence/README.md`.
The family index owns shared setup and scratch-copy guidance. Project records
own review state; keep that administration outside rendered lessons.

Predict the complete `Equal<Int>` requirement and the comparison before its
answer; trace declaration, requirement, selector, and method.

Use original explanations informed by the existing Liquid Shplait, DCIC, and
HtDP records. Preserve their adaptation and license boundaries. The existing
examples already establish the requested distinctions. Revising prose and
exercises is smaller than adding programs and their evidence; deferral leaves
predictions after answers and exercises with unclear starting states.

## Governing boundaries

- [name-resolution.md#imports-and-namespaces](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/name-resolution.md#imports-and-namespaces)
- [static-semantics.md#interfaces-and-constrained-schemes](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#interfaces-and-constrained-schemes)
- [static-semantics.md#constraint-satisfaction-and-checked-evidence](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
- [elaboration.md#interface-evidence-lowering](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/elaboration.md#interface-evidence-lowering)
- [Tool observations](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/docs/tools/ash.md)

Preserve all 3 canonical sources and displayed Ash blocks, 1 accepted
entry observations, 1 complete English diagnostic captures, semantic JSON
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
bash content/libraries/choosing-implementation-evidence/checks/verify.sh
/path/to/diag-ash
```

The final aggregate is `bash content/libraries/checks/verify.sh
/path/to/diag-ash`.
The focused test is
`cargo test --locked --lib module_newtype_wrapper_allocates_no_constructor_cell`.
