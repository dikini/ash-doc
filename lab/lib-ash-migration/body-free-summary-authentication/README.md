# Imported body-free summaries fail authentication

Three recursive-algorithm entries that compile and run at the exact
`modular-ash` checkpoint fail when their entry modules admit an already checked
dependency's body-free summary at exact `lib-ash`. Each Lib Ash invocation
exits with status `2`, writes nothing to standard output, and begins standard
error with `resolve.internal-state`.

This is compiler evidence, not a lesson or a statement that Ash should expose
this failure. The exact `lib-ash`
[tool contract](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/docs/tools/ash.md#failures)
classifies compiler-internal failures as status `2`. The
[specification overview](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/README.md#current-ash)
describes complete programs as acyclic source-module graphs whose dependencies
are checked before linking and evaluating `main ()`. The observation does not
establish why authentication failed or define valid source behavior.

The exact [import
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/name-resolution.md#imports-and-namespaces)
say that resolution consumes each already checked dependency's immutable,
body-free export summary. Summary admission authenticates its retained
identities and kinds. The exact [module and program
rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#globals-and-modules)
place that authentication before local declarations and bodies are checked,
and check each module after its dependencies. These rules locate the crossed
compiler boundary; they do not make the rendered internal diagnostic language
truth.

## Exact comparison

The predecessor is Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. The migration target is the signed
annotated `lib-ash` tag, peeled to
`d1e323d23390cdad03202ee3df76cd9100556e1d`. Both comparison checkouts must be
clean.

From the ash-doc repository root, run:

```text
bash lab/lib-ash-migration/body-free-summary-authentication/checks/verify.sh \
    /path/to/modular-ash \
    /path/to/lib-ash
```

The verifier builds both exact checkouts with their pinned Rust toolchain,
authenticates each copied source and predecessor output, and retains only the
stable Lib Ash status, channels, reason, and causal-label relationship. As a
control, it also runs each dependency file directly at Lib Ash. The search and
iterator libraries reach the `entry.missing-main` contract, while the red-black
library's own `main` succeeds. The status-2 failures therefore arise later,
when an importer admits the compiler-produced summary, rather than while the
dependency body is checked.

The rendered spans and the phrase “a dependency summary failed body-free
authentication” below are exact-pin observations retained for reproduction.
They are not a stable diagnostic-prose contract. The verifier separately
asserts the stable reason, channel, status, and causal import byte range.

## Search frontier

The original [search-frontier Case](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/choosing-a-search-frontier/README.md)
asks how LIFO and FIFO frontiers change path choice while one graph-search
transition remains fixed. This record retains its exact
[`searches.ash`](search-frontier/searches.ash) dependency and
[`main.ash`](search-frontier/main.ash) found-path entry.
Their immutable originals are
[`searches.ash`](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/choosing-a-search-frontier/src/searches.ash)
and
[`01-found-paths.ash`](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/choosing-a-search-frontier/src/01-found-paths.ash).
The Case's [source record](../../../research/graph-search-frontiers.md) selects
Pat Morin's *Open Data Structures* graph-traversal account as conceptual
inspiration, not direct adaptation, under the source's CC BY 2.5 Canada
license boundary.

At the predecessor commit, the entry exits `0`, writes no standard error, and
writes standard output with SHA-256
`254dc0d711ed8246b920f1be8b642af6d57a0aaa312a2d944de06fb570aea329`.
The immutable Case displays and explains that complete value and type. At Lib
Ash, the complete standard error is:

```text
resolve.internal-state
primary: source 0 0..27: a dependency summary failed body-free authentication
```

The primary span covers `import searches as Searches`. The failure blocks the
Case before either traversal result can be observed. The dependency exports no
interface-backed obligation, so this example also shows that the failure family
is not limited to a missing implementation selector. It matters beyond graph
search because an ordinary multi-file program can cross the same imported
summary boundary.

## Red-black dictionary

The original [red-black dictionary Case](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/guaranteeing-logarithmic-retrieval/README.md)
asks how a hidden colored representation prevents an ordered search tree from
degenerating. This record retains its exact
[`dictionaries.ash`](red-black-dictionary/dictionaries.ash) dependency and
[`main.ash`](red-black-dictionary/main.ash) prefix-matrix entry.
Their immutable originals are
[`dictionaries.ash`](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/guaranteeing-logarithmic-retrieval/src/dictionaries.ash)
and
[`01-prefix-matrix.ash`](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/guaranteeing-logarithmic-retrieval/src/01-prefix-matrix.ash).
Its [source record](../../../research/persistent-red-black-insertion.md) selects
Chris Okasaki's four-configuration functional insertion as conceptual
inspiration and excludes direct source adaptation. Andrew W. Appel's
*Verified Functional Algorithms* presentation corroborates the selected
structure under the record's separate MIT boundary; the Case directly adapts
neither source.

At the predecessor commit, the entry exits `0`, writes no standard error, and
writes standard output with SHA-256
`fbcad839ed0fcb98b146df63d4f478e191c38fe91083fb4b6c2e699b0777c2e1`.
The immutable Case retains the complete matrix. At Lib Ash, the complete
standard error is:

```text
resolve.internal-state
primary: source 0 0..35: a dependency summary failed body-free authentication
```

The primary span covers `import dictionaries as Dictionaries`. The failure
blocks the prefix-by-prefix invariant and lookup observations. Under the exact
import rules, that complete import selects names but no implementation facts.
This retained entry lacks a separate `impl Order` selector, so removing the
internal failure would not by itself preserve predecessor success: ordinary
checking must still apply the `lib-ash` implementation-selection rules. The
internal failure is a regression candidate because it occurs first and masks
that specified source-level result. The masking matters to any library client
whose dependency summary carries constrained public operations, not only to
red-black dictionaries.

## Tree iterator

The original [tree-iterator Case](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/resuming-tree-traversal/README.md)
asks how explicit immutable frames let eager traversal pause and resume. This
record retains its exact
[`dictionaries.ash`](tree-iterator/dictionaries.ash) dependency and
[`main.ash`](tree-iterator/main.ash) complete-sequence entry.
Their immutable originals are
[`dictionaries.ash`](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/resuming-tree-traversal/src/dictionaries.ash)
and
[`01-sequence.ash`](https://github.com/dikini/ash-doc/blob/recursive-1/content/cases/resuming-tree-traversal/src/01-sequence.ash).
The iterator Case selects no new external source; it extends the retained
recursive-algorithm, strictness, and persistent red-black records with an
original explicit-frame derivation.

At the predecessor commit, the entry exits `0`, writes no standard error, and
writes standard output with SHA-256
`190662c1447e5c5d9d5ae34d0e9dc95d0a157c6dfbf628656baa648a02166c45`.
The immutable Case retains the complete sequence. At Lib Ash, the complete
standard error is:

```text
resolve.internal-state
primary: source 0 0..35: a dependency summary failed body-free authentication
```

The primary span covers `import dictionaries as Dictionaries`. The failure
blocks the eager iterator and ordered-sequence observations. This complete
import also selects no `Order` implementation fact, so the same distinction
applies: the internal failure masks the later specified implementation-
selection result rather than promising predecessor success. It matters beyond
iteration because clients cannot reach ordinary checking feedback for public
APIs whose summaries combine opaque types, constraints, and reusable values.

## Classification and retention

All three exact sources pass at the predecessor and reach a compiler-internal
failure at the migration target. The search entry is blocked before its
otherwise ordinary qualified calls can be checked. The two dictionary clients
are blocked before their missing explicit implementation selection can receive
the specified source-level judgment. In each case, the earlier internal result
is an Ash implementation regression candidate. The shared observation family
does not prove that the three programs have one internal cause. Ash-doc does
not modify `ash-lang`, move the tag, prescribe a fix, or restructure these
retained sources to hide the failure.

This outcome retains the three complete original triggers rather than claiming
a minimized reproducer. Minimization may become useful during upstream Ash
investigation, but it is not needed to attribute the current failure to the
import boundary and could discard the distinct reader tasks that make the
evidence significant.

The copied source remains permanent migration evidence. Retain this case until
an authorized upstream resolution and a later ash-doc plan explicitly replace
its expected observation. The affected teaching Cases remain outside the
active `lib-ash` edition until their own migration outcome verifies them.
