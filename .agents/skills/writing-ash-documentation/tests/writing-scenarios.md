# Writing Skill Scenarios

These scenarios test discovery, retrieval, and application. Run them with a
fresh agent from the repository root without naming the skill in the request.

## Run an affected scenario

Choose the scenarios that exercise the rule being changed, including a
counterexample when the change could be applied too broadly. A caption change
does not require rerunning unrelated diagnostic or import scenarios.

1. Run the selected request with a fresh agent at the pre-change revision.
   Give it the repository context, but no previous discussion, proposed rule,
   skill name, or passing condition. Record the prompt, revision, references
   retrieved, and decisions that meet or miss the passing condition.
2. After changing the guidance, run the same request with another fresh agent
   at the updated revision. Compare its decisions with the baseline rather
   than comparing exact prose. A reference opened without being applied does
   not establish that the guidance works.
3. If the agent misses the rule or applies it too broadly, revise the smallest
   relevant instruction and repeat the affected scenario. Use the existing
   language, source-agreement, and rendering checks when its proposed change
   becomes actual lesson material.
4. Retain the before-and-after outcome with the change's review evidence, such
   as its commit or pull-request description. Name the scenarios run, the
   observed difference, and any remaining gaps. Distinguish a reviewed scenario
   from one actually run; do not report unrun scenarios as passing.

These are manual decision checks. They need no new harness, registry, permanent
pass ledger, or test that requires an agent to repeat particular wording.

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

## Choose a note form and figure width

### Note-choice request

Choose between numbered sidenotes, unnumbered margin notes, full-width asides,
and ordinary prose for a source credit attached to one claim, a reminder of an
introduced term beside an example, a comparison table, and a required causal
step. A diagram has many participants and a landscape aspect ratio. Explain
how to decide its width in print and on narrow screens, and give supported
source forms without inventing renderer options. Also choose a form for an
optional commutative diagram, program-state snapshot, or call-stack sketch
that reinforces the explanation.

### Note-choice passing condition

The agent uses the formatting reference to select a numbered sidenote for the
precise source credit, a labelled `.column-margin` note for the local reminder,
a `.column-page-right` aside for a comparison that needs wider space, and main
prose for essential reasoning. It chooses by relationship and content, rather
than length or a desire to fill the margin. It treats full-width regions as
available to diagrams and illustrations as well as prose. A landscape ratio
suggests a candidate; actual label size, printed height, caption placement,
note collisions, and narrow-screen readability determine the width. It can
suggest splitting a diagram if neither width works. It distinguishes these
ash-doc choices from Tufte's personal practice and retains the current limit on
placing generated diagram fences in full-width Divs.
Supplementary sketches may use either numbered or unnumbered notes according
to their association. They retain introduced vocabulary, remain faithful to
the example, and must be legible at actual note-column width. Essential
understanding stays in the main reading path; raw nested diagram fences remain
unsupported.
The agent also checks whether each note earns its place by assisting nearby
understanding. It removes repetitive or unrelated detours and reduces competing
notes even when the margin has enough room for them.

## Calculate a program from its problem

### Calculation request

Plan a revision of `content/cases/implementing-persistent-fifo-frontier/README.md`
so the reader calculates the queue program instead of meeting a complete module
before understanding its operations. The reader knows recursive lists,
`Option`, and constructor patterns. The two-list queue representation is new.
Keep the canonical programs and their observations. Give a prose outline and
a sample transition into the first operation.

### Calculation passing condition

The agent retrieves the program-design reference and begins with the FIFO
problem and a small example. It then establishes the data representation and
its logical sequence before calculating operation types and their input/result
requirements. It works from those requirements toward the concrete equations,
with examples and reasoning at the point where they help the reader choose a
case. It explains the novel two-list representation in enough detail to follow
the calculation, while briefly recalling the already familiar lists, options,
and patterns. It names new vocabulary only when needed and gives essential
definitions and reasoning in the main text. The outline is a connected account,
not a repeated checklist or a fixed set of mandatory headings. Existing Ash
claims stay tied to the pinned specification, and any displayed source must
retain canonical agreement.

## Expose structural wiring with compact names

### Wiring request

An author is planning a helper that combines two sorted runs. Each run supplies
a list, its length, and a comparison count, so six positional arguments and
repeated long names obscure which fields belong together. The result contains
the merged list, the combined length, and the updated count. Suggest one or two
readable arrangements and show how to explain their field correspondence and
correctness. The neighbouring helpers use curried calls. This is a design
review; do not claim an untested Ash fragment is executable.

### Wiring passing condition

The agent uses the program-design reference to establish the helper's type,
the meaning of its fields, and the requirements on the sorted inputs before
filling in the algorithm. It considers grouping each run's related fields and
destructuring those groups, or using compact local names when that is clearer.
An adjacent legend explains the mnemonics, and corresponding fields retain
their names throughout the explanation. Global names remain descriptive and
the proposed helper fits the neighbouring API's call style. A complete small
definition or labelled schematic exposes the wiring instead of presenting
unexplained fragments. The reasoning states how the output retains the input
elements in order and how length and comparison accounting follow the work.
Examples test distinguishing cases; their success is not called a proof of
the general invariant. The agent does not promise compiler optimisation,
require wrappers everywhere, or import the search-tree lesson's names and
palette into this different problem.

