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
