---
diagrams:
  - kind: illustration
    id: fig-foldl-replacement
    caption: Foldl replaces the combining operation and builds a left-associated expression.
    description: A right-branching list tree has blue colon circles and triangular leaves 1, 2, 3, empty brackets. Across an arrow labelled foldl f z, a left-branching application tree has orange f circles and leaves z, 1, 2, 3. Matching element colors persist. Labels first, next, last mark the successive accumulator extensions from the deepest f to the root, not evaluation times.
---

# Changing the association

The list groups to the right: `1 : (2 : (3 : []))`.
The result groups to the left: ``((z `f` 1) `f` 2) `f` 3``.
The first accumulator extension combines z and 1. Each later extension puts
the previous expression on the left of a new f, and the next element on its
right. The last extension becomes the root.

These are expression trees. First, next, and last identify recursive
accumulator extensions, not when Haskell evaluates their results.

```{#fig-foldl-replacement .illustration}
Show the structural transformation performed by Haskell's foldl f z on
the list [1,2,3], not a sequence of execution snapshots.
On the left, draw the original right-branching list tree: blue colon circles
with leaves 1, 2, 3, and []. On the right, draw the left-associated expression
f (f (f z 1) 2) 3: orange f circles, with leaves ordered z, 1, 2, 3.
Each f has its previous accumulator as its left child and its next element
as its right child. Do not merely recolor the original constructor tree.
Place a right-pointing arrow labelled foldl f z between the trees.
Use matching colored triangular leaves for each numbered element across
both trees; [] and z share a further color. Put function labels inside circles
and leaf labels below triangles. Label the deepest f first, the middle f next,
and the root f last, meaning accumulator-extension order, not forced evaluation.
Use split-md's structural tree layout with a common leaf baseline, rough
hand-drawn strokes, handwritten lettering, transparent background, and no frame.
Paint connectors behind filled shapes. Include a short expression below each
tree so the changed association is explicit.
```
