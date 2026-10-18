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
