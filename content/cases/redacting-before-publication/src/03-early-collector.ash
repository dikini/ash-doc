import events as Events

main : Unit -> (Events.InternalEvent, Events.Snapshots)
main () = handle {
    let final_event = hook Events.InternalFeed {
        register Events.InternalFeed Events.snapshot {
            register Events.InternalFeed Events.redact {
                perform Events.InternalFeed.publish (
                    Events.InternalEvent(1, 7, 424242)
                )
            }
        }
    }
    (final_event, Events.End)
} with Events.CollectInternal {
    capture event => {
        let (final_event, later) = resume ()
        (final_event, Events.Snapshot(event, later))
    }
}
