# Redact before publication

An internal event can carry information that a public consumer must never
receive. Suppose event `1` has public code `7` and sensitive value `424242`.
The public consumer needs the identifier and code. Removing the sensitive
value before that consumer runs is a property of the whole path from producer
to consumer, including the values seen by intermediate callbacks.

The [hook pipeline](../controlling-a-hook-pipeline/README.md) showed how each
callback receives the preceding stage's result. The
[hook lesson](../../effects/transforming-publications/README.md) established
that every callback preserves the hook's payload type. Those two facts give
us separate jobs: choose which internal stages can inspect the sensitive
field, then construct a public value before crossing the public interface.

## Derive the public boundary from the data

Represent the internal event by three integers: identifier, public code, and
secret, in that order. A public event has only the first two. The intended
calculation is non-executable notation:

```text
public_view(InternalEvent(id, code, secret)) = PublicEvent(id, code)
redact(InternalEvent(id, code, secret)) = InternalEvent(id, code, 0)
```

These operations answer different questions. Redaction preserves the internal
shape so it can participate in an internal hook. Projection changes the shape
so the secret field has no position in the public result. Both operations must
preserve the identifier and code. We also assume those two input fields are
suitable for publication; a type with two integers cannot establish that policy.

Work backward from the consumer. Give `collect_public` input type
`PublicEvent`; it returns that value as the observation collected here. Then
`public_view : InternalEvent -> PublicEvent` supplies exactly its input.
Separate `InternalFeed` and `PublicFeed` hooks preserve their own payloads.
`CollectInternal.capture` instead requests an ordinary snapshot collection;
it is an effect operation interpreted by our surrounding handler.

Keep these definitions in `events.ash`:

<!-- source: src/events.ash -->
```ash
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
```

The [module rules][modules] make the exported types, constructors, functions,
and effects available through an importing alias. `pub` controls that access;
it does not classify data as confidential. `InternalEvent` and `PublicEvent`
are distinct nominal types, and the public constructor deliberately remains
available. This lets us examine what the chosen interface actually guarantees.

`public_view` selects the first two fields and constructs a different type.
`redact` constructs another internal event with secret `0`. Neither can change
the original event saved by an earlier snapshot. Each calculation inspects
three fields and constructs one fixed-size value; its source-level work is
constant in this representation.

Enter `redacting-before-publication/src` from the Cases directory. In
`01-public-view.ash`, projection happens before public publication:

<!-- source: src/01-public-view.ash -->
```ash
import events as Events

main : Unit -> Events.PublicEvent
main () = hook Events.PublicFeed {
    register Events.PublicFeed Events.collect_public {
        let internal = Events.InternalEvent(1, 7, 424242)
        perform Events.PublicFeed.publish (Events.public_view internal)
    }
}
```

Predict the exact public event. Its identifier and code should be unchanged,
with no third field:

<!-- observation: src/01-public-view.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 01-public-view.ash
PublicEvent(1, 7) : PublicEvent
```
<!-- markdownlint-enable MD013 -->

The ordinary collector is also a valid public callback because its type is
`PublicEvent -> PublicEvent`. It returns the value it receives. The public
hook never carries an internal event. The [hook contract][hooks] checks these
connections; the equation for `public_view` explains why these particular
public fields are the intended ones.

## Locate the first observer before redacting

A public projection does not explain what happened earlier inside an internal
pipeline. To examine that path, `snapshot` requests collection and returns its
input unchanged. Place one snapshot outside `redact` and another inside it:

<!-- source: src/02-snapshot-order.ash -->
```ash
import events as Events

