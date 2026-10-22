# Opaque types

The previous lesson narrowed what crosses a module boundary: a targeted
import moves selected public spellings into the importing file. Every
spelling moved so far named a function. A boundary can also move a type —
but only part of the way. This lesson declares a type whose name crosses to
clients while its constructors stay home. A client can then name the type,
annotate values with it, and compute with values the provider built, without
ever building one itself.

## A score built at home

A game keeps a running tally. The module that owns the tally also owns how
tally values are made, so it declares the type opaque and offers functions
instead of the constructor. Create a fresh directory for this program with
the same two files:

```text
score/
|-- score.ash
`-- main.ash
```

`score.ash` holds the provider:

<!-- source: src/score.ash -->
```ash
pub opaque type Score = Score(Int)

pub make : Int -> Score
make points = Score(points)

pub add : Score -> Int -> Score
add (Score points) extra = Score(points + extra)

pub total : Score -> Int
total (Score points) = points
```

Read the first line as two decisions. `pub` places the type name `Score` in
the module's public summary; `opaque` keeps its constructors out. The type
and its constructor share the spelling `Score`, as they did in the data
lesson; inside this module both remain available, and the three functions
use the constructor freely. `make` builds a tally from an integer, `add`
consumes one tally and builds the next, and `total` reads a tally back into
an integer. Every construction happens in this file. The
[visibility rules][visibility-rules] define what each visibility mode
exports.

The targeted import names the type alongside the functions, so the client
can annotate a binding with it:

<!-- source: src/01-main.ash -->
```ash
import score (Score, make, add, total)

main : Unit -> Int
main () = {
    let score : Score = add (make 10) 5
    total score
}
```

The type name `Score` crossed the boundary with the functions, and the
annotation `let score : Score` names it. Follow the block: `make 10` builds
a tally of ten, `add ... 5` asks the provider for the next tally, and
`total` reads it back into an integer. Predict the value and type of the
block, then run the entry from `score`:

```text
ash main.ash
```

Ash follows the import, checks both files, and reports:

```text
15 : Int
```

## The boundary refuses the constructor

The client named the type in an annotation. What about the constructor that
shares its spelling? A client may try to name it too:

<!-- source: src/02-constructing.ash -->
```ash
import score (Score)

main : Unit -> Score
main () = Score(42)
```

Predict first: the import names `Score`, a public spelling — does the
constructor cross with the name? Run the saved version from `content/learn`:

<!-- diagnostic: src/02-constructing.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en opaque-types/src/02-constructing.ash
The constructor `Score` belongs to an opaque type and is not accessible here.
  --> /path/to/ash-doc/content/learn/opaque-types/src/02-constructing.ash:4:11
4 | main () = Score(42)
  |           ^ This name is not accessible here.
  --> /path/to/ash-doc/content/learn/opaque-types/src/score.ash:1:25
1 | pub opaque type Score = Score(Int)
  |                         ^ The inaccessible declaration is here.
reason: resolve.opaque-constructor
```
<!-- markdownlint-enable MD013 -->

The import succeeded and the signature `main : Unit -> Score` is accepted;
the refusal lands one line lower, on the term `Score(42)`. The first label
marks that term — "This name is not accessible here." The second label leads
into `score.ash`, and its column lands on the constructor after the `=`,
not on the type name earlier in the line: the declaration the client cannot
reach is the constructor, which `opaque` withholds.

The reason line also distinguishes this refusal from the previous lesson's.
Naming a private spelling in an import list refused the import itself, with
`resolve.unavailable-export`: that spelling never crossed. Here the type
name did cross, and `resolve.opaque-constructor` refuses the constructor
itself. A constructor can appear in a pattern as well;
the exercise below asks whether the boundary answers differently there.

> **With a learning assistant:** Show the assistant both source files and
> the complete diagnostic. Ask it to point to the label that refused the
> spelling and to the exact declaration the second label marks inside
> `score.ash`, then to explain why the import line itself was accepted —
> before suggesting any change.

## Changing what a value contains

The provider's side of the boundary can move without disturbing the client's.
Suppose the provider learns that the tally must also count how many times
`add` ran — say, to report an average later. The representation grows a
second integer, while every spelling the client named stays as it was. In a
fresh copy of the program, the provider becomes:

<!-- source: src/variant/score.ash -->
```ash
pub opaque type Score = Score(Int, Int)

pub make : Int -> Score
make points = Score(points, 0)

pub add : Score -> Int -> Score
add (Score(points, additions)) extra = Score(points + extra, additions + 1)

pub total : Score -> Int
total (Score(points, _)) = points
```

Inside the module, construction and matching follow the new definition;
`add` now carries a running count of additions. Outside, nothing about the
client changes: same import list, same annotation, same calls. The client
beside the revised provider is the earlier file, byte for byte, and it
still reports `15 : Int`.

Because the client never wrote the constructor, the new field has no
spelling to break; only the provider's own equations mention what a `Score`
contains. Had the type been declared with plain `pub type`, its constructors
would be public spellings too, and every client that built or matched
values through them would have to change with the representation.

## Exercise: grow the provider

Start from fresh copies of `src/score.ash` and `src/01-main.ash` beside each
other in your scratch directory.

1. The provider next offers `scale : Score -> Int -> Score`, which
   multiplies the stored points by the given integer. Add it to the
   provider, building the result with the provider's own constructor as
   `add` does, and keep the other functions unchanged. Then, in the client,
   scale `make 10` by `3` and read its total; predict the value and type,
   then run.
2. In a fresh client that imports `(Score, total)`, attempt the
   construction twice: once in a term, as the rejected program above does,
   and once in a match pattern. Predict whether the two refusals name the
   same reason, run both, and explain each capture's labels in your own
   words.

## The name crosses, the constructors stay

Three channels for moving names across a boundary are now known: a complete
import, a targeted import, and a public re-export. One visibility rule
decides what a moved name carries with it — a type name can cross without
its constructors. The provider owns how values of its type are built; its
clients own what they do with them. The [libraries path] develops the full
provider discipline this enables, and the Cases path protects an ordered
dictionary the same way at larger scale in
[Protecting the dictionary invariant][dictionary-case].

One question remains on this path: which local bindings can be reused across
different types, and which hold one chosen function value? The next chapter
develops it. Continue with
[Generalizing local functions](../generalizing-local-functions/README.md).

[dictionary-case]: ../../cases/protecting-dictionary-invariant/README.md
[libraries path]: ../../libraries/README.md
[visibility-rules]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#public-private-and-opaque-declarations
