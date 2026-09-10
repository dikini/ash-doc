# How can one method work at unrelated element types?

The previous lesson gave `F` the kind `Type -> Type`, so a definition could
accept a type constructor and apply it to an element type. A reusable mapping
operation needs another degree of freedom: the same operation must change
`F<Int>` into `F<Bool>` at one call and `F<Bool>` into `F<Int>` at another.

An interface parameter describes the type constructor whose implementation is
required. A method may declare additional type parameters for the types that
vary from one occurrence to the next.

## Declare the method's changing types

Put the interface and its constrained consumer in `api.ash`:

<!-- source: src/api.ash -->
```ash
pub interface Functor<F : Type -> Type> {
    map<A, B> : (A -> B, F<A>) -> F<B>
}

to_bool : Int -> Bool
to_bool value = value == 42

to_int : Bool -> Int
to_int true = 42
to_int false = 0

pub map_pair<F : Type -> Type> : (F<Int>, F<Bool>) -> (F<Bool>, F<Int>) where Functor<F>
map_pair (numbers, flags) = (map((to_bool, numbers)), map((to_int, flags)))
```

`F` belongs to the interface. A complete application such as `Functor<Box>`
is the implementation requirement. By contrast, `A` and `B` belong only to
`map`. They describe one occurrence's input and output element types and create
no separate interface requirement.

`map_pair` makes the distinction observable. Its first `map` occurrence uses
`A = Int` and `B = Bool`; its second uses `A = Bool` and `B = Int`. Both
occurrences retain the same `Functor<F>` requirement. Ash freshens the complete
interface vector and then the method's ordered parameters at each occurrence,
as specified by the
[interface method typing rule](https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/static-semantics.md#interfaces-and-constrained-schemes).

Supply one implementation in `carrier.ash`:

<!-- source: src/carrier.ash -->
```ash
pub import api (Functor, map)

pub type Box<A> = Box(A)

pub impl Functor<Box> {
    map (function, Box(value)) = Box(function(value))
}
```

The implementation head fixes the interface parameter to the `Box` type
constructor. The implementation method remains generic in the method's two
local types: it unwraps a `Box<A>`, applies the supplied `A -> B` function, and
wraps the resulting `B`. Its equations do not need to repeat the interface's
parameter spellings.

Now select that implementation from the entry:

<!-- source: src/01-map-pair.ash -->
```ash
import api (map_pair)
import carrier (Box, impl Functor)

main : Unit -> (Box<Bool>, Box<Int>)
main () = map_pair((Box(42), Box(true)))
```

From this lesson's `src` directory, run:

```text
ash 01-map-pair.ash
```

Ash reports:

```text
(Box(true), Box(42)) : (Box<Bool>, Box<Int>)
```

The entry selects one `Functor<Box>` fact. That evidence supplies `map` for
both method-local instantiations; it does not select a new implementation for
each element-type pair. The method's type operations and the selected interface
evidence are static. After checking, generated evidence lowers to ordinary
functions and erased type operations, not runtime type inspection or dynamic
interface lookup. The boundary is described by Ash's
[interface evidence lowering](https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/elaboration.md#interface-evidence-lowering)
and
[generated evidence evaluation](https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/dynamic-semantics.md#generated-interface-evidence).

## An omitted list binds no local types

Remove the method parameter list but leave its type unchanged:

<!-- source: src/02-missing-method-parameters.ash -->
```ash
interface Functor<F : Type -> Type> {
    map : (A -> B, F<A>) -> F<B>
}
```

Run:

<!-- diagnostic: src/02-missing-method-parameters.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-missing-method-parameters.ash
Method type parameters must be explicitly declared in the method's parameter list.
  --> /path/to/ash-doc/content/libraries/giving-method-local-type-parameters/src/02-missing-method-parameters.ash:2:5
2 |     map : (A -> B, F<A>) -> F<B>
  |     ^ Method type parameters must be explicitly declared in the method's parameter list.
  --> /path/to/ash-doc/content/libraries/giving-method-local-type-parameters/src/02-missing-method-parameters.ash:1:19
1 | interface Functor<F : Type -> Type> {
  |                   ^ An interface parameter is declared here.
reason: interface.method-parameter
```
<!-- markdownlint-enable MD013 -->

Ash exits with status `1` and writes this message on standard error.

An omitted method parameter list is not an inference request: it binds no
method-local type parameters. The signature therefore contains the unlisted
names `A` and `B`. The diagnostic's primary label covers the complete `map`
signature, and its related label points to the declared interface parameter
`F`. Adding `<A, B>` makes the method type's non-interface variables an ordered
declared set. These binding rules come from
[method parameter resolution](https://github.com/dikini/ash-lang/blob/57eec5bbadae885e49c323e0a05e7a01b9ce8a36/spec/name-resolution.md#type-binder-identity-and-scope).

This is rank-1 method polymorphism at an interface boundary. Each occurrence
instantiates the method scheme to a monotype; source code cannot store an
uninstantiated method scheme in a value, write `forall`, or pass a polymorphic
method as an ordinary argument.

## Practice: separate the two parameter roles

Work in copies of the accepted sources.

1. Use `map` twice at the same `Int -> Bool` element types. Identify what stays
   polymorphic even though both occurrences choose the same local arguments.
2. Reverse the written method parameters to `<B, A>` without changing the
   signature. Predict the output and explain what parameter order records.
3. Add an unused method parameter `C`. Predict the binding error before running
   the source.
4. Remove `impl Functor` only from the entry import. Explain why declared
   method-local parameters cannot satisfy the separate `Functor<Box>` evidence
   obligation.

One implementation can support unrelated element types because each method
occurrence instantiates the method's own parameters while retaining one
complete interface requirement. The next lesson asks how one known interface
argument can determine another before evidence selection.