## Explain a large successful result

### Structured-result request

An existing lesson has a successful captured result spanning more than a page:
a tuple containing the initial state, several intermediate states, returned
values, and accumulated work counts. Readers cannot tell what each field
establishes. Plan a clearer presentation while preserving the complete
canonical capture and checks. The next example shows a rejected program, and
the final exercise asks the reader to discover a different result.

### Structured-result passing condition

The agent separates the successful result into small, explained observations
in the order of the reader's questions. Each displayed selection identifies
the field or step it comes from and has an exact agreement check against the
complete capture; it does not pose as a complete CLI transcript or hide
contradictory fields. The canonical capture and its semantic checks remain
available as evidence, without forcing the entire result into the main reading
path. Prose connects each observation to a prediction or a property it
establishes and retains limits on what the result can show. The rejection still
displays its complete actual human message and command under the existing
edition checks. The discovery exercise still withholds its observation. The
agent does not solve the reading problem merely by shrinking type or assigning
the complete result a wider column.

## Preserve visual continuity and useful captions

### Diagram-continuity request

A queue chapter uses small before-and-after sketches showing its `front` and
`rear` lists. Each value has a stable colour and list connections show the
structure. An arrow between drawings shows the transfer. A new large figure
uses differently shaped boxes, long internal labels, and different colours for
the same values. Its caption is only “Queue,” followed by text above the image
that repeats “before and after.” Review that figure and propose an annotated
reference drawing that connects it to `Queue(front, rear)` and the code. Explain
what an empty list marker means without relying on the palette from another
chapter.

### Diagram-continuity passing condition

The agent retrieves the formatting reference and retains the established
shapes, colours, list-order conventions, and connection meanings for this queue
problem.
It follows each value's colour through the transfer; changed position or
attachment does not change value identity. It distinguishes structural
connections from the arrow marking the operation, and distinguishes a value
from a whole retained list. The larger drawing adds short code-aligned labels
beside the familiar shapes instead of introducing a second representation.
Any colour or shape used for `End` is defined locally as an empty list with no
element; white is not assumed to mean emptiness in every chapter. The caption
under the image names its particular operation or insight, with any additional
explanation after that name. Redundant before/after text is removed when the
arrow already communicates direction. A meaningful description and nearby
prose preserve the relationships without relying on colour alone. The agent
checks the drawing at its actual widths and does not treat a larger diagram as
a different visual language or infer physical sharing from reused colours.

## Keep simple programs and established notation simple

### Restraint request

Review a short lesson passage that defines a scalar addition function with two
`Int` inputs and one `Int` result. Its type, complete definition, and one
checked observation already fit together in the ordinary column. The same
lesson later has a standard Mermaid sequence diagram showing a client request
and a server response. Apply the repository's recent teaching and diagram
guidance where it helps; explain any changes you would leave out.

### Restraint passing condition

The agent discovers the writing skill and applies the guidance proportionately.
It keeps the scalar function and its call style compact, retaining any useful
type or result explanation without inventing grouped wrapper types, mnemonic
legends, forced operation inventories, or five recipe headings. It preserves
standard sequence-diagram participants, lifelines, and message-arrow meanings
instead of replacing them with a tree or queue representation. Visual
continuity applies within the relevant problem and notation; it does not
require every Ash diagram to use the same shapes, palette, or arrow semantics.
Any claimed change still has a concrete reading purpose and the applicable
source or rendering checks.

## Choose checks for the action and scope

### Scope request

Review an existing traversal lesson's A4 layout after a caption-only change.
The programs, displayed blocks, exact compiler pin, and observations are
unchanged with passing retained evidence. The maintainer needs the finding in
90 seconds; another reviewer suggests all four family aggregates and the whole
book “to be safe,” with cached tools available. State the context, checks, and
rendering needed, and any limits on the finding.

Then consider a Libraries introduction edit with an EPUB part review, and a
shared note-layout change affecting all supported outputs.

### Scope passing condition

The agent uses the writing skill and workflow, identifies each action and
scope, and chooses checks from affected inputs. The caption review checks its
meaning, selected source digest, affected A4 pages, caption association, and
layout; it reuses unchanged semantic evidence and does not build the book or
run unrelated programs. The part review covers its introduction, indexed order,
continuity, links, and requested EPUB. It does not edit sibling families or
execute unchanged programs. The shared layout case tests representative notes
in every affected format and applicable shared regressions. It neither reduces
all work to one lesson nor treats infrastructure work as a reason to rerun all
53 Ash clients. A discovered shared issue during lesson review requires scope
expansion or separate work. The narrow PDF finding does not establish book
pagination or compatibility in formats that were not reviewed.
