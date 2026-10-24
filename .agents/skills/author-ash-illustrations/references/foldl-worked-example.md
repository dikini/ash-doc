# From a problem to an illustration: foldl

The [worked example set](examples.md#foldl-with-structural-reassociation)
summarizes this case in the same format as the earlier examples. This longer
walkthrough retains the distinguishing derivation and feedback cycle.

This worked example teaches an authoring process, not a preferred layout for
every fold. It concerns Haskell, not the pinned Ash language. No reference
picture was supplied for foldl. The author requested the rough circles,
colored triangular leaves, and handwritten lettering of the earlier
[foldr example](../../../../rendering/illustrations/fold-tree-trial.md).

## The problem supplied by the author

Illustrate this Haskell definition. Explain the combining function's role and
how the process unfolds, using the preceding figure's visual vocabulary:

```plaintext
foldl :: (b -> a -> b) -> b -> [a] -> b
foldl f z []     = z
foldl f z (x:xs) = foldl f (f z x) xs
```

This is a reconstruction of the authoring task, not a verbatim transcript.
The author subsequently clarified that the intended comparison was the
replacement of infix list constructors by f, as in the foldr illustration,
rather than a series of recursive-call snapshots.

## Infer the explanatory relationship

Before describing shapes, derive a small distinguishing example. Three
elements expose the association without requiring a tall five-element tree:

```plaintext
input:  1 : (2 : (3 : []))
foldr:  f 1 (f 2 (f 3 z))
foldl:  f (f (f z 1) 2) 3
```

Foldr retains the right-associated shape. Foldl does not merely rename the
same nodes: the accumulator is the first argument of f. Repeatedly passing
`f accumulator x` builds a left-associated expression, with ordered leaves
z, 1, 2, 3. The final application is the root; the first accumulator extension
is the deepest application beside z.

Do not turn structural nesting into an evaluation-time claim. Haskell's foldl
does not force every intermediate accumulator; see the
[Haskell library documentation][foldl]. This illustration shows the expression
constructed by the recursive equations, not an execution trace, mutation, or
an allocation diagram. It is not an efficiency comparison with foldl'.

## Compare interpretations before drawing

The initial [snapshot brief](../../../../rendering/illustrations/foldl-trial.md)
and [snapshot authoring code](../../../../rendering/illustrations/foldl-trial.mjs)
produced four recursive-call states with a growing accumulator and shrinking
remaining list. The author found that explanation useful, but it answered a
different visual question. Retain it as an alternative, not as the requested
constructor-replacement result.

The corrected composition places the original list tree beside the accumulated
application tree. A third possibility, simply recoloring the original colon
nodes as f, is incorrect for foldl: it preserves the wrong argument order and
association. Style similarity must not override the operation's structure.

## Write the illustration description

The agent-authored [illustration fence](../../../../rendering/illustrations/foldl-replacement.md)
records the inferred composition in prose. It specifies:

- The input, operation, small example, and structural relationship.
- Right-branching colon circles versus left-branching f circles.
- Stable numbered-leaf colors, and matching terminal/seed color for [] and z.
- Function labels inside circles and element labels below triangular leaves.
- First, next, and last as accumulator-extension order, not evaluation times.
- Rough strokes, handwritten labels, transparency, and edge-first layering.

These details were authored from the problem and clarification. They are not
a grammar that the renderer infers, and the user did not have to supply
coordinates, split-md syntax, or drawing code.

## Construct, filter, and save

The [authoring adapter](../../../../rendering/illustrations/foldl-replacement.mjs)
saves two split-md constructions and their resolved scenes. It uses the exact
consumer pin's parse/layout/style sources from Git, without moving that pin
or requiring the upstream checkout to be at it. The adapter explicitly adds
solid constructor colors, labels, side-by-side composition, and the operation
arrow; those additions are not split-md grammar features.

Construction and appearance are separate decisions. Rough.js adds seeded rough
strokes during authoring; the existing
[lettering helper](../../../../rendering/illustrations/fold-tree-labels.py)
outlines the pinned Excalifont labels. Filled shapes cover connector interiors.
Reproducible generation is not evidence that the interpretation is correct:
the author must still review the structure and its visual explanation.

Run from the worktree root:

```bash
node rendering/illustrations/foldl-replacement.mjs
```

The generated `.build/foldl-replacement/` contains the original prose source,
an asset directory with `illustration.json` and `figure.svg`, a preview, and
an ordinarily prepared document. The saved state records constructions,
scenes, exact dependency hashes, stroke parameters, and a final rebuild
command. Replaying that command rebuilds this interpretation; it does not
understand a changed author request. Document preparation only substitutes
the saved SVG and never performs these authoring phases.

## Review and limits

The author accepted the reassociation diagram as the worked example's result.
Use its prose brief and construction as the primary example; the snapshots
remain a useful alternative for explaining recursive-call progression, not
the selected answer to the constructor-replacement task.

The adapter asserts the parsed right- and left-associated trees, three circles
and four triangles per tree, six connectors per tree, repeat-render byte
agreement, outlined labels, and no narrow-viewport horizontal overflow.
Human review must also check leaf order, the seed's changed position, function
argument order, annotation clearance, protected fills, and actual-size labels.
Phone-size labels require enlarging this side-by-side figure. EPUB and
production PDF layouts are not established by the standalone HTML preview.

## Transfer the process, not the picture

Given another problem, first identify what the reader should perceive and
derive an example that distinguishes a wrong interpretation. Then write a
prose illustration brief, choose a suitable construction method, apply only
compatible appearance phases, save reproducible artwork, and review the result.
Use clarification or a revised brief when feedback changes the intended
relationship. Do not copy these trees, colors, or temporal annotations into
an unrelated problem merely because this example uses them.

[foldl]: https://downloads.haskell.org/ghc/9.10.3-rc4/docs/libraries/base-4.20.2.0-ea02/Data-Foldable.html
