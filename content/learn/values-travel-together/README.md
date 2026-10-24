---
diagrams:
  - kind: illustration
    id: fig-sum-pair
    caption: "sum_pair : (Int, Int) -> Int — one pair input, one integer result."
    description: Two adjoining squares share one outer contour for a pair input. An interior seam distinguishes its two Int parts. An arrow leads to one separate Int result square. All three squares use the same type color.
  - kind: illustration
    id: fig-add-inputs
    caption: "add : Int -> Int -> Int — separate integer inputs, one integer result."
    description: Three separate blue Int squares show the first input, second input, and result in signature order. Arrows between adjacent squares follow the signature; they do not show conversions between integer values.
---

# Making values travel together

A `let` binding gives one value a local name. That value may be the result of a
long calculation, but it is still passed and returned as a unit. Sometimes two
values describe one piece of information: a number and whether it is ready, or
the two numbers at the ends of an interval. We want to keep the parts together
without losing their individual types.

A *tuple* is one value made from a fixed number of other values. Its type is
a *product type*, because the parts are present together rather than chosen
between. Its commas are important. They show where one part ends and the next
begins, both in the value and in its type.

## Making a pair

The smallest tuple with several parts is a pair:

<!-- source: src/01-pair.ash -->
```ash
main : Unit -> (Int, Bool)
main () = (42, true)
```

The expression puts two values into one pair. Predict its part order and
the corresponding type order, then run the program:

```text
(42, true) : (Int, Bool)
```

The integer appears first and the Boolean second, giving type `(Int, Bool)`.
The pair is not an integer followed by a separate Boolean result. It is one
result with two parts. If we exchanged the parts, the type would also change to
`(Bool, Int)`.

Parentheses alone already grouped arithmetic and function arguments in earlier
lessons. The comma is what makes this expression a tuple. Thus `(42)` is still
the integer `42`, while `(42, true)` is a pair.

## Receiving one pair

A function can receive a tuple as one input. Its parameter pattern names the
parts:

<!-- source: src/02-pair-input.ash -->
```ash
sum_pair : (Int, Int) -> Int
sum_pair (left, right) = left + right

main : Unit -> Int
main () = sum_pair (20, 22)
```

The signature has one arrow. `sum_pair` receives one `(Int, Int)` value and
produces an `Int`. The pattern `(left, right)` has the same shape as that
input. Predict what each name binds and what their addition produces.
Running confirms `42 : Int`; the pattern assigns the parts in order:

```text
sum_pair (20, 22)
20 + 22
42
```

This differs from the earlier function `add : Int -> Int -> Int`, defined
in the [multiple-inputs lesson](../using-more-than-one-input/README.md). `add`
receives one integer and then another; `sum_pair` receives one pair. Both can
perform the same addition, but their inputs have different shapes and their
signatures say so. Compare the complete calls with what remains after the
[first input][application]:

