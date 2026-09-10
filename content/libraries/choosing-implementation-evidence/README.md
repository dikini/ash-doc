# How can a program choose the implementation a library abstraction needs?

Suppose a library needs to compare two values. It could accept a comparison
function every time, but then every caller must carry that choice as an
ordinary value. Sometimes the library instead needs to state, “this operation
works when equality behavior is available for the value type.”

Ash represents that boundary with an *interface requirement*. The library can
describe the required operation, provide an implementation for a particular
type, and keep the requirement visible on any definition that uses it. A
client then chooses which public implementation facts are available in its
module.

Create `equality.ash` as the library source:

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

`Equal<A>` names a capability for a type `A`. Its method says that equality
behavior accepts two values of that type and produces a boolean. The
implementation supplies the complete method set for `Equal<Int>`; it does not
introduce an ordinary source name for the implementation itself. These are the
[interface and implementation forms](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#interfaces-and-constrained-schemes)
that the checker verifies.

The signature of `same` keeps its dependency explicit:

```text
pub same : (A, A) -> Bool where Equal<A>
```

The value type still says that `same` accepts a pair and returns a boolean.
The `where Equal<A>` clause adds the evidence `same` needs in order to use
`equal`. While Ash checks the body of `same`, that declared requirement is the
abstract evidence for the call. The library does not have to choose a concrete
implementation for every possible `A`.

This gives us two separate questions at a client boundary:

1. Can the client name `same`?
2. Has the client selected an implementation fact that satisfies the
   resulting `Equal<A>` obligation?

## A name is not implementation evidence

Begin with a client that imports only the constrained definition:

<!-- source: src/02-name-only.ash -->
```ash
import equality (same)

main : Unit -> Bool
main () = same((21, 21))
```

Before running it, predict whether the public `Equal<Int>` implementation in
`equality.ash` is automatically available here.

Run the entry from this lesson's `src` directory:

<!-- diagnostic: src/02-name-only.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 02-name-only.ash
No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/choosing-implementation-evidence/src/02-name-only.ash:4:11
4 | main () = same((21, 21))
  |           ^ No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/choosing-implementation-evidence/src/equality.ash:9:5
9 | pub same : (A, A) -> Bool where Equal<A>
  |     ^ This declaration introduced the interface requirement.
  --> /path/to/ash-doc/content/libraries/choosing-implementation-evidence/src/02-name-only.ash:1:18
1 | import equality (same)
  |                  ^ This import made the declaration available.
  --> /path/to/ash-doc/content/libraries/choosing-implementation-evidence/src/equality.ash:1:1
1 | pub interface Equal<A> {
  | ^ This interface participates in the failing evidence selection.
2 |     equal : (A, A) -> Bool
  | ^ This interface participates in the failing evidence selection.
3 | }
  | ^ This interface participates in the failing evidence selection.
reason: constraint.unsatisfied
```
<!-- markdownlint-enable MD013 -->

Ash exits with status `1` and writes this message on standard error.

The import made the spelling `same` available, so name resolution reached the
call and its constrained scheme. Ordinary typing also fixed `A` to `Int` from
the pair of integer arguments. The remaining obligation is therefore the
complete application `Equal<Int>`.

But a targeted name item selects no implementation facts. Ash reports the
unsatisfied obligation at the call and relates it to the imported `same`
item, the declaration that introduced the requirement, and the owning
`Equal` interface. It does not expose the public but unselected implementation
as though that fact were ambient. This behavior follows the separate
[name and implementation import channels](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/name-resolution.md#imports-and-namespaces)
and the rules for an
[unsatisfied evidence obligation](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence).

## Select the required fact

Now add an implementation item beside the name item:

<!-- source: src/01-selected.ash -->
```ash
import equality (same, impl Equal)

main : Unit -> Bool
main () = same((21, 21))
```

Run this entry:

```text
ash 01-selected.ash
```

Ash reports:

```text
true : Bool
```

The two clients differ only by `, impl Equal`. The item resolves the public
interface spelling in `equality.ash` and selects its public implementation
facts, but it binds no source name. Once ordinary typing fixes the call's
requirement to `Equal<Int>`, the selected `Equal<Int>` fact is the unique
matching concrete evidence. The method body compares `21 == 21`, so `same`
produces `true`.

That order matters. `impl Equal` does not choose a result by inspecting the
values at runtime. Checking first determines the complete interface
application and then selects evidence from the facts explicitly available in
the client module. After validation, Ash
[lowers selected evidence to ordinary Core functions and applications](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/elaboration.md#interface-evidence-lowering).
Imports, implementation identities, and checking registries do not become
runtime operations; evaluation performs
[no runtime interface lookup](https://github.com/dikini/ash-lang/blob/38e3478589b77133caa8e4f16ccc0ef1ad2b6c26/spec/dynamic-semantics.md#generated-interface-evidence).

The cost of this boundary is one explicit requirement on the library
definition and one explicit selection channel at the client. In return, the
library can describe the behavior it needs without accepting a comparator in
every value-level call, and the importing module makes its available
implementation evidence visible in source.

## Practice: change one boundary at a time

Work in copies of the three sources so the observations above remain intact.

1. Change the selected client's arguments to `21` and `22`. Predict the
   boolean before running it, then explain why the selected fact is unchanged.
2. Remove `pub` from the implementation in `equality.ash`. Run the selected
   client and explain why another module can no longer select that private
   fact.
3. Replace `impl Equal` with the ordinary name item `Equal`. The interface name
   is now available in the client, but is its implementation fact available?
   Predict what the message will explain and where its labels will point,
   then check it.

When you explain each result, keep the four roles separate: the interface
names required behavior, the implementation supplies that behavior for
`Int`, the `where` clause records the library definition's need, and
`impl Equal` selects public implementation facts for the client module.
