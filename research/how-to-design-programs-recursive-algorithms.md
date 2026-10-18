# Recursive-algorithm design in *How to Design Programs*

## Question

Which parts of *How to Design Programs* can help ash-doc teach recursive
algorithm design and cost without copying its curriculum or importing the
semantics of its teaching languages into Ash?

## Source consulted

- Matthias Felleisen, Robert Bruce Findler, Matthew Flatt, and Shriram
  Krishnamurthi, [*How to Design Programs*, second edition, release
  2026-02-25](https://htdp.org/2026-2-25/Book/).
- Part I, especially [Designing Functions and From Functions to
  Programs](https://htdp.org/2026-2-25/Book/part_one.html), for relating
  signatures and purposes to expected examples, deriving a function's
  structure from its data, and identifying needed helper operations before
  completing their bodies.
- Part II, especially [Designing with Self-Referential Data
  Definitions](https://htdp.org/2026-2-25/Book/part_two.html), for functions
  whose structure follows a data definition.
- Part III,
  [Abstraction](https://htdp.org/2026-2-25/Book/part_three.html), for identifying
  repeated function structure and making the varying operations explicit.
- Part V, [Generative
  Recursion](https://htdp.org/2026-2-25/Book/part_five.html), for the distinction
  between structurally smaller inputs and newly generated problem states, and
  for explicit termination arguments.
- [The Cost of
  Computation](https://htdp.org/2026-2-25/Book/i5-6.html)
  for counting source-level operations before using order-of-growth
  vocabulary.
- Part VI,
  [Accumulators](https://htdp.org/2026-2-25/Book/part_six.html), for recognizing
  lost knowledge, stating an accumulator invariant, and comparing the resulting
  work.

This record uses the exact dated edition selected by the project. Later HtDP
releases are not silently substituted for it.

## Contribution to ash-doc

The transferable method begins with the shape of the input data. For a
recursive list, one function equation handles the ending form and another
handles the form that contains a smaller list. Comparing several functions
with those same equations exposes the repeated traversal before abstraction is
introduced.

The design recipe places a signature, purpose, and expected examples before
the completed body. For a program with several operations, a needed helper
can first be described by its name, signature, and purpose. Ash-doc can use
those boundaries to reason about a composition, then derive each body from
its data cases and the promised results of its smaller computations. The
explanation must still establish why the chosen expressions satisfy the
purpose; a matching type alone does not establish an algorithm's invariant.

The method also keeps termination and cost attached to the program's source
structure. A structural call follows a field that is visibly smaller. A
generative call needs a separate argument that its produced state approaches a
stopping condition. Source-level work can be counted by naming the operation
and the input feature that causes it, such as one combiner call per list node.
Only then is an order-of-growth summary useful.

Accumulator design contributes a later comparison. An accumulator represents
knowledge retained from earlier steps, so its meaning must be stated as an
invariant rather than inferred from an optimized-looking function body. That
distinction supports the comparison between append-based and
accumulator-based reverse.

## Adaptation classification and license

This is **inspiration**, not direct adaptation. HtDP states that its material is
copyrighted by MIT Press and provided under
[CC BY-NC-ND](https://creativecommons.org/licenses/by-nc-nd/4.0/). The
NoDerivatives condition is incompatible with redistributing an adapted
curriculum, passage, diagram, exercise, or program without separate permission.

Ash-doc will therefore write original prose, examples, exercises, and ordering.
It may credit general design ideas and point readers to the source. It will not
translate HtDP examples into Ash, shadow the book's chapter sequence, or reuse
its wording. The record and citation provide attribution; they do not grant
broader reuse rights.

## Ash-specific departures

HtDP's examples and teaching languages do not govern Ash. An ash-doc case must
derive every language claim from the pinned FFI Base specification and every
command observation from the pinned tool. In particular:

- Ash uses nominal parameterized data and exhaustive equational definitions;
- Ash applications and tuples evaluate strictly;
- the fold is an ordinary rank-1 higher-order Ash function;
- cost statements count source-level calls, comparisons, and constructed
  representation nodes; and
- host stack behavior, heap byte counts, and compiler optimizations remain
  outside the language contract.

## Deliberate exclusions

The recursive-algorithms path will not reproduce HtDP's teaching languages,
world programs, image examples, curriculum, or exercises. It will not treat a
design recipe as an Ash semantic rule. Generative recursion and accumulators
enter only when a complete later case needs them and can provide executable
evidence at the exact Ash pin.

The first case uses the structural method and explicit operation counts. It
does not need the later generative-recursion or accumulator mechanisms yet.
