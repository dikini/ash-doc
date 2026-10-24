---
diagrams:
  - kind: illustration
    id: fig-foldl-steps
    caption: Each recursive call passes f accumulator x as the next accumulator.
    description: Four successive states of foldl on the list 1, 2, 3 show a growing left-nested accumulator tree and a shrinking remaining list. Each orange f circle takes the previous accumulator on its left and the next element on its right. The final empty list returns the expression f (f (f z 1) 2) 3.
---

# Building a left-associated accumulator

Follow the accumulator expression and the remaining list together. Each step
moves one element into a new application of f. The previous accumulator is
always its first argument. When the remaining list is empty, foldl returns
the accumulated expression.

The arrows show successive recursive calls, not the execution time of f.
Haskell's foldl does not force each intermediate accumulator. The growing
trees show expressions, not already-computed values. See the
[Haskell foldl documentation][foldl].

```{#fig-foldl-steps .illustration}
Illustrate the Haskell definition foldl f z [] = z and
foldl f z (x:xs) = foldl f (f z x) xs, using the list [1,2,3].
Use four snapshots in recursive-call order. In every snapshot show both
the current accumulator expression and the remaining list. Start with z.
At each step, draw a new orange f circle whose left child is the complete
previous accumulator tree and whose right child is the next list element.
Use colored triangular leaves, keeping each element's color consistent.
Give z its own triangular leaf and color. Show the remaining list shrinking
from [1,2,3] through [2,3] and [3] to []. At the empty list, return the whole
accumulator expression, f (f (f z 1) 2) 3. Label argument order clearly.
Use rough hand-drawn strokes, handwritten lettering, a transparent
background, and no enclosing boxes. Keep edges behind filled shapes.
Distinguish recursive-call progression from evaluation: do not claim that
f z 1 has been evaluated before constructing the next application.
```

[foldl]: https://downloads.haskell.org/ghc/9.10.3-rc4/docs/libraries/base-4.20.2.0-ea02/Data-Foldable.html
