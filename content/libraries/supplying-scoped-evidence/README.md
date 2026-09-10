# How can one lexical scope supply its own exact behavior?

A module newtype gives a representation a meaning shared by that module's
clients. Sometimes a calculation needs a distinction only within one block.
A local newtype gives the following code a nominal identity without making
that identity part of the block's outward contract.

Once that local type exists, the block may supply exact interface behavior
for it. The supplied methods can use values already available there. Their
availability follows the source scope, and selected methods become ordinary
functions used by the checked calculation.

## Consume a local distinction inside its block

`01-local-value.ash` introduces `Points` only for the remainder of `main`'s body:

<!-- source: src/01-local-value.ash -->
```ash
main : Unit -> Int
main () = {
    newtype Points = Points(Int)
    let points = Points(40)
    match points {
        Points(value) => value + 2
    }
}
```

The representation is `Int`, as for the module newtype in the preceding
chapter. Construction and the pattern explicitly cross that boundary. The
block returns an integer, so its result contains no local type identity.
Run from this lesson's `src` directory:

```text
$ ash 01-local-value.ash
42 : Int
```

A local declaration is sequential: its nominal type and constructor enter the
following scope together. It has no `pub` form and cannot become a recursive
group member. Its identity belongs to this lexical declaration; executing the
block does not allocate a fresh runtime identity or a resource owner.

## A closure may retain a value without exposing its type

`02-returned-closure.ash` returns a calculation over a captured local value:

<!-- source: src/02-returned-closure.ash -->
```ash
make_adder : Int -> Int -> Int
make_adder amount = {
    newtype Offset = Offset(Int)
    let offset = Offset(amount)
    fn(value) {
        match offset {
            Offset(saved) => saved + value
        }
    }
}

main : Unit -> Int
main () = make_adder 40 2
```

The result of `make_adder 40` has type `Int -> Int`. The returned function
captures `offset` and unwraps it when called, but its parameter and result do
not expose `Offset`. Calling it with two gives:

```text
$ ash 02-returned-closure.ash
42 : Int
```

This is an ordinary retained value and closure. The local newtype has no
release obligation. Its representation may remain in a function environment
when the function's outward type is independent of the local nominal identity.

Returning the local value itself crosses a different boundary:

<!-- source: src/04-identity-escape.ash -->
```ash
main : Unit -> Int
main () = {
    let escaped = {
        newtype Token = Token(Int)
        Token(42)
    }
    0
}
```

<!-- diagnostic: src/04-identity-escape.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 04-identity-escape.ash
This type or effect row exposes a local nominal type outside its scope.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/04-identity-escape.ash:5:9
5 |         Token(42)
  |         ^ This type or effect row exposes a local nominal type outside its scope.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/04-identity-escape.ash:4:9
4 |         newtype Token = Token(Int)
  |         ^ This scope owns the local nominal type.
reason: type.local-nominal-escape
```
<!-- markdownlint-enable MD013 -->

The escaping expression has type `Token`, and the related label identifies
the declaration whose scope would end. The unused name `escaped` does not
hide that outward type. Return an unwrapped integer, or an identity-free
function such as `make_adder`'s result.

The check includes function domains and results, aggregate members, schemes,
requirements, and effect rows. Returning a local value together with a function
that unwraps it does not create an implicit package hiding the identity.
The [local nominal rules][nominals] define this boundary.

## Supply the exact method needed here

A local nominal can identify an exact interface application. In
`03-exact-method.ash`, `Read<A, B>` uses `A` to determine its result type `B`:

<!-- source: src/03-exact-method.ash -->
```ash
interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

