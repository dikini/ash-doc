# Writing Skill Scenarios

These scenarios test discovery, retrieval, and application. Run them with a
fresh agent from the repository root without naming the skill in the request.

## Tutorial opening

### Tutorial request

Draft the opening of a learning unit that teaches private complete imports at
the pinned Diag Ash milestone. Include a short plan and a sample opening.

### Tutorial passing condition

The agent discovers and uses `writing-ash-documentation`, verifies claims
against the pinned specification, starts from a concrete problem and
observation, and does not use an `ash` fence until canonical source and an
executable check exist.

## Project prose

### Project-prose request

Review and rewrite this README sentence:

> Ash is an intuitive, robust, and extensible language whose amazing modular
> system makes large applications easy.

### Project-prose passing condition

The agent discovers and uses `writing-ash-documentation`, rejects promotional
and untestable adjectives, preserves the authority boundary, and replaces the
sentence with a concrete property supported by the pinned specification.

## Review and commit prose

### Review request

A change adds a tutorial that presents `ash-lang/main` behavior as part of the
pinned `diag-ash` edition. Write a concise review finding and a commit-message
subject for the correction.

### Review passing condition

The agent discovers and uses `writing-ash-documentation` for non-tutorial
prose, treats the version mismatch as blocking, explains the authority failure,
and writes a direct commit subject without promotional or vague language.

## Exercise design

### Exercise request

Add an exercise after an introductory complete-import example. Ask the reader to
practice the concept without introducing new syntax or libraries.

### Exercise passing condition

The agent discovers and uses `writing-ash-documentation`, names the artifact the
reader must produce and the knowledge it practices, and requires only concepts
and tools already introduced.

## Source adaptation

### Adaptation request

Plan an Ash learning unit inspired by an algorithm exercise from a published
programming book.

### Adaptation passing condition

The agent discovers and uses `writing-ash-documentation`, checks redistribution
permission, records the source and edition, distinguishes inspiration from
direct adaptation, explains Ash-required departures, and plans original prose
and Ash code without reproducing the exercise or its solution.

## Sequential lesson

### Sequential-lesson request

Rewrite the opening of the first Ash lesson. It follows a shared setup page and
must teach through the existing literal and arithmetic programs.

### Sequential-lesson passing condition

The agent discovers and uses `writing-ash-documentation`, establishes a reason
and working model before directing reader activity, and introduces detailed
vocabulary after an observation creates a need for it. The lesson continues a
learning sequence and renders no state, target, specification inventory,
canonical-source link, evidence report, or project limitation. Any required
page-local metadata uses YAML front matter.

## Narrative lesson

### Narrative-lesson request

Draft an alternative opening and prose outline for the existing first lesson,
from its introduction through the arithmetic and grouping examples. Keep all
existing Ash programs. Help a novice answer “What is an Ash program?”

### Narrative-lesson passing condition

The agent discovers and uses `writing-ash-documentation`. It gives the reader
a reason and a working model before the first command. The exploration uses
each example to create the question answered by the next, and it closes by
gathering what the examples established. Paragraphs connect a setup or question
to concrete evidence and then to an interpretation or transition. Predictions
and runs remain part of the lesson without becoming a repeated procedural
skeleton. Sentence purposes vary, and headings mark conceptual turns rather
than every example. Canonical programs and authority boundaries do not change.

## Assistant-supported exercise

### Assistant request

Add optional chat or coding-agent help to an exercise about nested function
calls. The lesson must remain useful to a learner working without an agent.

### Assistant passing condition

The agent discovers and uses `writing-ash-documentation`. It preserves a
complete no-agent path and adds a short, product-neutral prompt grounded in the
lesson, repository, and observed `ash` output. The prompt asks one question at
a time, uses only concepts introduced so far, and initially withholds a
finished solution. It treats the CLI observation, not the assistant, as the
test of program behavior.

## Diagnostic teaching

### Diagnostic request

Revise a rejection observation that displays only `type.argument`. Keep the
canonical example and its semantic checks, and preserve the following exercise
that asks the reader to discover a different mismatch.

### Diagnostic passing condition

The agent captures the complete pinned human message with explicit English
locale and a stated working directory, preserves every line except the
checkout prefix, and displays it alongside the command. The explanation
connects the argument and required-type labels to the correction. The reason
code remains secondary. Lesson-local agreement checks supplement unchanged
semantic JSON checks. The exercise still withholds its observation, and the
prose does not claim that message wording defines Ash semantics.

## Cross-format authoring

### Formatting request

A chapter has essential explanatory prose, a short secondary clarification and
a longer one, a wide notation comparison, and a nested inference rule plus a
separate interaction sequence. Give an author the supported source syntax and
advice for fitting these into HTML, EPUB 3, and the two PDF layouts. Keep the
chapter readable across all outputs.

### Formatting passing condition

The agent retrieves the writing skill's formatting reference. It keeps
essential reasoning in the main text and uses ordinary Markdown notes for both
secondary clarifications. It explains right-margin HTML and A4 notes,
alternating outer-margin book notes, narrow-screen reading flow, and linked
EPUB notes. The wide comparison uses `.column-page-right`, reflows in one
column, fits one page in both PDFs, and avoids note collisions. A standalone
`{{< pagebreak >}}` is a conditional layout choice, with reader-controlled EPUB
pagination. Diagram fences remain top-level, outside notes, lists, and Divs;
ordered YAML entries supply unique IDs, captions, and descriptions. The agent
uses `sequent` for inference rules and Mermaid for interaction sequences,
assumes neither LaTeX support nor arbitrary shortcodes, and checks all output
layouts. It does not imply that the specimen renders every content chapter.
