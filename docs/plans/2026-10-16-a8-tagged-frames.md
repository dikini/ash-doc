# A8: Round-trip tagged frames

The reader asks how encoding and decoding can preserve a message while buffer
access remains scoped. The observable boundary separates format agreement,
logical frame length, acquisition failure, operation failure, and escaping
access. Scope is one lesson implementing roadmap A8.

## Target and prerequisites

**State:** planned; application code and observations remain unverified.

Use `diag-ash`, exact Ash commit
`9ec5920e8c395f9a36125805ee93b7f58c0f4764`, throughout.
Read README, workflow, writing skill, and roadmap A8. Continue
`content/cases/reading-a-bounded-message/`,
`content/effects/acquiring-a-buffer/`, and
`content/effects/keeping-access-in-scope/`, including their local checks.
The [overview][overview], [native-buffer typing][buffers],
[buffer execution][execution], and [resource dependencies][resources] govern
scoped access and nested outcomes. They do not establish a format's round trip.
DN-0052 at `9f8738b7e0d7f280f9744bf808343d2c97ce6661` is informative only.

## Fixed design

Use slug `round-tripping-tagged-frames`, branch `codex/a8-tagged-frames`.
Non-executable design notation: `Message = Ping | Reading(Int) | Pair(Int, Int)`;
`DecodeResult = Decoded(Message) | BadTag | Truncated | TrailingData`;
`run_frame(capacity, byte_values)` returns
`Buffer.Outcome<Buffer.Outcome<DecodeResult>>`.
The outer layer identifies acquisition and the inner layer operation results
from the same builtin outcome family; preserve nesting rather than flattening.

The entire format is exactly one frame: `Ping` encodes `[0]`, `Reading(n)`
encodes `[1,n]`, and `Pair(x,y)` encodes `[2,x,y]`. Trailing input is rejected.
Payload bytes are integers `0..255`; native writes enforce their range. Never
claim a native read returns `256`. Encode into an ordinary integer list;
validate each byte through checked writes and decode under one live buffer
owner. A scoped cursor
tracks a numeric position and the logical frame length; a direct decoder returns
only copied ordinary `Message` data. `run_frame` derives logical length from
its supplied byte list, never from allocated capacity or caller metadata.

A cursor EOF means logical length reached, even if zeroed allocation has spare
capacity. Thus empty input at capacity `1` is truncated, `[1]` at capacity `2`
is truncated rather than `Reading(0)`, and `[0]` at capacity `3` is valid rather
than trailing data. Positive insufficient capacity remains a native write
`InvalidIndex` failure, distinct from logical truncation.

Compare a direct decoder with a separate materialized token representation.
Choose direct decoding because one small tagged frame needs no extra IR;
deferral risks obscuring the logical-length boundary. Explain tag cases and
field order from golden bytes. A swapped-pair encoder remains well typed but
breaks format agreement. Revisit an IR only for a concrete later decoding need.

## Owned files

All paths are relative to `content/cases/round-tripping-tagged-frames/`.
Create `README.md`, `checks/verify.sh`, and:

- `src/frames.ash`: ordinary message, byte-list, format and decoder results.
- `src/codec.ash`: encoder, scoped cursor, direct decoder, `run_frame`.
- `src/01-round-trips.ash`: constructors, distinct pair fields, boundaries 0/255.
- `src/02-malformed.ash`: bad tags, truncation, trailing and logical length.
- `src/03-buffer-failures.ash`: acquisition/write failures and unchanged bytes.
- `src/04-swapped-pair.ash`: well-typed inconsistent encoder.
- `src/05-escaping-cursor.ash`: rejected closure capturing scoped buffer access.
- `src/06-decode-in-scope.ash`: accepted repair returning ordinary data.
- `checks/05-escaping-cursor.diagnostic.json`: inspected semantic fixture.

Keep golden byte lists as literal expected data in the entries and local checks;
keep complete human capture in the README's marked transcript fence. No binary,
network, string, or external-process fixtures are required.

## Implementation sequence

1. Derive encoder/decoder types and error channels from the format profile.
   Hand-calculate constructor bytes and the logical-length examples first.
2. Implement checked writes, a cursor confined to its owner, and direct decoder.
   Keep acquisition's outer wrapper and operation's inner wrapper visible.
3. Check golden encoding bytes independently before round trips: two mutually
   wrong functions can agree. Decode independent golden inputs as a second check.
4. Add malformed inputs, capacity boundaries, and invalid writes. Establish each
   result channel before writing prose that explains its cause.
