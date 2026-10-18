import events as Events

main : Unit -> (Events.InternalEvent, Events.PublicEvent, Events.Snapshots)
main () = handle {
    let internal = hook Events.InternalFeed {
        register Events.InternalFeed Events.redact {
            hook Events.InternalFeed {
                register Events.InternalFeed Events.snapshot {
                    perform Events.InternalFeed.publish (
                        Events.InternalEvent(1, 7, 424242)
                    )
                }
            }
        }
    }
    let public = Events.collect_public (Events.public_view internal)
    (internal, public, Events.End)
} with Events.CollectInternal {
    capture event => {
        let (internal, public, later) = resume ()
        (internal, public, Events.Snapshot(event, later))
    }
}
