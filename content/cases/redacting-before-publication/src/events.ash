pub type InternalEvent = InternalEvent(Int, Int, Int)
pub type PublicEvent = PublicEvent(Int, Int)
pub type Snapshots = End
    | Snapshot(InternalEvent, Snapshots)

pub effect InternalFeed {
    publish : InternalEvent -> InternalEvent
}

pub effect PublicFeed {
    publish : PublicEvent -> PublicEvent
}

pub effect CollectInternal {
    capture : InternalEvent -> Unit
}

pub public_view : InternalEvent -> PublicEvent
public_view (InternalEvent(event_id, code, ignored_secret)) = {
    PublicEvent(event_id, code)
}

pub redact : InternalEvent -> InternalEvent
redact (InternalEvent(event_id, code, ignored_secret)) = {
    InternalEvent(event_id, code, 0)
}

pub collect_public : PublicEvent -> PublicEvent
collect_public event = event

pub snapshot : InternalEvent -> InternalEvent ! {CollectInternal}
snapshot event = {
    let ignored = perform CollectInternal.capture event
    event
}
