# Design library abstractions in Ash

This path asks how reusable source libraries can state the behavior and type
structure they need, then carry those abstractions across module boundaries.
It continues from the complete [Learn Ash](../learn/README.md) path. Finish
that path first so functions, parameterized definitions, public declarations,
and source imports are already familiar.

Use the `ash` command prepared by the repository's
[shared setup](../../README.md#prepare-ash). Each lesson keeps its program in a
`src` directory. Change into that directory before running an entry file, so
its sibling library imports resolve from the same program directory.

For each boundary, use the same cycle:

1. Read the library source and identify what it promises to clients.
2. Predict whether the client has the names, types, and implementation evidence
   its call requires.
3. Run the complete entry and observe its value and type or its first stable
   rejection reason.
4. Explain the result through the declarations and imports that caused it.
5. Change one boundary in a copy, predict again, and compare the observation.

## Lessons in order

1. [Choose implementation evidence](choosing-implementation-evidence/README.md)
   — separate an imported constrained name from the public implementation fact
   that satisfies its concrete requirement.
2. [Forward capability evidence](forwarding-capability-evidence/README.md)
   — carry public names and implementation authorization through a facade
   without redefining the capability.
3. [Accept a type constructor](accepting-type-constructors/README.md)
   — use an explicit function kind when an abstraction applies a type
   constructor to different element types.
4. [Give a method local type parameters](giving-method-local-type-parameters/README.md)
   — instantiate one interface method at unrelated element types while
   retaining one complete implementation requirement.
5. [Let one interface argument determine another](determining-interface-results/README.md)
   — use one total forward edge to complete an interface obligation before
   implementation selection.
