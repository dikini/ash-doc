# How can clients use a dictionary without constructing invalid trees?

The preceding case made key order reusable, but its tree remained transparent.
A client could still construct a `Node` whose keys occupied the wrong branches.
Lookup trusted the ordering invariant, followed one branch, and missed a key
that was structurally present.

A dictionary module can close that construction route. It can export the
dictionary's type identity and operations while withholding its constructors.
Clients can name and pass dictionary values, but only the defining module can
construct or inspect their representation directly.

That boundary controls source access. It does not prove that the module's
operations preserve the invariant, that an `Order` implementation obeys
ordering laws, or that the representation is secret.

## Put construction behind the module

The dictionary module retains the preceding `Order`, `Natural`, `Option`,
lookup, and insertion behavior. Its recursive representation now begins with
`pub opaque type`.

<!-- source: src/dictionaries.ash -->
<!-- markdownlint-disable MD013 -->
```ash
pub type Ordering =
    Less
    | Equal
    | Greater

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Dictionary<K, V>, K, V, Dictionary<K, V>)

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(left, current_key, current_value, right) = match compare query current_key {
    Less => lookup query left
    Equal => Some(current_value)
    Greater => lookup query right
}

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value Empty = Node(Empty, key, value, Empty)
insert key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert key value right)
}

fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated End = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>
insert_entry dictionary entry = match entry {
    (key, value) => insert key value dictionary
}

pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>
build entries = fold_left insert_entry (empty ()) entries

above_lower : Option<K> -> K -> Bool where Order<K>
above_lower None key = true
above_lower Some(lower) key = match compare lower key {
    Less => true
    Equal => false
    Greater => false
}

below_upper : K -> Option<K> -> Bool where Order<K>
below_upper key None = true
below_upper key Some(upper) = match compare key upper {
    Less => true
    Equal => false
    Greater => false
}

both : Bool -> Bool -> Bool
both true right = right
both false right = false

valid_between : Option<K> -> Option<K> -> Dictionary<K, V> -> Bool where Order<K>
valid_between lower upper Empty = true
valid_between lower upper Node(left, key, ignored_value, right) = {
    let respects_lower = above_lower lower key
    let respects_upper = below_upper key upper
    let left_valid = valid_between lower (Some(key)) left
    let right_valid = valid_between (Some(key)) upper right
    both respects_lower (both respects_upper (both left_valid right_valid))
}

pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>
invariant_holds dictionary = valid_between None None dictionary

main : Unit -> Bool
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let malformed = Node(
        Node(Empty, one, 10, Node(Empty, three, 30, Empty)),
        two,
        20,
        Empty
    )
    invariant_holds malformed
}
```
<!-- markdownlint-enable MD013 -->

Under Ash's [public, private, and opaque declaration
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/name-resolution.md#public-private-and-opaque-declarations),
`Dictionary<K, V>` is nameable in an importing module, but `Empty` and `Node`
are not available there as values or patterns. Both constructors remain
available throughout this defining module.

The public API is:

```text
empty : Unit -> Dictionary<K, V>
lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
build : List<(K, V)> -> Dictionary<K, V> where Order<K>
invariant_holds : Dictionary<K, V> -> Bool where Order<K>
```

Of these operations, `empty`, `insert`, and `build` are the exported routes
that return `Dictionary` values. `lookup` and `invariant_holds` observe those
values without exposing their representation constructors.

