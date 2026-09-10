# How can several values travel together?

A `let` binding gives one value a local name. That value may be the result of a
long calculation, but it is still passed and returned as a unit. Sometimes two
values describe one piece of information: a number and whether it is ready, or
the two numbers at the ends of an interval. We want to keep the parts together
without losing their individual types.

A *tuple* is one value made from a fixed number of other values. Its commas are
important. They show where one part ends and the next begins, both in the value
and in its type.

## Making a pair

The smallest tuple with several parts is a pair:

<!-- source: src/01-pair.ash -->
```ash
main : Unit -> (Int, Bool)
main () = (42, true)
```

The expression `(42, true)` puts an `Int` beside a `Bool`. Its type records the
same order, `(Int, Bool)`. Running the program shows both:

```text
(42, true) : (Int, Bool)
```

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
produces an `Int`. The pattern `(left, right)` has the same shape as that input,
so `left` stands for `20` and `right` stands for `22`:

```text
sum_pair (20, 22)
20 + 22
42
```

This differs from the earlier function `add : Int -> Int -> Int`. `add`
receives one integer and then another; `sum_pair` receives one pair. Both can
perform the same addition, but their inputs have different shapes and their
signatures say so.

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

Run the program and trace the bindings in order:

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

The call supplies one value of type `(Int, Int, Int)`, but `sum_pair` requires
one value of type `(Int, Int)`. Run this version from `content/learn`:

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
restores the two-field input and produces `42 : Int`.

## Exercise: keep two results

Define this function:

```text
sum_and_product : (Int, Int) -> (Int, Int)
```

Its input is a pair of integers. Its result should be another pair containing
the input's sum and product. Then use a local tuple pattern in `main` to name
the two results and add them.

With `(6, 7)` as the input, predict the pair that `sum_and_product` produces and
the integer that `main` reports. Account for the type of each intermediate
value before running the program.

## One value, several parts

A tuple keeps a fixed collection of values together. The tuple's type records
the number, order, and type of its parts. A pattern with the same shape gives
those parts names, whether it appears in a function definition or a local
binding.

Tuples describe combinations chosen at the point of use. Programs also need
data with names that express what a value means and which forms it may take.
The next lesson shows how an Ash program defines such data for itself.
