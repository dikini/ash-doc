pub type Request = Request(Int, Bool)
pub type Steps = End
    | Step(Int, Steps)

pub type Result = Delivered(Request)
    | Rejected

effect Pipeline {
    publish : Request -> Request
}

effect Policy {
    check : Request -> Unit
}

effect Trace {
    stage : Int -> Unit
}

normalize : Request -> Request ! {Trace}
normalize (Request(priority, tagged)) = {
    let ignored = perform Trace.stage 1
    match priority == 0 {
        true => Request(1, tagged)
        false => Request(priority, tagged)
    }
}

check_policy : Request -> Request ! {Policy, Trace}
check_policy request = {
    let ignored = perform Trace.stage 2
    let ignored = perform Policy.check request
    request
}

enrich : Request -> Request ! {Trace}
enrich (Request(priority, tagged)) = {
    let ignored = perform Trace.stage 3
    Request(priority, true)
}

publish_and_deliver : Request -> Result ! {Pipeline, Trace}
publish_and_deliver request = {
    let transformed = perform Pipeline.publish request
    let ignored = perform Trace.stage 4
    Delivered(transformed)
}

pipeline : Bool -> Result ! {Policy, Trace}
pipeline include_enrichment = hook Pipeline {
    register Pipeline normalize {
        register Pipeline check_policy {
            match include_enrichment {
                true => register Pipeline enrich {
                    publish_and_deliver (Request(0, false))
                }
                false => publish_and_deliver (Request(0, false))
            }
        }
    }
}

pub run : (Bool, Bool) -> (Result, Steps)
run (allow, include_enrichment) = handle {
    let result = handle (pipeline include_enrichment) with Policy {
        check request => match allow {
            true => resume ()
            false => {
                let ignored = discard
                Rejected
            }
        }
    }
    (result, End)
} with Trace {
    stage digit => {
        let (result, later) = resume ()
        (result, Step(digit, later))
    }
}