5. Add swapped-pair and escaping-cursor examples; capture the complete rejection
   and repair through decoding inside the live scope.
6. Write the connected chapter and practice. Verify locally, then obtain shared
   integrator updates and independent review within the same Case PR.

## Acceptance and verification

- `Ping`, `Reading(0)`, `Reading(255)`, `Pair(0,255)`, and `Pair(255,0)`
  have exact golden bytes and decode back to the same constructor and field
  order. Verify encoding and decoding independently, then round trips.
- `[9]` yields `BadTag`; `[1]` and `[2,7]` yield `Truncated`;
  `[0,9]` yields `TrailingData`. These are ordinary decode results within two
  success wrappers, not source failures.
- Empty bytes at capacity `1` yield `Truncated`; `[1]` at capacity `2` still
  yields `Truncated`; `[0]` at capacity `3` yields `Decoded(Ping)`.
- Writing `256` to a valid index yields inner `Failure(InvalidByte)`.
  An independent write/read control proves that rejected write leaves the
  previously written byte unchanged. Never inject 256 through native reading.
- Capacity `0` yields outer `Failure(InvalidLength)` and a body-entry sentinel
  proves the body was not entered. Positive too-small capacity yields outer
  success with inner `Failure(InvalidIndex)` during writing.
- The swapped-pair encoder compiles but fails distinct-field golden agreement.
  Escaping a cursor closure rejects with `type.resource-escape`, relevant
  owner/capture labels, and an accepted in-scope repair returning copied data.
- Assert the source relationship deriving logical length from byte-list length,
  not buffer capacity, and preserve the two result wrappers in expected types.

Run from ash-doc after implementation:

```sh
bash content/cases/round-tripping-tagged-frames/checks/verify.sh /path/to/diag-ash
bash -n content/cases/round-tripping-tagged-frames/checks/verify.sh
shellcheck -x -P SCRIPTDIR content/cases/round-tripping-tagged-frames/checks/verify.sh
markdownlint content/cases/round-tripping-tagged-frames/README.md
```

Exclude forced allocation exhaustion, String/Bytes APIs, standard codecs,
reflection, derivation, general IR frameworks, pointers, FFI, and external I/O.

## Execution and handoff

Follow the [shared execution contract](2026-10-16-application-cases-integration.md#shared-execution-contract).
Use `dikini/ash-doc`, one issue and one PR for this Case, and an isolated
`.worktrees/` checkout. Dispatch the PM with `gpt-6.1-sol` / `medium`,
the developer with `gpt-6.1-sol` / `xhigh`, and the reviewer with
`gpt-6.1-sol` / `max`. The Case author owns the lesson and this temporary plan.
The integrator owns shared index, runner, and coverage/count updates, included
in this same PR before final review. Do not edit those shared paths concurrently.

The issue must carry the reader question, exact pin, this plan, owned inventory,
acceptance criteria, and exclusions. The PR records observations, affected
checks, independent review findings and repairs, and remaining discoveries.
Do not merge until the complete Case and integrator changes pass review.
Remove this plan when its outcome is complete; Git retains its history.

Read every changed source, check spelling, relative links, attribution and
pinned anchors, and run `git diff --check` and `git status --short`.
Use original prose and code; adapt the teaching method recorded in the project's
HtDP/DCIC/Liquid Shplait research rather than copying their examples or wording.
Each displayed executable block must exactly match its canonical source.
Use the existing `content/checks/lib.sh` and its JSON and human comparisons;
assert value, type, stdout, stderr, status, and causal source relationships.
Capture every provided diagnostic in full using explicit human format and
English locale; normalize only the documented checkout prefix. Keep discovery
exercise answers undisclosed. Do not promote diagnostic wording to semantics.

No Case rendering is required here. Final integration owns HTML, EPUB, and both
PDF formats. Do not run whole-book builds or unrelated lesson checks.
Correct documentation errors against the pin. Minimize a specified-behavior
failure with passing controls as a regression candidate; return unspecified
semantics to Ash design. Retain other pressure as evidence. A regression leaves
the promised outcome incomplete: do not weaken it, modify ash-lang, or move the
pin. Report a required lab/shared change for separately bounded ownership.

[overview]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/README.md
[buffers]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-native-buffers
[resources]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/static-semantics.md#scoped-cells-and-resource-dependencies
[execution]: https://github.com/dikini/ash-lang/blob/9ec5920e8c395f9a36125805ee93b7f58c0f4764/spec/dynamic-semantics.md#scoped-native-buffer-execution
