# How can the representation prevent a search tree from degenerating?

The dictionary from the preceding case hides its constructors, but insertion
can still build a long chain. Insert the associations `(3, 30)`, `(2, 20)`,
and `(1, 10)` into an empty dictionary. Ordered insertion puts `2` below the
left branch of `3`, then `1` below the left branch of `2`. Looking up `1` visits
all three nodes. Repeating that pattern gives height `h = n`: one ordered
branch can contain every key.

We want insertion to keep lookup paths short while retaining the same
associations. For these three keys, `2` can be the root, with `1` and `3` as
its children. Lookup still uses the key comparison from the preceding case.
The change belongs in how insertion constructs the tree.

A hidden color on each nonempty node will tell insertion when a local path
needs repair. We will develop that data, state the operations it needs, then
calculate their bodies using the three-association example. Insertion remains
persistent: it returns a new dictionary, leaving the earlier value available.

{{< pagebreak >}}

## Describe the colored data

The keys and values retain their meanings. A `Dictionary<K, V>` associates
keys of type `K` with values of type `V`. Its recursive alternatives tell us
whether there is an association at the current position. The following
non-executable declaration excerpt adds a color to the representation:

<!-- markdownlint-disable MD013 -->

<!-- excerpt: src/dictionaries.ash#representation -->

```text
type Color =
    Red
    | Black

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)
```

<!-- markdownlint-enable MD013 -->

`Empty` has no association. `Node` contains a color, the left dictionary, a
key, its associated value, and the right dictionary, in that order. `K` and
`V` describe every association in that tree. We reuse `Natural`, `Option`,
`Ordering`, and the `Order<K>` comparison from the preceding case. The new
`Color` has exactly two alternatives, `Red` and `Black`.

A color is useful only with rules for interpreting it. `Empty` counts as
black.[^red-root-example] A black node adds one to the count on every path
below it; a red node adds none. We call the common count, including the
terminal `Empty`, the subtree's *black-height*. It measures the black forms
on a path, rather than all its nonempty nodes.

A subtree is recursively consistent when three conditions hold:

1. It has the global ordering invariant from the preceding case. Every left
   descendant is `Less` than the current key, and every right descendant is
   `Greater`.
2. A red node has no red child.
3. Every path from the subtree root to `Empty` contains the same number of
   black forms.

A recursively consistent subtree may have a red root. A completed public
dictionary adds one more condition: its root is black, unless the dictionary
is `Empty`. Separating that final condition lets red subtrees participate in
insertion. In the three-key result, a black `2` with black children `1` and `3`
meets all four conditions: every path counts the root, one black child, and
its terminal `Empty`, giving black-height three. A black `3` with only a red
left child `2` also has equal counts. The shorter right path counts `3` and
`Empty`; each longer left path counts the same two black forms. Equal
black-height therefore allows some difference in total path length. The
rule against adjacent red nodes limits how much longer a path can become.

<!-- markdownlint-disable MD013 -->

