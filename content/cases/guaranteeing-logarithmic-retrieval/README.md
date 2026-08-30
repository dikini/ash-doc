# How can the representation prevent a search tree from degenerating?

Opacity answered who may assemble dictionary nodes. It did not constrain the
shape produced by the public operations. In the preceding case, ascending keys
could still form a right chain with height `h = n`. Lookup followed only one
branch, but that branch could contain every key.

A hidden color on each nonempty node gives insertion enough information to
limit that height. Color does not change search order. It records a second
invariant that prevents any root-to-empty path from becoming much longer than
the others. The dictionary remains persistent: insertion returns a new value
and reconstructs only the entered path and a bounded neighborhood around each
repair.

## Separate recursive consistency from the root

The hidden representation adds a private `Color` field:

```text
Dictionary<K, V>
    Empty
    Node(color, left, key, value, right)
```

`Empty` counts as black. A subtree is recursively consistent when three
conditions hold:

1. It has the global ordering invariant from the preceding case. Every left
   descendant is `Less` than the current key, and every right descendant is
   `Greater`.
2. A red node has no red child.
3. Every path from the subtree root to `Empty` contains the same number of
   black forms.

A recursively consistent subtree may have a red root. A completed public
dictionary adds one more condition: its root is black, unless the dictionary
is `Empty`. Keeping the root condition separate lets red subtrees participate
in repair without making red nodes invalid everywhere.

The opaque declaration still controls only source access. Importers can name
`Dictionary<K, V>`, but cannot name its constructors under Ash's
[public and opaque declaration rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations).
The defining module can construct any of its forms, including invalid ones.
Neither the nominal type nor `Order<K>` proves these representation laws.

The module checks ordering and balance in two passes. `valid_between` carries
the inherited lower and upper key bounds through the whole tree. A separate
balance pass returns either `Invalid` or the common black-height. It binds both
child summaries before comparing them, just as the ordering pass binds both
recursive results before combining them. Ash bindings evaluate their
initializers before continuing under the pinned
[binding rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#bindings),
so a completed validation enters both branches in both passes. A final check
tests only the top-level root color.

The defining module contains five private trees. Predict one `true` followed
by four `false` values:

- a valid one-node black tree;
- a tree with a deeper key beyond an inherited ordering bound;
- a red root whose recursive properties otherwise hold;
- a red parent with red children whose ordering and black-height hold; and
- a tree whose two root paths contain different black counts.

These cases distinguish the checks. They do not prove that insertion preserves
them for every input.

## Repair one colored path

Insertion first follows the ordered branch selected by `compare`. At `Empty`,
it constructs a red leaf. A black leaf would increase the black count on only
the entered path. A red leaf leaves that count unchanged, but it may appear
below a red parent.

That red-red edge has a red parent on either the left or right of a black
grandparent. The new red child can also be on either side of its parent. These
two choices produce exactly four orientations:

| Orientation | Insertion order |
|---|---|
| left-left | `3, 2, 1` |
| left-right | `3, 1, 2` |
| right-left | `1, 3, 2` |
| right-right | `1, 2, 3` |

All four contain three increasing key-value associations separated by four
subtrees. One normalization gives them the same local result:

```text
                         [Red]
                    middle:middle_value
                    /                  \
             [Black]                  [Black]
        first:first_value          last:last_value
          /           \              /          \
       first         second        third        fourth
      subtree        subtree       subtree      subtree
```

Every value stays paired with its key. The four surrounding subtree values pass
unchanged into the new constructors, and the in-order sequence remains first,
middle, last. The source expresses this shared result in `restore_three`; four
nested `restore` patterns only select which fields supply it. Pattern selection
follows Ash's exhaustive
[pattern and match rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage).

The transient candidate differs from a recursively consistent tree only at
the red-red edge, so the four surrounding subtrees have one common
black-height. Each new black child adds one black form above two of those
subtrees. The red middle root adds none. Every path through the normalized
result therefore has the common subtree black-height plus one, the same count
as through the former black grandparent. Repair preserves equal black-height
as well as order and associations.

This functional insertion strategy takes conceptual inspiration from the
tradition evaluated in the
[persistent red-black insertion record](../../../research/persistent-red-black-insertion.md).
The Ash program, diagram, derivation, examples, and exercises here are original.

As recursion returns, a repaired red middle node can become the child of a red
ancestor. The next black grandparent repairs that edge. Because public
insertion starts from a valid black-rooted dictionary, reconstruction removes
every red-red edge before the internal result reaches the top. `blacken_root`
then restores only the public root-color condition. Recoloring a red root adds
one black form to every root path equally; it does not change key order or
key-value associations.

Equal insertion takes a different arm. It retains the stored representative
key, current color, and both branches while replacing only the value. It creates
no red leaf and needs no repair.

Here is the complete defining module.

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

type Color =
    Red
    | Black

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)

type BalanceCheck =
    Invalid
    | Valid(Int)

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
lookup query Node(ignored_color, left, current_key, current_value, right) = match compare query current_key {
    Less => lookup query left
    Equal => Some(current_value)
    Greater => lookup query right
}

