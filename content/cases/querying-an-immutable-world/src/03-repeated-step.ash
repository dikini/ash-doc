import systems (move_world)
import world (World, initial, impl StoreAccess)

main : Unit -> (World, World, World)
main () = {
    let original = initial ()
    let first = move_world original
    let second = move_world first
    (original, first, second)
}