[^red-root-example]: Both paths contain one black form: their terminal `Empty`.
    A red root adds no black form.

    ![A red root with two black Empty forms.](assets/red-root-sketch.svg){#red-root-sketch fig-alt="A schematic red root has two Empty children, each counted as black. Each path contains one black form; the red root contributes none." width=100%}

<!-- markdownlint-enable MD013 -->

The opaque declaration controls source access. Importers can name
`Dictionary<K, V>`, but cannot name its constructors under Ash's
[public and opaque declaration rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/name-resolution.md#public-private-and-opaque-declarations).
The defining module can construct any of its forms, including invalid ones.
Neither the nominal type nor `Order<K>` proves the representation laws. We
must design the operations to preserve them.

## State the operations we need

Work out the function types before filling their bodies. In the following
type calculations, `D` abbreviates `Dictionary<K, V>` in the explanation;
it is not a new Ash type or a declaration in the program. The source
signatures keep the full spelling.

The public operation has the same job as before: insert a key and value into
a valid dictionary. If the comparison is `Equal`, replace that association's
value; otherwise add the association. Return a valid dictionary with all
other associations retained. We supply a key of type `K`, then a value of
type `V`, then a dictionary of type `D`; the result must also have type `D`.
Reading those inputs and the result in order gives `K -> V -> D -> D`.
Comparison needs `Order<K>`, so the signature includes that requirement.
The following source signature is a non-executable excerpt:

<!-- markdownlint-disable MD013 -->

<!-- signature: src/dictionaries.ash#insert -->

```text
pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
```

<!-- markdownlint-enable MD013 -->

Insertion still descends through one ordered branch. We need an internal
operation that performs that descent while allowing a temporary red root or
an edge between two red nodes. Its input is a recursively consistent
subtree. Its result retains ordering and black-height, but may have a
red-red edge directly below its red root. A black ancestor must repair that
edge. The requirement on `Order<K>` supplies the comparison that selects the
branch. Its job still takes a `K`, a `V`, and a `D` and returns a `D`, so
`insert_colored` has the same function type as public insertion:

<!-- markdownlint-disable MD013 -->

<!-- signature: src/dictionaries.ash#insert_colored -->

```text
insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
```

<!-- markdownlint-enable MD013 -->

When recursion returns a child, the parent has its color, its two branches,
and its own association available. These five pieces have types `Color`,
`D`, `K`, `V`, and `D`, in constructor-field order. Rebuilding or repairing
that parent must return a `D`. Write one arrow after each input type, then
put `D` for the result. This calculates the signature of `restore`, which
repairs a red-red edge beneath a black parent when it finds one:

<!-- markdownlint-disable MD013 -->

::: {#wide-restore-signature .column-page-right}

<!-- signature: src/dictionaries.ash#restore -->

```text
restore : Color -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
```

:::

<!-- markdownlint-enable MD013 -->

That repair will rearrange three associations with four intervening subtrees.
Every subtree has type `D`, every key has type `K`, and every associated
value has type `V`. `restore_three` consumes them in their increasing order:
subtree, key, value, subtree, key, value, subtree, key, value, subtree. Write
one arrow after each of those ten inputs, then put `D` for the result.
That calculation gives the longer signature below. Its last dictionary
type is the output; the preceding four are subtree inputs. The different
orientations will supply the same types of pieces to this one construction:

<!-- markdownlint-disable MD013 -->

::: {#wide-restore-three-signature .column-page-right}

<!-- signature: src/dictionaries.ash#restore_three -->

```text
restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
```

:::

<!-- markdownlint-enable MD013 -->

Finally, internal insertion may return a red root. `blacken_root` restores
the public root condition without searching the tree or changing an
association. It receives one whole dictionary and returns one whole
dictionary, giving `D -> D`:

<!-- markdownlint-disable MD013 -->

<!-- signature: src/dictionaries.ash#blacken_root -->

```text
blacken_root : Dictionary<K, V> -> Dictionary<K, V>
```

<!-- markdownlint-enable MD013 -->

We can already check how these operations fit together. Once we supply
`key : K` and `value : V`, `insert_colored key value` has remaining type
`D -> D`. Give it a dictionary and its result has type `D`.
`blacken_root` accepts that result because its input type is also `D`.
Its output is `D`, which is exactly what public insertion promises.
We have calculated the connection between the two operations before
choosing either body. Ash checks application inputs and results under its
[function and application typing rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#functions-and-application).

These signatures describe the shapes of inputs and outputs. The purposes add
requirements that the types do not express. Completed dictionaries and
temporary insertion results have the same `Dictionary<K, V>` type; their
stated conditions differ. In particular, `restore` is a local repair for
candidates produced by insertion. It is not a general operation for
correcting an arbitrary malformed tree.

## Repair one colored path

We have the function types and the conditions each operation must maintain.
Now fill the public operation, follow its call into recursive insertion,
and develop the smaller repair it needs. The three-association example will
let us check each choice with a concrete tree.

The following calculations are schematic source calculations, not runnable
programs or tool output. Numerals stand for the corresponding `Natural`
keys; values such as `10` remain integers.

Begin with the public goal. The type calculation already tells us how the
two operations connect: obtain the internal insertion result, then pass that
whole dictionary to `blacken_root`. Assuming those operations do their
stated jobs, this expression gives public insertion the required result:

<!-- markdownlint-disable MD013 -->

<!-- excerpt: src/dictionaries.ash#insert -->

```text
pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value dictionary = blacken_root (insert_colored key value dictionary)
```

<!-- markdownlint-enable MD013 -->

The body names the two remaining jobs. We can develop each one from its
promised input and result, starting with the insertion that produces the
dictionary for `blacken_root`.

### Insert into the recursive data

`insert_colored` must give public insertion a dictionary with the new or
replaced association. Its input is either `Empty` or `Node`, so those two
alternatives supply its first cases. At `Empty`, a new association needs
two empty children. The replaced `Empty` contributes one black form. A red
node above two `Empty` children also contributes one on each path, leaving
the count unchanged. A black node would make that count two on only the
entered branch. This determines the new node's red color and gives the
first expected result:

```text
insert_colored 1 10 Empty
=> Node(Red, Empty, 1, 10, Empty)
```

At a `Node`, comparison gives three cases. For `Less`, recur on `left`.
Its type is `D`, and the function type tells us that
`insert_colored key value left` returns `D`. Assume this smaller call inserts
the association and preserves ordering and black-height, allowing a red-red
edge directly below a red root.

The returned left dictionary can now replace the old left field. The other
four fields retain their types: `color : Color`, `current_key : K`,
`current_value : V`, and `right : Dictionary<K, V>`. Put the five pieces in
the order required by `restore`. Its result is the whole dictionary this
case needs. At a black parent it can repair the returned child's edge;
at a red parent it reconstructs the subtree for the enclosing ancestor.
This determines the combining expression in the `Less` arm. `Greater`
makes the same calculation with the returned right dictionary. For a finite
dictionary, each recursive input is a smaller child, so descent reaches
`Empty` or an equal key, provided the comparisons return.

On `Equal`, inserting `(2, 99)` over `(2, 20)` retains the stored key,
children, and color, changing only the value. This supplies the middle arm
without recursion or repair. The completed excerpt is:

<!-- markdownlint-disable MD013 -->

::: {#wide-insert-colored-excerpt .column-page-right}

<!-- excerpt: src/dictionaries.ash#insert_colored -->

```text
insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert_colored key value Empty = Node(Red, Empty, key, value, Empty)
insert_colored key value Node(color, left, current_key, current_value, right) = match compare key current_key {
    Less => restore color (insert_colored key value left) current_key current_value right
    Equal => Node(color, left, current_key, value, right)
    Greater => restore color left current_key current_value (insert_colored key value right)
}
```

:::

<!-- markdownlint-enable MD013 -->

### Repair the returned child

Insertion has asked `restore` to construct a dictionary from the parent
fields, with one child replaced by the recursive result. Its type already
tells us the five inputs and their result. Which field patterns need repair?
A black parent can receive a red child with a red child of its own. That
local candidate contains three associations in increasing order, with four
intervening subtrees. Name them first, middle, and last; name the subtrees
`A`, `B`, `C`, and `D` from left to right.

For the running example, black `3` receives red `2` with red `1` below it.
The parent must return the same associations without that red-red edge.
The shared helper's job is to return red middle above black first and last,
with `A` and `B` below first and `C` and `D` below last. This gives `restore`
a result to request while we have yet to fill `restore_three`'s body.
A nested pattern can name the pieces needed by that call:

- The outer parent is black and supplies the last association, `(3, 30)`.
- Its red left child supplies the middle association, `(2, 20)`.
- That child's red left child supplies the first association, `(1, 10)`.
- The remaining child fields supply `A`, `B`, `C`, and `D` in increasing order.

Those names give the arguments to `restore_three` directly. The expected
calculation is:

```text
restore Black
    Node(Red, Node(Red, Empty, 1, 10, Empty), 2, 20, Empty)
    3 30 Empty
=> restore_three Empty 1 10 Empty 2 20 Empty 3 30 Empty
=> red 2 above black 1 and black 3, with the same values
```

A red parent can be on either side of the black grandparent, and its red
child can be on either side again. We need four patterns, rather than a rule
that repairs only the descending example:

| Orientation | Insertion order | Fields supplying first, middle, last |
| --- | --- | --- |
| left-left | `3, 2, 1` | grandchild, child, parent |
| left-right | `3, 1, 2` | child, grandchild, parent |
| right-left | `1, 3, 2` | parent, grandchild, child |
| right-right | `1, 2, 3` | parent, child, grandchild |

For instance, `3, 1, 2` puts the middle association in the red child's right
branch. The second pattern must take it from that branch. The destination is
unchanged: red middle above black first and last. Each pattern only selects
which candidate fields supply that shared construction.

{{< pagebreak >}}

What should happen when none of the four patterns fits? Inserting `2` below
black `3` creates only one red child, so there is no red-red edge to repair.
Returning the parent's fields in an ordinary `Node` preserves that result.
This fallback also reconstructs a red parent. If its returned child is red,
a black ancestor will handle the edge between them. The complete equation
group is:

<!-- markdownlint-disable MD013 -->

::: {#wide-restore-excerpt .column-page-right}

<!-- excerpt: src/dictionaries.ash#restore -->

```text
restore : Color -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore Black Node(
    Red,
    Node(Red, first, first_key, first_value, second),
    middle_key,
    middle_value,
    third
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black Node(
    Red,
    first,
    first_key,
    first_value,
    Node(Red, second, middle_key, middle_value, third)
) last_key last_value fourth = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    Node(Red, second, middle_key, middle_value, third),
    last_key,
    last_value,
    fourth
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore Black first first_key first_value Node(
    Red,
    second,
    middle_key,
    middle_value,
    Node(Red, third, last_key, last_value, fourth)
) = restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth
restore color left key value right = Node(color, left, key, value, right)
```

:::

<!-- markdownlint-enable MD013 -->

Ash tries these patterns in source order and selects the first matching
equation once the arguments have arrived. The final equation handles every
remaining color and subtree shape. The
[pattern and coverage rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#patterns-matches-and-coverage)
check that the equations cover the input type. The
[evaluation rules for matches and equations](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#tuples-constructors-and-matches)
explain which body executes. Neither check establishes the ordering or
black-height premises we used in the repair calculation.

### Construct the shared repair result

`restore_three` receives the ten values selected by `restore` and must
construct one `Dictionary<K, V>`. The middle association separates the
first two subtrees from the last two. Place the first association above
`first` and `second`, and the last above `third` and `fourth`. Those two
constructed dictionaries can become the middle node's children.

Give the first and last nodes black colors to remove the red-red edge and
allow red-rooted surrounding subtrees. Keep the middle root red to retain
the black-height. For the running example, the four subtrees are `Empty`
and the associations are `(1, 10)`, `(2, 20)`, and `(3, 30)`. The expected
local result makes the construction concrete:

```text
Node(
    Red,
    Node(Black, Empty, 1, 10, Empty),
    2,
    20,
    Node(Black, Empty, 3, 30, Empty)
)
```

This is the result of the local repair, before public insertion blackens its
root. Each value stays with its key. In the general body, the association
names are `first_key`, `middle_key`, and `last_key`, with their corresponding
values. The four subtree positions are `first`, `second`, `third`, and
`fourth`. The drawing uses `A`, `B`, `C`, and `D` for those subtrees:

<!-- markdownlint-disable MD013 -->

::: {#repair-comparison .column-page-right}

![Left-left repair preserves the associations and subtrees; the same result handles all four orientations.](assets/tree-repair.svg){#fig-tree-repair fig-alt="Before left-left repair, a black last node has red middle and first nodes down its left branch. First has subtrees A and B; middle has C on its right; last has D on its right. After repair, red middle has black first and last children. First retains A and B, and last retains C and D. Each key stays with its value." width=100%}

:::

<!-- markdownlint-enable MD013 -->

The ordering tells us where each subtree belongs. `A` and `B` stay below the
first key. `C` and `D` become the children of the last key. The middle key
separates those two constructed dictionaries. Each subtree must retain its
inherited key bounds: `A` below the first key, `B` between first and middle,
`C` between middle and last, and `D` above the last key. Their roots may be
red; making the first and last nodes black also prevents a new red-red edge
where those subtrees attach. The constructor expression we just calculated
therefore completes `restore_three`:

<!-- markdownlint-disable MD013 -->

::: {#wide-restore-three-excerpt .column-page-right}

<!-- excerpt: src/dictionaries.ash#restore_three -->

```text
restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth = Node(
    Red,
    Node(Black, first, first_key, first_value, second),
    middle_key,
    middle_value,
    Node(Black, third, last_key, last_value, fourth)
)
```

:::

<!-- markdownlint-enable MD013 -->

This definition is a non-executable excerpt from the complete companion
module. It constructs three nodes and passes the four subtree values
unchanged into them. It needs no comparison: its caller must supply the
associations and subtrees in the required order.

For the insertion candidates we will produce, the four surrounding subtrees
are recursively consistent and have one common black-height. The candidate
may contain the one red-red edge being repaired. If the common height is
`b`, the former black grandparent contributes one, giving `b + 1` on every
path. The result's black children each contribute one and its red root
contributes none, so every path still has `b + 1`. This calculation explains
why the colors in the body preserve the count.

### Restore the public root condition

Internal insertion has kept the associations ordered and the path counts
equal, but our calculated root is red. `blacken_root` has three meaningful
inputs: `Empty`, a black node, or a red node. The first two already meet the
public root condition and should be returned unchanged. For a red node,
retain its association and both children and change only its color:

<!-- markdownlint-disable MD013 -->

<!-- excerpt: src/dictionaries.ash#blacken_root -->

```text
blacken_root : Dictionary<K, V> -> Dictionary<K, V>
blacken_root dictionary = match dictionary {
    Empty => Empty
    Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) => dictionary
    Node(Red, left, key, value, right) => Node(Black, left, key, value, right)
}
```

<!-- markdownlint-enable MD013 -->

For our local result, that final case returns black `2` with black `1` and
`3` beneath it. Every path gains the same one black form. Recoloring the
root changes neither ordering nor key-value associations.

### Assemble and run the example

Starting with `Empty`, inserting `(3, 30)` creates red `3`, then blackens it.
Inserting `(2, 20)` leaves black `3` with a red left child because no repair
pattern fits. Inserting `(1, 10)` now selects `Less` at both nodes.
At `Empty`, the first equation returns red `1`. The pending reconstruction
at `2` receives that result:

```text
restore Red Node(Red, Empty, 1, 10, Empty) 2 20 Empty
=> Node(Red, Node(Red, Empty, 1, 10, Empty), 2, 20, Empty)
```

Its parent color is red, so none of the four repair equations fits; the
fallback produces the temporary red-red edge. The next pending
reconstruction, at black `3`, receives the candidate derived for the
left-left repair. Its first pattern selects `restore_three`, which returns
red `2` with black `1` and `3` as children.

The nested recursive expression is evaluated before `restore` receives that
child value, under Ash's strict
[application rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#application).
The calculation therefore descends through comparisons, then reconstructs
from the returned child toward the root. A repair can return a red root
beneath a red ancestor; the next black grandparent handles that edge.
Starting from a valid black-rooted dictionary ensures that any such edge
has a black grandparent before the internal result reaches the top.

The final `blacken_root` call changes the returned red `2` to black. Predict
that black root with black children `1` and `3`, and the original values
`10`, `20`, and `30` still paired with their keys.

The complete client below names the three `Natural` keys explicitly and uses
only public operations. The `impl Order` import item supplies the public
ordering implementation, as in the preceding case.

<!-- markdownlint-disable MD013 -->

<!-- source: src/03-repair.ash -->

```ash
import dictionaries (Dictionary, Natural, Zero, Next, empty, insert, impl Order)

main : Unit -> Dictionary<Natural, Int>
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let after_three = insert three 30 (empty ())
    let after_two = insert two 20 after_three
    insert one 10 after_two
}
```

<!-- markdownlint-enable MD013 -->

Run it from `content/cases`:

```text
ash guaranteeing-logarithmic-retrieval/src/03-repair.ash
```

<!-- markdownlint-disable MD013 -->

```text
Node(Black, Node(Black, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 20, Node(Black, Empty, Next(Next(Next(Zero))), 30, Empty)) : Dictionary<Natural, Int>
```

<!-- markdownlint-enable MD013 -->

The printed tree makes each predicted association and color visible. Opacity
prevents the client from constructing or matching these nodes; the tool can
still display the returned value. The result checks this particular
calculation. It does not establish preservation for every dictionary.

The [complete dictionary module](src/dictionaries.ash) also contains the
ordering and balance checks used later in the chapter. `valid_between`
checks inherited key bounds. A separate pass obtains each child's
black-height, rejects red-red edges and unequal counts, and a final check
examines the root. Both passes bind both recursive child results before
combining them. Ash's strict
[binding rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#bindings)
mean that a completed validation enters both branches.

The defining module's private `main` constructs five trees to distinguish
these checks. Predict one `true` followed by four `false` values:

- a valid one-node black tree;
- a deeper key beyond an inherited ordering bound;
- a red root whose recursive properties otherwise hold;
- a red parent with red children whose ordering and black-height hold; and
- two root paths with different black counts.

Run the complete companion directly from `content/cases`:

```text
ash guaranteeing-logarithmic-retrieval/src/dictionaries.ash
```

```text
(true, false, false, false, false) : (Bool, Bool, Bool, Bool, Bool)
```

This observation distinguishes the selected malformed values from the valid
one. The finite examples supplement the ordering and black-height
calculations; they do not replace the argument about what repair preserves.

This functional insertion strategy takes conceptual inspiration from the
tradition evaluated in the
[persistent red-black insertion record](../../../research/persistent-red-black-insertion.md).
The Ash program, diagram, derivation, examples, and exercises here are original.

## Check every selected insertion prefix

The first public client records six separate scenarios. Each `Scenario` begins
with the empty dictionary's validity. Every `PrefixCheck` then records four
facts after one insertion: the invariant, the newly inserted association, the
first retained association in that scenario, and one absent key. The final list
checks every exact key-value association again and ends with the same absence.

Predict `true` in every position for these sequences, in order: ascending
`1` through `7`, descending `7` through `1`, then left-left, left-right,
right-left, and right-right. The four three-key cases use the insertion orders
from the repair table.

The complete import makes the public names available through `Dictionaries`.
The separate `impl Order` import selects the library's public ordering
implementation for these calls, as in the earlier ordering Case.

<!-- source: src/01-prefix-matrix.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries
import dictionaries (impl Order)

type PrefixCheck =
    PrefixCheck(Bool, Bool, Bool, Bool)

type Scenario =
    Scenario(Bool, Dictionaries.List<PrefixCheck>, Dictionaries.List<Bool>)

type PrefixRun =
    PrefixRun(
        Dictionaries.List<PrefixCheck>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>
    )

has_value : Int -> Dictionaries.Option<Int> -> Bool
has_value expected Dictionaries.None = false
has_value expected Dictionaries.Some(actual) = expected == actual

is_none : Dictionaries.Option<A> -> Bool
is_none Dictionaries.None = true
is_none Dictionaries.Some(ignored_value) = false

prefix_run : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> PrefixRun
prefix_run Dictionaries.End retained_key retained_value absent_key dictionary = PrefixRun(
    Dictionaries.End,
    dictionary
)
prefix_run Dictionaries.More(entry, rest) retained_key retained_value absent_key dictionary = match entry {
    (key, value) => {
        let next_dictionary = Dictionaries.insert key value dictionary
        let current_check = PrefixCheck(
            Dictionaries.invariant_holds next_dictionary,
            has_value value (Dictionaries.lookup key next_dictionary),
            has_value retained_value (Dictionaries.lookup retained_key next_dictionary),
            is_none (Dictionaries.lookup absent_key next_dictionary)
        )
        let later_run = prefix_run rest retained_key retained_value absent_key next_dictionary
        match later_run {
            PrefixRun(later_checks, final_dictionary) => PrefixRun(
                Dictionaries.More(current_check, later_checks),
                final_dictionary
            )
        }
    }
}

lookup_checks : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Dictionaries.Dictionary<Dictionaries.Natural, Int> -> Dictionaries.List<Bool>
lookup_checks Dictionaries.End absent_key dictionary = Dictionaries.More(
    is_none (Dictionaries.lookup absent_key dictionary),
    Dictionaries.End
)
lookup_checks Dictionaries.More(entry, rest) absent_key dictionary = match entry {
    (key, value) => Dictionaries.More(
        has_value value (Dictionaries.lookup key dictionary),
        lookup_checks rest absent_key dictionary
    )
}

scenario : Dictionaries.List<(Dictionaries.Natural, Int)> -> Dictionaries.Natural -> Int -> Dictionaries.Natural -> Scenario
scenario entries retained_key retained_value absent_key = {
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let run = prefix_run entries retained_key retained_value absent_key empty
    match run {
        PrefixRun(checks, final_dictionary) => Scenario(
            Dictionaries.invariant_holds empty,
            checks,
            lookup_checks entries absent_key final_dictionary
        )
    }
}

main : Unit -> (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let four = Dictionaries.Next(three)
    let five = Dictionaries.Next(four)
    let six = Dictionaries.Next(five)
    let seven = Dictionaries.Next(six)
    let ascending = Dictionaries.More(
        (one, 10),
        Dictionaries.More(
            (two, 20),
            Dictionaries.More(
                (three, 30),
                Dictionaries.More(
                    (four, 40),
                    Dictionaries.More(
                        (five, 50),
                        Dictionaries.More(
                            (six, 60),
                            Dictionaries.More((seven, 70), Dictionaries.End)
                        )
                    )
                )
            )
        )
    )
    let descending = Dictionaries.More(
        (seven, 70),
        Dictionaries.More(
            (six, 60),
            Dictionaries.More(
                (five, 50),
                Dictionaries.More(
                    (four, 40),
                    Dictionaries.More(
                        (three, 30),
                        Dictionaries.More(
                            (two, 20),
                            Dictionaries.More((one, 10), Dictionaries.End)
                        )
                    )
                )
            )
        )
    )
    let left_left = Dictionaries.More(
        (three, 30),
        Dictionaries.More((two, 20), Dictionaries.More((one, 10), Dictionaries.End))
    )
    let left_right = Dictionaries.More(
        (three, 30),
        Dictionaries.More((one, 10), Dictionaries.More((two, 20), Dictionaries.End))
    )
    let right_left = Dictionaries.More(
        (one, 10),
        Dictionaries.More((three, 30), Dictionaries.More((two, 20), Dictionaries.End))
    )
    let right_right = Dictionaries.More(
        (one, 10),
        Dictionaries.More((two, 20), Dictionaries.More((three, 30), Dictionaries.End))
    )
    (
        scenario ascending one 10 Dictionaries.Zero,
        scenario descending seven 70 Dictionaries.Zero,
        scenario left_left three 30 Dictionaries.Zero,
        scenario left_right three 30 Dictionaries.Zero,
        scenario right_left one 10 Dictionaries.Zero,
        scenario right_right one 10 Dictionaries.Zero
    )
}
```
<!-- markdownlint-enable MD013 -->

Run the client:

```text
ash guaranteeing-logarithmic-retrieval/src/01-prefix-matrix.ash
```

<!-- markdownlint-disable MD013 -->
```text
(Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))))))), More(true, More(true, More(true, More(true, More(true, More(true, More(true, More(true, End))))))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))))))), More(true, More(true, More(true, More(true, More(true, More(true, More(true, More(true, End))))))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End))))), Scenario(true, More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), More(PrefixCheck(true, true, true, true), End))), More(true, More(true, More(true, More(true, End)))))) : (Scenario, Scenario, Scenario, Scenario, Scenario, Scenario)
```
<!-- markdownlint-enable MD013 -->

The two seven-key scenarios contain seven successful prefix checks and eight
successful final positions: seven exact associations plus the absence. Each
three-key scenario contains three prefix checks and four final positions. The
matrix exercises every named repair orientation and repeated repairs under
ascending and descending pressure.

It does not establish the general theorem by enumeration. A faulty repair can
be exposed by one of these runs, while the general preservation claim still
depends on the source equations, the representation conditions, and the
ordering premises.

## Retain build, replacement, and older values

Balancing changes the hidden shape, not the public dictionary operations. The
next client first inserts `two` and `one`, retains that older dictionary,
replaces `two` with `99`, and extends only the newer dictionary with `three`.
It also builds the extended value independently from the input order
`(two, 20)`, `(one, 10)`, `(two, 99)`, `(three, 30)`.

Predict four valid dictionaries. Lookup of `two` should return `20` in the old
value and `99` in both later constructions. Lookup of `three` should return
`None` in the old value and `Some(30)` in the extended and built values. The
structural part should show a black root with red children where those children
are present.

<!-- source: src/02-build-and-persistence.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries
import dictionaries (impl Order)

main : Unit -> (
    (
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>,
        Dictionaries.Dictionary<Dictionaries.Natural, Int>
    ),
    (Bool, Bool, Bool, Bool),
    (
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>,
        Dictionaries.Option<Int>
    )
)
main () = {
    let one = Dictionaries.Next(Dictionaries.Zero)
    let two = Dictionaries.Next(one)
    let three = Dictionaries.Next(two)
    let empty : Dictionaries.Dictionary<Dictionaries.Natural, Int> = Dictionaries.empty()
    let with_two = Dictionaries.insert two 20 empty
    let older = Dictionaries.insert one 10 with_two
    let replaced = Dictionaries.insert two 99 older
    let extended = Dictionaries.insert three 30 replaced
    let entries = Dictionaries.More(
        (two, 20),
        Dictionaries.More(
            (one, 10),
            Dictionaries.More(
                (two, 99),
                Dictionaries.More((three, 30), Dictionaries.End)
            )
        )
    )
    let built = Dictionaries.build entries
    (
        (older, replaced, extended, built),
        (
            Dictionaries.invariant_holds older,
            Dictionaries.invariant_holds replaced,
            Dictionaries.invariant_holds extended,
            Dictionaries.invariant_holds built
        ),
        (
            Dictionaries.lookup two older,
            Dictionaries.lookup two replaced,
            Dictionaries.lookup two built,
            Dictionaries.lookup three older,
            Dictionaries.lookup three extended,
            Dictionaries.lookup three built
        )
    )
}
```
<!-- markdownlint-enable MD013 -->

