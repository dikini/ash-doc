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