main : Unit -> (Events.InternalEvent, Events.Snapshots)
main () = handle {
    let final_event = hook Events.InternalFeed {
        register Events.InternalFeed Events.snapshot {
            register Events.InternalFeed Events.redact {
                register Events.InternalFeed Events.snapshot {
                    perform Events.InternalFeed.publish (
                        Events.InternalEvent(1, 7, 424242)
                    )
                }
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
```

The collector handler surrounds the code that establishes all registrations.
A handler installed only around `perform InternalFeed.publish` would not
supply the callback's context. As in the previous pipeline, its clause resumes
once and prepends the current event to the returned later snapshots. The
base list is `End`, so the returned list follows the collection order.

Before running, calculate the stages from the [execution rule][execution].
For outer callback `A` and inner callback `B`, publication computes
`B(A(payload))`. Here the complete chain is non-executable notation:

```text
snapshot_after(redact(snapshot_before(InternalEvent(1, 7, 424242))))
```

The outer snapshot returns its unchanged input. Redaction then constructs an
event with secret `0`, which reaches the inner snapshot. Predict the two
snapshots and final internal payload, then inspect the single returned pair:

<!-- observation: src/02-snapshot-order.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 02-snapshot-order.ash
(InternalEvent(1, 7, 0), Snapshot(InternalEvent(1, 7, 424242), Snapshot(InternalEvent(1, 7, 0), End))) : (InternalEvent, Snapshots)
```
<!-- markdownlint-enable MD013 -->

The pair's first field is the final payload. Its second field contains first
`InternalEvent(1, 7, 424242)`, then `InternalEvent(1, 7, 0)`. The first snapshot
remains sensitive even though the final payload is redacted. The handler
retains ordinary event values; a later construction cannot erase a value it
has already collected. Each snapshot adds one list node, so retained snapshot
space grows with the number collected. Hook work also includes one ordinary
callback application per participating registration, plus handler search and
the callback's own work.

Now suppose the collector itself is treated as the public observer, while
redaction remains a later stage. Remove the second snapshot, leaving
`03-early-collector.ash`:

<!-- source: src/03-early-collector.ash -->
```ash
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
```

Does a redacted final payload imply that this earlier collector saw no secret?
Use the same outer-to-inner calculation before running:

<!-- observation: src/03-early-collector.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 03-early-collector.ash
(InternalEvent(1, 7, 0), Snapshot(InternalEvent(1, 7, 424242), End)) : (InternalEvent, Snapshots)
```
<!-- markdownlint-enable MD013 -->

The answer is no: the saved snapshot contains `424242`. This is an accepted
program and a confidentiality counterexample for that placement. Every
callback preserves `InternalEvent`, and the ordinary handler receives exactly
the type it requests. The compiler has no reason to reject those connections.
An internal observer can be appropriate, but calling it public does not remove
its access to the internal shape.

## An inner root can bypass the outer transformation

It is also tempting to place one redactor around a larger computation and
assume that every internal publication passes through it. In
`04-nested-root.ash`, locate the second root for the same exact `InternalFeed`
inside that registration:

<!-- source: src/04-nested-root.ash -->
```ash
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
```

An [exact nested root][execution] starts a separate identity chain. The inner
publication reaches its snapshot and then that root; it never reaches the
outer redactor. Predict the internal event, projected public event, and saved
snapshot, in that order:

<!-- observation: src/04-nested-root.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 04-nested-root.ash
(InternalEvent(1, 7, 424242), PublicEvent(1, 7), Snapshot(InternalEvent(1, 7, 424242), End)) : (InternalEvent, PublicEvent, Snapshots)
```
<!-- markdownlint-enable MD013 -->

Both internal observations keep `424242`. The explicit public projection
still produces the intended two-field event. Placing the conversion directly
before the public consumer makes the data boundary visible even when the
internal chain changes. A surrounding registration alone cannot establish
that every producer uses its chain.

## Two rejected connections and their repairs

Could projection itself be an internal transformation? Try registering
`public_view` in `06-type-changing-registration.ash`:

<!-- source: src/06-type-changing-registration.ash -->
```ash
import events as Events

main : Unit -> Events.InternalEvent
main () = hook Events.InternalFeed {
    register Events.InternalFeed Events.public_view {
        perform Events.InternalFeed.publish (Events.InternalEvent(1, 7, 424242))
    }
}
```

The target's payload is `InternalEvent`, so the callback must accept and
return that type. Predict which end of `public_view` fails that requirement.
Run from the same `src` directory:

<!-- diagnostic: src/06-type-changing-registration.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 06-type-changing-registration.ash
This expression must have type `InternalEvent -> InternalEvent`, but it has type `InternalEvent -> PublicEvent`.
  --> /path/to/ash-doc/content/cases/redacting-before-publication/src/06-type-changing-registration.ash:5:5
5 |     register Events.InternalFeed Events.public_view {
  |     ^ This has type `InternalEvent -> PublicEvent`.
6 |         perform Events.InternalFeed.publish (Events.InternalEvent(1, 7, 424242))
  | ^ This has type `InternalEvent -> PublicEvent`.
7 |     }
  | ^ This has type `InternalEvent -> PublicEvent`.
reason: type.mismatch
```
<!-- markdownlint-enable MD013 -->

The message compares `InternalEvent -> InternalEvent`, required by the
registration, with `InternalEvent -> PublicEvent`, supplied by `public_view`.
Its label spans the registration and its body, where that callback contract
is imposed. The input agrees; the result does not. Both feed declarations
qualify as hooks, so this is an ordinary type mismatch, reported secondarily
as `type.mismatch`.

The repair is the complete program `01-public-view.ash`: project the internal
value before publishing on `PublicFeed`, and register `collect_public`, whose
input and result are both `PublicEvent`. Changing just the hook name while
keeping `public_view` as callback would still leave its input type wrong.
The repaired program returns the public event already observed above.

The consumer's input boundary can reject an internal value even without a
hook. `07-internal-to-public.ash` attempts that connection directly:

<!-- source: src/07-internal-to-public.ash -->
```ash
import events as Events

main : Unit -> Events.PublicEvent
main () = Events.collect_public (Events.InternalEvent(1, 7, 424242))
```

<!-- diagnostic: src/07-internal-to-public.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 07-internal-to-public.ash
This function argument must have type `PublicEvent`, but has type `InternalEvent`.
  --> /path/to/ash-doc/content/cases/redacting-before-publication/src/07-internal-to-public.ash:4:33
4 | main () = Events.collect_public (Events.InternalEvent(1, 7, 424242))
  |                                 ^ This has type `InternalEvent`.
  --> /path/to/ash-doc/content/cases/redacting-before-publication/src/events.ash:28:5
28 | pub collect_public : PublicEvent -> PublicEvent
   |     ^ This function requires an argument of type `PublicEvent`.
  --> /path/to/ash-doc/content/cases/redacting-before-publication/src/07-internal-to-public.ash:4:11
4 | main () = Events.collect_public (Events.InternalEvent(1, 7, 424242))
  |           ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The first label identifies the supplied `InternalEvent`. The label in
`events.ash` points to `collect_public`, whose declared domain requires
`PublicEvent`; the final label locates the containing application. These
three labels connect the rejected argument to the consumer contract. The
secondary identifier is `type.argument`.

For this second repair, replace the argument with the explicit projection.
The following replacement expression is a non-executable fragment, to use
as the body of `main` in a scratch copy of the preceding program:

```text
Events.collect_public (Events.public_view (Events.InternalEvent(1, 7, 424242)))
```

Run the repaired copy. It produces the same `PublicEvent(1, 7)` as the public
pipeline. The two repairs enforce the intended connection at different
places: the public hook carries only public values, and the ordinary consumer
accepts only public values. Diagnostic wording and source layout describe this
tool's presentation; the nominal type and callback requirements are the
language boundary.

## A public shape still needs correct public values

The rejected argument prevents passing the whole internal event to this
consumer. It does not prevent constructing a public event whose code contains
the wrong integer. `05-copy-secret.ash` deliberately copies the secret into
that position:

<!-- source: src/05-copy-secret.ash -->
```ash
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
```

The public constructor takes two integers. Predict whether this program meets
its type and whether its value meets our publication policy:

<!-- observation: src/05-copy-secret.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 05-copy-secret.ash
PublicEvent(1, 424242) : PublicEvent
```
<!-- markdownlint-enable MD013 -->

The program is accepted. Its public shape has no secret field, yet its code
now discloses `424242`. The type checker distinguishes the two nominal event
types; it does not track where each integer originated or supply an automatic
secrecy policy. Transparent constructor access also permits this explicit
construction. The wrong result exposes the application mistake without
changing the language's guarantee.

For every internal event whose identifier and code are suitable for public
use, the definition of `public_view` preserves those two fields and omits the
third. That conclusion follows from its single constructor equation. The
finite observations above check our chosen examples and distinguish the
plausible wrong paths. Same-type redaction is useful within an internal chain,
but the separate public type supplies a boundary the ordinary collector can
check. Correct field selection and the placement of earlier observers remain
program design obligations.

## Practice: choose the observation boundary

Make scratch copies outside this lesson's `src` directory, keeping a copy of
`events.ash` beside each entry. Predict the result before running each change.

1. In `02-snapshot-order.ash`, move both snapshot registrations inside
   `redact`. Explain what they can observe and what earlier code could still
   have seen.
2. In `04-nested-root.ash`, move the inner root outside the redactor's
   registration. Trace the root and registrations used by each publication.
3. Change only the secret in `01-public-view.ash`. Explain from the projection
   equation which parts of the public result can change.
4. In `05-copy-secret.ash`, repair the field selection while preserving the
   public constructor's input shape. Explain why type checking alone could
   not distinguish the original and repaired versions.

The public boundary now has two parts: an explicit conversion that chooses
values, and a nominal interface that checks how they connect. Internal hook
order answers which earlier observers have already received a value. The next
question is how an ordinary handler should judge a proposed action when safe
continuation and application approval are separate responsibilities.

[modules]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#public-private-and-opaque-declarations
[hooks]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#synchronous-typed-hooks
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#synchronous-hook-execution
