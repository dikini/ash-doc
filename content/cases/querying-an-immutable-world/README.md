# Querying an immutable world

An entity can have a position without a velocity. Another entity can have a
velocity without a position. A movement step needs both components for the
*same entity*: it adds that entity's velocity to its position and leaves every
other position alone. Keeping the previous world lets a caller inspect the
state before the step as well as the state after it.

The [list dictionary](../dictionary-as-list/README.md) already gives us lookup
and retained versions. Its newest binding shadows an older binding with the
same key, however. A component store must enumerate each entity once, or one
movement step could visit the same entity more than once. We will replace an
existing binding at its enumeration position and append an absent binding.
Then we can separate two questions: which component store does a system need,
and which entities occur in both stores? This arrangement — entities, one
store per component type, and systems that query those stores — is called an
*entity-component system*; this world is its finite form, with two fixed
stores rather than an open registry.

Use three entities with positions in this order:

| Entity | Position |
| --- | --- |
| 1 | (10, 5) |
| 2 | (20, 7) |
| 3 | (30, 9) |

Put velocities in a deliberately different order:

| Entity | Velocity |
| --- | --- |
| 3 | (1, 2) |
| 1 | (2, -1) |
| 4 | (9, 9) |

Before writing the movement step, identify its joined rows. Entity `1` pairs
`Position(10, 5)` with `Velocity(2, -1)`; entity `3` pairs `Position(30, 9)`
with `Velocity(1, 2)`. Entity `2` stays still because it lacks a velocity.
Entity `4` contributes no position. The order of this join follows the
positions: `1`, then `3`.

## Keep one binding per entity

`EntityId` wraps an integer so an identifier has its own nominal type.
`Position` and `Velocity` each contain two integers, but their distinct nominal
types give coordinates and displacements different roles. These are ordinary
[data declarations and constructor applications][constructors]; the types alone
do not assert that two identifiers are equal or that a store is unique.

A `Rows<C>` value enumerates zero or more entity-component pairs. A
`Store<C>` wraps those rows and hides its constructor. Clients can read an
enumeration through `entries`, but they cannot construct a `Store` from
arbitrary rows. Under the [opaque export rules][opacity], only the module below
can use its `Store` constructor or pattern.

Derive its operations from the desired result. `lookup` needs an identifier
and a store, and returns `Option<C>` because absence is possible. `put` needs
an identifier, a component, and a store, and returns a new store of the same
component type. `entries` needs only the store. Each operation receives one
value; the multiple inputs of `lookup` and `put` form a tuple.

<!-- source: src/stores.ash -->
<!-- markdownlint-disable MD013 -->
```ash
pub type EntityId = EntityId(Int)

pub type Position = Position(Int, Int)

pub type Velocity = Velocity(Int, Int)

pub type Option<C> = None
    | Some(C)

pub type Rows<C> = NoRows
    | Row(EntityId, C, Rows<C>)

pub opaque type Store<C> = Store(Rows<C>)

pub empty : Unit -> Store<C>
empty () = Store(NoRows)

pub entries : Store<C> -> Rows<C>
entries Store(rows) = rows

same_entity : (EntityId, EntityId) -> Bool
same_entity (EntityId(left), EntityId(right)) = left == right

lookup_rows : (EntityId, Rows<C>) -> Option<C>
lookup_rows (query, NoRows) = None
lookup_rows (query, Row(entity, component, rest)) = match same_entity(query, entity) {
    true => Some(component)
    false => lookup_rows(query, rest)
}

pub lookup : (EntityId, Store<C>) -> Option<C>
lookup (query, Store(rows)) = lookup_rows(query, rows)

put_rows : (EntityId, C, Rows<C>) -> Rows<C>
put_rows (entity, component, NoRows) = Row(entity, component, NoRows)
put_rows (entity, component, Row(current, saved, rest)) = match same_entity(entity, current) {
    true => Row(entity, component, rest)
    false => Row(current, saved, put_rows(entity, component, rest))
}

pub put : (EntityId, C, Store<C>) -> Store<C>
put (entity, component, Store(rows)) = Store(put_rows(entity, component, rows))
```
<!-- markdownlint-enable MD013 -->

