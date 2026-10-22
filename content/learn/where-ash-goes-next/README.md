# Where Ash goes next

One model carried this path from its first file to its last: definitions
describe expressions, and expressions calculate values. The programs grew
from a single expression to recursive data, module boundaries, and text,
and the model stayed put through every lesson.

Ash has features this path never needed, and three of them are worth
meeting before you leave it. Each extends the model rather than replacing
it, and each belongs to a path that continues after this one. This closing
lesson shows all three working in small programs you can run. None asks
you to learn its machinery; each asks you to recognize the shape and
follow the pointer to the path that develops it.

## Behavior a definition states

[Definitions for many types](../definitions-for-many-types/README.md)
closed with a promise. Parametric polymorphism fixes one definition for
every type; the other principal form, *ad-hoc polymorphism*, gives one
operation different implementations for different types. Ash provides
that form through interfaces, and `01-twice.ash` shows the whole
mechanism at once:

<!-- source: src/01-twice.ash -->
```ash
interface Twice<A> {
    double : A -> (A, A)
}

impl Twice<Int> {
    double value = (value, value)
}

replicate : A -> (A, A) where Twice<A>
replicate item = double item

main : Unit -> (Int, Int)
main () = replicate 21
```

`Twice<A>` names a capability: for a type `A`, a value can be doubled
into a pair. The implementation supplies that capability for `Int`. The
signature of `replicate` records its need in `where Twice<A>`, and its
body calls `double` as an ordinary function. When `main` calls
`replicate 21`, checking fixes `A` to `Int`, and the implementation for
`Int` answers. These are the [interface and implementation forms][forms]
the checker verifies.

Predict the displayed pair before running. From this lesson's `src`
directory:

```text
$ ash 01-twice.ash
(21, 21) : (Int, Int)
```

The need was stated in the signature and satisfied without passing the
behavior as an argument. The [libraries path](../../libraries/README.md)
develops interfaces and their implementation evidence, starting from this
shape in
[choosing implementation evidence](../../libraries/choosing-implementation-evidence/README.md).

## A value a handler supplies

Sometimes a calculation needs a value it should not choose for itself.
An *effect* declares the request; a surrounding *handler* answers it.
`02-scale-price.ash` requests the scale factor for a price:

<!-- source: src/02-scale-price.ash -->
```ash
effect Scale {
    by : Int -> Int
}

price : Int -> Int ! {Scale}
price base = perform Scale.by base

main : Unit -> Int
main () = handle (price 20) with Scale {
    by factor => resume (factor * 3)
}
```

The declaration `effect Scale` names one operation, `by : Int -> Int`.
Inside `price`, `perform Scale.by base` makes the request, and the
signature's `! {Scale}` records the outstanding need as part of the
calculation's contract. The [effect rules][effects] and [row
notation][rows] describe both parts. The handler's clause binds the
requested integer as `factor` and answers with `resume (factor * 3)`,
which supplies the value and continues the waiting calculation.

Follow the request and work out the multiplication before running, again
from this lesson's `src` directory:

```text
$ ash 02-scale-price.ash
60 : Int
```

`price` never chooses a factor; the handler does. The
[effects path](../../effects/README.md) builds its opening chapter,
[requesting a value](../../effects/requesting-a-value/README.md), around
this exchange.

## A cell a scope owns

The third feature gives one scope an owned place to hold an integer
while a calculation runs. `03-cell-tally.ash` acquires such a cell,
replaces its contents, and reads them back:

<!-- source: src/03-cell-tally.ash -->
```ash
import @builtin.cell as Cell

main : Unit -> Int
main () = resource cell<R> tally = 0 {
    let ignored = Cell.write (tally, 7)
    Cell.read tally
}
```

`import @builtin.cell as Cell` makes the compiler-owned cell operations
available under the alias `Cell`. The `resource cell<R> tally = 0 { ... }`
form acquires a cell holding `0` and runs its body with `tally` naming
the cell; the scope owns the cell's release when the body finishes.
`Cell.write` replaces the cell's integer, and `Cell.read` copies the
current one out. The [cell rules][cells] describe the acquisition and
its owned scope.

Predict the copied integer, then run from this lesson's `src` directory:

```text
$ ash 03-cell-tally.ash
7 : Int
```

The write replaced the initial `0` before the read, so the body returns
`7`. The effects path develops scoped cells after its handler chapters,
in [counting with a cell](../../effects/counting-with-a-cell/README.md).

## Practice: choose a different answer

Make a fresh copy of `02-scale-price.ash` in a scratch directory outside
this lesson's `src` tree, and run the copy from there. Change the
handler's clause so it answers with the requested factor plus ten rather
than the factor times three. Predict the program's result before running
your copy, then identify which line chooses the answer and which line
only requests it.

Nothing in these programs breaks the path's model. An interface states a
need in a signature; an effect states a need in a row; a resource scope
owns a cell while expressions calculate values inside it. The three
features extend the model rather than replace it, and the
[libraries path](../../libraries/README.md) and the
[effects path](../../effects/README.md) develop them in order, each
building on this path's definitions, signatures, and runs.

Good luck in the paths ahead, and predict before you run.

[forms]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#interfaces-and-constrained-schemes
[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[rows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#computation-types-and-effect-rows
[cells]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-cells-and-resource-dependencies
