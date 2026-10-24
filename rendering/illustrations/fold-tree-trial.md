---
diagrams:
  - kind: illustration
    id: fig-fold-tree
    caption: The branching structure stays; constructors and the terminal change.
    description: Two matching trees have five blue colon circles on the left and five orange f circles on the right. Six colored triangular leaves in each tree are labelled 1 through 5 and either empty brackets or z. Corresponding leaves retain their colors and order.
---

# Replacing constructors, keeping structure

Follow the same colored leaves across the two trees. Each circle combines its
left leaf with the remaining right branch. The final triangle changes from
the empty list to z.

```{#fig-fold-tree .illustration}
Show foldr f z replacing the constructors of the list 1, 2, 3, 4, 5.
Use split-md's binary tree layout, with circles for functions and triangular
leaves. Put the two trees side by side with a right-pointing transformation
arrow labelled foldr f z between them. The five colon circles on the left
are blue; the five f circles on the right are orange. Put the function labels
inside the circles. Give leaves 1 through 5 distinct colors and keep each
leaf's color and order across both trees. Use one further color for the
terminal triangle, labelled [] on the left and z on the right. Label leaves
below the triangles. Keep split-md's aligned leaf baseline, even where this
makes branches long. Use rough hand-drawn strokes and handwritten lettering,
a transparent background, and no frame. Keep connectors behind filled nodes.
```