At `NoRows`, lookup returns `None`. At a row, it compares identifiers:
a match returns the component; a mismatch searches the smaller tail. `Some`
and `None` keep absence separate from any possible component value. The
[pattern and coverage rules][patterns] check that these cases cover the data.

For `put_rows`, the empty case creates one binding. A matching identifier
replaces that row's component and keeps its tail. A mismatch retains the
current row and recurses into the smaller tail. Thus replacement preserves the
identifier's position, while insertion reaches the end and appends a row.

The uniqueness argument needs a premise: the input rows contain at most one
binding per identifier. In the matching case, the tail contains no second copy,
so replacement retains uniqueness. In the mismatch case, the unchanged head's
identifier differs from the inserted identifier and was absent from the old
tail; the recursive result therefore remains distinct from that head. The empty
case starts the argument. `empty` creates unique rows. The only exported store
producers in `stores.ash` are `empty` and `put`. The private constructor
prevents a client from injecting a duplicate enumeration. This is an argument
about this API and its equations, beyond the finite observations below.

## Join identifiers before moving positions

A join walks the position rows. For each identifier it looks up a velocity.
An absent velocity contributes no joined row; a present velocity contributes
one row containing the original position and its matching velocity. Recursing
on the remaining positions preserves their order. Since the position store is
unique, the resulting identifiers are unique too.

Movement then receives the joined rows and the original position store.
`advance` adds `(dx, dy)` to `(x, y)`. `move_positions` puts that new position
back under the joined identifier, carrying the returned store into the next
recursive call. Every joined identifier already occurs in the position store,
so these puts replace existing entries. Unjoined positions keep their values
and their positions in the enumeration.

First keep access concrete. A `World` contains a position store followed by a
velocity store. `move_direct` unpacks those two fields, joins them, moves the
joined positions, and constructs `World(moved, velocities)`. It keeps the
velocity field from its input. The complete world module appears below when
we add generic access; this entry uses its concrete operation:

<!-- source: src/01-direct-movement.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import stores (Rows, Position, Velocity)
import systems (join_stores)
import world (World, initial, move_direct)

