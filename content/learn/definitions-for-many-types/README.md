# How can one definition work with many types?

Several definitions in this path have depended on integers. `IntList` contains
integers, and `apply_twice` accepts an `Int -> Int` function. Yet some of their
structure does not depend on what the values are. Returning an input unchanged
requires no knowledge of its type. Keeping values in a list requires no
knowledge of how those values are calculated.

A *type parameter* gives a name to such an unspecified type. The definition
must then work in the same way for every type that may replace the parameter.
We will begin with a function whose entire job is to preserve its input.

## One function, different uses

The identity function returns the value it receives:

<!-- source: src/01-identity.ash -->
```ash
identity : A -> A
identity value = value

main : Unit -> (Int, Bool)
main () = (identity 42, identity true)
```

The uppercase name `A` in the signature is a type parameter. Read `A -> A` as
“takes a value of some type and returns a value of that same type.” Nothing in
the body assumes that the value is an integer, a Boolean, or any other
particular type.

At the first call, `A` is `Int`, so `identity 42` has type `Int`. At the second
call, `A` is `Bool`, so `identity true` has type `Bool`. Ash determines those
choices from the calls; the source expression does not supply type arguments.

Running the program reports:

```text
(42, true) : (Int, Bool)
```

There is still only one `identity` definition. Each use replaces `A`
consistently through its signature.

## Data with an element type

A data definition writes its type parameters between angle brackets. Here a
box may contain one value of any type:

<!-- source: src/02-box.ash -->
```ash
type Box<A> = Box(A)

main : Unit -> (Box<Int>, Box<Bool>)
main () = (Box(42), Box(false))
```

In `Box<A>`, `A` names the type of the constructor's field. Replacing `A` with
`Int` gives `Box<Int>`, whose constructor carries an integer. Replacing it with
`Bool` gives `Box<Bool>`, whose constructor carries a Boolean.

The constructor expressions make those replacements visible:

```text
Box(42)     : Box<Int>
Box(false)  : Box<Bool>
```

The two values share the `Box` shape, but their complete types remain
different. A function that accepts `Box<Int>` cannot therefore be given a
`Box<Bool>` by accident.

## A list that leaves its elements open

We can now remove the integer-specific part of `IntList`. The recursive shape
stays the same; a parameter names the element type:

<!-- source: src/lists.ash -->
```ash
pub type List<A> =
    Empty
    | More(A, List<A>)

pub map : (A -> B) -> List<A> -> List<B>
map transform Empty = Empty
map transform More(first, rest) = More(transform first, map transform rest)
```

This source file defines `List<A>` in the same way that `IntList` was defined:
the list is either empty or contains a first element followed by another list.
The difference is that the first field has type `A`, and the rest must be a
list with that same element type.

The function `map` introduces two type parameters. Its signature says:

1. receive a function from `A` to `B`;
2. receive a list whose elements have type `A`; and
3. produce a list whose elements have type `B`.

The equations follow the data definition. Mapping over `Empty` produces
`Empty`. For `More`, the supplied function transforms `first`, while the
recursive call transforms the `rest`. The result constructor combines those
two pieces as a `List<B>`.

Neither equation needs to know what `A` and `B` are. It can construct and
follow the list, and it can call `transform`, but only the supplied function
knows how one element becomes another.

Both the type and the function are public because another source file will use
them:

<!-- source: src/03-list-main.ash -->
```ash
import lists as Lists

main : Unit -> Lists.List<Int>
main () = Lists.map (fn(number) {
    number + 1
}) (Lists.More(41, Lists.Empty))
```

The import and qualified names follow the module boundary from the second
lesson. Here `A` and `B` are both `Int`: the anonymous function transforms an
integer into an integer, and the input list contains `41`.

Follow the two equations:

```text
Lists.map increment (Lists.More(41, Lists.Empty))
Lists.More(increment 41, Lists.map increment Lists.Empty)
Lists.More(42, Lists.Empty)
```

The name `increment` in this trace stands for the anonymous function in the
program. Running the source file reports:

```text
More(42, Empty) : List<Int>
```

This one example brings together the beginning path: a module exports data and
a function; the data is recursive; the function follows its forms; and another
function value determines how each element changes.

> **With a learning assistant:** Before changing `map`, draw the input and
> output list values as nested `More` and `Empty` forms. Ask the assistant to
> check whether each recursive call follows a smaller `rest`, and whether every
> occurrence of `A` and `B` in the signature agrees with your two lists.

## Supplying every type parameter

`List` by itself does not say what type its elements have. Every use of the
type must supply the one argument declared by `List<A>`:

<!-- source: src/04-unsaturated-list.ash -->
```ash
type List<A> =
    Empty
    | More(A, List<A>)

keep : List -> List
keep list = list

main : Unit -> List<Int>
main () = keep Empty
```

The signature of `keep` uses bare `List`, even though the data definition
requires one type argument. Ash rejects the source with:

```text
resolve.type-argument-count
```

Writing `keep : List<Int> -> List<Int>` would make this particular function
integer-specific. Writing `keep : List<A> -> List<A>` would let the unchanged
structure work for any element type, like `identity` and `map`.

## Exercise: change the element type

Keep the `lists.ash` module unchanged. In the entry source, define:

```text
is_42 : Int -> Bool
is_42 number = number == 42
```

Map `is_42` over a two-element `List<Int>`. Before running the program:

1. decide which types replace `A` and `B` in `map`;
2. construct the expected `List<Bool>` value; and
3. trace one `map` call for each `More` layer and one for `Empty`.

Then change the integer elements so that one produces `true` and the other
produces `false`. The list shape should remain unchanged while its element type
and values change.

## The beginning model

A parameterized definition names the types it does not need to fix. Each use
supplies consistent types for those parameters, while the definition follows
the same structure. This form of reuse is called *parametric polymorphism*.

We can now give a fuller answer to the question that began this path. An Ash
program is a group of source modules containing definitions. Its expressions
produce values; its functions connect calculations; its data definitions name
the possible shapes of values; and its patterns guide functions over those
shapes. Evaluation begins with `main ()`, and the command-line tool reports the
resulting value and type.

The examples have grown from one integer expression to a public, recursive
list transformation without changing that central model: definitions describe
expressions, and expressions calculate values.