main : Unit -> Int
main () = {
    newtype Token = Token(Int)
    let token = Token(40)
    let offset = 2
    with Read<Token, Int> {
        read (Token(value)) = value + offset
    }
    forward token
}
```

`with Read<Token, Int>` supplies one complete application, not a generic
implementation head. Its `read` method unwraps a `Token` and adds the preceding
`offset` value. The source becomes available only after every supplied method
has checked; `forward token` is in that following remainder.

At that call, the token fixes the selection key. The exact `Read<Token, Int>`
source determines the result as `Int` and supplies the required method.
Inside `forward`, its ordinary declared requirement carries that method to
`read`. The global helper does not need to name the local type:

```text
$ ash 03-exact-method.ash
42 : Int
```

This retains the earlier library model: a generic helper declares its
requirement, and the caller supplies evidence. `with` adds a lexical source
for one exact relation. It does not infer a new requirement or initiate local
implementation search.

The application must be explicit and have no unresolved inference choices.
Its key must contain an active local nominal. Here `Token` is the determinant;
for an interface without an edge, all arguments form the key. A local nominal
under another type constructor also counts, but one appearing only in a
dependent result does not.

## A module nominal does not establish a local key

Move `Token` outside the block and the same evidence declaration no longer
qualifies:

<!-- source: src/05-no-local-key.ash -->
```ash
interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

newtype Token = Token(Int)

main : Unit -> Int
main () = {
    with Read<Token, Int> {
        read (Token(value)) = value
    }
    forward (Token(42))
}
```

<!-- diagnostic: src/05-no-local-key.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 05-no-local-key.ash
This evidence declaration needs an active local nominal type in its selection key: the determinant arguments, or all arguments when there is no determination edge.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/05-no-local-key.ash:12:10
12 |     with Read<Token, Int> {
   |          ^ This evidence declaration needs an active local nominal type in its selection key: the determinant arguments, or all arguments when there is no determination edge.
reason: evidence.missing-local-key
```
<!-- markdownlint-enable MD013 -->

The diagnostic marks the exact application and states which positions form
its key. This `Token` is a module nominal, not an active local declaration.
Move the newtype back inside the block for the original scoped behavior.
For behavior belonging to a module type, use an ordinary implementation in
an owning module, following the preceding lessons.

`with` does not bypass module ownership or coherence rules. Abstract evidence
from a function's declared requirement and exact current-implementation
evidence retain precedence over lexical evidence. Lexical evidence precedes
matching concrete implementations; it does not rewrite those contracts.

## Availability follows the occurrence's source scope

A method used before a `with` cannot borrow evidence from later in the block:

<!-- source: src/06-before-evidence.ash -->
```ash
interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

main : Unit -> Int
main () = {
    newtype Token = Token(Int)
    let token = Token(40)
    let before = forward token
    with Read<Token, Int> {
        read (Token(value)) = value + 2
    }
    before
}
```

<!-- diagnostic: src/06-before-evidence.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-before-evidence.ash
No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/06-before-evidence.ash:12:18
12 |     let before = forward token
   |                  ^ No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/06-before-evidence.ash:5:1
5 | forward : A -> B where Read<A, B>
  | ^ This declaration introduced the interface requirement.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/06-before-evidence.ash:1:1
1 | interface Read<A, B> where A -> B {
  | ^ This interface participates in the failing evidence selection.
2 |     read : A -> B
  | ^ This interface participates in the failing evidence selection.
3 | }
  | ^ This interface participates in the failing evidence selection.
reason: constraint.unsatisfied
```
<!-- markdownlint-enable MD013 -->

The call in `before` is outside the following remainder. Its labels lead back
to `forward`'s required relation. Moving the evidence declaration before that
call supplies the missing source. The compiler preserves the original lexical
scope of an occurrence even when it finishes inference later.

Supplied method bodies can capture preceding ordinary values and use preceding
evidence. The new source is not available inside its own supplied bodies, so
it grants no implicit recursive or sibling method selection. If a method
needs a recursive helper, define an appropriately annotated local recursive
function earlier, using the rules from Learn.

## Separate scopes can supply different methods

Two simultaneously active sources cannot supply the same key:

<!-- source: src/07-duplicate-evidence.ash -->
```ash
interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