The `where Order<K>` requirements still declare the needed comparison evidence
under the pinned [interface and constrained-scheme
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#interfaces-and-constrained-schemes).
Opacity changes who can name the representation constructors; it does not
select implementation evidence, change lookup's branch selection, or change
insertion's equations.

The module also contains a private `main`. When `dictionaries.ash` is selected
directly as the entry source, that `main` runs. When another source imports the
module, its private `main` is not exported or evaluated as module
initialization. Ash modules are passive dependencies, and only the selected
entry module supplies the executed `main`, as described by the specification
[overview](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/README.md#current-ash).

## Construct through the public operations

Begin with `empty`, then insert `three`, `one`, `two`, and `four`.

<!-- source: src/01-public-api.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries
import dictionaries (impl Order)

main : Unit -> (Bool, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let four = Dictionaries.Next(three)
    let with_three = Dictionaries.insert three 30 empty
    let with_one = Dictionaries.insert one 10 with_three
    let with_two = Dictionaries.insert two 20 with_one
    let dictionary = Dictionaries.insert four 40 with_two
    (
        Dictionaries.invariant_holds dictionary,
        Dictionaries.lookup one dictionary,
        Dictionaries.lookup two dictionary,
        Dictionaries.lookup three dictionary,
        Dictionaries.lookup four dictionary,
        Dictionaries.lookup Dictionaries.Zero dictionary
    )
}
```
<!-- markdownlint-enable MD013 -->

The two imports perform independent static work. The complete import binds
public names beneath `Dictionaries`, but selects no implementation facts. The
`impl Order` item binds no name; it selects the dependency's public `Order`
facts for evidence selection in this entry. The pinned [import
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/name-resolution.md#imports-and-namespaces)
define that separation. Selecting evidence neither reveals `Empty` or `Node`
nor weakens their opaque access boundary. This private selector does not
re-export the facts, make them transitively available to another client, or
create a runtime implementation lookup.

Predict the resulting shape from the insertion equations:

```text
        three
       /     \
     one     four
       \
       two
```

At `two`, the inherited lower bound is `one` and the inherited upper bound is
`three`. The separate right branch gives `four` the lower bound `three`. All
four inserted keys satisfy their bounds, so predict `true` followed by four
hits and one absence.

Run the entry from `content/cases`:

```text
ash protecting-dictionary-invariant/src/01-public-api.ash
```

<!-- markdownlint-disable MD013 -->
```text
(true, Some(10), Some(20), Some(30), Some(40), None) : (Bool, Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>)
```
<!-- markdownlint-enable MD013 -->

The result confirms what this complete program does. Clients obtained a named
`Dictionary<Natural, Int>` and composed its public operations without naming
either dictionary constructor.

The result alone does not prove preservation. Fix one `Order<K>` implementation
whose required comparisons return and satisfy these premises:

- `Equal` is the chosen key equivalence;
- reversing a strict comparison reverses `Less` and `Greater`;
- strict comparison is transitive; and
- equivalent keys have the same ordering relationship to every other key.

A finite dictionary is valid when both subtrees are valid, every key in the
left subtree compares `Less` than the current key, and every key in the right
subtree compares `Greater`.

Under those premises, `empty` is valid. For a finite valid input whose
entered-path comparisons return, completed `insert` preserves validity. Its
`Less` and `Greater` arms rebuild around the recursively changed branch. Its
`Equal` arm retains the stored representative key and both branches while
replacing only the value.

These conclusions follow from the operation equations and premises. The
`Order` interface and opaque nominal do not encode the ordering laws or
invariant as type-level propositions.

## Build in input order

The public `List<A>` remains transparent so a client can construct finite input
for `build`. The private `fold_left` passes the current dictionary accumulator
to `insert_entry`, then continues with the returned dictionary.

<!-- source: src/02-build.ash -->
```ash
import dictionaries as Dictionaries
import dictionaries (impl Order)

main : Unit -> (Bool, Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More((two, 99), Dictionaries.End)
        )
    )
    let dictionary = Dictionaries.build entries
    (
        Dictionaries.invariant_holds dictionary,
        Dictionaries.lookup two dictionary,
        Dictionaries.lookup one dictionary
    )
}
```

The selector authorizes the same `Order<Natural>` evidence used by `build`,
`invariant_holds`, and `lookup`; it does not authorize representation access.
The client can construct the transparent input `List`, while the dictionary
constructors remain unavailable.

Predict the accumulated states:

```text
empty
insert two 20
insert one 10
insert two 99
```

The final insertion compares equal at `two`. It replaces `20` with `99`, so
the later list entry wins.

Run the entry:

```text
ash protecting-dictionary-invariant/src/02-build.ash
```

```text
(true, Some(99), Some(10)) : (Bool, Option<Int>, Option<Int>)
```

The exact result records both the valid completed dictionary and the
input-order replacement. This `build` is an ordinary strict left fold over a
finite list. It is not a lazy producer abstraction or a fold/build fusion
mechanism.

For a finite list of `n` entries whose successive insertions return,
`fold_left` invokes its combiner exactly `n` times, so `build` invokes `insert`
exactly `n` times. Let insertion `j` enter `m_j` existing `Node` forms. Let
`C_j(i)` count all completed selected comparison-method applications caused by
comparing against its `i`th visited key. The comparison sub-work is:

```text
sum over j of (sum from i = 1 to m_j of C_j(i))
```

The list steps and entered tree nodes contribute surrounding named source work
of:

```text
O(n + sum over j of m_j)
```

Without balancing, ascending or descending entries can make the total
entered-node work quadratic in `n`. Neither opacity nor `build` supplies a
logarithmic-height guarantee.

## Check descendant bounds, not only children

`invariant_holds` begins with no lower or upper bound. At each `Node`,
`valid_between` checks the current key against every bound inherited through
that path:

- the left recursion keeps the old lower bound and installs the current key as
  its upper bound;
- the right recursion installs the current key as its lower bound and keeps the
  old upper bound.

An immediate-child check is insufficient. In the module's private example,
`one` is left of `two`, and `three` is right of `one`. Those local relationships
hold. But `three` remains inside the complete left subtree of `two`, so it must
also be less than the older upper bound `two`.

Run the defining module directly:

```text
ash protecting-dictionary-invariant/src/dictionaries.ash
```

```text
false : Bool
```

The defining module can construct this malformed value because its own
constructors remain accessible. The value never crosses the public API.

The four bindings in `valid_between` evaluate the two bound checks and both
recursive validations before the nested `both` applications combine them.
Bindings evaluate their initializers before continuing under the pinned
[binding
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/dynamic-semantics.md#bindings),
and function arguments evaluate strictly under the pinned [application
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/dynamic-semantics.md#application).
A completed validation therefore enters both branches even when an earlier
Boolean is already `false`.

For a finite dictionary with `n` structural `Node` occurrences whose required
bound comparisons return, completed `invariant_holds` visits exactly those `n`
occurrences. Let `B` be the number of validator-initiated `compare` calls. It
equals the number of present lower bounds plus the number of present upper
bounds:

- `B = 0` for an empty or one-node dictionary; and
- `n - 1 <= B <= 2n - 2` when `n > 1`.

For validator call `r`, let `C_r` count every completed method application
performed by the selected comparison for that pair, including recursive
applications and the terminal Natural equation. Exact comparison sub-work is:

```text
sum over the B calls of C_r
```

Only when every `C_r <= Cmax`, with `Cmax >= 1`, may this be summarized as
`O(B * Cmax)` and therefore `O(n * Cmax)`. The traversal's surrounding named
source work is `O(n)`. These counts describe source operations, not elapsed
time or machine instructions.

## Separate the type name from its constructors

Before testing constructor access, consider this complete client. It names the
opaque type and calls a public operation, but it contains no dictionary
constructor occurrence.

<!-- source: src/03-observe.ash -->
```ash
import dictionaries as Dictionaries