main : Unit -> (Rows<(Position, Velocity)>, World, World)
main () = {
    let original = initial ()
    let World(positions, velocities) = original
    (join_stores(positions, velocities), move_direct original, original)
}
```
<!-- markdownlint-enable MD013 -->

Run commands from `content/cases/` throughout this chapter:

```sh
ash querying-an-immutable-world/src/01-direct-movement.ash
```

The result is one tuple: the joined rows, the moved world, and the retained
original world. Its type is `(Rows<(Position, Velocity)>, World, World)`.
The first field of that captured result is:

<!-- markdownlint-disable MD013 -->
```text
Row(EntityId(1), (Position(10, 5), Velocity(2, -1)), Row(EntityId(3), (Position(30, 9), Velocity(1, 2)), NoRows))
```
<!-- markdownlint-enable MD013 -->

This is one complete field, with the surrounding tuple and worlds omitted.
The moved world's positions are `1=(12,4)`, `2=(20,7)`, and `3=(31,11)`.
For example, entity `1` computes `(10+2, 5+(-1)) = (12,4)`. The velocity store
still enumerates `3`, `1`, `4` with their original values. The third field
still has positions `1=(10,5)`, `2=(20,7)`, `3=(30,9)`. The checks compare the
complete stores, including their order and every component, rather than an
aggregate coordinate sum.

## State which store the system needs

The concrete operation fixes the world's representation. A generic movement
system can instead require two operations: read a component store and replace
that store while keeping the rest of the world. Continue the
[implementation-evidence lesson](../../libraries/choosing-implementation-evidence/README.md)
by giving that requirement two parameters, `StoreAccess<W, C>`.

Its `component_store` method has type `W -> Store<C>`. Its `replace_store`
method has type `(W, Store<C>) -> W`. Both parameters occur in each method's
value type, as the [interface rules][interfaces] require for an interface
without a determination edge. The complete application is the evidence key.
For this world we need both `StoreAccess<World, Position>` and
`StoreAccess<World, Velocity>`.

A determination edge from `W` to `C` would say that a world type determines one
component type. Our world has two stores, so that would describe the wrong
relationship. Keep both arguments in the key and use ordinary type context to
fix the requested component. In `joined` and `move_world`, the local result
annotations distinguish the two reads of `component_store`. The final
`replace_store` receives a `Store<Position>`; its argument fixes the same
component choice.

Here is the system module. It imports storage types and operations and has no
import of the concrete world:

<!-- source: src/systems.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import stores (EntityId, Position, Velocity, Store, Rows, NoRows, Row, None, Some, entries, lookup, put)

pub interface StoreAccess<W, C> {
    component_store : W -> Store<C>
    replace_store : (W, Store<C>) -> W
}

join_rows : (Rows<Position>, Store<Velocity>) -> Rows<(Position, Velocity)>
join_rows (NoRows, velocities) = NoRows
join_rows (Row(entity, position, rest), velocities) = match lookup(entity, velocities) {
    None => join_rows(rest, velocities)
    Some(velocity) => Row(entity, (position, velocity), join_rows(rest, velocities))
}

pub join_stores : (Store<Position>, Store<Velocity>) -> Rows<(Position, Velocity)>
join_stores (positions, velocities) = join_rows(entries positions, velocities)

pub advance : (Position, Velocity) -> Position
advance (Position(x, y), Velocity(dx, dy)) = Position(x + dx, y + dy)

pub move_positions : (Rows<(Position, Velocity)>, Store<Position>) -> Store<Position>
move_positions (NoRows, positions) = positions
move_positions (Row(entity, pair, rest), positions) = {
    let updated = put(entity, advance pair, positions)
    move_positions(rest, updated)
}

pub joined<W> : W -> Rows<(Position, Velocity)> where StoreAccess<W, Position>, StoreAccess<W, Velocity>
joined world = {
    let positions : Store<Position> = component_store world
    let velocities : Store<Velocity> = component_store world
    join_stores(positions, velocities)
}

pub move_world<W> : W -> W where StoreAccess<W, Position>, StoreAccess<W, Velocity>
move_world world = {
    let positions : Store<Position> = component_store world
    let velocities : Store<Velocity> = component_store world
    let moved = move_positions(join_stores(positions, velocities), positions)
    replace_store(world, moved)
}
```
<!-- markdownlint-enable MD013 -->

The two `where` requirements let each generic body use the corresponding
methods as abstract evidence. When a caller fixes `W` to `World`, it must supply
the two complete applications. [Constraint satisfaction][selection] selects
that evidence; importing a method or constrained function name alone does not
select an implementation.

`move_world` finishes all position updates before one call to `replace_store`.
That is one replacement of the world's position field. Each `put` inside
`move_positions` still searches and reconstructs part of the association list;
we have not made all that work disappear.

The world module re-exports the interface name and publishes two implementation
facts. Each implementation reads one field and replaces only that field.
The direct operation uses the same join and position-update calculation,
with its field access written explicitly.

The fixed velocity for entity `1` needs the integer `-1`. Ordinary expression
[syntax][syntax] has no negative literal or subtraction operator at this
checkpoint. The private constant-only declaration binds `DecreaseOne` to that
ordinary `Int` through the existing [passive scalar constant form][constants].
It declares no symbol and executes no native call. The world uses that value
only to construct `Velocity(2, DecreaseOne)`:

