import events as Events

main : Unit -> Events.PublicEvent
main () = {
    let Events.InternalEvent(event_id, ignored_code, secret) = (
        Events.InternalEvent(1, 7, 424242)
    )
    hook Events.PublicFeed {
        register Events.PublicFeed Events.collect_public {
            perform Events.PublicFeed.publish (
                Events.PublicEvent(event_id, secret)
            )
        }
    }
}
