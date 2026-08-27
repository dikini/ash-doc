# Beginning Path Review Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to
> implement this plan task-by-task.

**Goal:** Review the eleven-lesson beginning path as one reader experience,
make the smallest evidence-backed revisions, and close the roadmap increment.

**Architecture:** Use the temporary plan as the course audit ledger while the
work remains active. Establish the executable baseline, audit the three course
parts in order, classify findings before editing, and verify the complete path
after revision. Keep lesson prose, canonical programs, and checks in their
existing local boundaries.

**Tech Stack:** Markdown, Bash, Git, `markdownlint-cli2`, and Ash
`modular-ash` at `dca16039923475c48025c5f17beadeb6bcb6a4bf`.

---

## Worktree and authority

Work in `/home/dikini/Projects/ash-doc/.worktrees/beginning-path-review` on
branch `docs/beginning-path-review`. Do not merge or push the branch while
executing this plan.

Use @writing-ash-documentation for every lesson or project-prose review and
edit. Use the pinned specification for language claims and the pinned tool
guide, implementation, and tests for commands and executable observations.
Do not import language behavior from current `ash-lang/main`.

The clean pinned Ash checkout is:

```text
/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Make unsigned commits with:

```bash
git -c commit.gpgsign=false commit --no-gpg-sign -m "<message>"
```

## Audit ledger

During Tasks 2 through 4, add concise findings below this paragraph. Each
finding must name the lesson and exact passage, the earlier idea on which it
depends, the observable reader or executable evidence, and one disposition:
retain, revise locally, verify against a governing source, consider structural
change, or route outside ash-doc. Do not propose wording until the evidence and
disposition are recorded.

### Baseline

- Intended outcome: a learner can design, run, and explain a pure multi-file
  Ash program over data they define; trace values through functions; use
  patterns to distinguish data; follow a data definition with recursion; and
  use type parameters when a definition does not depend on a particular
  element type.
- Lesson order:

  1. *What is an Ash program?*
  2. *How can one source file use another?*
  3. *How can a function use more than one input?*
  4. *How can a program choose a result?*
  5. *How can a calculation name an intermediate value?*
  6. *How can several values travel together?*
  7. *How can a program define its own data?*
  8. *How can a function handle each form of data?*
  9. *How can a function follow recursive data?*
  10. *How can a function itself be a value?*
  11. *How can one definition work with many types?*
- Excluded topics: interfaces, implementations, constraints, or ad-hoc
  polymorphism; opaque or hidden representation boundaries; targeted imports,
  named roots, or re-export details; advanced restrictions on recursive
  initialization; and documentation tooling and publication mechanisms.
- Review boundary: cross from lesson-local executable verification to the
  continuity of the eleven lessons as one reader experience. Audit
  prerequisites, transitions, vocabulary, exercises, assistant prompts, and
  the final outcome without adding another language topic.
- Executable baseline: `Verified 11 learning lesson(s) at
  dca16039923475c48025c5f17beadeb6bcb6a4bf.`

### Lessons 1–5: programs and calculations

#### Lesson 1: *What is an Ash program?*

- **Prerequisites and opening — retain.** The opening before the first
  `ash program.ash` command assumes only the index setup and contrasts a list
  of commands with definitions whose expressions calculate values. It then
  establishes `main ()` as the entry calculation and `value : Type` as the
  observation. The `01-literal.ash` result is `42 : Int`, exactly as the
  [lesson verifier](../../content/learn/what-is-an-ash-program/checks/verify.sh)
  asserts. This model agrees with the pinned specification's
  [entry contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  and the pinned tool's
  [successful-output contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output).
- **Predict, run, and explain — retain.** In
  [*Expressions calculate values*](../../content/learn/what-is-an-ash-program/README.md#expressions-calculate-values),
  `02-addition.ash` asks for the value before the run, while
  `03-precedence.ash` and `04-grouping.ash` pair predictions with explicit
  calculations and observed `7 : Int` and `9 : Int`. In
  [*Giving a calculation a name*](../../content/learn/what-is-an-ash-program/README.md#giving-a-calculation-a-name),
  `05-function-call.ash` and `06-composition.ash` reuse the smaller-expression
  model to calculate outward before reporting `42 : Int`.
  `01-literal.ash` establishes the first observation before asking for
  predictions. The verifier asserts every displayed result, and the
  sequence follows pinned
  [precedence](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#precedence-and-associativity),
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application),
  and
  [primitive-operation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#primitive-operations)
  behavior.
- **Vocabulary at the expression `double (increment 20)` — retain.** The
  passage first explains the observable relationship—the result of `increment`
  becomes the input to `double`—and then names that connection *function
  composition*. The
  [beginning-path record](../project/beginning-learning-path.md#programs-and-calculations)
  includes composition in lesson 1's verified scope. Lesson 5's description of
  the same source as a nested expression identifies its syntactic shape; it
  does not conflict with the project-level vocabulary. Removing the term would
  update that recorded scope, and the audit found no reader evidence that
  justifies such a change.
- **Negative boundary — retain.**
  [*Where does evaluation begin?*](../../content/learn/what-is-an-ash-program/README.md#where-does-evaluation-begin)
  presents a `Unit -> Int` definition under `answer` instead of `main`; the
  reader runs `07-missing-main.ash`, sees `entry.missing-main`, and explains why
  an otherwise valid definition is not the entry. The verifier also requires
  the causal text about no local `main` and status `1`, matching the pinned
  [program rule](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  and tool
  [failure contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#failures).
- **Exercise and assistant prompts — retain.**
  [*Exercise: square, then double*](../../content/learn/what-is-an-ash-program/README.md#exercise-square-then-double)
  requires only signatures, one-input definitions, calls, multiplication, and
  inside-out prediction already introduced in this lesson; its expected
  reasoning is `square 3` to `9`, then `double 9` to `18 : Int`. The grouping
  prompt asks the learner to defend a comparison, while the exercise prompt
  asks them to trace one expression at a time. Those are distinct uses of
  dialogue and both withhold a solution until after the learner reasons.
- **Handoff — retain.**
  [*The whole program*](../../content/learn/what-is-an-ash-program/README.md#the-whole-program)
  gathers definitions, expressions, calls, `main`, and the tool observation,
  then makes the one-file boundary explicit. That creates the next lesson's
  question—how one file can use a definition from another—without introducing
  module vocabulary early.

#### Lesson 2: *How can one source file use another?*

- **Prerequisites and opening — retain.** The opening names lesson 1's
  one-file definitions and `main` as its starting point, then establishes the
  new model before `ash main.ash`: two source files remain parts of one program
  and an import connects their modules. `arithmetic.ash` reuses the earlier
  `double` call before introducing `pub`; `01-main.ash` then introduces the
  import path, alias, and qualified call. This agrees with pinned
  [module paths](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#module-paths-and-identity)
  and
  [imports and namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces).
- **Positive and negative tool cycle — retain.** The unnamed opening passage
  directs `ash main.ash`, presents `42 : Int`, and then traces
  `Arithmetic.answer ()` through `double 21`. The
  [*What remains inside a module?*](../../content/learn/using-another-source-file/README.md#what-remains-inside-a-module)
  passage directs the run of `02-private-main.ash`, presents
  `resolve.unavailable-export`, and then explains the private-declaration
  cause. The shared
  [lesson method](../../content/learn/README.md#how-to-work-through-a-lesson)
  already asks the reader to predict every program before running it. As in the
  varied tool cycle retained for lesson 4, repeating that instruction locally
  would not solve a distinct reader problem: the positive trace and negative
  explanation provide the needed comparison, and the assistant prompt supports
  diagnosis after observation. The verifier establishes both exact outcomes.
  The private cause is governed by pinned
  [public and private declarations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations).
- **Exercise — retain.**
  [*Exercise: move `square`*](../../content/learn/using-another-source-file/README.md#exercise-move-square)
  depends on lesson 1's `square`, signatures, calls, prediction, and `main`,
  plus this lesson's two-file layout, `pub`, import alias, and qualified call.
  The learner must predict `36 : Int`, then remove `pub` and explain the
  changed observation as an access boundary between the two modules.
- **Assistant prompt — retain.** The prompt in
  [*What remains inside a module?*](../../content/learn/using-another-source-file/README.md#what-remains-inside-a-module)
  adds a distinct cross-file diagnostic task: locate the import, alias, public
  declaration, and qualified occurrence before considering a change. The
  lesson remains complete without it, and the prompt uses only names already
  introduced.
- **Handoff — retain.**
  [*One program, two files*](../../content/learn/using-another-source-file/README.md#one-program-two-files)
  gathers the module access model, then points out that every function used so
  far still receives one input. This directly creates the question answered by
  lesson 3 rather than adding another module feature.

#### Lesson 3: *How can a function use more than one input?*

- **Prerequisites and opening — retain.** The opening recalls lesson 1's
  one-input `double`, lesson 2's `Arithmetic.answer ()`, and the established
  function-call model. Before the first run it establishes that each call
  supplies one input and may leave a function waiting for another. That is the
  working model needed to read `Int -> Int -> Int`, whose arrows are
  [right-associative](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#precedence-and-associativity),
  and application remains unary under pinned
  [function typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application).
- **Predict, run, and explain — retain.**
  [*Supplying two inputs*](../../content/learn/using-more-than-one-input/README.md#supplying-two-inputs)
  calculates `add 20 22` before the `42 : Int` run;
  [*Pausing after the first input*](../../content/learn/using-more-than-one-input/README.md#pausing-after-the-first-input)
  asks what is missing before observing `<function> : Int -> Int`, then
  `03-reuse-a-partial-call.ash` traces the remembered input before its run.
  [*Each input keeps its type*](../../content/learn/using-more-than-one-input/README.md#each-input-keeps-its-type)
  uses `04-wrong-input.ash` to explain `type.argument` from the remaining
  `Int -> Int` domain. The verifier asserts all four observations, including
  `expected Int` and status `1`; the function rendering is part of the pinned
  tool's
  [successful-output contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output).
- **Exercise — retain.**
  [*Exercise: multiply three numbers*](../../content/learn/using-more-than-one-input/README.md#exercise-multiply-three-numbers)
  uses only multiplication, signatures, parameters, calls, and the newly
  introduced right-associated-arrow model. The learner must account for three
  inputs, predict both an integer result and the type left after two inputs,
  then complete and run the call.
- **No assistant prompt — retain.** The chapter supplies the two-step model,
  concrete arrow regrouping, a rendered function value, a reusable partial
  call, and a type rejection. An assistant would not add a distinct task to
  the existing predict-and-explain sequence, and the exercise remains
  self-contained.
- **Handoff — retain.**
  [*From inputs to decisions*](../../content/learn/using-more-than-one-input/README.md#from-inputs-to-decisions)
  gathers complete and partial calls, then contrasts every calculation's fixed
  route with the need to inspect a value. That creates lesson 4's decision
  question using the expression model already in place.

#### Lesson 4: *How can a program choose a result?*

- **Prerequisites and opening — retain.** The opening depends on the earlier
  expression-tracing model and lesson 3's multi-input calls. Before the first
  run, it establishes a two-part decision: an expression produces `true` or
  `false`, and a `match` supplies one result expression for each value. The
  later `choose : Bool -> Int -> Int -> Int` therefore adds no new call shape.
- **Question and choice observations — retain.**
  [*Asking a question*](../../content/learn/choosing-a-result/README.md#asking-a-question)
  predicts `20 + 22 == 42` before observing `true : Bool`, then asks for a
  changed prediction and run with `41`.
  [*Describing both choices*](../../content/learn/choosing-a-result/README.md#describing-both-choices)
  traces `02-choose.ash` for `true` and reasons about the `false` alternative;
  [*Calculating the condition*](../../content/learn/choosing-a-result/README.md#calculating-the-condition)
  traces the earlier arithmetic expression into `03-calculated-choice.ash`.
  Challenging the lack of a repeated run command does not justify revision:
  the equality run establishes the observation, the two traces explain the new
  match behavior, the exercise runs both routes, and the verifier asserts all
  three canonical results. This varied sequence avoids turning the tool cycle
  into a repeated prose template. The calculations agree with pinned
  [primitive operations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#primitive-operations)
  and
  [match evaluation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches).
- **Negative boundary — retain.**
  [*Accounting for every value*](../../content/learn/choosing-a-result/README.md#accounting-for-every-value)
  starts from the newly established two-value `Bool` model, removes the
  `false` arm in `04-missing-choice.ash`, and explains
  `coverage.non-exhaustive` as a pre-execution rejection. The verifier asserts
  that reason, its stable causal text, and status `1`, matching pinned
  [match coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage).
- **Exercise and assistant prompt — retain.**
  [*Exercise: keep or double*](../../content/learn/choosing-a-result/README.md#exercise-keep-or-double)
  requires only lesson 3's two-input signatures and calls plus this lesson's
  `Bool`, equality, match arms, and common `Int` result. The learner predicts
  both direct Boolean routes and then replaces the condition with a calculated
  equality. The assistant prompt has distinct value at the negative boundary:
  it asks the learner to identify and justify the missing value before seeking
  feedback, without teaching diagnostic presentation as a contract.
- **Handoff — retain.**
  [*A complete decision*](../../content/learn/choosing-a-result/README.md#a-complete-decision)
  gathers Boolean production, exhaustive matching, and the selected result,
  then identifies the cost of repeating a growing expression when one arm has
  several steps. This creates lesson 5's local-name question.

#### Lesson 5: *How can a calculation name an intermediate value?*

- **Prerequisites and opening — retain.** The opening returns to lesson 1's
  exact `double (increment 20)` expression and the smaller-expression model.
  Before any run, it establishes a block as one expression that can name the
  ordered route to its one result. This model follows pinned block
  [syntax](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  and left-to-right
  [local scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#local-scope).
- **Positive observations — retain.**
  [*Naming one result*](../../content/learn/naming-intermediate-values/README.md#naming-one-result)
  explains the `01-one-name.ash` binding and final expression, traces each, and
  then runs the program for `42 : Int`.
  [*Letting one step use another*](../../content/learn/naming-intermediate-values/README.md#letting-one-step-use-another)
  makes the dependency in `02-several-names.ash` explicit, predicts `21` then
  `42`, and asks the run to check the chain. The verifier asserts both results,
  and pinned
  [block typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks)
  and
  [binding evaluation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings)
  support the causal account.
- **Negative boundary — retain.**
  [*Names appear in order*](../../content/learn/naming-intermediate-values/README.md#names-appear-in-order)
  changes `03-forward-reference.ash` so `answer` depends on a later local,
  explains why `later` is not in scope, observes `resolve.unknown-name`, and
  asks the learner to reorder and rerun. The verifier asserts the stable reason,
  `not in scope`, and status `1`. The existing negative is the smallest account
  of ordinary sequential `let`; the pinned
  [local-scope rule](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#local-scope)
  also keeps the later recursion topic intentionally out of this lesson.
- **Exercise prerequisite — revise locally.**
  [*Exercise: expose the hidden steps*](../../content/learn/naming-intermediate-values/README.md#exercise-expose-the-hidden-steps)
  asks the learner to name the intermediate results and preserve `42 : Int`,
  using only lesson 1's `increment`, `double`, and inside-out trace plus this
  lesson's sequential bindings. However, “Keep the existing
  `increment` and `double` definitions” has no local antecedent: all three
  canonical programs in this lesson define only `main`. Challenging the issue
  against lesson 1 confirms that the needed definitions already exist there,
  so the bounded correction points back to that earlier program rather than
  adding a new example or structural change. The rewrite remains governed by
  pinned
  [block typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#blocks)
  and
  [binding evaluation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings).
- **No assistant prompt — retain.** The chapter already makes the intermediate
  values visible in prose calculations, tests the ordering boundary, and gives
  a bounded rewrite exercise. After the exercise prerequisite is clarified,
  dialogue would not add a distinct task and the lesson remains independently
  usable.
- **Handoff — retain.**
  [*A calculation with visible steps*](../../content/learn/naming-intermediate-values/README.md#a-calculation-with-visible-steps)
  gathers blocks, sequential local names, and the final result, then contrasts
  one name for one value with several values that belong to one step. That
  directly creates lesson 6's question of how several values travel together.

### Lessons 6–9: data and structure

#### Lesson 6: *How can several values travel together?*

- **Prerequisites and opening — retain.** The opening recalls lesson 5's local
  `let` binding and lesson 1's distinction between a value and its type, then
  establishes the needed model before `01-pair.ash`: a tuple is one value with
  a fixed number of ordered parts, and commas mark those parts in both the
  value and type. This is the smallest extension of the earlier expression
  model and agrees with pinned
  [tuple typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors).
- **Construction, patterns, and observations — retain.**
  [*Making a pair*](../../content/learn/values-travel-together/README.md#making-a-pair)
  establishes `(42, true) : (Int, Bool)` and contrasts tuple commas with
  earlier grouping before
  [*Receiving one pair*](../../content/learn/values-travel-together/README.md#receiving-one-pair)
  introduces the parameter pattern in `02-pair-input.ash`.
  `sum_pair (20, 22)` is then calculated to `42`, and
  [*Naming the parts inside a block*](../../content/learn/values-travel-together/README.md#naming-the-parts-inside-a-block)
  reuses lesson 5's sequential bindings to trace `pair`, `left`, and `right` in
  `03-local-pattern.ash`. Thus construction precedes both uses of a tuple
  pattern. The shared lesson method supplies prediction where the prose varies
  the local instruction, and the verifier asserts all three displayed
  observations. Pinned
  [pattern checking](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage)
  supports both the function and irrefutable local patterns.
- **Negative shape boundary — retain.**
  [*Shape is part of the type*](../../content/learn/values-travel-together/README.md#shape-is-part-of-the-type)
  changes only the arity of the constructed tuple in
  `04-triple-is-not-a-pair.ash`. The explanation distinguishes one wrong-shaped
  input from a missing curried input, directly challenging the interaction
  with lesson 3. The verifier requires `type.argument`, `expected (Int, Int)`,
  and status `1`, so the rejection establishes the fixed-arity boundary
  without teaching diagnostic presentation.
- **Exercise and no assistant prompt — retain.**
  [*Exercise: keep two results*](../../content/learn/values-travel-together/README.md#exercise-keep-two-results)
  requires lesson 1's arithmetic and function definitions, lesson 5's block,
  and this lesson's tuple construction, tuple signature, and local pattern.
  The expected reasoning accounts for the input pair, the sum-and-product
  result pair, each intermediate type, and the final addition before running.
  The lesson already supplies construction, two pattern positions, a trace,
  and a negative arity contrast, so an assistant prompt would not add a
  distinct task to this self-contained exercise.
- **Handoff — retain.**
  [*One value, several parts*](../../content/learn/values-travel-together/README.md#one-value-several-parts)
  gathers fixed structural combinations, then contrasts them with data whose
  names express meaning and enumerate possible forms. That creates lesson 7's
  nominal-data question without using constructors or constructor patterns
  early.

#### Lesson 7: *How can a program define its own data?*

- **Prerequisites and opening — retain.** The opening depends on lesson 1's
  value-and-type model, lesson 4's idea that a type has possible values, and
  lesson 6's tuples as unnamed combinations. Before `01-signal.ash`, it
  establishes a data definition as one new type plus the complete list of
  subject-named forms its values may take. That source-facing model follows
  the pinned
  [data-declaration grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar),
  and its complete list supplies the family used by pinned
  [coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage).
- **Nullary construction and observation — retain.**
  [*Naming the possible forms*](../../content/learn/defining-data/README.md#naming-the-possible-forms)
  first reads the complete `Signal` definition, names `Signal`, `Go`, and
  `Stop` only after the source needs them, then observes `Go : Signal` from
  `01-signal.ash`. Changing only `main` to `Stop` provides a second prediction
  and run over the same definition. The verifier asserts the canonical `Go`
  observation, and pinned
  [constructor typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors)
  supports both complete values.
- **Payload construction and observation — retain.**
  [*A form that carries a value*](../../content/learn/defining-data/README.md#a-form-that-carries-a-value)
  places the complete `Result` definition before explaining that `Found`
  needs one `Int`, `Found(42)` supplies it, and `Missing` is complete without a
  field. The run of `02-result-with-value.ash` preserves both form and field as
  `Found(42) : Result`, which the verifier asserts. Although the pinned model
  treats a payload constructor as an ordinary unary function used through
  application, calling it a constructor that “needs” a field keeps this lesson
  on data construction; lesson 10 remains the deliberate place for function
  values.
- **Nominal distinction — retain.**
  [*A new name makes a new type*](../../content/learn/defining-data/README.md#a-new-name-makes-a-new-type)
  uses `03-distinct-types.ash` to contrast `Score(42)` and `Count(42)` after
  constructing both forms. The verifier requires `type.argument`, `expected
  Score`, and status `1`; replacing `Count(42)` with `Score(42)` gives the
  nearby positive comparison. This is the smallest executable evidence that
  equal payload shape does not erase nominal identity, as specified by pinned
  [type equality](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md).
- **Exercise and no assistant prompt — retain.**
  [*Exercise: describe a reading*](../../content/learn/defining-data/README.md#exercise-describe-a-reading)
  uses only the just-introduced type declaration, one payload constructor, one
  nullary constructor, `main`, and the established prediction-and-run cycle.
  The learner must predict each constructor-shaped value and the shared
  `Reading` type, then explain the subject meaning of both forms. Those paired
  construction and explanation tasks are bounded and need no assistant prompt.
- **Handoff — retain.**
  [*Data shaped for the program*](../../content/learn/defining-data/README.md#data-shaped-for-the-program)
  gathers construction and nominal identity, then asks how a function can
  handle every already-constructed `Result` form. Constructor patterns are
  therefore deferred until lesson 8, while the reference to known matches and
  patterns reconnects to lessons 4 and 6.

#### Lesson 8: *How can a function handle each form of data?*

- **Prerequisites and opening — retain.** The opening names lesson 7's complete
  `Result` definition and constructed `Found(42)` and `Missing` values. Before
  `01-match-result.ash`, it establishes the design rule that each constructor
  leads to one same-shaped pattern and one result expression. This combines
  lesson 4's exhaustive `match` with lesson 6's shape-matching patterns only
  after nominal construction has been learned.
- **Explicit-match observations — retain.**
  [*Matching the data definition*](../../content/learn/handling-data-forms/README.md#matching-the-data-definition)
  places `Found(Int) | Missing` beside the two arms of
  `01-match-result.ash`, explains recognition and field binding, and traces the
  results for both `Found(42)` and `Missing`. The reader predicts and runs both
  calls, observing `42 : Int` and `0 : Int`; the verifier asserts the canonical
  first run. Pinned
  [match typing and coverage](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage)
  and
  [match evaluation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches)
  support the explanation.
- **Equational observations — retain.**
  [*Letting the equations follow the forms*](../../content/learn/handling-data-forms/README.md#letting-the-equations-follow-the-forms)
  introduces separate equations only after the explicit match has made the
  constructor-to-result correspondence visible. The two traces for
  `02-equations.ash` preserve the earlier `42` and `0` reasoning, while the
  verifier asserts the canonical `42 : Int`. The explanation distinguishes an
  explicit match inside a larger expression from equations whose whole
  definition follows the input, rather than presenting a second mechanism
  without a design reason.
- **Coverage and multi-field bridge — retain.**
  [*Following every branch of the definition*](../../content/learn/handling-data-forms/README.md#following-every-branch-of-the-definition)
  uses the complete `Result` definition as a checklist before removing only
  the `Missing` equation in `03-missing-constructor.ash`. The verifier requires
  `coverage.non-exhaustive`, its causal equation-group text, and status `1`,
  and the prose explains why the rejection does not depend on the value in
  `main`. The closing sentence about matching the number and order of fields
  follows lesson 6's tuple-shape boundary and prepares lesson 9's
  two-field `More`; it does not advance coverage beyond the complete data
  definition.
- **Exercise and no assistant prompt — retain.**
  [*Exercise: respond to a signal*](../../content/learn/handling-data-forms/README.md#exercise-respond-to-a-signal)
  reuses lesson 7's complete `Signal` definition and requires one equation and
  one match arm for each constructor. The learner must predict `1` and `0`,
  preserve those observations across both presentations, and explain how the
  data definition generates the cases. The side-by-side model, two equivalent
  presentations, and negative coverage example already support that reasoning,
  so the absence of an assistant prompt is appropriate.
- **Handoff — retain.**
  [*Functions that follow data*](../../content/learn/handling-data-forms/README.md#functions-that-follow-data)
  gathers patterns and exhaustive handling, then changes one property of the
  data: a field may have the type currently being defined. That creates lesson
  9's structural-recursion question from the existing data-guided function
  method rather than introducing recursion in isolation.

#### Lesson 9: *How can a function follow recursive data?*

- **Prerequisites and opening — retain.** The opening contrasts lesson 7's
  shallow `Result` forms with data that repeats one shape and explains the
  `rest` field as another line of integers before `01-int-list.ash`. It depends
  on nominal forms and fields from lesson 7, multi-field patterns from lessons
  6 and 8, and lesson 8's rule that a function follows its complete data
  definition. The new working model is self-reference in the data, not an
  unexplained recursive function.
- **Recursive construction before recursive handling — retain.** In
  [*A finite list of integers*](../../content/learn/following-recursive-data/README.md#a-finite-list-of-integers),
  `01-int-list.ash` first constructs and expands the two `More` layers down to
  `Empty`; only after that structure is visible does the reader run it and
  observe `More(20, More(22, Empty)) : IntList`. The verifier asserts that
  structural result. Pinned
  [constructor evaluation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches)
  governs how the value is built, pinned
  [observation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
  pairs and renders the value with its result type, and the pinned
  [`ash` successful-output contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  governs the reported output line.
- **Deriving the recursive function — retain.**
  [*A function with the same shape*](../../content/learn/following-recursive-data/README.md#a-function-with-the-same-shape)
  begins with lesson 8's one-equation-per-form method. In `02-sum.ash`, the
  `Empty` form yields `0`, the `More(first, rest)` pattern exposes exactly the
  fields in the data definition, and only the self-referential `rest` field
  leads to `sum rest`. The five-line calculation shows each call crossing one
  layer of the displayed finite value before the run confirms `42 : Int`, as
  the verifier asserts. Global self-reference is admitted by pinned
  [global typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules).
  The assistant prompt adds distinct value by checking a learner-created
  three-element trace for the exact `rest` relationship while leaving the
  arithmetic and explanation to the learner.
- **Base form and negative boundary — retain.**
  [*The ending form still matters*](../../content/learn/following-recursive-data/README.md#the-ending-form-still-matters)
  challenges the temptation to keep only the visibly recursive equation in
  `03-missing-empty.ash`. The verifier requires `coverage.non-exhaustive`, its
  causal equation-group text, and status `1`. The explanation connects the
  same coverage promise from lesson 8 to the calculation's base result, so
  `Empty` is both a valid input and the form that ends every finite source
  value used in this lesson. This account does not claim that all Ash values
  are acyclic; explicit recursive initialization remains outside the beginning
  path's selected scope.
- **Exercise — retain.**
  [*Exercise: count the integers*](../../content/learn/following-recursive-data/README.md#exercise-count-the-integers)
  requires only the complete `IntList` definition, constructor patterns,
  addition, and the just-derived call on `rest`. The learner must derive both
  equations from the forms, predict empty, one-layer, and two-layer results,
  and compare `length` with `sum` to isolate the unchanged structural recursion
  from the changed combining expression. The unused first field still has a
  place in the known constructor pattern, so no new pattern form is required.
- **Handoff — retain.**
  [*Recursion follows self-reference*](../../content/learn/following-recursive-data/README.md#recursion-follows-self-reference)
  gathers the data-derived recursive call and base form, then contrasts the
  named calls used so far with functions as receivable and returnable values.
  Lesson 10 deliberately anchors that new question in lesson 3's observable
  partial function value, while lesson 11 later recombines function values with
  this lesson's recursive-list structure in `map`. A stronger local coupling
  would obscure that course-level dependency, so no structural change is
  warranted.

### Lessons 10–11: functional abstraction

#### Lesson 10: *How can a function itself be a value?*

- **Prerequisites and opening — retain.** The opening returns to lesson 3's
  observable `add 20` result and its remaining `Int -> Int` type. Before
  `01-named-function.ash`, it extends that model by stating that a function is
  a value that can be supplied as an input, produced as a result, or associated
  with a name. That is the smallest bridge from partial application to the
  function-valued domain in `apply_twice : (Int -> Int) -> Int -> Int`, whose
  parentheses and right-associated remaining arrows depend only on lesson 3.
  Pinned
  [function typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application)
  treats the supplied `transform` as an ordinary callable value.
- **Named and anonymous function observations — retain.** In
  [*Giving a function as an input*](../../content/learn/functions-as-values/README.md#giving-a-function-as-an-input),
  `01-named-function.ash` calculates the two nested `increment` calls before
  the reader runs the program and observes `42 : Int`. In
  [*Writing a function where it is needed*](../../content/learn/functions-as-values/README.md#writing-a-function-where-it-is-needed),
  `02-anonymous-function.ash` changes only the presentation of that
  transformation, explains how the expected `Int -> Int` type checks its
  parameter and result, and predicts the unchanged `42` observation. The
  shared lesson method supplies the run, and the
  [lesson verifier](../../content/learn/functions-as-values/checks/verify.sh)
  asserts both results. The comparison explains the naming choice after the
  equivalent behavior is visible rather than treating `fn` as a separate call
  mechanism.
- **Produced-function observation — retain.** In
  [*Producing a function*](../../content/learn/functions-as-values/README.md#producing-a-function),
  `03-remembered-input.ash` first traces `make_adder 20` to the function that
  retains `20`, then supplies `22` and traces the complete call to `42`. This
  makes the earlier partial-call model account for a source-written anonymous
  function and gives the reader observable reasoning before the verifier's
  `42 : Int` result. The statement that `amount` remains available is governed
  by pinned lexical
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application)
  and its
  [capture derivation](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#lexical-capture-v-004).
- **Negative function-domain boundary — retain.** In
  [*A function parameter requires a function*](../../content/learn/functions-as-values/README.md#a-function-parameter-requires-a-function),
  `04-not-a-function.ash` changes only the first argument of `apply_twice` from
  a function to the integer `2`. The signature lets the reader predict why
  Ash rejects the call with `type.argument`, and the verifier requires
  `expected Int -> Int` and status `1`. The example therefore isolates the
  callable-value boundary without introducing any later abstraction topic.
- **Exercise and no assistant prompt — retain.**
  [*Exercise: apply three times*](../../content/learn/functions-as-values/README.md#exercise-apply-three-times)
  requires only lesson 1's nested calls, lesson 3's function-valued partial
  result, and this lesson's named and anonymous function inputs. The learner
  must predict and trace three successive calls in both presentations before
  checking that each produces the same integer. The lesson already compares
  those presentations, derives a captured function, and tests the type
  boundary; an assistant prompt would not add a distinct reasoning task.
- **Handoff — retain.**
  [*Calculations as data*](../../content/learn/functions-as-values/README.md#calculations-as-data)
  gathers receiving, calling, constructing, and returning function values,
  then identifies the integer-specific parts of `apply_twice` and lesson 9's
  `IntList`. This creates lesson 11's type-independence question without
  introducing type-parameter syntax or claiming behavior beyond the pinned
  rank-1 model.

#### Lesson 11: *How can one definition work with many types?*

- **Prerequisites and opening — retain.** The opening names the exact two
  limitations left by lessons 9 and 10: `IntList` fixes its element type, and
  `apply_twice` fixes its transformation to `Int -> Int`. Before
  `01-identity.ash`, it establishes a type parameter as a name for an
  unspecified type and the invariant that the definition cannot depend on
  which type replaces it. Pinned name resolution
  [implicitly binds](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#global-scope)
  free uppercase names in global signatures, while pinned
  [rank-1 inference](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#inference-and-rank-1-restrictions)
  instantiates each use without source type arguments.
- **Parameterized-function observation — retain.** In
  [*One function, different uses*](../../content/learn/definitions-for-many-types/README.md#one-function-different-uses),
  `01-identity.ash` explains `A -> A`, predicts `A = Int` for `identity 42`
  and `A = Bool` for `identity true`, then presents the run's
  `(42, true) : (Int, Bool)` observation. The
  [lesson verifier](../../content/learn/definitions-for-many-types/checks/verify.sh)
  asserts that result. The unchanged body is enough to explain both calls, so
  the example introduces reuse independently of recursive data.
- **Parameterized-data observation — retain.** In
  [*Data with an element type*](../../content/learn/definitions-for-many-types/README.md#data-with-an-element-type),
  `02-box.ash` carries the same `A` model into `type Box<A> = Box(A)`. The
  constructor calculations identify `Box<Int>` and `Box<Bool>` before the
  verifier asserts `(Box(42), Box(false)) : (Box<Int>, Box<Bool>)`; the prose
  then explains why the shared shape does not make those complete types equal.
  This depends on lesson 7's nominal construction and lesson 6's tuple
  observation, and agrees with pinned parameterized
  [constructor typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#tuples-and-constructors).
- **Reusable-list and `map` observations — retain.** In
  [*A list that leaves its elements open*](../../content/learn/definitions-for-many-types/README.md#a-list-that-leaves-its-elements-open),
  `lists.ash` first preserves lesson 9's `Empty | More` shape while replacing
  the integer field with `A`. The prose reads every part of
  `map : (A -> B) -> List<A> -> List<B>`, follows both equations, and explains
  the invariant: `transform` alone changes one element, while the recursive
  call preserves the list shape over `rest`. Only then does
  `03-list-main.ash` supply an anonymous `Int -> Int` transformation through a
  qualified import. The displayed three-step trace predicts
  `More(42, Empty) : List<Int>`, which the verifier asserts. This sequence
  recombines function values, constructor equations, and structural recursion
  only after each was independently established.
- **Negative saturation boundary — retain.** In
  [*Supplying every type parameter*](../../content/learn/definitions-for-many-types/README.md#supplying-every-type-parameter),
  `04-unsaturated-list.ash` contrasts the previously complete `List<Int>` and
  `List<A>` uses with a bare `List` in `keep : List -> List`. The reader can
  locate the missing argument from `type List<A>` before observing
  `resolve.type-argument-count`; the verifier also requires the stable
  `expected List with 1 type arguments` cause and status `1`. This is the
  smallest negative example for pinned nominal
  [type-argument arity](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#type-and-constructor-scope).
- **Exercise — retain.**
  [*Exercise: change the element type*](../../content/learn/definitions-for-many-types/README.md#exercise-change-the-element-type)
  requires lesson 2's separate module, lesson 4's equality and `Bool`, lessons
  7–9's constructors, patterns, and recursive list, lesson 10's function
  value, and this lesson's `A`/`B` account. The learner must identify
  `A = Int` and `B = Bool`, predict the two-element `List<Bool>`, and trace one
  call per `More` plus the `Empty` call before running it. Keeping `lists.ash`
  unchanged makes the reasoning task an application of the provided generic
  structure rather than a redesign of `map`.
- **Assistant prompt before *Supplying every type parameter* — revise
  locally.** The prompt follows the completed `03-list-main.ash` trace and asks
  the learner to draw that program's input and output lists, check each smaller
  `rest`, and reconcile `A` and `B`; those are useful checks of the final
  recombination. However, its opening says “Before changing `map`,” although no
  surrounding task asks for such a change and the later exercise explicitly
  says to keep `lists.ash` unchanged. Challenging the phrase against the
  index's edit-predict-run-explain method does not supply a missing edit: the
  observable work is to reason about calls that use `map`, not to alter its
  equations. The bounded correction aligns the prompt with the existing trace
  while preserving the unchanged `lists.ash` boundary. Its `A` and `B`
  reasoning follows pinned
  [global typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules),
  while the `rest` trace follows pinned
  [application](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application)
  and
  [constructor and equation matching](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches).
  It needs no source, check, or structural change.
- **Closure — retain.**
  [*The beginning model*](../../content/learn/definitions-for-many-types/README.md#the-beginning-model)
  names parametric polymorphism only after the function, data, and `map`
  examples have established its invariant. It then gathers modules,
  definitions, expressions, functions, data, patterns, `main ()`, and the tool
  observation as teaching content. Pinned
  [type erasure](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#type-erasure)
  supports the claim that the runtime calculation does not inspect type
  parameters.

### Final reader model and course frame

- **Final program dependency trace — retain.** Every idea in `lists.ash` and
  `03-list-main.ash` has an earlier teaching dependency or explicit staging in
  lesson 11: lesson 1 supplies `main`, signatures, expressions, integer
  addition, calls, and value/type observations; lesson 2 supplies two source
  modules, `pub`, a complete import, its alias, and qualified use; lesson 3
  supplies chained arrows and calls; lesson 7 supplies nominal data and
  constructors; lesson 8 supplies constructor patterns and one equation per
  form; lesson 9 supplies the self-referential `rest` field and recursive call;
  and lesson 10 supplies the function-valued input and anonymous function.
  Lesson 11 then adds `A` and `B`, first in `identity` and `Box`, before
  combining them in `List` and `map`. Lesson 6's fixed tuple shape also
  underlies `More`'s two ordered fields, already applied to recursive data in
  lesson 9. The first combination of a public constructor family with a
  qualified import occurs in lesson 11 and is assessed separately below; no
  final-program idea requires a later lesson.
- **Public constructor qualification — revise locally.** Lesson 2's
  [*One program, two files*](../../content/learn/using-another-source-file/README.md#one-program-two-files)
  explains `pub`, complete imports, aliases, and qualified access through a
  public global function. Lesson 7's
  [*Naming the possible forms*](../../content/learn/defining-data/README.md#naming-the-possible-forms)
  introduces a constructor family only inside its defining module. Lesson 11
  is therefore the first crossing of both boundaries: `lists.ash` declares
  `pub type List<A>`, and `03-list-main.ash` uses `Lists.List`, `Lists.More`,
  and `Lists.Empty`. The run proves that the names are available, and the prose
  says that the type and function are public, but it does not state the causal
  rule that a public transparent type exports its complete constructor set.
  Pinned
  [visibility](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations)
  exports that set, and a pinned
  [complete import](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces)
  exposes the public type and constructors through the alias. Challenging the
  existing observation against the needed causal account shows that the code
  alone leaves this first feature interaction implicit. The bounded
  one-sentence clarification connects `pub type` to the qualified constructor
  uses without a new example, check, or structural change.
- **Intended outcome test — revise locally.** The final trace lets the reader
  predict the one-element transformation, follow `More(first, rest)` and
  `map transform rest` together to `Empty`, explain the anonymous function as
  the value supplied to `transform`, identify `A` as the input element type
  and `B` as the output element type, and read `Lists.List`, `Lists.map`,
  `Lists.More`, and `Lists.Empty` through the lesson 2 module alias. The local
  clarification now supplies a causal explanation of those last two qualified
  names under pinned
  [public transparent visibility](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations)
  and
  [complete imports](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces).
  Design practice is explicit across four tasks: lesson 2's
  [*Exercise: move `square`*](../../content/learn/using-another-source-file/README.md#exercise-move-square)
  builds and diagnoses a two-file program; lesson 7's
  [*Exercise: describe a reading*](../../content/learn/defining-data/README.md#exercise-describe-a-reading)
  designs a nominal type and its values; lesson 9's
  [*Exercise: count the integers*](../../content/learn/following-recursive-data/README.md#exercise-count-the-integers)
  derives a recursive function from the data forms; and lesson 11's
  [*Exercise: change the element type*](../../content/learn/definitions-for-many-types/README.md#exercise-change-the-element-type)
  chooses `A = Int` and `B = Bool`, supplies the transformation, and preserves
  list shape. Together, these exercises establish the design portion of the
  [intended outcome](../project/beginning-learning-path.md#intended-outcome):
  design, run, and explain a pure multi-file program over defined data, trace
  its values, follow patterns and recursion, and use type parameters where the
  element type is irrelevant.
- **Excluded-topic boundary — retain.** The final program needs only a public
  transparent type and public function reached through the complete import
  model already introduced in lesson 2. Its reuse follows from unconstrained
  type parameters and ordinary function application; it does not depend on
  interfaces, implementations, constraints, ad-hoc polymorphism, opacity,
  targeted or named-root imports, re-exports, recursive initialization, or
  documentation machinery. The lesson therefore stays inside the
  [beginning-path exclusions](../project/beginning-learning-path.md#outside-the-beginning-path).
- **Learning index method and order — retain.**
  [*How to work through a lesson*](../../content/learn/README.md#how-to-work-through-a-lesson)
  supplies the shared edit, predict, run, inspect, and explain cycle that the
  lessons vary rather than repeat mechanically. The
  [contents](../../content/learn/README.md#contents) list the same eleven-lesson
  order as the project path, and the lesson 10 handoff leads directly into the
  final type-parameter question. The index owns one-time setup and reading
  order; neither final lesson repeats edition administration.
- **Optional assistant course boundary — retain.** The index explicitly says
  every chapter works without an assistant and limits dialogue to evidence
  from the lesson, repository, and observed `ash` output. Lesson 10 needs no
  separate prompt, and lesson 11 remains complete through its runnable sources,
  explanations, negative boundary, and exercise. The local action mismatch in
  lesson 11's prompt requires the revision recorded above, but it neither makes
  the assistant necessary nor changes the course-level optional boundary.
- **Structural decision — retain.** The prerequisite graph has no cycle:
  lesson 10 extends the partial-function observation from lesson 3, and lesson
  11 draws only on lessons 2–10 before completing the abstraction. Its staged
  `identity`, `Box`, `List`, and `map` examples keep function and data
  parameterization distinct before recombination. No transition needs a split
  or reorder. The lesson 5 exercise antecedent, lesson 11 assistant-prompt
  action, and lesson 11 public-constructor explanation are three independent
  local continuity repairs, not evidence for a structural change.

### Final verification

- **Executable and shell evidence.** Running
  `content/learn/checks/verify.sh
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin`
  reported all eleven lesson source-agreement summaries followed by `Verified
  11 learning lesson(s) at
  dca16039923475c48025c5f17beadeb6bcb6a4bf.` Running `bash -n
  content/learn/checks/*.sh content/learn/*/checks/verify.sh` exited with status
  `0` and no output. The pinned checkout reported that exact commit and no
  working-tree changes.
- **Documentation evidence.** Running `markdownlint-cli2 '**/*.md'
  '#.worktrees/**'` checked 26 Markdown files and reported `0 error(s)`.
  Running `python3
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py
  .agents/skills/writing-ash-documentation` reported `Skill is valid!`.
- **Links and source agreement.** A read-only link audit over the five changed
  Markdown files resolved all 79 relative-link occurrences and their anchors,
  including lesson 5's link to *Giving a calculation a name* and the roadmap's
  two active-plan links. A second audit mapped all 50 pinned `ash-lang` link
  occurrences to the clean checkout and found every file and anchor at
  `dca16039923475c48025c5f17beadeb6bcb6a4bf`. Direct comparisons found no
  change to either revised lesson's hidden source markers. The complete
  verifier confirmed every displayed Ash block against canonical source, and
  `git diff --name-only main...HEAD` contained no `.ash` or `.sh` file.
- **Changed-source and scope review.** `git diff --check main...HEAD` produced
  no output, and `git status --short --branch` showed a clean branch before
  this ledger entry. `git diff --stat main...HEAD` reported:
  `5 files changed, 1325 insertions(+), 5 deletions(-)`.
  Separately, the complete `git diff main...HEAD` was read as source and
  contained only the two revised lessons, two active plans, and roadmap.
  Those hunks add no split, reorder, executable observation, or project
  mechanism.
- **Authority, status, attribution, and license review.** The specification
  overview and cited pinned chapters remain the authority for every recorded
  language claim; the pinned tool guide remains the authority for command,
  output, diagnostic, and status claims. In particular, the lesson 11 repair
  agrees with the pinned public-transparent-type and complete-import rules.
  Lessons contain only teaching material, while the review's target, evidence,
  decisions, and temporary status remain in project records. The revisions add
  original continuity prose and no adapted text, code, or external asset, so
  they create no new attribution or license obligation and select no project
  license.

### Task 1: Reconfirm the baseline and course contract

**Files:**

- Read: `README.md`
- Read: `AGENTS.md`
- Read: `docs/project/roadmap.md`
- Read: `docs/project/workflow.md`
- Read: `docs/project/beginning-learning-path.md`
- Read: `content/learn/README.md`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Confirm repository and target state

Run:

```bash
git status --short --branch
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
  rev-parse HEAD