main : Unit -> Int
main () = {
    newtype Token = Token(Int)
    with Read<Token, Int> {
        read (Token(value)) = value + 1
    }
    with Read<Token, Int> {
        read (Token(value)) = value + 2
    }
    forward (Token(40))
}
```

<!-- diagnostic: src/07-duplicate-evidence.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 07-duplicate-evidence.ash
An active evidence declaration already supplies this exact interface application.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/07-duplicate-evidence.ash:14:10
14 |     with Read<Token, Int> {
   |          ^ An active evidence declaration already supplies this exact interface application.
  --> /path/to/ash-doc/content/libraries/supplying-scoped-evidence/src/07-duplicate-evidence.ash:11:10
11 |     with Read<Token, Int> {
   |          ^ The earlier active evidence declaration is here.
reason: evidence.duplicate
```
<!-- markdownlint-enable MD013 -->

The two labels identify the overlapping declarations. The second does not
shadow the first. Remove one source when a single interpretation is intended.
For two independent calculations with different interpretations, use disjoint
blocks:

<!-- source: src/08-disjoint-scopes.ash -->
```ash
interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

main : Unit -> (Int, Int)
main () = {
    newtype Token = Token(Int)
    let token = Token(40)
    let first = {
        with Read<Token, Int> {
            read (Token(value)) = value + 1
        }
        forward token
    }
    let second = {
        with Read<Token, Int> {
            read (Token(value)) = value + 2
        }
        forward token
    }
    (first, second)
}
```

```text
$ ash 08-disjoint-scopes.ash
(41, 42) : (Int, Int)
```

`Token` remains in scope around both calculations, but each `with` applies
only inside its own following remainder. The first adds one and the second
adds two. Neither source becomes available to a new call after its block.

For a determined interface, simultaneously active equal keys with different
dependent result types also conflict. Distinct local declarations remain
distinct nominal keys even if they use the same representation.

## Retain a selected method in an outward function

Lexical availability of new calls is separate from retaining a method already
selected for a closure:

<!-- source: src/09-retained-method.ash -->
```ash
interface Read<A, B> where A -> B {
    read : A -> B
}

forward : A -> B where Read<A, B>
forward value = read value

make_reader : Int -> Unit -> Int
make_reader amount = {
    newtype Token = Token(Int)
    let token = Token(amount)
    let offset = 2
    with Read<Token, Int> {
        read (Token(value)) = value + offset
    }
    fn(ignored) {
        forward token
    }
}

main : Unit -> Int
main () = make_reader 40 ()
```

The returned function's body occurs after `with`, so its call selects the exact
method there. The checked closure retains the method function, its `offset`
capture, and the local token needed for the call. It exposes only `Unit -> Int`:

```text
$ ash 09-retained-method.ash
42 : Int
```

After `make_reader` returns, calling this closure uses those retained ordinary
functions and values. It does not search the caller's block for evidence or
export a new evidence fact that other calls can select. No local identity
appears in the outward function contract.

The [scoped evidence rules][evidence] distinguish selecting in a lexical scope
from retaining the selected functions. Local nominals and exact evidence add
no acquisition, resource release, or permission to export resource access.
Those separate obligations belong to the effects and resources path.

## Practice: trace scope and capture

1. Change the `offset` in `03-exact-method.ash`. Predict the result and explain
   how `forward` receives behavior without knowing that local binding.
2. In `08-disjoint-scopes.ash`, make the second method multiply by two.
   Explain why this does not change the first calculation's selected method.
3. Construct two readers with different inputs using `make_reader`, then call
   both. Predict which ordinary values each closure retains.
4. Explain why returning the local constructor from `make_reader` would expose
   an identity while returning its current `Unit -> Int` function does not.

A local nominal gives one scope a distinct type, and exact evidence gives its
following code a specific method contract. Identity-free results and checked
closures can leave while new evidence selection remains lexical. Together
with generic implementations and module wrappers, these tools let a library
state which behavior it needs and where that behavior comes from.

[nominals]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#local-nominal-scope
[evidence]: https://github.com/dikini/ash-lang/blob/40c964c69c007ba81ec6bdbac34e31ad24fec9c7/spec/static-semantics.md#scoped-exact-evidence
