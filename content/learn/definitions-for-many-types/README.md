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

For each call, identify the type replacing `A` and use it consistently for
the input and result. Predict the pair's value and type before running:

```text
(42, true) : (Int, Bool)
```

The first call chooses `Int`, and the second chooses `Bool`. Ash determines
those choices from the calls; the source expression does not supply type
arguments. There is still one `identity` definition, with a consistent
substitution at each use.

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

Predict the complete type of each constructor expression before running the
program. These two fields account for the tuple it reports:

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

Because `pub type List<A>` makes the type and all its constructors public, the
import makes `Lists.More` and `Lists.Empty` available through the alias
`Lists`.

The import and qualified names follow the module boundary from the second
lesson. Use the input list and the transformation's type to choose `A` and
`B`. Then predict the output list by following one `More` case and its
`Empty` rest. Run the entry beside `lists.ash`; it reports:

```text
More(42, Empty) : List<Int>
```

Both parameters are `Int` here. The transformation produces `42` from
`41`, while the recursive call preserves the empty tail:

```text
Lists.map increment (Lists.More(41, Lists.Empty))
Lists.More(increment 41, Lists.map increment Lists.Empty)
Lists.More(42, Lists.Empty)
```

The name `increment` in this trace stands for the anonymous function in the
program.

This one example brings together the beginning path: a module exports data and
a function; the data is recursive; the function follows its forms; and another
function value determines how each element changes.

> **With a learning assistant:** Draw the input and output list values from the
> program above as nested `More` and `Empty` forms. First trace and explain how
> each recursive call follows a smaller `rest`; ask the assistant to question
> that explanation one step at a time. After you finish the recursion trace,
> examine one occurrence of `A` or `B` at a time and ask the assistant to check
> it against your two lists.

## When a complete type is required

`List` by itself does not yet describe the type of a value. It is a *type
constructor*: applying it to an element type constructs a complete list type.
Ash describes what a type-level name still needs with a *kind*. `List` has kind
`Type -> Type` because it needs one type of kind `Type`; after that application,
`List<Int>` has kind `Type`.

Bare and partially applied type constructors are valid where the surrounding
declaration accepts the remaining function kind. An ordinary function
parameter or result position instead requires a type of kind `Type`. That
distinction explains why this signature is rejected:

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

What kind does `List` have before receiving an element type, and what kind
does each ordinary input and result position require? Run this version from
`content/learn` to compare that mismatch with the labels:

<!-- diagnostic: src/04-unsaturated-list.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en definitions-for-many-types/src/04-unsaturated-list.ash
This position requires a complete value type (kind `Type`), but has kind `Type -> Type`.
  --> /path/to/ash-doc/content/learn/definitions-for-many-types/src/04-unsaturated-list.ash:5:8
5 | keep : List -> List
  |        ^ Found kind `Type -> Type` here.
  --> /path/to/ash-doc/content/learn/definitions-for-many-types/src/04-unsaturated-list.ash:1:1
1 | type List<A> =
  | ^ This declaration fixes the kind as `Type -> Type`.
2 |     Empty
  | ^ This declaration fixes the kind as `Type -> Type`.
3 |     | More(A, List<A>)
  | ^ This declaration fixes the kind as `Type -> Type`.
reason: kind.expected-type
```
<!-- markdownlint-enable MD013 -->

The message marks the first bare `List` in `keep` and relates its function kind
to the declaration `type List<A>`. The parameter position needs a complete
value type; applying `List` to an element type supplies one. The
[kind rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#kinds-monotypes-and-schemes)
derive both kinds and require ordinary function domains and results to have
kind `Type`.

Writing `keep : List<Int> -> List<Int>` would make this particular function
integer-specific. Writing `keep : List<A> -> List<A>` would let the unchanged
structure work for any element type, like `identity` and `map`.

## Exercise: change the element type

Start with fresh copies of `src/lists.ash` and `src/03-list-main.ash` beside
each other in your scratch directory. Keep the module unchanged. In the entry,
define:

```text
is_42 : Int -> Bool
is_42 number = number == 42
```

Map `is_42` over a two-element `List<Int>` and update `main`'s result type
to describe that transformation. Before running the program:

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

The next chapter asks which local function bindings can retain this reuse
across different input types, and which bindings hold one chosen function
value. Continue with
[local generalization](../generalizing-local-functions/README.md).
