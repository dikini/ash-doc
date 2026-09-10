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
[kinds, monotypes, and schemes](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#kinds-monotypes-and-schemes).

Run the program:

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

## Omission means `Type`, not inference

It might seem that Ash could discover `F`'s function kind from `F<A>`. Test
that prediction with the parallel program:

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

The only change is the removal of `: Type -> Type`. Run it:

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
[kind grammar](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/syntax.md#grammar).

## Practice: follow the remaining kind

Work in copies of the accepted program.

1. Replace `Option` with a two-parameter type `Pair<A, B>`. Give a parameter
   the kind `Type -> Type -> Type`, apply it to one type, and state the kind
   that remains.
2. Apply that parameter to two types and explain why the result can appear as a
   function domain or result.
3. Change `F` back to an omitted-kind parameter. Predict which application is
   rejected before running the program.
4. Try to use bare `Option` as `main`'s result type. Explain why a value boundary
   needs kind `Type`, not `Type -> Type`.

An abstraction accepts a one-argument type constructor by declaring a parameter
of kind `Type -> Type`. Ash keeps omission deliberately different: omitted
declaration kinds are `Type`. The next lesson uses this constructor parameter
inside an interface method that has its own type parameters.
