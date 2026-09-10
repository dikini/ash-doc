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
[kinds, monotypes, and schemes](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#kinds-monotypes-and-schemes).

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

```text
ash 02-omitted-kind.ash
```

Ash exits with status `1`, writes no standard output, and begins standard error
with:

```text
kind.not-applicable
```

An omitted declaration kind is fixed to `Type`; Ash does not infer a function
kind from later use. The primary label covers the first `F<A>` application,
while the related label points back to the declaration of `F`. The report
retains the boundary directly:

```text
expected Type -> _
found Type
```

The underscore means that applying a type requires some function kind; the
result kind is not the problem yet. The declared `F` has kind `Type`, so it
cannot accept `A`. Adding the annotation changes the declaration, not a runtime
operation. Kind annotations and type arguments are checked statically and do
not become values.

Kind arrows associate to the right. `Type -> Type -> Type` therefore means
`Type -> (Type -> Type)`: a constructor that accepts one type and leaves a
constructor waiting for one more. Parentheses are needed for a parameter that
instead accepts a one-argument constructor, such as
`(Type -> Type) -> Type`. The exact forms come from Ash's
[kind grammar](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/syntax.md#grammar).

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
