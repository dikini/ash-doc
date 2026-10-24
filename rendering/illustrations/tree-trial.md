---
illustration-defaults:
  font: excalifont
  stroke: mild
diagrams:
  - kind: illustration
    id: fig-tree-repair-trial
    caption: The same associations and subtrees before and after left-left repair.
    description: A black violet root has a red blue left child with a red yellow left child. After repair, the middle blue association is a red root with black yellow and violet children. Four triangular subtrees retain their order and identity colors.
---

# Keeping the same pieces during repair

This authoring trial adapts the left-left repair picture from *Guaranteeing
logarithmic retrieval*. Compare which association moves to the root and which
subtrees remain attached. The picture is not a storage or mutation claim.

```{#fig-tree-repair-trial .illustration}
Draw two small trees, before above and after below, with a downward arrow
between them. Before: black (k3,v3) has red (k2,v2) on its left and subtree d
on its right. Red (k2,v2) has red (k1,v1) on its left and subtree c on its
right; (k1,v1) has subtrees a and b. After: red (k2,v2) is the root, with
black (k1,v1) on its left and black (k3,v3) on its right. Keep a and b under
(k1,v1), and c and d under (k3,v3).
Use split circles for forms above associations and triangles for subtrees.
Keep k1 yellow, k2 blue, k3 violet, and a/b/c/d green/orange/pink/cyan in both
states. Use mild hand-drawn strokes. Do not print labels inside the artwork;
the passage and caption provide the comparison. Keep the two states distinct.
```

The shapes and identity colors let you follow the same pieces across the
change. The arrow between trees separates states; edges inside a tree show
its connections.
