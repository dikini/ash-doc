# First lesson narrative design

## Problem

The first lesson now follows a sound conceptual sequence, but its prose still
reads as a sequence of instructions with explanations attached. It begins by
directing the reader to answer a small question before it establishes what a
program is or why evaluation is the useful starting point. Repeated cycles of
replacing, predicting, running, and inspecting make the teaching method visible
as machinery instead of letting it support the lesson.

The lesson needs a human narrative: an introduction that gives the topic a
setting, an exploration in which one observation creates the need for the next,
and a conclusion that answers the title question. This is a prose and teaching
change. It must not alter the Ash programs, their verified behavior, or the
edition boundary.

## Semantic boundary

The reader asks what an Ash program is and how to write a first one. The
observable boundary is a complete source file passed to `ash`, followed by the
value and type reported for its evaluation.

At the selected Ash edition, the source path passed to `ash` is the entry
module. Ash checks its definitions, requires a suitable local `main`, and
evaluates `main ()`. A successful run reports the resulting value and its type.
For the first lesson, the useful learner model is smaller: an Ash source file
contains definitions; `main` supplies the starting calculation; and Ash
evaluates expressions to produce values. The lesson does not need module,
linking, monomorphism, closed-result, diagnostic-contract, or implementation
terminology.

## Source tradition

