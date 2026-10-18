import stores (EntityId, Position, Velocity, Store, empty, put)

main : Unit -> Store<Position>
main () = put(EntityId(1), Velocity(2, 1), empty())