<!-- source: src/world.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import stores (EntityId, Position, Velocity, Store, empty, put)
pub import systems (StoreAccess)
import systems (component_store, replace_store, join_stores, move_positions)

foreign library FixtureNumbers {
    profile "x86_64-unknown-linux-gnu"
    repr Signed = signed(64)
    const DecreaseOne : Signed = -1
}

pub type World = World(Store<Position>, Store<Velocity>)

pub initial : Unit -> World
initial () = {
    let positions = put(EntityId(1), Position(10, 5), empty())
    let positions = put(EntityId(2), Position(20, 7), positions)
    let positions = put(EntityId(3), Position(30, 9), positions)
    let velocities = put(EntityId(3), Velocity(1, 2), empty())
    let velocities = put(EntityId(1), Velocity(2, DecreaseOne), velocities)
    let velocities = put(EntityId(4), Velocity(9, 9), velocities)
    World(positions, velocities)
}

pub move_direct : World -> World
move_direct World(positions, velocities) = {
    let moved = move_positions(join_stores(positions, velocities), positions)
    World(moved, velocities)
}

pub impl StoreAccess<World, Position> {
    component_store World(positions, velocities) = positions
    replace_store (World(positions, velocities), replacement) = World(replacement, velocities)
}

pub impl StoreAccess<World, Velocity> {
    component_store World(positions, velocities) = velocities
    replace_store (World(positions, velocities), replacement) = World(positions, replacement)
}
```
<!-- markdownlint-enable MD013 -->

The module graph remains acyclic: systems depends on stores; world depends on
systems and stores. The generic algorithm does not need to import a world
that imports it back. The [module rules][modules] check these dependencies and
the public facts crossing each boundary.

Select the world's facts explicitly at the generic entry:

<!-- source: src/02-generic-movement.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import stores (Rows, Position, Velocity)
import systems (joined, move_world)
import world (World, initial, impl StoreAccess)

main : Unit -> (Rows<(Position, Velocity)>, World, World)
main () = {
    let original = initial ()
    (joined original, move_world original, original)
}
```
<!-- markdownlint-enable MD013 -->

```sh
ash querying-an-immutable-world/src/02-generic-movement.ash
```

This produces the same complete joined rows, moved world, and original world
as the direct entry, with the same tuple type. Each is checked against the
independently specified component values above; equality between two faulty
implementations would not establish the intended movement.

Selected evidence lowers to [ordinary functions and applications][lowering].
There is no runtime search through the world's fields. The two methods provide
access; their types do not promise that an implementation preserves unrelated
fields or that a join matches identifiers. Those properties come from the
implementations and calculations we have just followed.

## Retain snapshots across two steps

A second step uses the first step's returned world. Keep all three values so
the result can show whether the earlier positions survived:

<!-- source: src/03-repeated-step.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import systems (move_world)
import world (World, initial, impl StoreAccess)

