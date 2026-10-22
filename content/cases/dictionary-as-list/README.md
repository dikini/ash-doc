# Representing a dictionary as a list

The preceding case placed new list elements at the front of an accumulated
result. A dictionary can use the same front construction for key-value entries.
Insertion then needs no search: it places the new entry before the previous
dictionary. Lookup supplies the choice. It can return at the first matching
entry, or it can follow the rest after a mismatch.

This newest-to-oldest order gives duplicate keys a meaning. If we insert key
`1` with value `10`, then later insert key `1` with value `11`, lookup reaches
`11` first. The older entry remains behind it. The new value *shadows* the old
one; insertion does not delete the old entry.

## Put the newest entry first

The shared module gives each key and value one `Entry<K, V>`. A
`Dictionary<K, V>` is either `Empty` or a `More` containing an entry and the
rest of the dictionary. `Option<A>` separates an absent result, `None`, from a
present result, `Some(A)`.

The pinned [syntax
grammar](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#grammar)
provides these parameterized nominal declarations and constructor forms. The
[type and constructor
scope](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#type-and-constructor-scope)
makes `Dictionary` visible in its own `More` payload and binds each constructor
to its nominal type. Under the static [tuple and constructor
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#tuples-and-constructors),
applying a payload constructor such as `Entry`, `More`, or `Some` produces a
value of its declared nominal type.

<!-- source: src/dictionaries.ash -->
<!-- markdownlint-disable MD013 -->
```ash
pub type Entry<K, V> =
    Entry(K, V)

pub type Dictionary<K, V> =
    Empty
    | More(Entry<K, V>, Dictionary<K, V>)

pub type Option<A> =
    None
    | Some(A)

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
insert key value dictionary = More(Entry(key, value), dictionary)

pub lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
lookup same_key query Empty = None
lookup same_key query More(Entry(key, value), rest) = match same_key query key {
    true => Some(value)
    false => lookup same_key query rest
}

pub lookup_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_counted same_key query Empty = (None, 0)
lookup_counted same_key query More(Entry(key, value), rest) = match same_key query key {
    true => (Some(value), 1)
    false => {
        let (found, later_comparisons) = lookup_counted same_key query rest
        (found, later_comparisons + 1)
    }
}

fold_entries : (Entry<K, V> -> B -> B) -> B -> Dictionary<K, V> -> B
fold_entries combine base Empty = base
fold_entries combine base More(entry, rest) = {
    let folded_rest = fold_entries combine base rest
    combine entry folded_rest
}

prefer_current : (K -> K -> Bool) -> K -> Entry<K, V> -> (Option<V>, Int) -> (Option<V>, Int)
prefer_current same_key query Entry(key, value) (found, comparisons) = match same_key query key {
    true => (Some(value), comparisons + 1)
    false => (found, comparisons + 1)
}

pub lookup_through_fold_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_through_fold_counted same_key query dictionary = fold_entries (prefer_current same_key query) (None, 0) dictionary
```
<!-- markdownlint-enable MD013 -->

Each shared function uses the pinned [equational global
presentation](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#global-function-presentations):
a signature followed by its contiguous clauses. Module-wide [global
scope](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#global-scope)
makes recursive functions such as `lookup` and `fold_entries` available in
their own bodies. The static [global and module
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#globals-and-modules)
check each clause against its declared function scheme.

Start from `Empty` and apply the three insertions used throughout this chapter.
Expanding only the `insert` equation predicts the complete order:

```text
insert 1 11 (insert 2 20 (insert 1 10 Empty))
=> More(Entry(1, 11), More(Entry(2, 20), More(Entry(1, 10), Empty)))
```

This newest-to-oldest lookup order is a property of these equations, not a
general property of Ash data.

Each `insert` evaluates one `Entry(key, value)` constructor application and one
front `More(entry, dictionary)` constructor application. The complete previous
dictionary is the new `More` tail. The pinned dynamic [application
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#application)
and [constructor
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches)
govern those evaluations. The construction account names source operations; it
does not yet make a claim about physical storage.

This way of deriving a recursive function from the forms of its input is
inspired by HtDP's [design with self-referential data
definitions](https://htdp.org/2026-2-25/Book/part_two.html).

## Stop at the first matching key

`lookup` receives equality as an explicit function because `K` can be any type.
The pinned static [function and application
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#functions-and-application)
check `same_key query key` against that supplied function type. At `Empty`,
there is no entry to return. At `More`, lookup applies equality exactly once.
The static [pattern, match, and coverage
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#patterns-matches-and-coverage)
require the `Empty` and `More` equations to cover the dictionary and the
`true` and `false` arms to cover the equality result. The true arm returns
`Some(value)` and has no recursive call. Only the false arm follows `rest`.
Ash's [dynamic match
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches)
evaluate the scrutinee once and enter only the selected arm.

The first complete entry defines integer equality and asks for the newest key
`1` and the absent key `3`.

<!-- source: src/01-ordinary-lookup.ash -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> (Dictionaries.Option<Int>, Dictionaries.Option<Int>)
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let second_dictionary = Dictionaries.insert 2 20 first_dictionary
    let dictionary = Dictionaries.insert 1 11 second_dictionary
    (
        Dictionaries.lookup int_equal 1 dictionary,
        Dictionaries.lookup int_equal 3 dictionary
    )
}
```

Before running it, predict the two branches. Query `1` matches the first entry,
so its result should be `Some(11)`. Query `3` should cross all three false arms
and reach `Empty`, so its result should be `None`.

Run the entry from `content/cases`:

```text
ash dictionary-as-list/src/01-ordinary-lookup.ash
```

```text
(Some(11), None) : (Option<Int>, Option<Int>)
```

The first field confirms that front insertion makes the later duplicate win.
The second field is an accepted missing result after the complete traversal,
not a rejected program or diagnostic. The checked result type distinguishes
both outcomes with `Option<Int>`.

The definition of `int_equal` uses Ash's primitive integer equality. The
pinned static [primitive operation
rule](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#primitive-operations)
requires two `Int` operands and produces `Bool`; the dynamic [integer equality
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#primitive-operations)
produce `true` exactly when those integer values are equal.

## Count the comparisons that lookup enters

`lookup_counted` preserves the same branches while returning the number of
equality applications it entered. `Empty` contributes zero. A current match
contributes one. After a mismatch, the recursive result supplies the later
count, and the current comparison adds one.

<!-- source: src/02-counted-lookup.ash -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> ((Dictionaries.Option<Int>, Int), (Dictionaries.Option<Int>, Int))
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let second_dictionary = Dictionaries.insert 2 20 first_dictionary
    let dictionary = Dictionaries.insert 1 11 second_dictionary
    (
        Dictionaries.lookup_counted int_equal 1 dictionary,
        Dictionaries.lookup_counted int_equal 3 dictionary
    )
}
```

Predict one comparison for query `1`, because it matches at the front. Predict
three comparisons and `None` for query `3`, because every key differs.

Run the counted entry:

```text
ash dictionary-as-list/src/02-counted-lookup.ash
```

<!-- markdownlint-disable MD013 -->
```text
((Some(11), 1), (None, 3)) : ((Option<Int>, Int), (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

The counters confirm the selective control flow: a front hit enters one
equality application, while a complete miss enters three. The result `None`
after count `3` is the chapter's negative semantic observation. Each field's
`(Option<Int>, Int)` type pairs an optional value with this source counter.

For a fixed query `q`, let `m` be the first matching position in
front-to-back order, or the dictionary length when no key matches. Direct
lookup visits exactly `m` `More` forms and performs exactly `m` equality
applications. In the worst case, both named counts grow linearly with the
number `n` of entries.

The counter does not reveal the work inside an arbitrary supplied equality
function. Let `E_q(k_i)` name the source work performed by the complete
application `same_key q k_i` at visited entry `i`. For a finite dictionary,
assuming each required equality application returns, equality sub-work is:

```text
E_q(k_1) + E_q(k_2) + ... + E_q(k_m)
```

Including constant inspection and branching work for each visited entry gives:

```text
O(m + sum E_q(k_i))
```

Only under a uniform bound `E_q(k_i) <= Emax` may we abbreviate this as:

```text
O(m * (1 + Emax))
worst case: O(n * (1 + Emax))
```

For this entry, `int_equal` performs one pinned primitive integer equality at
each visited entry. The reported `Int` counts equality applications. It is not
elapsed time, a machine-instruction count, or a measurement of the internal
work of the supplied equality function.

This source-operation account is inspired by HtDP's [cost-of-computation
method](https://htdp.org/2026-2-25/Book/i5-6.html): name the operation and the
input feature that causes it before summarizing its growth.

## Compare selective lookup with a strict fold

The direct function can stop because its recursive call occurs only after a
mismatch. `fold_entries` makes a different dependency. In its `More` equation,
the `folded_rest` binding completes the fold of the complete tail before
`combine entry folded_rest` runs. The pinned [dynamic binding
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#bindings)
evaluate a binding initializer before extending the environment and continuing
with the block.

`prefer_current` receives the result already folded from older entries. A
matching current entry replaces that older result with `Some(value)`; a
nonmatching current entry retains `found`. Because the newest entry combines
last, its match still shadows an older match. The fold nevertheless applies
equality once at every entry.

<!-- source: src/03-selective-and-fold.ash -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> ((Dictionaries.Option<Int>, Int), (Dictionaries.Option<Int>, Int))
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let second_dictionary = Dictionaries.insert 2 20 first_dictionary
    let dictionary = Dictionaries.insert 1 11 second_dictionary
    (
        Dictionaries.lookup_counted int_equal 1 dictionary,
        Dictionaries.lookup_through_fold_counted int_equal 1 dictionary
    )
}
```

Both calls receive query `1` and the same three-entry dictionary. Predict the
same `Some(11)` result from each. Predict count `1` for selective lookup and
count `3` for the strict fold.

Run the comparison:

```text
ash dictionary-as-list/src/03-selective-and-fold.ash
```

<!-- markdownlint-disable MD013 -->
```text
((Some(11), 1), (Some(11), 3)) : ((Option<Int>, Int), (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

Both algorithms select the front match, but their source dependencies differ.
Selective lookup does not enter the older equality applications after a front
match. The strict fold completes them before it can combine that front entry.
The result type pairs each `Option<Int>` selection with its comparison count.
This comparison assumes a finite dictionary and that every equality
application required by the chosen algorithm returns. The fold can therefore
enter older equality work that selective lookup skips.

## Keep both dictionary versions

The final entry gives names to the two-entry and three-entry dictionaries.
`newer_dictionary` uses `older_dictionary` directly as the tail supplied to
`insert`, and both values remain available to later expressions.

<!-- source: src/04-retained-versions.ash -->
```ash
import dictionaries as Dictionaries

int_equal : Int -> Int -> Bool
int_equal left right = left == right

main : Unit -> ((Dictionaries.Option<Int>, Int), (Dictionaries.Option<Int>, Int))
main () = {
    let empty_dictionary = Dictionaries.empty ()
    let first_dictionary = Dictionaries.insert 1 10 empty_dictionary
    let older_dictionary = Dictionaries.insert 2 20 first_dictionary
    let newer_dictionary = Dictionaries.insert 1 11 older_dictionary
    (
        Dictionaries.lookup_counted int_equal 1 older_dictionary,
        Dictionaries.lookup_counted int_equal 1 newer_dictionary
    )
}
```

Before running it, follow the two visible chains. In `older_dictionary`, query
`1` first crosses key `2` and then finds value `10`, for two comparisons. In
`newer_dictionary`, the new front entry immediately supplies value `11`, for
one comparison.

Run the retained-version entry:

```text
ash dictionary-as-list/src/04-retained-versions.ash
```

<!-- markdownlint-disable MD013 -->
```text
((Some(10), 2), (Some(11), 1)) : ((Option<Int>, Int), (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

The older value remains observable through the older dictionary, while the
new front value shadows it in the newer dictionary. One call to `insert`
completes one `Entry` application and one `More` application; it performs no
equality application and reconstructs no older entry. The two
`(Option<Int>, Int)` fields make each version's selected value and comparison
count observable. The two earlier entries remain reachable from
`older_dictionary` and, behind the new front entry, from
`newer_dictionary`.

This is a source-level construction and reachability account. It does not
establish object or pointer identity, exact heap bytes, garbage-collection or
liveness behavior, or a compiler representation. The pinned [observation
rules](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#observation)
render tuples and constructors structurally; the output does not expose those
implementation choices. Each complete line follows the tool's
[successful-output
contract](https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#successful-output):
one value, its checked type, and a newline.

## Practice: change the front

First, predict the result and comparison count for queries `2` and `4` in the
three-entry dictionary. Check each prediction with `lookup_counted`, then
explain which equality result selected or continued the traversal.

Next, retain the three-entry dictionary and insert `(2, 21)` to make a newer
version. Predict lookup of `2` in both versions. Compare selective and folded
counts for the newer version, and explain why inserting the duplicate does not
remove the older `(2, 20)` entry.

This case does not require equality laws or interfaces, evidence selection,
key ordering, trees, balancing, opacity, deletion, mutation or in-place update,
or lazy, infinite, or cyclic data. Its source counts say nothing about host
stack use, tail-call optimization, elapsed time, machine instructions, exact
heap bytes, garbage collection, pointer identity, or compiler optimization.

A single `rest` gives lookup one next place to search. How does the
data-directed method extend when recursive data branches into a tree?
