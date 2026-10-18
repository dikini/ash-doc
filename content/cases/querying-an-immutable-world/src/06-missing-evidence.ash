import systems (move_world)
import world (World, initial)

main : Unit -> World
main () = move_world(initial())
