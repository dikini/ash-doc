# How can a facade forward a capability without redefining it?

The previous lesson made a client choose `Equal<Int>` directly from the source
that defines it. A larger program may not want every client to depend on that
source. It may place a smaller public boundary in front of several libraries
and let clients depend on that boundary instead.

Such a boundary is often called a *facade*. An Ash facade can re-export public
names, but equality behavior needs more than names. The implementation owner,
facade, and client form a route: the owner publishes an implementation fact,
the facade authorizes that fact for its dependents, and the client selects it.
We can observe what each hop contributes without writing another equality
implementation.

Begin with the same `equality.ash` source used in the previous lesson:

<!-- source: src/equality.ash -->
```ash
pub interface Equal<A> {
    equal : (A, A) -> Bool
}

pub impl Equal<Int> {
    equal (left, right) = left == right
}

pub same : (A, A) -> Bool where Equal<A>
same pair = equal pair
```

This source still owns the `Equal` interface, its `Int` implementation, and
the constrained `same` definition. The facade will not copy any of those
declarations.

## What do public names carry?

First make `names_only_facade.ash` contain one public targeted import:

<!-- source: src/names_only_facade.ash -->
```ash
pub import equality (Equal, equal, same)
```

The import makes the three selected names available in the facade and stages
them for its public summary. A later client reaches the original declarations
through those spellings: re-export preserves each defining identity rather
than creating a forwarding declaration. But ordinary name items select no
implementation facts. These are separate rules in Ash's
[imports and namespaces](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/name-resolution.md#imports-and-namespaces).

Use that facade from `02-names-only.ash`:

<!-- source: src/02-names-only.ash -->
```ash
import names_only_facade (same)

main : Unit -> Bool
main () = same((21, 21))
```

Before running it, follow the name route. The client imports `same` from the
facade, and the facade publicly imported `same` from the equality owner. The
call can therefore reach the constrained definition. Now ask a different
question: which source item selected `Equal<Int>` implementation evidence for
this client?

Run the entry from this lesson's `src` directory:

```text
ash 02-names-only.ash
```

Ash exits with status `1`, writes no standard output, and begins standard
error with:

```text
constraint.unsatisfied
```

Typing the integer pair fixes the call's requirement to `Equal<Int>`, but no
implementation item supplied a candidate. The diagnostic places its sole
primary label on the `same` call. Its related labels identify the client's
import and the original `same` and `Equal` declarations in `equality.ash`.
There is no facade-owned copy to identify, and the unselected implementation is
not exposed. The
[constraint-selection rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence)
make an eligible concrete obligation with no available source
`constraint.unsatisfied`.

## Forward the implementation route

Now make `capability_facade.ash` differ by one import item:

<!-- source: src/capability_facade.ash -->
```ash
pub import equality (Equal, equal, same, impl Equal)
```

`impl Equal` binds no source name. In this public import, it selects the
equality owner's public `Equal` facts and adds their authorization routes to
the facade's public implementation closure. The route retains its hop back to
the defining source and preserves the original implementation identity. The
facade still contains no interface, function, or implementation body.

The client must select the route that the facade made public:

<!-- source: src/01-forwarded.ash -->
```ash
import capability_facade (same, impl Equal)

main : Unit -> Bool
main () = same((21, 21))
```

Run it:

```text
ash 01-forwarded.ash
```

Ash reports:

```text
true : Bool
```

There are two explicit implementation items. The public item in the facade
authorizes the route for later dependents. The private item in the client
selects that authorized fact into the client's effective implementation
environment. Ordinary typing fixes `Equal<Int>`, the route leads to the
original implementation, and its method compares the two integers.

This routing is static. A public import does not construct a runtime facade
object, register an implementation, or arrange dynamic dispatch. After Ash
validates the selected route, it
[lowers evidence to ordinary Core functions and applications](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/elaboration.md#interface-evidence-lowering).
The evaluator performs
[no runtime interface lookup](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/dynamic-semantics.md#generated-interface-evidence).

The representation cost is one additional import hop and an explicit selector
at each boundary that forwards or consumes the capability. The invariant is
visible in source: names and implementation authorization travel through
independent items. The facade gains a stable public boundary without
duplicating the interface, constrained function, implementation identity, or
method body.

## Practice: inspect each hop

Work in copies of these sources so the observations above remain intact.

1. Remove `impl Equal` only from `capability_facade.ash`, leaving the client
   selector in place. Predict whether the failure occurs while resolving the
   import or while satisfying the call, then run it. This is a different
   boundary from the lesson's name-only client.
2. Restore the facade selector, then remove `impl Equal` only from the client.
   Explain why a public authorization route does not become ambient evidence.
3. Add the ordinary name `Equal` to the name-only client's import. Explain why
   making the interface spelling available is still not implementation
   selection.
4. Change `pub import` to `import` in a facade copy. Identify which facts remain
   usable inside that facade and which route is no longer public to its client.

A facade forwards a capability only when its public boundary carries both the
needed names and an implementation authorization route. A dependent still
chooses that route explicitly. The next lesson asks how a library abstraction
can accept a type constructor such as `Option`, rather than only a completed
type such as `Int`.
