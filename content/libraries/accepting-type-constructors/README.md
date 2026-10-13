# How can an abstraction accept a type constructor?

The first two library lessons worked with the completed type `Int` and the
complete requirement `Equal<Int>`. Some abstractions need a different input.
They should work with `Option<Int>`, `Option<Bool>`, and every other application
of `Option` without being tied to one element type.

To describe that boundary, distinguish a completed type from a type constructor.
`Int` and `Option<Int>` are types that values can have. Bare `Option` still
needs one type argument. Ash records that difference with *kinds*.

## State the constructor's kind

This complete program defines `keep`, which returns a constructed value without
changing it:

<!-- source: src/01-explicit-kind.ash -->
```ash
type Option<A> =
    None
    | Some(A)

keep<F : Type -> Type, A> : F<A> -> F<A>
keep value = value

main : Unit -> Option<Int>
main () = keep(Some(42))
```

`Type` is the kind of a completed value type. `Type -> Type` is the kind of a
constructor that accepts one `Type` and produces another. Because `Option`
accepts its element type and produces `Option<A>`, bare `Option` has kind
`Type -> Type`.

The annotation gives `F` the same shape:

```text
F : Type -> Type
```

The parameter `A` omits an annotation, so its kind is `Type`. Applying `F` to
`A` consumes that input and leaves the completed type `F<A>`. Both the domain
and result of `keep` are therefore valid value types. These relationships
follow Ash's rules for
[kinds, monotypes, and schemes](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#kinds-monotypes-and-schemes).

At the call in `main`, which constructor replaces `F`, and which element type
replaces `A`? Follow `keep`'s body to predict both the returned value and its
completed type. Run the program from this lesson's `src` directory:

```text
ash 01-explicit-kind.ash
```

Ash reports:

```text
Some(42) : Option<Int>
```

At this call, ordinary typing chooses `F = Option` and `A = Int`. `keep` does
not inspect either type argument or the `Some` value. It returns the same
`Option<Int>` value it received.

## Read the omitted declaration

The omitted annotation on `A` fixed its kind to `Type`. The same rule applies
to every omitted declaration kind; Ash does not infer a function kind from
use. The parallel program removes `F`'s annotation:

<!-- source: src/02-omitted-kind.ash -->
```ash
type Option<A> =
    None
    | Some(A)

keep<F, A> : F<A> -> F<A>
keep value = value

main : Unit -> Option<Int>
main () = keep(Some(42))
```

Before running it, locate the first type application that needs `F` to have a
function kind. Which declaration fixes the kind that application receives?

<!-- diagnostic: src/02-omitted-kind.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-omitted-kind.ash
The applied type has kind `Type` and cannot take type arguments.
  --> /path/to/ash-doc/content/libraries/accepting-type-constructors/src/02-omitted-kind.ash:5:14
5 | keep<F, A> : F<A> -> F<A>
  |              ^ Found kind `Type` here.
  --> /path/to/ash-doc/content/libraries/accepting-type-constructors/src/02-omitted-kind.ash:5:6
5 | keep<F, A> : F<A> -> F<A>
  |      ^ This declaration fixes the kind as `Type`.
reason: kind.not-applicable
```
<!-- markdownlint-enable MD013 -->

Ash exits with status `1` and writes this message on standard error.

An omitted declaration kind is fixed to `Type`; Ash does not infer a function
kind from later use. The primary label covers the first `F<A>` application,
while the related label points back to the declaration of `F`. The diagnostic
explains that the applied type has kind `Type` and cannot take type arguments.

Applying a type requires a function kind. The declared `F` has kind `Type`, so it
cannot accept `A`. Adding the annotation changes the declaration, not a runtime
operation. Kind annotations and type arguments are checked statically and do
not become values.

Kind arrows associate to the right. `Type -> Type -> Type` therefore means
`Type -> (Type -> Type)`: a constructor that accepts one type and leaves a
constructor waiting for one more. Parentheses are needed for a parameter that
instead accepts a one-argument constructor, such as
`(Type -> Type) -> Type`. The exact forms come from Ash's
[kind grammar](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/syntax.md#grammar).

## Practice: follow the remaining kind

Start each task with a fresh copy of `01-explicit-kind.ash` in a scratch
directory.

1. Reason about replacing `Option` with a two-parameter type `Pair<A, B>` and
   giving `F` the kind `Type -> Type -> Type`. Apply `F` to one type on paper
   and state the kind that remains. Explain which context could accept it;
   this task does not ask for a partial application in a value-type position.
2. Replace `Option` with `Pair<A, B>`. Revise `keep` to accept its two-argument
   constructor and apply it to both element types in its domain and result.
   Construct a pair in `main` and update its result annotation. Predict the
   value and type, then run the complete program and explain the kinds.
3. Change `F` back to an omitted-kind parameter. Predict which application is
   rejected before running the program.
4. Try to use bare `Option` as `main`'s result type. Predict whether its kind
   satisfies that value boundary, then run it and follow the causal labels.

An abstraction accepts a one-argument type constructor by declaring a parameter
of kind `Type -> Type`. Ash keeps omission deliberately different: omitted
declaration kinds are `Type`. The next lesson uses this constructor parameter
inside an [interface method that has its own type parameters](../giving-method-local-type-parameters/README.md).
