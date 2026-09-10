# Persistent red-black insertion for logarithmic dictionaries

## Question

Which persistent red-black-tree tradition can support a future ash-doc case
about worst-case logarithmic dictionary retrieval, and what may ash-doc reuse
from that tradition?

The observable boundary is a persistent ordered tree that may degenerate into a
linear chain versus one whose hidden representation preserves enough balance
invariants to bound its height. This record selects source and adaptation
boundaries for that future case. It neither specifies an Ash representation nor
establishes executable Ash behavior.

## Selected tradition

The selected tradition is Chris Okasaki's four-configuration functional
insertion from:

- Chris Okasaki, [*Red-black trees in a functional
  setting*](https://doi.org/10.1017/S0956796899003494), *Journal of Functional
  Programming* 9(4), July 1999, pages 471--477. The
  [publisher record](https://www.cambridge.org/core/journals/journal-of-functional-programming/article/redblack-trees-in-a-functional-setting/62BC5EA75A2C95E3F6EE95AE3DADF0E5)
  identifies the work as a Functional Pearl, gives DOI
  `10.1017/S0956796899003494`, and records copyright 1999 Cambridge University
  Press. The [publisher
  PDF](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/62BC5EA75A2C95E3F6EE95AE3DADF0E5/S0956796899003494a.pdf/red-black-trees-in-a-functional-setting.pdf)
  was the material consulted.
- Chris Okasaki, *Purely Functional Data Structures*, Cambridge University
  Press, print publication 1998, section 3.3 in chapter 3, pages 17--30. The
  [publisher chapter
  record](https://www.cambridge.org/core/books/abs/purely-functional-data-structures/some-familiar-data-structures-in-a-functional-setting/079AE6D76DB1F9BB0071B45067BF70FA)
  gives chapter DOI `10.1017/CBO9780511530104.004` and online publication on
  17 September 2009.

The paper supplies the smallest causal model needed by the case. A
binary-search ordering directs lookup and insertion into one branch. No red
node has a red parent, and every path from the root to an empty node contains
the same number of black nodes. Empty nodes count as black. Together these
conditions keep the longest path within a constant factor of the shortest and
support logarithmic-height operations.

Insertion first creates a red leaf. That choice preserves black-height but may
create a red node below a red parent. A black grandparent can see four possible
orientations: left-left, left-right, right-left, and right-right. Each
configuration is reordered into the same ordered local shape with a red root
and two black children. Reconstruction continues toward the top, and the outer
operation blackens the final root.

The paper names the red-parent and equal-black-path conditions as its two
balance invariants. It handles a black root separately by final recoloring. A
future case may retain a black root as a representation invariant, but it must
explain that the public insertion operation restores that condition rather
than attribute a third named invariant to the paper.

## Corroborating presentation

Andrew W. Appel's *Verified Functional Algorithms*, edited by Benjamin C.
Pierce, Software Foundations volume 3, version 2.1, 2026, explicitly states
that its [red-black-tree
chapter](https://softwarefoundations.cis.upenn.edu/vfa-2.1/Redblack.html) uses
Okasaki's algorithms. It presents a finite-map form with values, the four
balance branches, insertion of a red leaf, final root blackening, binary-search
ordering, and red-black proof obligations. The [versioned
preface](https://softwarefoundations.cis.upenn.edu/vfa-2.1/Preface.html) gives
the edition and recommended bibliographic identity.

The versioned distribution's
[license](https://softwarefoundations.cis.upenn.edu/vfa-2.1/LICENSE) grants the
MIT permissions for its software and associated documentation, subject to
retaining its copyright and permission notice in copies or substantial
portions. The consulted `vfa.tgz` has SHA-256:

```text
f03296c763d78aa5bc18a545d848d398292575e5c8af4b5aa94dc25709e169b8
```

This presentation corroborates the selected program structure and exposes
useful proof boundaries. It does not replace Okasaki as the primary identity
of the algorithm. This record also does not treat incomplete exercises or
admitted exercise obligations as completed proofs.

## Alternatives considered

### Left-leaning red-black trees

Robert Sedgewick's [*Left-leaning Red-Black
Trees*](https://sedgewick.io/wp-content/themes/sedgewick/papers/2008LLRB.pdf),
2008, is a credible alternative tradition. It adds a rule that red links lean
left and expresses repair through rotations and color flips after recursive
calls. That extra invariant reduces symmetric source cases, but it no longer
answers the case through Okasaki's four configurations. Its published
example is also a mutable Java symbol table rather than a persistent functional
construction.

No explicit reuse license was found in the author-hosted paper or the author's
[research record](https://sedgewick.io/research/). Public access is not treated
as adaptation permission. The left-leaning tradition is therefore neither the
conceptual basis nor a code source for this case.

### SML/NJ production map

The SML/NJ Library's
[`RedBlackMapFn`](https://github.com/smlnj/smlnj/blob/eed009153b27c15f2eb5f341053795459979fd6b/smlnj-lib/Util/redblack-map-fn.sml)
at commit `eed009153b27c15f2eb5f341053795459979fd6b` identifies its code as based
on Okasaki and records the red and black-height invariants. Its repository
[license](https://github.com/smlnj/smlnj/blob/eed009153b27c15f2eb5f341053795459979fd6b/LICENSE)
is BSD-3-Clause, so direct adaptation would require retention of the applicable
notice, conditions, and disclaimer.

That implementation also carries a production map interface, element counts,
local mutation, deletion, and bulk construction from other sources. Those
features obscure the insertion boundary and would require separating several
provenances. A permissive license does not make this larger source the better
teaching basis, so ash-doc will not adapt it.

## Adaptation classification and rights boundary

The selected Okasaki contribution is **conceptual inspiration**, not direct
adaptation. The publisher record records copyright 1999 Cambridge University
Press and does not identify an open-content license for the article. The
Cambridge chapter interface limits saved content to personal use and does not
identify an open adaptation license. Access to either source does not grant
permission to translate or redistribute its expression.

Ash-doc will cite the algorithmic tradition and write original Ash programs,
names, prose, derivations, diagrams, insertion sequences, tests, and exercises.
It will not translate the paper's Haskell equations, reproduce its figure,
reuse the book's programs or exercises, or imitate either source's exposition.

The MIT license makes the Software Foundations material available for lawful
direct adaptation with notice retention, but no direct adaptation is selected.
It remains corroborating evidence. If later work copies or closely translates
a substantial portion, that work must preserve the versioned license notice
and update this classification before publication.

## Contribution to case 9

The selected tradition can support these original explanations and evidence:

- ordering, a black root, no red parent with a red child, and equal
  black-height as the representation conditions maintained by public
  construction;
- insertion of a red leaf, the four red-red balance configurations, local
  reordering that preserves search order and black-height, and final root
  blackening;
- persistent source reconstruction along the entered path while unchanged
  subtrees pass unchanged into new constructors; and
- the height argument that turns one-branch lookup and insertion into
  logarithmic-height operations.

The precise Ash cost statements remain case-specific derivations, not claims
copied from the sources. The case must show that lookup performs a bounded
number of ordering comparisons per entered node and that insertion constructs
only a constant number of representation nodes per entered level. Those facts,
combined with logarithmic height, support `O(log n)` comparisons and
`O(log n)` newly constructed path nodes. If one key comparison costs at most
`Cmax`, the combined comparison work may be summarized as
`O(log n * Cmax)` only under that explicit bound.

Passing an unchanged subtree into a new constructor supports a source-level
reuse account. It does not establish runtime pointer identity, physical
sharing, heap allocation counts, or garbage-collection behavior.

## Ash-specific departures

Okasaki's paper implements a set in Haskell. The Ash case instead needs
a dictionary with key-value entries and later-equal replacement while keeping
the existing public client API. Its programs follow the pinned dynamic
[application
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/dynamic-semantics.md#application)
and use only forms supported by the pinned Diag Ash edition.

The case must derive preservation from its own ordering equations, balance
equations, and explicit ordering-law premises. An `Order<K>` interface
requirement follows the pinned [interfaces and constrained
schemes](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#interfaces-and-constrained-schemes)
and [constraint satisfaction and checked
evidence](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
rules; those rules do not prove that the comparison forms a total order.
Likewise, a nominal dictionary declaration does not prove the red-black
invariant. The guarantee comes from the pinned [public opaque declaration
boundary](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/name-resolution.md#public-private-and-opaque-declarations)
together with the selected invariant-preserving public operations.

All language claims must come from the
[pinned specification](https://github.com/dikini/ash-lang/tree/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec),
and all command observations must follow the pinned
[`ash` tool
guide](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/docs/tools/ash.md).
The target remains `diag-ash` at
`9231b21228c5ccacbbee0cc0da60b380e5d2dc59`. Neither the sources in this
record nor current `ash-lang/main` can add behavior to that edition.

## Deliberate exclusions

The source relationship excludes:

- deletion and its additional balance states;
- the left-leaning invariant and imperative rotations;
- type-indexed or machine-checked invariants as Ash language features;
- lazy evaluation, infinite structures, or amortized claims from unrelated
  functional structures;
- arbitrary-precision comparison bit costs without a stated comparison bound;
- elapsed time, machine instructions, native stack, heap bytes, pointer
  identity, or compiler-optimization claims;
- claims of universal optimality rather than worst-case logarithmic
  comparison-based retrieval; and
- copied source programs, figures, proofs, exercises, or teaching order.

This record owns source attribution, adaptation boundaries, and excluded
claims. The canonical programs and checks in the corresponding Case establish
its behavior at the repository baseline.
