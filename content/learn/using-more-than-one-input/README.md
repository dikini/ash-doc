---
diagrams:
  - kind: illustration
    id: fig-add-types
    width: 49.563mm
    caption: Curried function.
    description: "The signature add : Int -> Int -> Int aligns with a red function box and three blue boxes for the integer positions."
  - kind: illustration
    id: fig-add-type-value
    width: 49.563mm
    caption: Function application.
    description: The same signature appears above split boxes. Upper halves show types, red for the function and blue for Int. Lower halves distinguish add, 20, 22, and result 42 by color, with labels beneath. Arrows in the lower row are schematic application guides, not conversions between integers.
  - kind: illustration
    id: fig-add-20-application
    width: 37.375mm
    caption: Partial application.
    description: Applying add to 20 produces the function add_20 of type Int -> Int. Its separate function square has a red type half and an orange value half labelled add 20. The input 22 and result 42 have blue type halves and violet and green value halves. The value row labels the function add_20.
---

# Using more than one input

Our functions have received one value at a time. `double` received one number;
`Arithmetic.answer` received `()`. Many calculations need more information. To
add two numbers, for example, a function must receive both of them.

Ash does not require a new kind of call for this. We can use a technique called
*currying*. A function receives the first input and leaves a function ready to
receive the second.
Supplying both inputs in one line is the same process written without a pause.
We can see the two steps by starting with a complete call and then stopping
halfway through it.

## Supplying two inputs

Here is a function that adds two integers:

<!-- source: src/01-two-inputs.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int
main () = add 20 22
```

The definition names two parameters, `left` and `right`. In the call
`add 20 22`, the inputs line up with those parameters from left to right.
Predict the value, then save and run the program. Ash reports:

```text
42 : Int
```

The substitution accounts for that result:

```text
add 20 22
20 + 22
42
```

The signature tells the same story as the definition. Function arrows
[group from the right][arrows] — the arrow is *right-associative* — so we read

```text
Int -> Int -> Int
```

as

```text
Int -> (Int -> Int)
```

The first `Int` is the first input. After that input arrives, what remains has
the type `Int -> Int`: a function waiting for the second input. When the second
`Int` arrives, the calculation produces the final `Int`.

## Pausing after the first input

To make that middle step visible, remove `22` from the call. Since `main` now
produces a function, its result type must change as well:

<!-- source: src/02-one-input-left.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int -> Int
main () = add 20
```

Before running, count the inputs still needed. `add` has received `20` for
`left`; what remains to receive `right`, and what type does it have?
Run the program to compare that prediction:

```text
<function> : Int -> Int
```

No second integer has arrived, so the result is a function of type
`Int -> Int`. The tool displays the function as `<function>`; that display
does not show its body. Such a call is called a *partial call*, or
*partial application*: it supplies some, but not all, of a
function's inputs. The result is still useful. It remembers the input already
supplied and can receive the rest later.

Three margin figures show the same progression visually: the signature
against its boxes, types layered over values in the complete call, and the
partial call followed from `add 20` through `add_20` to `42`.

::: {#note-add-one-input .column-margin}

::: {.block}

```{#fig-add-types .illustration}
Align add : Int -> Int -> Int with a red function square and three blue
integer squares. Show the schematic application guide from the second integer
input to the result. Preserve the solid type-square vocabulary, not a value
conversion. Use shared aside-size squares, rough strokes, and Excalifont labels.
```

```{#fig-add-type-value .illustration}
Keep the signature alignment and four square positions of the type-only
figure. Split each square horizontally: the upper half shows the function
or Int type; the lower half identifies add, 20, 22, or 42 with its color and
label. Preserve the application guide and shared aside square size. Use rough
strokes and Excalifont; do not imply that arrows convert integer values.
```

```{#fig-add-20-application .illustration}
Show add with 20 in the upper row, then a downward transition to the waiting
function add_20 with input 22 and result 42. Preserve type/value halves:
function types red, Int types blue, add_20 orange, 22 violet, and 42 green.
Align add_20 : Int -> Int over the lower row. Keep its application guide
distinct from the between-row arrow. Match square size to the other aside
figures, not the width of this shorter row. Use rough strokes and Excalifont.
```

:::

:::

We can name the waiting function and use it in the next line:

<!-- source: src/03-reuse-a-partial-call.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int
main () = {
    let add_20 = add 20
    add_20 22
}
```

The braces collect these lines into one *block*; its last line gives the
block's value. The binding `let add_20 = add 20` gives the waiting function
the name `add_20`. It remembers `20` and has type `Int -> Int`. The next
line supplies `22` as its remaining input. Predict the result, then run the
program and compare Ash's `42 : Int` with these steps:

```text
add_20 22
add 20 22
20 + 22
42
```

## Exercise: multiply three numbers

Start from a fresh copy of `src/01-two-inputs.ash` in your scratch directory,
and build a three-input multiplication with this signature:

```text
multiply_three : Int -> Int -> Int -> Int
```

Then try three calls in `main`, one at a time: supply every input and predict
the integer; supply only two and predict the waiting function's type; give
that function its final input and check the result. Use the arrows in the
signature to account for every input and every result.

## From inputs to decisions

Several inputs change nothing about how a call reads: each value arrives from
the left, each arrow says what remains, and a complete call reaches the final
result. A partial call simply stops earlier, leaving a function that is still
waiting.

Every calculation so far has followed one fixed route. What happens when the
program must examine a value and choose the route?

[arrows]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#precedence-and-associativity
