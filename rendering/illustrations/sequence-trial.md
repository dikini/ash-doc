---
diagrams:
  - kind: illustration
    id: fig-item-lookup-trial
    caption: A caller receives an item through a service.
    description: Three participants run left to right as Caller, Service, and Store. Caller sends Get item to Service, which sends Read item to Store. Store replies Item to Service, and Service replies Item to Caller. Time runs downward; requests are solid arrows and replies are dashed arrows.
---

# Following a request and its reply

The caller does not contact the store directly. Follow the service's request
to the store and the replies back to the caller. Read the messages from top
to bottom.

```{#fig-item-lookup-trial .illustration}
Make a Mermaid sequence diagram with Caller, Service, and Store, arranged
left to right. Caller asks Service to get an item. Service asks Store to read
the item. Store returns the item to Service, then Service returns it to Caller.
Label the two requests Get item and Read item, and label both replies Item.
Show time flowing downward, with solid request arrows and dashed reply arrows.
Use regular lettering and crisp strokes for this first renderer trial. Keep
the picture focused on these four messages; do not add retries or failures.
```

The message order distinguishes the request from the work that the service
delegates. The diagram does not specify storage details or error handling.
