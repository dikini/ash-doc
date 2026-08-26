# How can a function itself be a value?

In the lesson on several inputs, the partial call `add 20` produced a function.
That function could wait for another integer because functions are values in
Ash. Like other values, a function can be given as an input, produced as a
result, and associated with a name.

This lets one function describe *when* another calculation should be used. We
will begin with a named function, then remove the name, and finally construct a
function that remembers an earlier input.

## Giving a function as an input

Suppose we want to apply the same integer transformation two times:

<!-- source: src/01-named-function.ash -->
```ash
increment : Int -> Int
increment number = number + 1

apply_twice : (Int -> Int) -> Int -> Int
apply_twice transform number = transform (transform number)

main : Unit -> Int
main () = apply_twice increment 40
```

The first input to `apply_twice` has type `Int -> Int`. The parentheses in
`(Int -> Int) -> Int -> Int` keep that whole function type together. After
receiving such a function, `apply_twice` receives an integer and produces an
integer.

In the body, `transform` stands for the function supplied by the call. Since
`main` supplies `increment`, the calculation becomes:

```text
apply_twice increment 40
increment (increment 40)
increment 41
42
```

Run the program. Ash reports `42 : Int`. No special call syntax is needed for
the function parameter; `transform number` works like every named function
call we have written.

## Writing a function where it is needed

If a small function is used in only one place, a separate definition may hide
the calculation rather than clarify it. An *anonymous function* is a function
expression without a source-level name:

<!-- source: src/02-anonymous-function.ash -->
```ash
apply_twice : (Int -> Int) -> Int -> Int
apply_twice transform number = transform (transform number)

main : Unit -> Int
main () = apply_twice (fn(number) {
    number + 1
}) 40
```

Read the expression inside the parentheses as “a function of `number` whose
result is `number + 1`.” Ash knows that `apply_twice` requires an `Int -> Int`,
so the parameter and result are checked as integers.

The anonymous function performs the same calculation as `increment`. Applying
it twice to `40` still produces `42`. The choice between a named and anonymous
function is about explanation: name a function when the name helps the reader
or the calculation is reused; keep a short, local transformation beside its
use when that is clearer.

## Producing a function

A function expression may use a parameter from the surrounding definition.
That use remains available after the surrounding call has produced the new
function:

<!-- source: src/03-remembered-input.ash -->
```ash
make_adder : Int -> Int -> Int
make_adder amount = fn(number) {
    amount + number
}

main : Unit -> Int
main () = make_adder 20 22
```

`make_adder` first receives `amount`. Its result is the anonymous function
`fn(number) { amount + number }`. That function remembers the particular
`amount` from the call that created it.

Trace the call in two stages:

```text
make_adder 20
fn(number) { 20 + number }
```

Supplying the remaining input continues the calculation:

```text
make_adder 20 22
20 + 22
42
```

This is the earlier partial-call idea written out. `make_adder 20` produces an
`Int -> Int`; giving that function `22` produces the final integer.

## A function parameter requires a function

Function types preserve the same boundary as other types. The first input to
`apply_twice` cannot be an integer:

<!-- source: src/04-not-a-function.ash -->
```ash
apply_twice : (Int -> Int) -> Int -> Int
apply_twice transform number = transform (transform number)

main : Unit -> Int
main () = apply_twice 2 40
```

The value `2` has type `Int`, but the first part of the signature requires
`Int -> Int`. Ash rejects the call with a message beginning:

```text
type.argument
```

The function's signature tells us not only how many inputs remain, but whether
one of those inputs must itself be callable.

## Exercise: apply three times

Define:

```text
apply_three_times : (Int -> Int) -> Int -> Int
```

Its body should apply `transform` three times, using the result of each call as
the input to the next. First give it a named `increment` function and the value
`39`. Then replace `increment` with an anonymous function that adds one.

Trace both programs before running them. They should produce the same integer
and make three calls to the supplied function.

## Calculations as data

A function value carries a calculation that can be used later. A function can
receive such a value, call it, or return a new function. An anonymous function
describes the calculation at the expression where it is needed, and it may
remember names from that surrounding expression.

`apply_twice` works only with functions from `Int` to `Int`, even though its
structure does not depend on integers. Our `IntList` similarly repeats a shape
that need not be limited to integer elements. The final lesson asks how one
definition can express that independence from a particular type.