main : Unit -> Dictionaries.Dictionary<Dictionaries.Natural, Int>
main () = Dictionaries.empty()
```

Keep that program aside while testing the two forbidden source forms.

First, try to use `Empty` as a constructor value.

<!-- source: src/04-construct.ash -->
```ash
import dictionaries as Dictionaries

main : Unit -> Dictionaries.Dictionary<Dictionaries.Natural, Int>
main () = Dictionaries.Empty
```

Predict rejection during name resolution. The type annotation may name
`Dictionaries.Dictionary`, but opacity withholds `Dictionaries.Empty`.

Run the entry:

```text
ash protecting-dictionary-invariant/src/04-construct.ash
```

The diagnostic reports this reason code:

```text
resolve.opaque-constructor
```

The stable observation is status `1`, empty standard output, diagnostic
reason `resolve.opaque-constructor`, a primary label on the
`Empty` member token in the client, and a related label on its withheld
declaration in `dictionaries.ash`. Rendered wording and layout are not the
teaching contract. The tool's
[failure
contract](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/docs/tools/ash.md#failures)
assigns source rejection to standard error with status `1`.

Now try the same constructor spelling as a pattern.

<!-- source: src/05-match.ash -->
```ash
import dictionaries as Dictionaries

inspect : Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Int
inspect Dictionaries.Empty = 0

