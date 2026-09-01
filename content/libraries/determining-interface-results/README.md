# How can one interface argument determine another?

The previous lesson used one complete requirement, `Functor<Box>`, while each
`map` occurrence chose its own method-local types. Some interfaces relate two
arguments even when an operation reveals only one of them. A measurement
operation might receive a key type while its implementation fixes a separate
result type that never appears in the method's value type.

Ash can state one forward *determination edge* on an interface. The edge says
which known arguments may determine the remaining arguments before Ash selects
implementation evidence.

## Declare the forward relationship

Put the relation and one implementation in `measurement.ash`:

<!-- source: src/measurement.ash -->
```ash
pub interface Measure<Key, Result> where Key -> Result {
    measure : Key -> Int
}

pub impl Measure<Bool, Unit> {
    measure value = 42
}
```

`Measure` has the complete ordered parameter vector `<Key, Result>`. The
`where Key -> Result` clause partitions it into a nonempty determinant and its
dependent complement. This arrow is a static relationship between interface
arguments, not a function from `Key` values to `Result` values.

Without a determination edge, every interface parameter must occur in each
method type. Here only the determinant `Key` is required. `Result` may be
absent from `measure : Key -> Int` because a source for the known key can fill
it before selection. These conditions come from Ash's
[interface well-formedness rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#interfaces-and-constrained-schemes).

The published implementation is one such source. It records the complete
application `Measure<Bool, Unit>`: the key `Bool` determines the dependent
argument `Unit`.

## Select a source for the known key

The successful client imports the method name and independently selects the
published implementation fact:

<!-- source: src/01-selected.ash -->
```ash
import measurement (measure, impl Measure)

main : Unit -> Int
main () = measure(true)
```

From this lesson's `src` directory, run:

```text
ash 01-selected.ash
```

Ash reports:

```text
42 : Int
```

The argument `true` fixes `Key = Bool` without guessing. The selected source
with that key improves the pending obligation by filling `Result = Unit`.
Ash can then select the complete `Measure<Bool, Unit>` implementation and run
its `measure` method.

The sequence matters:

```text
known Bool key -> determine Unit -> select Measure<Bool, Unit>
```

Determination changes only static evidence checking. It creates no result-type
projection, runtime search, or dynamic mapping from `Bool` to `Unit`. Checked
evidence still
[lowers to ordinary functions and erased type operations](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/elaboration.md#interface-evidence-lowering).

## A known key is not enough by itself

Now leave the same method call and ordinary import in place, but omit the
implementation selector:

<!-- source: src/02-name-only.ash -->
```ash
import measurement (measure)

main : Unit -> Int
main () = measure(true)
```

Run:

```text
ash 02-name-only.ash
```

Ash exits with status `1`, writes no standard output, and begins standard error
with:

```text
constraint.ambiguous
```

The call still fixes the key to `Bool`, but no selected implementation source
is available to determine `Result`. The obligation therefore remains
incomplete when its evidence scope closes. This is `constraint.ambiguous`, not
`constraint.unsatisfied`: Ash has not reached a complete application for which
it could establish that no candidate exists. The
[checked-evidence rules](https://github.com/dikini/ash-lang/blob/d1e323d23390cdad03202ee3df76cd9100556e1d/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
do not invent the dependent type or infer it from an implementation that the
client did not select.

The diagnostic's primary label covers the `measure` occurrence. Its related
labels point to the client's name import, the original method declaration, and
the complete `Measure` interface declaration. Together they retain the path
from the ambiguous call back to the relation that owns its obligation.

## Practice: trace completeness before selection

Work in copies of the accepted sources.

1. Change the implementation key and call argument from `Bool` to `Int`.
   Identify which source occurrence fixes the determinant.
2. Keep the selector but add a second published implementation with the same
   `Bool` key and a different dependent type. Predict why one key must not
   determine two results.
3. Change the method to return `Result`. Explain why the edge still records an
   interface-level invariant even though ordinary result typing may now expose
   the dependent argument.
4. Remove the determination clause. Predict why a method that never mentions
   `Result` is then rejected before evidence selection.

A determination edge lets an inference-free key and an eligible selected
source complete an interface obligation in one forward direction. It does not
make evidence ambient or turn interface arguments into runtime values. This
completes the library-abstraction path; continue with the
[recursive-algorithm Cases](../../cases/README.md) to apply explicit
capabilities while deriving concrete data structures and algorithms.