git -C /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin \
  status --short
```

Expected: the ash-doc worktree is clean on `docs/beginning-path-review`; the
Ash checkout reports `dca16039923475c48025c5f17beadeb6bcb6a4bf` and no
changes.

#### Step 2: Reconstruct the course contract

Read the files listed above. Write a short baseline entry in the audit ledger
that names the intended learner outcome, the eleven-lesson order, the excluded
topics, and the whole-path review boundary.

#### Step 3: Run the complete executable baseline

Run:

```bash
content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: eleven lesson summaries followed by:

```text
Verified 11 learning lesson(s) at dca16039923475c48025c5f17beadeb6bcb6a4bf.
```

Record the exact result in the audit ledger. Stop and use
@superpowers:systematic-debugging if the baseline fails.

#### Step 4: Commit the baseline record

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: record beginning path baseline"
```

### Task 2: Audit programs and calculations in sequence

**Files:**

- Read: `content/learn/what-is-an-ash-program/README.md`
- Read: `content/learn/using-another-source-file/README.md`
- Read: `content/learn/using-more-than-one-input/README.md`
- Read: `content/learn/choosing-a-result/README.md`
- Read: `content/learn/naming-intermediate-values/README.md`
- Inspect: `content/learn/{what-is-an-ash-program,using-another-source-file,using-more-than-one-input,choosing-a-result,naming-intermediate-values}/src/*.ash`
- Inspect: `content/learn/{what-is-an-ash-program,using-another-source-file,using-more-than-one-input,choosing-a-result,naming-intermediate-values}/checks/verify.sh`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Read lessons 1 through 5 without editing

Read every lesson aloud and inspect each canonical program and verifier beside
the prose that uses it. Follow the reader from expressions and `main` through
modules, chained inputs, Boolean choice, and sequential local bindings.

#### Step 2: Trace course dependencies

For each lesson, record in the audit ledger:

- concepts and vocabulary assumed from earlier lessons;
- the new model established before the first command;
- each predict-run-explain opportunity;
- exercise prerequisites and expected reasoning;
- whether an assistant prompt adds distinct value; and
- whether the ending creates the next lesson's question.

Use exact headings or quoted identifiers to locate evidence. Keep any quotation
brief; the lesson path and passage description should do most of the work.

#### Step 3: Challenge the first findings

For each proposed revision, look for a smaller explanation already supplied by
earlier Ash semantics, a negative example that already establishes the
boundary, or an interaction with a later lesson that justifies retaining the
text. Update the finding's disposition rather than editing lesson prose.

#### Step 4: Commit the first course-part audit

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: audit beginning calculations"
```

### Task 3: Audit data and structure in sequence

**Files:**

- Read: `content/learn/values-travel-together/README.md`
- Read: `content/learn/defining-data/README.md`
- Read: `content/learn/handling-data-forms/README.md`
- Read: `content/learn/following-recursive-data/README.md`
- Inspect: `content/learn/{values-travel-together,defining-data,handling-data-forms,following-recursive-data}/src/*.ash`
- Inspect: `content/learn/{values-travel-together,defining-data,handling-data-forms,following-recursive-data}/checks/verify.sh`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Read lessons 6 through 9 without editing

Read every lesson aloud and inspect its source and check evidence. Follow the
reader from tuples through nominal data, constructor-shaped functions,
coverage, and structural recursion.

#### Step 2: Trace data-design dependencies

Apply the same dependency, vocabulary, prediction, exercise, prompt, and
handoff review used in Task 2. Pay particular attention to whether patterns are
introduced only after construction, whether coverage follows the complete data
definition, and whether recursive functions are derived from recursive data
rather than presented as an isolated mechanism.

#### Step 3: Challenge and classify findings

Test every candidate against earlier lessons and the smallest causal account.
Record a disposition for each finding. Do not edit lesson prose during the
audit pass.

#### Step 4: Commit the second course-part audit

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: audit beginning data design"
```

### Task 4: Audit functional abstraction and the final outcome

**Files:**

- Read: `content/learn/functions-as-values/README.md`
- Read: `content/learn/definitions-for-many-types/README.md`
- Inspect: `content/learn/functions-as-values/src/*.ash`
- Inspect: `content/learn/functions-as-values/checks/verify.sh`
- Inspect: `content/learn/definitions-for-many-types/src/*.ash`
- Inspect: `content/learn/definitions-for-many-types/checks/verify.sh`
- Read: `content/learn/README.md`
- Read: `docs/project/beginning-learning-path.md`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Read lessons 10 and 11 without editing

Read both lessons aloud and inspect their executable evidence. Trace the move
from functions as values to definitions whose behavior does not depend on one
particular element type.

#### Step 2: Test the final reader model

Trace every idea in the final multi-file `List<A>` and `map` program back to
the lesson that introduced it. Confirm that a reader can predict the
transformation, follow the recursive data and function together, explain the
function value, identify the type parameters, and follow the qualified module
use without relying on excluded topics.

#### Step 3: Review the course frame

Compare `content/learn/README.md` with the actual study method and reading
order. Confirm that assistant guidance remains optional and that the final
lesson gathers the intended outcome rather than administering project state.
Record all evidence and dispositions in the audit ledger.

#### Step 4: Decide whether structural change is warranted

Consider splitting or reordering only if the ledger shows a prerequisite cycle
or a transition that local prose cannot repair. If it does, stop and present
that evidence for project approval before changing navigation or directories.
Otherwise record that local revisions are sufficient.

#### Step 5: Commit the final course-part audit

```bash
git add docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: audit beginning abstraction"
```

### Task 5: Verify governing claims and revise accepted findings

**Files:**

- Modify as evidence requires: `content/learn/README.md`
- Modify as evidence requires: `content/learn/*/README.md`
- Modify only if an observable claim changes: `content/learn/*/src/*.ash`
- Modify only if source or observation changes: `content/learn/*/checks/verify.sh`
- Read: `/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/spec/README.md`
- Read as selected by each claim: `/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/spec/{lexical-structure,syntax,name-resolution,static-semantics,elaboration,dynamic-semantics}.md`
- Read for tool claims: `/home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin/docs/tools/ash.md`
- Modify: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Select accepted revisions

Review every ledger item marked `revise locally` or `verify against a governing
source`. Reject edits based only on preference. Group accepted findings by one
causal reader problem, not merely by file.

#### Step 2: Verify claims before drafting

Read the pinned specification overview, then only the chapters governing each
accepted semantic finding. Read the pinned tool guide and relevant tests or
implementation only for command, output, failure, or diagnostic findings.
Add the governing section to the ledger item before changing prose or code.

#### Step 3: Make the smallest revision for one finding group

Use @writing-ash-documentation. Preserve the lesson's conceptual arc, source
markers, canonical program agreement, and transition into the next lesson.
Do not introduce a new language topic or project administration into rendered
lesson prose.

#### Step 4: Verify the affected lesson locally

For each changed lesson, run:

```bash
bash content/learn/<lesson>/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
```

Expected: a canonical-source summary for that lesson at the exact pinned
commit. If only the learning index changes, inspect its links instead.

#### Step 5: Read and commit the finding group

Read every changed file as source, then run:

```bash
git diff --check
git diff -- content/learn
```

Stage only that finding group and commit with a message naming the reader
problem, for example:

```bash
git add content/learn/<exact-files>
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: clarify <reader boundary>"
```

Repeat Steps 3 through 5 for each independent finding group. Stop and use
@superpowers:systematic-debugging for any unexpected executable failure.

### Task 6: Verify the complete revised path

**Files:**

- Read: every file changed from `main`
- Verify: `content/learn/README.md`
- Verify: `content/learn/*/README.md`
- Verify: `content/learn/checks/*.sh`
- Verify: `content/learn/*/checks/verify.sh`
- Verify: `.agents/skills/writing-ash-documentation/`

#### Step 1: Run executable and shell verification

```bash
content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/learn/checks/*.sh content/learn/*/checks/verify.sh
```

Expected: all eleven lessons pass at the exact pinned commit and Bash reports
no syntax errors.

#### Step 2: Run documentation checks

```bash
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
```

Expected: Markdown lint reports zero errors and the skill validator reports a
valid skill.

#### Step 3: Review links, status, and changed source

Inspect every changed relative link at its source and confirm its target
exists. Then run:

```bash
git diff --check main...HEAD
git status --short --branch
git diff --stat main...HEAD
git diff main...HEAD
```

Expected: no whitespace errors, only files authorized by accepted findings and
the active plans are changed, and every diff hunk has been read.

#### Step 4: Record final verification

Add the exact commands and results to the audit ledger. Commit the completed
audit evidence with any final prose corrections:

```bash
git add docs/plans/2026-08-27-beginning-path-review.md content/learn
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: verify beginning reader journey"
```

### Task 7: Select the next outcome and close the review

**Files:**

- Modify: `docs/project/roadmap.md`
- Delete: `docs/plans/2026-08-27-beginning-path-review-design.md`
- Delete: `docs/plans/2026-08-27-beginning-path-review.md`

#### Step 1: Propose the next complete outcome

Use the completed audit evidence and the roadmap's later decisions to compare
at least two bounded next outcomes. Do not select a new language topic,
renderer, coverage mechanism, or publication design without its own concrete
need. Present the recommendation for project approval before changing the
roadmap.

#### Step 2: Record closure after approval

Replace the roadmap's current edition state and verified-increment account
with the completed whole-path review. Replace `Next complete increment` with
the approved next outcome. Remove links to the review plans.

#### Step 3: Remove temporary plans

Delete both review plan files. Git history retains their design, audit, and
execution evidence.

#### Step 4: Run final verification

```bash
content/learn/checks/verify.sh \
  /home/dikini/.config/superpowers/worktrees/ash-lang/ash-doc-modular-pin
bash -n content/learn/checks/*.sh content/learn/*/checks/verify.sh
markdownlint-cli2 '**/*.md' '#.worktrees/**'
python3 \
  /home/dikini/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  .agents/skills/writing-ash-documentation
git diff --check main...HEAD
git status --short --branch
git log --format='%h %G? %s' main..HEAD
```

Expected: eleven lessons pass at the pinned commit; shell, Markdown, skill, and
whitespace checks pass; only intended review changes remain; both plan files
are absent; and each branch commit reports signature status `N`.

#### Step 5: Commit closure

```bash
git add docs/project/roadmap.md \
  docs/plans/2026-08-27-beginning-path-review-design.md \
  docs/plans/2026-08-27-beginning-path-review.md
git -c commit.gpgsign=false commit --no-gpg-sign \
  -m "docs: close beginning path review"
```

Do not merge, push, or remove the worktree during plan execution. Use
@superpowers:finishing-a-development-branch after all verification passes to
present integration choices.
