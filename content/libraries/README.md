# Design library abstractions in Ash

This path asks how reusable source libraries can state the behavior and type
structure they need, then carry those abstractions across module boundaries.
It continues from the complete [Learn Ash](../learn/README.md) path. Finish
that path first so functions, parameterized definitions, public declarations,
and source imports are already familiar.

Use the `ash` command prepared by the repository's
[shared setup](../../README.md#prepare-ash). Each lesson keeps its program in a
`src` directory. Run the displayed commands from that directory. Relative
imports resolve from the importing source file's directory, so keep sibling
library files beside their clients.

The [diagnostic reading notes](../../README.md#read-a-diagnostic) explain the
shell prompt, English output, and source-path convention. Rejection commands
also run from the lesson's `src` directory.

For practice, start each task in a fresh scratch directory outside the lesson's
canonical `src` tree. Copy the named entry and its required sibling modules
together, keeping their filenames. Run the copied entry from that scratch
directory. Begin the next task with fresh copies, so an earlier edit does not
change the boundary you are testing.

For each boundary, use the same cycle:

1. Read the library source and identify what it promises to clients.
2. Predict whether the client has the names, types, and implementation evidence
   its call requires.
3. Run the complete entry and inspect its value and type or the complete
   diagnostic explanation and source labels.
4. Explain the result through the declarations and imports that caused it.
5. Change one boundary in a copy, predict again, and compare the observation.

## Lessons in order

1. [Choosing implementation evidence](choosing-implementation-evidence/README.md)
   — separate an imported constrained name from the public implementation fact
   that satisfies its concrete requirement.
2. [Forwarding capability evidence](forwarding-capability-evidence/README.md)
   — carry public names and implementation authorization through a facade
   without redefining the capability.
3. [Accepting a type constructor](accepting-type-constructors/README.md)
   — use an explicit function kind when an abstraction applies a type
   constructor to different element types.
4. [Giving a method local type parameters](giving-method-local-type-parameters/README.md)
   — instantiate one interface method at unrelated element types while
   retaining one complete implementation requirement.
5. [Determining interface results](determining-interface-results/README.md)
   — use one total forward edge to complete an interface obligation before
   implementation selection.
6. [Requiring element behavior](requiring-element-behavior/README.md)
   — derive container behavior from explicit element prerequisites.
7. [Wrapping a representation](wrapping-a-representation/README.md)
   — use explicit newtype conversions and nominal interface behavior.
8. [Supplying scoped evidence](supplying-scoped-evidence/README.md)
   — combine local nominal types with sequential exact method evidence.
