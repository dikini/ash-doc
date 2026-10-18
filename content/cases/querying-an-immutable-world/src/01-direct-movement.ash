import stores (Rows, Position, Velocity)
import systems (join_stores)
import world (World, initial, move_direct)

main : Unit -> (Rows<(Position, Velocity)>, World, World)
main () = {
    let original = initial ()
    let World(positions, velocities) = original
    (join_stores(positions, velocities), move_direct original, original)
}
