import events as Events

main : Unit -> Events.PublicEvent
main () = hook Events.PublicFeed {
    register Events.PublicFeed Events.collect_public {
        let internal = Events.InternalEvent(1, 7, 424242)
        perform Events.PublicFeed.publish (Events.public_view internal)
    }
}
