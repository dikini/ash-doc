# Develop a program the reader can follow

How can the reader see why a program has its types, cases, and connections,
rather than lose the idea in a complete listing? Develop the solution from
the problem toward its smaller calculations. This method applies the teaching
traditions named in the [writing skill](../SKILL.md); it does not define Ash
semantics or prescribe headings for every chapter. Use the pinned specification
and executable evidence under [AGENTS.md](../../../../AGENTS.md).

## Establish the problem and data

Begin with the task and one concrete example: what information arrives, what
answer is wanted, and which condition makes an answer useful? Choose an example
small enough to trace, but retain the boundary the lesson promises. Let it
create the need for the representation before showing the whole program.

Describe the data next. For a new type, explain what its values mean, why its
cases or fields exist, and how an example is represented. State the conditions
the algorithm relies on. Distinguish conditions recorded by the type from
additional promises maintained by the program. A type name and constructor
listing alone do not establish this model.

Use the reader's existing knowledge. If lists and recursion are familiar but
tokens are new, spend the explanation on tokens and their role in this problem.
Explain a familiar concept's new facet locally, without repeating its whole
introduction. If the reader would need a new concept to understand an optional
note, introduce it in the main account or remove the note.

## Derive the operations before the algorithms

Start from the public result. Name the operations needed to obtain it and give
each a purpose and a type. Explain the role of each input, the result, required
conditions, and what must be preserved. Then show how intermediate types allow
those operations to connect. Keep signatures adjacent to global definitions
when displaying complete code; early type calculations may use clearly
labelled non-executable fragments.

The signature constrains the connections, but it does not supply the algorithm
or establish every promised property. Explain ordering, preservation, and other
conditions separately. Avoid presenting an ordinary nominal type as a guarantee
that every value has an algorithm's invariant.

Keep the API's actual input shape. Curried inputs and one tuple input can lead
to the same final answer, but they have different types and supply different
values at each call. Use the [Learn comparison][tuple-comparison] when that
distinction matters. The pinned [application rules][application] and
[call syntax][call-syntax] govern it; layout preferences do not change it.

## Fill the calculation from general to concrete

Show how the public operation combines the promised smaller operations. Then
calculate each smaller operation from its inputs and required result. When
recursion carries the argument, identify the smaller data, state what its
recursive result promises, and explain how the surrounding construction
preserves that promise. Include the empty or simplest case and the reason the
data gets smaller.

State premises and conclusions in plain language. A proof can follow the data's
cases and the function's equations without starting with unfamiliar theoretical
vocabulary. Keep the reasoning: examples can expose a faulty implementation,
but passing a finite collection does not establish a claim about every input.
Name the conditions under which the general argument holds.

Give the reader a manageable unit at each turn. Introduce a helper's purpose,
signature, and cases before displaying its body. For several structural cases,
name each case, explain what distinguishes it, and show its complete equation
or checked excerpt beside that explanation. Treat a fallback separately and
explain what it preserves. A short complete function can stay together; a long
one benefits from interleaved reasoning, rather than an uninterrupted listing
followed by commentary.

Use existing source-agreement checks for displayed definitions and exact source
excerpts. Distinguish complete runnable programs, exact excerpts, and schematic
calculations in their fences and introductions; label schematics non-executable.
Splitting the explanation does not create independent programs or license
incomplete text in an `ash` fence. Connect the source and evidence behind the
lesson rather than displaying project machinery to readers.

## Make structural wiring visible

Repeated argument groups can crowd out the relationship they express. Consider
grouping related values when the group has a useful meaning across the
operations. Introduce that meaning and its fields, destructure the group, and
rebuild the required arrangement. Repeated patterns can expose the same mapping
in successive cases. A parameter pattern or a local destructuring binding may
serve it; choose a style that readers can recognise across the related API.

Prefer descriptive names for global operations and ordinary domain values.
Short local mnemonics can improve a dense structural calculation when they let
the reader compare patterns and constructions at a glance. Give a nearby key,
state the ordering or roles, and use those names in prose, code, and diagrams.
Do not make the reader translate between `first_key` and `k1`, or between `A`
and `a`, for the same value. Unexplained abbreviations merely move the burden.

The [repair calculation][repair-cases] is a worked example: `a`, `b`, `c`, and
`d` denote the four subtrees in order; `k` and `v` denote key and value;
`(k1, v1)` through `(k3, v3)` denote associations in increasing key order.
The indices are positions in this local pattern, not literal key values or
insertion order. `RArg` groups one subtree with its following association;
the final subtree remains separate. The shared helper unpacks those groups and
reconstructs the tree. These choices expose this operation's structure; they
are not required names or a wrapper for every multi-input function.

Do not add a representation merely to shorten a signature. A short scalar
calculation may need no wrapper or destructuring. Likewise, do not shorten an
API by changing currying or tuple shape solely for the printed page. When a
representation change only groups a fixed number of fields, discuss relevant
constant costs separately from the algorithm's asymptotic argument; establish
compiler optimisations through evidence rather than assuming them.

First make the program understandable; then choose its width. Wider code can
preserve the alignment of a pattern and its reconstruction when wrapping would
hide it. Keep the established type size and exact canonical text. The
[formatting reference](formatting.md#choose-a-code-width) covers placement and
pagination. More space cannot replace smaller explained calculations.

## Read large results as observations

Introduce the command and what its result represents before displaying it.
For a large successful structured value, select meaningful components, explain
each, and then connect them to the whole. Name where each component comes from
and say explicitly that these are parts of one captured result, with surrounding
structure omitted. Preserve the complete capture in the checks; compare every
displayed component and any summary against it. Do not present excerpts as
complete outputs of separate runs, invent intermediate output, or use unexplained
ellipses.

The [prefix observations][prefix-observations] demonstrate this approach. They
read the empty check, successive prefix checks, and final lookup flags from one
scenario in a captured six-scenario tuple, then give a checked summary. Each
observation explains a particular consequence; the general preservation argument
remains separate.

This selection rule applies to successful structured results. Supplied rejection
observations still show the complete human diagnostic beside the reproducible
command. Discovery exercises still withhold the answer the learner must find.
A smaller example is useful only if it retains the lesson's intended boundary.

## Review the reader's calculation

Ask a reviewer to follow one input through the operation types, one case's
pattern, the reconstruction, and the reported result. Can they identify what
each piece means, what changes, and what stays true without translating names
or searching a long listing? Then try another case and a boundary case.
Keep enough explanation to make those predictions possible; shorten repeated
reasoning once the reader has the pattern.

[repair-cases]: ../../../../content/cases/guaranteeing-logarithmic-retrieval/README.md#repair-the-returned-child
[prefix-observations]: ../../../../content/cases/guaranteeing-logarithmic-retrieval/README.md#assemble-the-inputs-and-read-the-result
[tuple-comparison]: ../../../../content/learn/values-travel-together/README.md#receiving-one-pair
[application]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#functions-and-application
[call-syntax]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/syntax.md#precedence-and-associativity