main : Unit -> (World, World, World)
main () = {
    let original = initial ()
    let first = move_world original
    let second = move_world first
    (original, first, second)
}
```
<!-- markdownlint-enable MD013 -->

```sh
ash querying-an-immutable-world/src/03-repeated-step.ash
```

The single result has type `(World, World, World)`, in original, first, and
second order. The table selects its position coordinates; it omits the
surrounding constructors and all three velocity fields.

| Entity | Original position | After one step | After two steps |
| --- | --- | --- | --- |
| 1 | (10, 5) | (12, 4) | (14, 3) |
| 2 | (20, 7) | (20, 7) | (20, 7) |
| 3 | (30, 9) | (31, 11) | (32, 13) |

All three worlds still carry velocities `3=(1,2)`, `1=(2,-1)`, `4=(9,9)`,
in that order. There is no position for entity `4`. Each position enumeration
contains identifiers `1`, `2`, `3` exactly once.

These pure functions construct returned values from their inputs.
[Binding and constructor evaluation][values] do not overwrite the original
world when a new store or world is constructed. Retaining `original` therefore
retains its components. This says nothing about every field being physically
copied: unchanged tails and values can be reused, and the language's
observation is the retained value, not a heap-layout report.

## Test the absent cases

The usual input already checks a missing velocity and an extra velocity.
Boundary stores let us inspect insertion, replacement, and empty joins
separately:

<!-- source: src/04-store-boundaries.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import stores (EntityId, Position, Rows, Option, empty, entries, lookup, put)
import systems (move_world)
import world (World, initial, impl StoreAccess)

main : Unit -> (Rows<Position>, Rows<Position>, Option<Position>, World, World, World)
main () = {
    let World(positions, velocities) = initial ()
    let replaced = put(EntityId(1), Position(99, 98), positions)
    let inserted = put(EntityId(4), Position(40, 12), positions)
    (
        entries replaced,
        entries inserted,
        lookup(EntityId(4), positions),
        move_world(World(empty(), empty())),
        move_world(World(positions, empty())),
        move_world(World(empty(), velocities))
    )
}
```
<!-- markdownlint-enable MD013 -->

```sh
ash querying-an-immutable-world/src/04-store-boundaries.ash
```

The tuple contains the following six observations, in order. These summaries
select fields of one captured result; they are not six separate command outputs.
The full value and its type are checked together.

| Field | Operation | Selected observation |
| --- | --- | --- |
| 1 | Replace position 1 | IDs 1, 2, 3; position 1 is (99, 98) |
| 2 | Insert position 4 | IDs 1, 2, 3, 4; position 4 is (40, 12) |
| 3 | Look up absent position 4 | `None` |
| 4 | Move two empty stores | Both stores are empty |
| 5 | Move with no velocities | All original positions remain |
| 6 | Move with no positions | No positions; all original velocities remain |

Replacement leaves one binding for entity `1`, rather than adding a newer
binding in front of an older one. Insertion keeps the original three bindings
and appends entity `4` once. Both operations receive the original store, so the
lookup of position `4` still returns `None`. An empty join calls no `put`, and
the original positions pass through. A velocity-only world cannot invent a
position: the join is driven by position rows.

## A well-typed join can still match the wrong entities

A positional zip looks plausible because the two lists have compatible lengths
and every selected value has the expected component type. It pairs the first
position with the first velocity, then recurses on the two tails. On our input,
that means entity pairs `1/3`, `2/1`, and `3/4`.

Keep both identifiers in each zipped row so the mismatch is visible. Here the
outer `Row` identifier comes from positions and the identifier inside its
payload comes from velocities. `move_zipped` deliberately ignores the latter
identifier when calculating new positions:

<!-- source: src/05-positional-zip.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import stores (EntityId, Position, Velocity, Store, Rows, NoRows, Row, entries, put)
import systems (advance, joined)
import world (World, initial, impl StoreAccess)

zip_rows : (Rows<Position>, Rows<Velocity>) -> Rows<(EntityId, Position, Velocity)>
zip_rows (NoRows, velocities) = NoRows
zip_rows (Row(entity, position, rest), NoRows) = NoRows
zip_rows (Row(entity, position, rest), Row(other, velocity, later)) = {
    Row(entity, (other, position, velocity), zip_rows(rest, later))
}

move_zipped : (Rows<(EntityId, Position, Velocity)>, Store<Position>) -> Store<Position>
move_zipped (NoRows, positions) = positions
move_zipped (Row(entity, (other, position, velocity), rest), positions) = {
    let updated = put(entity, advance(position, velocity), positions)
    move_zipped(rest, updated)
}