restore_three : Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> K -> V -> Dictionary<K, V> -> Dictionary<K, V>
restore_three first first_key first_value second middle_key middle_value third last_key last_value fourth = Node(
    Red,
    Node(Black, first, first_key, first_value, second),
    middle_key,
    middle_value,
    Node(Black, third, last_key, last_value, fourth)
)

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

insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert_colored key value Empty = Node(Red, Empty, key, value, Empty)
insert_colored key value Node(color, left, current_key, current_value, right) = match compare key current_key {
    Less => restore color (insert_colored key value left) current_key current_value right
    Equal => Node(color, left, current_key, value, right)
    Greater => restore color left current_key current_value (insert_colored key value right)
}

blacken_root : Dictionary<K, V> -> Dictionary<K, V>
blacken_root dictionary = match dictionary {
    Empty => Empty
    Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) => dictionary
    Node(Red, left, key, value, right) => Node(Black, left, key, value, right)
}

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value dictionary = blacken_root (insert_colored key value dictionary)

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
valid_between lower upper Node(ignored_color, left, key, ignored_value, right) = {
    let respects_lower = above_lower lower key
    let respects_upper = below_upper key upper
    let left_valid = valid_between lower (Some(key)) left
    let right_valid = valid_between (Some(key)) upper right
    both respects_lower (both respects_upper (both left_valid right_valid))
}

is_black : Dictionary<K, V> -> Bool
is_black Empty = true
is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

children_colors_hold : Color -> Dictionary<K, V> -> Dictionary<K, V> -> Bool
children_colors_hold Black left right = true
children_colors_hold Red left right = both (is_black left) (is_black right)

add_black : Color -> Int -> Int
add_black Red height = height
add_black Black height = height + 1

balance_summary : Dictionary<K, V> -> BalanceCheck
balance_summary Empty = Valid(1)
balance_summary Node(color, left, ignored_key, ignored_value, right) = {
    let left_result = balance_summary left
    let right_result = balance_summary right
    let children_hold = children_colors_hold color left right
    match (left_result, right_result) {
        (Invalid, ignored_right_result) => Invalid
        (Valid(ignored_left_height), Invalid) => Invalid
        (Valid(left_height), Valid(right_height)) => match children_hold {
            false => Invalid
            true => match left_height == right_height {
                false => Invalid
                true => Valid(add_black color left_height)
            }
        }
    }
}

balance_holds : Dictionary<K, V> -> Bool
balance_holds dictionary = match balance_summary dictionary {
    Invalid => false
    Valid(ignored_height) => true
}

root_is_black : Dictionary<K, V> -> Bool
root_is_black Empty = true
root_is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
root_is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>
invariant_holds dictionary = {
    let ordered = valid_between None None dictionary
    let balanced = balance_holds dictionary
    let black_root = root_is_black dictionary
    both ordered (both balanced black_root)
}

main : Unit -> (Bool, Bool, Bool, Bool, Bool)
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let four = Next(three)
    let valid = Node(Black, Empty, one, 10, Empty)
    let invalid_order = Node(
        Black,
        Node(Black, Empty, one, 10, Node(Red, Empty, three, 30, Empty)),
        two,
        20,
        Node(Black, Empty, four, 40, Empty)
    )
    let red_root = Node(Red, Empty, one, 10, Empty)
    let red_red = Node(
        Black,
        Node(
            Red,
            Node(Red, Empty, one, 10, Empty),
            two,
            20,
            Node(Red, Empty, three, 30, Empty)
        ),
        four,
        40,
        Empty
    )
    let uneven_black_height = Node(
        Black,
        Node(Black, Empty, one, 10, Empty),
        two,
        20,
        Empty
    )
    (
        invariant_holds valid,
        invariant_holds invalid_order,
        invariant_holds red_root,
        invariant_holds red_red,
        invariant_holds uneven_black_height
    )
}
```
<!-- markdownlint-enable MD013 -->

The private `main` returns the five predictions in fixture order. Run the module
directly from `content/cases`:

```text
ash guaranteeing-logarithmic-retrieval/src/dictionaries.ash
```

```text
(true, false, false, false, false) : (Bool, Bool, Bool, Bool, Bool)
```

The result shows that this validator distinguishes each selected malformed
shape from the valid one. It remains an observation of five finite values, not
a type-level proof or an exhaustive preservation argument.

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

<!-- source: src/01-prefix-matrix.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import dictionaries as Dictionaries

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
[observation rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation)
render nominal data structurally. That output does not export the private color
type or either opaque dictionary constructor. It gives client source no new
name to construct or match.

## Derive the logarithmic bound

Let `n` count nonempty `Node` forms. Let `h` be the largest number of `Node`
forms on a path from the root to `Empty`. Let `q` be the equal number of black
forms on such a path, including the terminal `Empty`.

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
[constrained-scheme rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#interfaces-and-constrained-schemes);
it does not encode those laws.

The return and height claims apply to finite valid dictionary spines produced
from `empty` by completed public insertions and finite builds. A required
comparison that does not return can prevent lookup, insertion, build, or
ordering validation from returning. Code in the defining module can still
construct an invalid value, a constructor-guarded cyclic spine, or a bad public
operation. The static
[recursive block-group rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#recursive-block-groups)
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
