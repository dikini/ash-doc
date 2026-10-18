import stores (Rows, Position, Velocity)
import systems (joined, move_world)
import world (World, initial, impl StoreAccess)

main : Unit -> (Rows<(Position, Velocity)>, World, World)
main () = {
    let original = initial ()
    (joined original, move_world original, original)
}