Run the client:

```text
ash guaranteeing-logarithmic-retrieval/src/02-build-and-persistence.ash
```

<!-- markdownlint-disable MD013 -->
```text
((Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 20, Empty), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Empty), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Node(Red, Empty, Next(Next(Next(Zero))), 30, Empty)), Node(Black, Node(Red, Empty, Next(Zero), 10, Empty), Next(Next(Zero)), 99, Node(Red, Empty, Next(Next(Next(Zero))), 30, Empty))), (true, true, true, true), (Some(20), Some(99), Some(99), None, Some(30), Some(30))) : ((Dictionary<Natural, Int>, Dictionary<Natural, Int>, Dictionary<Natural, Int>, Dictionary<Natural, Int>), (Bool, Bool, Bool, Bool), (Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>, Option<Int>))
```
<!-- markdownlint-enable MD013 -->

The first two rendered dictionaries differ only at the value paired with
`two`. The old one remains separately observable. The extended and built
dictionaries have the same structure and associations because the finite build
applies public insertion in input order.

`Red`, `Black`, `Node`, and `Empty` appear because Ash's
[observation rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#observation)
render nominal data structurally. That output does not export the private color
type or either opaque dictionary constructor. It gives client source no new
name to construct or match.

## Derive the logarithmic bound

Let `n` count nonempty `Node` forms. Let `h` be the largest number of `Node`
forms on a path from the root to `Empty`. Let `q` be the equal number of black
forms on such a path, including the terminal `Empty`.

::: {#height-counting-cue .column-margin}
*Counting cue.* Count terminal `Empty` in `q`, but only `Node` forms in `n`
and `h`.
:::

For a nonempty valid dictionary, each path contains `q - 1` black `Node` forms.
The root is black, and two red nodes cannot be adjacent. At most one red node
can therefore accompany each black node on a path:

```text
h <= 2 * (q - 1)
```

Now let `N(q)` be the least number of nodes in any recursively consistent
subtree whose paths contain `q` black forms. `N(1) = 0` because `Empty` has one
black form and no `Node`. For `q > 1`, a black root contributes one node, and
both children have black-height `q - 1`:

```text
N(q) >= 1 + 2 * N(q - 1)
```

A red root contributes no black form, so each of its nonempty black children
still has black-height `q`. Each black child contributes one node above two
subtrees of black-height `q - 1`. The red-rooted case therefore contains at
least `1 + 2 * (1 + 2 * N(q - 1))` nodes, which is larger than the black-rooted
case. Induction gives at least:

```text
2^(q - 1) - 1
```

nonempty nodes. Rearranging the two bounds gives:

```text
q - 1 <= log2(n + 1)
h <= 2 * log2(n + 1)
```

The empty dictionary has `n = h = 0` and is handled separately. These formulas
are mathematical consequences of the representation conditions, not Ash
numeric operations or timing measurements.

If lookup or insertion enters `m` existing nodes, it initiates exactly one
top-level key comparison at each node, so `m <= h`. If comparison `i` causes
`C(query, key_i)` selected method applications, exact comparison sub-work is:

```text
sum from i = 1 to m of C(query, key_i)
```

Only when every term is at most `Cmax`, with `Cmax >= 1`, may the combined
comparison account be summarized as `O(log(n + 1) * Cmax)`. Lookup constructs
no dictionary `Node` forms.

For an absent insertion, let `r` be the number of entered levels whose
`restore` call selects the three-node repair, and let `b` be `1` exactly when
root blackening constructs a replacement root. The evaluated source `Node`
applications are:

```text
m + 1 + 2r + b
```

Each entered level returns either one fallback `Node` or a repaired result with
three `Node` forms. Counting one result form per level as the baseline gives two
extra constructions for every repaired level, followed by one red leaf and at
most one final root construction. Because `0 <= r <= m` and `0 <= b <= 1`,
there are at most `3m + 2` applications. Insertion therefore constructs
`O(log(n + 1))` source-level representation nodes.

Equal replacement after entering `m` existing nodes constructs exactly `m`
`Node` forms: one replacement at the equal key and one fallback reconstruction
for each ancestor. It creates no red leaf, selects no repair, and returns the
already-black root unchanged.

`invariant_holds` is separate work. For a finite `n`-node dictionary, its
ordering pass visits every node once, and its balance pass visits every node
once. The ordering pass initiates `B = 0` bound comparisons when `n <= 1`; for
`n > 1`, `n - 1 <= B <= 2n - 2`. Its exact comparison-method work is
`sum C_r`, or `O(n * Cmax)` only under the same explicit bound on every term.
The balance pass performs a bounded number of named source operations per node,
with at most one child-height equality and one `Int` increment. The separate
root check is constant named source work. Thus validation uses linear named
source work outside comparison-method sub-work, and its two full traversals are
not part of the logarithmic lookup or insertion account. This account excludes
the arbitrary-precision bit cost of the private `Int` equality and addition.

## Keep the premises with the guarantee

The logarithmic argument fixes one `Order<K>` implementation whose required
comparisons return and satisfy the premises already used for ordered trees:
`Equal` is the chosen key equivalence, reversed strict comparisons reverse
`Less` and `Greater`, strict order is transitive, and equivalent keys relate to
every other key in the same way. The interface requirement supplies checked
comparison evidence under Ash's
[constrained-scheme rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#interfaces-and-constrained-schemes);
it does not encode those laws.

The return and height claims apply to finite valid dictionary spines produced
from `empty` by completed public insertions and finite builds. A required
comparison that does not return can prevent lookup, insertion, build, or
ordering validation from returning. Code in the defining module can still
construct an invalid value, a constructor-guarded cyclic spine, or a bad public
operation. The static
[recursive block-group rules](https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#recursive-block-groups)
admit guarded recursive data; opacity and red-black checks do not turn
finiteness into a type proposition.

Whole-tree validation enters both branches in each pass. Lookup and insertion
enter only the selected path, so an unentered cycle need not affect a completed
call. A cyclic key can prevent comparison from returning. Lookup may return a
cyclic value without traversing that payload, while final structural
observation may later render its active-path revisit as `<cycle>`. A cyclic
input list can prevent `build` from reaching `End`.

At source level, reconstruction supplies unentered branches and the four
surrounding repair subtrees unchanged to new `Node` applications. This is the
only reuse claim. The equations establish no mutation, pointer identity,
physical sharing, allocation count, heap layout, garbage-collection behavior,
elapsed time, native-stack use, tail-call optimization, or compiler
representation. It also establishes no arbitrary-precision integer bit-cost
bound.

## Practice and continue

1. Insert keys `5`, `3`, and `4` into an empty dictionary. Predict which repair
   orientation runs and draw the resulting colors and key-value positions.
2. Explain why inserting a later value for an equal key constructs no red leaf
   and selects no repair.
3. For an absent insertion that enters `m` existing nodes, triggers `r` repairs,
   and reconstructs the root when `b = 1`, derive `m + 1 + 2r + b` from the
   source equations.
4. Explain why changing a red root to black changes every root path's black
   count equally.
5. Starting from equal black-height and the rule against adjacent red nodes,
   derive the minimum-node recurrence and the final logarithmic height bound.

Balanced lookup enters only one logarithmic path. An in-order traversal must
eventually visit every association, but it need not produce them all at once.
How can traversal pause and resume without laziness?
