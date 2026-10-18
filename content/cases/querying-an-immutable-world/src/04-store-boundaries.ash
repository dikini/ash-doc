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
