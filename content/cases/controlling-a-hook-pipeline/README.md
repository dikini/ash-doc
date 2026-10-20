# Controlling a hook pipeline

A middleware pipeline lets surrounding code choose transformations while the
producer publishes one value. Each callback observes the value at its stage,
works locally on it, and returns the value for the next callback. It need not
know who produced the request or which callbacks surround it.

Continue from [hooks](../../effects/transforming-publications/README.md),
[early stopping](../../effects/stopping-a-calculation/README.md), and the
[scripted session](../running-a-scripted-session/README.md). Here a callback
also requests an ordinary policy operation. The handler decides whether to
resume that callback or stop the captured pipeline.

Our request holds a priority and a Boolean enrichment tag. A zero priority
means unspecified. The stages are:

| Trace digit | Stage | Local work |
| --- | --- | --- |
| 1 | Normalize | Replace priority zero with one. |
| 2 | Check policy | Request permission, then return the request if resumed. |
| 3 | Enrich | Set the tag to `true`. |
| 4 | Deliver | Return the transformed request after publication completes. |

The trace is a list of stages actually entered. Delivery here produces ordinary
data, so the example needs no external service.

## Register transformations, handle decisions

Keep the shared definitions in `pipeline.ash`. The first three stages are
registered callbacks; delivery follows the publication. Their registration
order makes normalization run before the check and enrichment after it.

<!-- source: src/pipeline.ash -->
```ash
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
```

`Pipeline.publish` returns the transformed request. Its callbacks retain the
same `Request -> Request` shape, with ordinary effects in their rows:
`check_policy` requires both `Policy` and `Trace`. The hook discharges only
`Pipeline`; `run` supplies handlers for the remaining requests.

The policy handler surrounds the call that establishes the registrations.
That placement lets it interpret a callback's `Policy.check`. A handler placed
only around publication inside a registration would not supply that callback's
context. The callback has no middleware `next` capability: it requests an
operation, and the ordinary handler owns `resume` or `discard`.

The trace handler uses the same technique as the scripted session. It resumes
once, receives the later trace, and prepends the current digit. This records
execution order without a mutable log.

## Observe continuation and abandonment

From the Cases directory, enter `controlling-a-hook-pipeline/src`. Each entry
uses the same pipeline definitions. Predict the delivered request and trace
before running it.

<!-- source: src/01-permitted.ash -->
```ash
import pipeline as Pipeline

main : Unit -> (Pipeline.Result, Pipeline.Steps)
main () = Pipeline.run (true, true)
```

<!-- markdownlint-disable MD013 -->
```text
$ ash 01-permitted.ash
(Delivered(Request(1, true)), Step(1, Step(2, Step(3, Step(4, End))))) : (Result, Steps)
```
<!-- markdownlint-enable MD013 -->

The policy resumes with unit. The callback returns its normalized request,
enrichment sets the tag, and delivery runs. The trace contains all four stages.

<!-- source: src/02-rejected.ash -->
```ash
import pipeline as Pipeline

main : Unit -> (Pipeline.Result, Pipeline.Steps)
main () = Pipeline.run (false, true)
```

```text
$ ash 02-rejected.ash
(Rejected, Step(1, Step(2, End))) : (Result, Steps)
```

The policy discards instead. Its captured computation owns the active pipeline
registrations and pending work. Closing it skips the rest of the check,
enrichment, and delivery. The handler returns `Rejected`; the surrounding trace
handler still records the two stages already entered. Abandonment does not
undo work that ran before the decision.

<!-- source: src/03-without-enrichment.ash -->
```ash
import pipeline as Pipeline

main : Unit -> (Pipeline.Result, Pipeline.Steps)
main () = Pipeline.run (true, false)
```

<!-- markdownlint-disable MD013 -->
```text
$ ash 03-without-enrichment.ash
(Delivered(Request(1, false)), Step(1, Step(2, Step(4, End)))) : (Result, Steps)
```
<!-- markdownlint-enable MD013 -->

The permitted pipeline now has no enrichment registration. The tag remains
false and stage three is absent, while the producer and remaining callbacks
keep their definitions. This is inversion of control: the calculation requests
processing, registrations select local transformations, and an ordinary handler
supplies the decision about continuation.

## Connect this to reactive programming

The arrangement resembles a reactive sequence: a source emits a value,
operators transform it, and a consumer uses the result. Here publication is the
source boundary, registered callbacks are the transformations, and delivery is
the consumer. Each callback observes the value reaching its own stage; the next
callback receives its returned value. Registration lifetime follows lexical
scope.

This example is synchronous: publication returns a transformed value to its
caller. The callbacks form one transformation chain, rather than broadcasting
the original value to independent subscribers. `discard` abandons captured
work; it is not a stream filter that drops one event and automatically continues
with the next. Hooks alone supply no asynchronous scheduling, buffering, or
backpressure.

For practice, exchange the check and enrichment registrations. Predict the
rejected run's trace before executing it. Which work has already happened when
the policy rejects? A later extension could supply a policy that examines the
request's priority while keeping the callback unchanged.