The revision adapts the expository method of Matthias Felleisen, Robert Bruce
Findler, Matthew Flatt, and Shriram Krishnamurthi, *How to Design Programs*,
second edition. The material consulted is the 25 February 2026 online release,
especially the
[Prologue: How to Program](https://htdp.org/2026-2-25/Book/part_prologue.html)
and sections 2.1 through 2.3 of
[Part I: Fixed-Size Data](https://htdp.org/2026-2-25/Book/part_one.html).

HtDP first gives the reader a familiar way to think about the subject, then
places an example in that setting. It lets several observations accumulate
before pausing to name them. Its paragraphs usually perform one connected
move: recall or raise an idea, examine an example, interpret it, and leave a
reason to continue. Commands occur inside that conversation rather than
forming the skeleton of the prose.

Ash-doc will adapt those techniques, not HtDP's wording, examples, exercises,
humor, Racket environment, or claims about programs. HtDP is published under
CC BY-NC-ND 2.0; this revision remains original prose and code.

## Approaches considered

### Polish the existing sentences

Shortening sentences and varying verbs would improve local rhythm, but the
lesson would retain its procedural skeleton. The reader would still encounter
a series of commands before a developing account of programs. This does not
address the cause of the mechanistic feel.

### Build one developing explanation

Keep the seven programs and their order, but rewrite the prose around one idea:
running an Ash program asks Ash to evaluate a calculation. Begin with that
model, let the literal program make it concrete, and let each later example
answer a question created by the earlier one. This preserves verified evidence
while changing the reader's experience. This is the selected approach.

### Introduce a larger story problem

A named application could give the functions a concrete domain, but the
current Ash edition offers no input, text, or I/O for a natural first-program
story. Inventing a numeric setting for every expression would add explanation
without strengthening the answer to the lesson's question. Defer richer
problem stories until the language and curriculum provide suitable data and
operations.

## Narrative shape

The title remains the only heading before the introduction. Two or three short
paragraphs connect a familiar notion of a program with Ash's evaluation model:
programs are often described as instructions, but an Ash program begins with
definitions and expressions. When run, its expressions calculate a value. The
first program will make that account concrete.

The body then develops in five movements:

1. **A first program.** Present the literal program and the command as part of
   the prose. After the result appears, slow down and read the two source lines.
   Introduce `main`, the signature, `Unit`, `()`, `Int`, expression, value, and
   type only where the program gives each word a referent.
2. **Expressions calculate.** Change `42` to `40 + 2`, then use precedence and
   grouping to show that an expression may contain smaller expressions. Avoid
   repeating the full study cycle as an imperative checklist. Predictions and
   runs remain, but the prose varies their purpose and phrasing.
3. **Functions name calculations.** The growing expression creates the reason
   to name a calculation. Introduce `increment`, relate its input to the
   parameter, and explain the call through substitution. Add `double` because
   the next question is how named calculations work together.
4. **Ash needs a beginning.** Once the reader understands several definitions,
   remove `main`. The rejection answers why one definition has had a special
   name throughout the lesson.
5. **Practice and conclusion.** The exercise asks the reader to add `square`
   and connect it to `double`. The conclusion gathers the observed facts into
   a direct answer to the title question and opens the next lesson's module
   question.

Use headings only for genuine turns in this account. A small movement may use
several paragraphs without a subheading. The headings should name ideas, not
workflow stages.

## Paragraph and sentence shape

Each paragraph should do one piece of explanatory work. Its first sentence
connects to the reader's current model or raises the next question. Its middle
uses the program, result, or calculation as evidence. Its final sentence
interprets the evidence or makes the next step necessary. This is a guide to
coherence, not a template that every paragraph must expose.

Vary sentence length and purpose. Place short sentences at conceptual turns,
not after every code block. Prefer transitions that name a relationship—"so
far," "this time," "because," or "now that"—over generic sequencing such as
"next" and "then." Use direct questions sparingly and only when a reader can
reason from material already on the page.

Commands should sound like invitations within the explanation. Avoid a chain
of bare imperatives and avoid false intimacy, motivational praise, decorative
adjectives, and stock phrases. The author may use `we` for a calculation that
author and reader are genuinely examining together; use `you` for actions the
reader alone performs.

## Learning-assistant boundary

The lesson remains complete without an assistant. Retain no more than two
optional assistant prompts, but integrate them where a conversation has a clear
purpose: testing an explanation of grouping and examining an exercise attempt.
Each prompt begins with the learner's own program, prediction, and observed
`ash` result. It asks the assistant to question the learner rather than produce
the next program.

## Reusable writing guidance

Extend the preferred project writing skill so future agents plan both the
conceptual sequence and the prose sequence. It should require:

- an introductory passage that gives a reader a reason and a model before the
  first command;
- an exploration whose examples create questions for later examples;
- a conclusion that gathers the lesson's answer;
- paragraph-level continuity from setup through evidence to interpretation;
- varied commands and sentence shapes rather than a repeated teaching recipe;
- headings only at conceptual turns; and
- a read-aloud review for procedural rhythm and generated-sounding filler.

The skill must not prescribe a rigid introduction-body-summary template for
every page or force every paragraph into the same shape. Project records and
reference pages have different purposes.

## Deferred lesson filename

`README.md` is convenient for repository browsing because Git hosts render it
automatically inside the lesson directory. `index.md` is conventional for a
page that may later become a website directory index. Ash-doc has not selected
a renderer or publication platform, so neither convention currently has
enough downstream evidence to win.

Record the question in the roadmap's later decisions. Do not rename the lesson,
change links, or generalize the verifier during this revision. Revisit the name
when the project first designs a renderer or publication workflow.

## Verification

The change is complete when:

- an independent baseline response written without the new skill guidance
  exhibits the procedural or paragraph-level weakness the guidance addresses;
- the same writing scenario using the revised skill produces an introduction,
  connected exploration, and conclusion without a repeated command rhythm;
- the lesson answers the title question through connected prose;
- all seven displayed Ash blocks still match their canonical sources;
- all seven programs retain their existing accepted or rejected observations;
- the lesson contains no rendered project administration;
- the deferred filename question appears in the roadmap without selecting a
  renderer or renaming a file;
- Markdown, links, skill validation, shell syntax, and Git checks pass; and
- all commits remain unsigned on the isolated branch, with no merge or push.

## Exclusions

This revision does not change canonical Ash code, checks, language semantics,
the learning order, setup instructions, assistant products, renderer choice,
publication tooling, or lesson filenames. It does not design the second
lesson.