main : Unit -> (Rows<(EntityId, Position, Velocity)>, Rows<Position>, Rows<(Position, Velocity)>)
main () = {
    let original = initial ()
    let World(positions, velocities) = original
    let wrong = zip_rows(entries positions, entries velocities)
    (wrong, entries(move_zipped(wrong, positions)), joined original)
}
```
<!-- markdownlint-enable MD013 -->

```sh
ash querying-an-immutable-world/src/05-positional-zip.ash
```

Ash accepts this entry and exits with status `0`, with no standard error.
Its three result fields are the wrong zipped rows, their moved positions,
and the correct joined rows. The first two fields select these pairs and values:

| Position entity | Velocity entity | Wrong moved position |
| --- | --- | --- |
| 1 | 3 | (11, 7) |
| 2 | 1 | (22, 6) |
| 3 | 4 | (39, 18) |

For example, `(10,5) + (1,2)` gives `(11,7)`, but that displacement belongs
to entity `3`. The calculation is well typed and fails the application's
identity requirement. The third field is the correct two-row join shown
earlier. Repairing the algorithm means looking up each position identifier
in the velocity store, as `join_rows` does. Selecting evidence does not perform
that repair for us.

## Distinguish missing evidence from a wrong component

A generic call can fail before any join runs. This entry imports the world's
names but selects no implementation facts:

<!-- source: src/06-missing-evidence.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import systems (move_world)
import world (World, initial)

main : Unit -> World
main () = move_world(initial())
```
<!-- markdownlint-enable MD013 -->

The argument fixes the world type, and `move_world` fixes the two component
types in its requirements. There is no unresolved component choice. Run the
explicit English human format from `content/cases/`:

<!-- diagnostic: src/06-missing-evidence.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en querying-an-immutable-world/src/06-missing-evidence.ash
No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/cases/querying-an-immutable-world/src/06-missing-evidence.ash:5:11
5 | main () = move_world(initial())
  |           ^ No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/cases/querying-an-immutable-world/src/systems.ash:35:5
35 | pub move_world<W> : W -> W where StoreAccess<W, Position>, StoreAccess<W, Velocity>
   |     ^ This declaration introduced the interface requirement.
  --> /path/to/ash-doc/content/cases/querying-an-immutable-world/src/06-missing-evidence.ash:1:17
1 | import systems (move_world)
  |                 ^ This import made the declaration available.
  --> /path/to/ash-doc/content/cases/querying-an-immutable-world/src/systems.ash:3:1
3 | pub interface StoreAccess<W, C> {
  | ^ This interface participates in the failing evidence selection.
4 |     component_store : W -> Store<C>
  | ^ This interface participates in the failing evidence selection.
5 |     replace_store : (W, Store<C>) -> W
  | ^ This interface participates in the failing evidence selection.
6 | }
  | ^ This interface participates in the failing evidence selection.
reason: constraint.unsatisfied
```
<!-- markdownlint-enable MD013 -->

This exits with status `1`, with empty standard output. The primary label
identifies the `move_world` occurrence whose requirement lacks evidence.
The related labels trace the constrained declaration, its import, and the
owning interface. The failure is `constraint.unsatisfied`: being able to name
`move_world` and `World` does not select the two facts. Add
`impl StoreAccess` to the world's import, as the successful generic entry does.
That selector makes the public facts available for the complete applications;
it does not infer the entity join.

A different entry supplies a velocity where its result requires a position
store:

<!-- source: src/07-wrong-component.ash -->
<!-- markdownlint-disable MD013 -->
```ash
import stores (EntityId, Position, Velocity, Store, empty, put)

main : Unit -> Store<Position>
main () = put(EntityId(1), Velocity(2, 1), empty())
```
<!-- markdownlint-enable MD013 -->

The `Velocity` argument makes this `put` call produce a `Store<Velocity>`.
The signature of `main` requires `Store<Position>` instead. Run:

<!-- diagnostic: src/07-wrong-component.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en querying-an-immutable-world/src/07-wrong-component.ash
The function body must return `Store<Position>`, but returns `Store<Velocity>`.
  --> /path/to/ash-doc/content/cases/querying-an-immutable-world/src/07-wrong-component.ash:4:11
4 | main () = put(EntityId(1), Velocity(2, 1), empty())
  |           ^ This has type `Store<Velocity>`.
  --> /path/to/ash-doc/content/cases/querying-an-immutable-world/src/07-wrong-component.ash:3:16
3 | main : Unit -> Store<Position>
  |                ^ This signature requires result type `Store<Position>`.
reason: type.definition-result
```
<!-- markdownlint-enable MD013 -->

