---
diagrams:
  - kind: illustration
    id: fig-foldr-structure
    caption: List constructors become f, and the empty list becomes z.
    description: Two diagonal branching trees have numbered leaves 1 through 5 in corresponding positions. The left tree has colon constructors and ends in empty brackets. The right tree replaces each constructor with italic f and ends in italic z. A right-pointing arrow between the roots is labelled foldr f z.
---

# Replacing the constructors

Follow the matching numbered leaves in the two trees. Their branching shape
stays the same while the constructor labels change.

```{#fig-foldr-structure .illustration}
Show how foldr f z transforms a list into a nested application.
On the left, draw the list 1, 2, 3, 4, 5 as a diagonal branching spine ending
in []. On the right, repeat the same structure, replacing each list-construction
node with f and [] with z. Keep numbered leaves in corresponding positions.
Place a right-pointing arrow between the roots, labelled foldr f z.
Use thin, hand-drawn connectors and serif mathematical lettering, with f and z
italicized. Keep spacing and branch angles consistent. Use a transparent
background, no enclosing border, and no node boxes.
```
