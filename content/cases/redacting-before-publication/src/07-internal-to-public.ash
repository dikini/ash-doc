import events as Events

main : Unit -> Events.PublicEvent
main () = Events.collect_public (Events.InternalEvent(1, 7, 424242))