main : Unit -> Int
main () = inspect(Dictionaries.empty())
```

Predict the same resolution reason. The defining module can pattern-match on
`Empty` and `Node`; an importer cannot. Imported opaque values may still be
passed to functions or covered without representation inspection, but their
withheld constructors cannot occur in importer patterns under the pinned
[opaque declaration
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/name-resolution.md#public-private-and-opaque-declarations)
and [coverage
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#patterns-matches-and-coverage).

Run the entry:

```text
ash protecting-dictionary-invariant/src/05-match.ash
```

The diagnostic reports this reason code:

```text
resolve.opaque-constructor
```

This complete program also exits with status `1`, writes no standard output,
and identifies the inaccessible `Empty` pattern occurrence.

Return to the accepted observation and predict its result. The client obtains
the dictionary through `empty`, so the program checks and evaluates even though
the result type is opaque.

```text
ash protecting-dictionary-invariant/src/03-observe.ash
```

```text
Empty : Dictionary<Natural, Int>
```

The output still renders the constructor structure. Ash's [observation
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/dynamic-semantics.md#observation)
render nominal data structurally, and the tool's [successful-output
contract](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/docs/tools/ash.md#successful-output)
prints the resulting value and closed type.

That rendering does not create a source binding named `Dictionaries.Empty`. It
also does not expose a pointer, promise representation secrecy, or provide
cryptographic privacy or runtime access control. Opacity is a static
source-access boundary.

## Keep the guarantees attached to their premises

For finite valid dictionaries and the fixed ordering premises, completed
`insert` preserves the invariant. Starting from `empty`, completed `build`
preserves it across a finite input list by applying `insert` in list order. The
exact module gives clients no constructor route around those operations.

That does not make finiteness a property proved by `Dictionary<K, V>`. Code
inside the defining module could create a constructor-guarded dictionary-spine
cycle or export a bad operation. Ash's static [recursive block-group
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/static-semantics.md#recursive-block-groups)
and dynamic [recursive-binding
rules](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/dynamic-semantics.md#recursive-bindings)
admit guarded recursive data; opacity does not change that semantic boundary.

The selected public operations produce finite acyclic dictionary spines when
they start from finite prior dictionaries and finite input lists and their
required calls return. The generic key or value payloads may independently
contain cycles. A cyclic value payload does not add a dictionary `Node`, and a
completed lookup can return `Some(cyclic_value)` without inspecting that
payload. If the entry `main` returns that option, final structural
[observation](https://github.com/dikini/ash-lang/blob/9231b21228c5ccacbbee0cc0da60b380e5d2dc59/spec/dynamic-semantics.md#observation)
traverses the option and its payload and renders an active-path revisit as
`<cycle>`. A comparison that follows a cyclic key or otherwise fails to return
can prevent lookup, insertion, build, or validation from returning.

A reachable dictionary-spine cycle can prevent the whole-tree validator from
returning because it enters both branches. Lookup and insertion follow only
their selected path, so a cycle in an unentered branch need not affect that
call. A cyclic input list can prevent `build` from reaching `End`.

Ash exposes no source-level mutation here. Returning a new dictionary value
does not establish pointer identity, physical sharing, heap layout,
garbage-collection behavior, native-stack use, tail-call optimization, or
compiler allocation strategy. The source equations show only which previous
branch values are supplied to new `Node` applications.

## Practice and continue

1. Suppose `build` receives three entries for the same key with values `20`,
   `99`, and `7`, in that order. Predict the retained value and explain which
   fold and insertion equations determine it.
2. At `valid_between lower upper Node(left, key, value, right)`, state the two
   bounds passed to the left recursive call and the two passed to the right
   recursive call.
3. Describe a three-node dictionary in which each child has the correct
   relationship to its parent but one deeper descendant violates an older
   ancestor bound. Explain why an immediate-child-only check accepts it.

The opaque boundary keeps clients from constructing malformed dictionary
nodes, but insertion can still produce a chain whose height equals its number
of keys. How can the hidden representation itself prevent that degeneration
while preserving the public dictionary operations?