This also exits with status `1` and empty standard output, but its cause is an
incompatible function result. The primary label identifies the body that
produces `Store<Velocity>`; the related label identifies the signature requiring
`Store<Position>`. Its reason is `type.definition-result`. The distinct
nominal types remain distinct even though both constructors hold two integers.
Use `Position(2, 1)` in this entry for a position insertion, as `initial` uses
`Position` values, or request a velocity store when inserting a velocity.
Adding store-access evidence cannot change this mismatch; this entry needs no
interface evidence at all.

The captured wording records this edition's tool presentation. The
[tool's failure contract][tool-failures] separates status, reason, and causal
locations from exact prose and layout. Only the checkout prefix is normalized
here, to `/path/to/ash-doc/`.

## Count the work this representation performs

Let `p` be the number of positions, `v` the number of velocities, and `j` the
number of joined entities. A lookup compares at most `v` velocity identifiers.
The join traverses `p` position rows and performs one lookup per row, so its
worst-case work is `O(1 + p + p*v)`. It constructs `j` joined rows, in position
order. This is a bound derived from the equations, not a timing measurement.

Each movement `put` searches a position store of length `p`. Its identifier is
already present, so it replaces a row without changing the store length.
Repeated puts cost at most `O(j*p)` row visits, in addition to the join and
traversal of its result. Since `j <= p`, the whole step has the bound
`O(1 + p + p*v + j*p)` under constant-cost identifier comparison and coordinate
arithmetic. These assumptions isolate list work; they are not a claim that
arbitrary-size integer operations take constant time.

The source also constructs values: the join builds rows, `advance` builds
positions, and each `put` rebuilds its searched prefix and wraps the returned
rows. A matched tail can be reused. Replacing the world's position field once
at the end still leaves all those earlier constructions. The pinned
[constructor evaluation rules][values] explain their logical allocation;
we have measured neither bytes nor elapsed time and claim no runtime
optimization. Retaining several worlds also retains the values reachable from
them.

The fixed world is enough for this comparison. A different storage structure
could change lookup and update costs, but it would need its own representation
and preservation argument. This program introduces no mutation, packed storage,
dynamic component registry, automatic type-index search, or concurrency.

The completed system separates three obligations. Store producers preserve
unique identifiers; the join matches identifiers and chooses its order; the
selected access methods connect those stores to a concrete world. Pure returned
values let the caller retain earlier snapshots. The finite checks distinguish
these obligations on the fixed data, while the arguments explain why the
operations preserve them under their stated premises.

For practice, add a velocity for entity `2` using the existing `put` operation.
Predict the joined identifier order and all three positions after two steps,
then edit an entry and compare your prediction with `ash`. Next, change the
velocity insertion order while keeping its identifier-value pairs. Explain
which observations should stay the same and which enumeration should change.
Keep the original world in the result so you can inspect that claim as well.

This leaves a further design question: what representation would let a system
find a component without repeatedly searching a list, while retaining the
snapshot and identity guarantees?

[constructors]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#tuples-and-constructors
[opacity]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#imports-and-namespaces
[patterns]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#patterns-matches-and-coverage
[interfaces]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#interfaces-and-constrained-schemes
[selection]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence
[modules]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#globals-and-modules
[lowering]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#generated-interface-evidence
[values]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches
[tool-failures]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#failures
[syntax]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/syntax.md#grammar
[constants]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#source-foreign-declarations
