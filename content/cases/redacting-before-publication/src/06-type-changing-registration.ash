import events as Events

main : Unit -> Events.InternalEvent
main () = hook Events.InternalFeed {
    register Events.InternalFeed Events.public_view {
        perform Events.InternalFeed.publish (Events.InternalEvent(1, 7, 424242))
    }
}