::: {#note-input-shapes .column-margin}

```{#fig-sum-pair .illustration}
Show sum_pair receiving one pair containing two Int slots and producing one
Int slot. Follow the solid type-square style in the "Using more than one input"
lesson. Attach the pair's two squares along one edge, then draw an arrow to a
separate result square. Use the same color for all three Int slots.

A continuously connected shape represents one slot, which may contain other
slots. The internal seam distinguishes the pair's component slots. Show type
shape, without implying a physical memory layout or mutation.
Put the function signature in the figure caption, not inside the artwork.
Use labels large enough for the margin aside; abbreviate the lower labels to
pair input and result.
```

```{#fig-add-inputs .illustration}
Show the literal add : Int -> Int -> Int signature as three separate blue
Int squares with arrows between adjacent squares. Match the square size,
Int color, and arrow style of fig-sum-pair. Label the positions first input,
second input, and result. Do not join the inputs or enclose the remaining
function. Put the signature in the caption, outside the artwork.
The arrows follow the type signature, not conversions between integer values.
Use labels large enough for the margin aside; abbreviate the lower labels to
first, second, and result.
```

:::

| Comparison | `add` | `sum_pair` |
| --- | --- | --- |
| Type | `Int -> Int -> Int` | `(Int, Int) -> Int` |
| Full call | `add 20 22` | `sum_pair (20, 22)` |
| First supplied value | `20 : Int` | `(20, 22) : (Int, Int)` |
| Result after one input | Function of type `Int -> Int` | `42 : Int` |

The curried `add` can pause after receiving `20`; its second integer arrives
in a later call. The one input to `sum_pair` contains both integers, so that
call produces their sum. This follows from these two signatures.

`sum_pair(20, 22)` is [the same call][call-syntax] as `sum_pair (20, 22)`.
The space before `(` is optional. The comma inside the parentheses makes
`(20, 22)` one pair argument containing two parts.

## Naming the parts inside a block

Tuple patterns also work in the `let` bindings from the preceding lesson:

<!-- source: src/03-local-pattern.ash -->
```ash
main : Unit -> Int
main () = {
    let pair = (20, 22)
    let (left, right) = pair
    left + right
}
```

The first binding gives the whole pair one name. The second binding takes that
value apart by matching its shape. Afterward, the rest of the block can use
`left` and `right` separately.

Predict the two part bindings and the final sum before running. The program
reports `42 : Int`. Trace how the whole pair supplies the separate names:

```text
pair  = (20, 22)
left  = 20
right = 22
left + right = 42
```

Constructing a tuple brings values together. A tuple pattern gives its parts
names. Neither operation changes the parts themselves.

## Shape is part of the type

A tuple always has a fixed number of parts. A triple is therefore not a pair,
even when every part has the same type:

<!-- source: src/04-triple-is-not-a-pair.ash -->
```ash
sum_pair : (Int, Int) -> Int
sum_pair (left, right) = left + right

main : Unit -> Int
main () = sum_pair (20, 21, 22)
```

Count the parts in the supplied value and in `sum_pair`'s input type.
Does the one tuple argument have the required shape? Run from `content/learn`:

<!-- diagnostic: src/04-triple-is-not-a-pair.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en values-travel-together/src/04-triple-is-not-a-pair.ash
This function argument must have type `(Int, Int)`, but has type `(Int, Int, Int)`.
  --> /path/to/ash-doc/content/learn/values-travel-together/src/04-triple-is-not-a-pair.ash:5:20
5 | main () = sum_pair (20, 21, 22)
  |                    ^ This has type `(Int, Int, Int)`.
  --> /path/to/ash-doc/content/learn/values-travel-together/src/04-triple-is-not-a-pair.ash:1:12
1 | sum_pair : (Int, Int) -> Int
  |            ^ This function requires an argument of type `(Int, Int)`.
  --> /path/to/ash-doc/content/learn/values-travel-together/src/04-triple-is-not-a-pair.ash:5:11
5 | main () = sum_pair (20, 21, 22)
  |           ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The first label identifies the triple, and the signature label identifies the
pair required by `sum_pair`. There is no missing second call and no extra
curried input. The one input has the wrong tuple shape. Supplying `(20, 22)`
restores the two-part input and produces `42 : Int`.

## Exercise: keep two results

Start from a fresh copy of `src/02-pair-input.ash` in your scratch directory.

Give one pair of integers to a function that answers with two results at once:

```text
sum_and_product : (Int, Int) -> (Int, Int)
```

Its result pair should hold the input's sum and product. In `main`, use a
local tuple pattern to name those two results and add them.

With `(6, 7)` as the input, predict the pair the function produces and the
integer `main` reports, accounting for the type of each intermediate value
before you run the program.

## One value, several parts

A tuple is one value with a fixed set of parts, and its type records their
number, order, and types. A pattern of the same shape gives those parts names,
in a definition or a local binding alike.

Tuples suit combinations chosen at the point of use. A program also needs data
whose names say what a value means and which forms it may take; the next
lesson defines such data.

[application]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#functions-and-application
[call-syntax]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#precedence-and-associativity
