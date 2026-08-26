# How can a function use more than one input?

Our functions have received one value at a time. `double` received one number;
`Arithmetic.answer` received `()`. Many calculations need more information. To
add two numbers, for example, a function must receive both of them.

Ash does not require a new kind of call for this. A function receives the first
input and leaves a function ready to receive the second. Supplying both inputs
in one line is the same process written without a pause. We can see the two
steps by starting with a complete call and then stopping halfway through it.

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
`add 20 22`, the inputs line up with those parameters from left to right:

```text
add 20 22
20 + 22
42
```

Save the program and run it. Ash reports:

```text
42 : Int
```

The signature tells the same story as the definition. Function arrows group
from the right, so we read

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

Before running the program, notice what is missing. `add` has received `20` for
`left`, but it has received nothing for `right`. There is no integer result to
report yet. Ash instead reports the waiting function and its type:

```text
<function> : Int -> Int
```

Such a call is often called a *partial call*: it supplies some, but not all, of
a function's inputs. The result is still useful. It remembers the input already
supplied and can receive the rest later.

We can give the waiting calculation a descriptive name:

<!-- source: src/03-reuse-a-partial-call.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

add_twenty : Int -> Int
add_twenty number = add 20 number

main : Unit -> Int
main () = add_twenty 22
```

Read the body of `add_twenty` from left to right. `add 20` first produces a
function that remembers `20`. The remaining `number` is then supplied to that
function. With `22` as the input, the calculation becomes:

```text
add_twenty 22
add 20 22
20 + 22
42
```

Run the program and compare Ash's `42 : Int` with these steps.

## Each input keeps its type

Pausing partway through a call does not loosen what the function accepts. After
`add 20`, the waiting function still requires an `Int`. Replace the second
number with `true`:

<!-- source: src/04-wrong-input.ash -->
```ash
add : Int -> Int -> Int
add left right = left + right

main : Unit -> Int
main () = add 20 true
```

Ash rejects the program with a message whose first line is:

```text
type.argument
```

The first call step is sound: `20` is an `Int`. The next step tries to give the
waiting `Int -> Int` function a `Bool`. The signature lets us locate the
mistake before any addition can take place.

## Exercise: multiply three numbers

Define a function with this signature:

```text
multiply_three : Int -> Int -> Int -> Int
```

Give the definition three parameters and multiply them. Then try these in
`main`, one at a time:

1. Supply all three inputs and predict the integer result.
2. Supply two inputs and predict the type of the waiting function.
3. Give the waiting function its final input and check the result.

Use the arrows in the signature to account for every input and every result.

## From inputs to decisions

A function can therefore use several inputs without packing them together.
Each call supplies one value from the left, and each arrow tells us what remains
after that value arrives. A complete call reaches the final result; a partial
call produces a function that is still waiting.

All the calculations so far have followed one fixed route. The next question
is how a program can examine a value and choose which expression should
produce its result.
