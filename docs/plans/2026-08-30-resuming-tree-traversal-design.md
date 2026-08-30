# Resuming tree traversal design

Status: approved on 2026-08-30 after independent specification and
instructional/workflow review

## Reader question and observable boundary

**Question:** How can traversal pause and resume without laziness?

Case 9 ends with a balanced dictionary whose lookup enters one logarithmic
path. An in-order traversal must eventually enter every node, but a client may
want one association now and the next one later. The crossed boundary is one
recursive call that completes a whole eager traversal versus explicit immutable
state that records the unfinished traversal between calls.

The new idea is not a lazy sequence. It is the recursive continuation written
as ordinary eager data: the next association, its unentered right subtree, and
the remaining unfinished ancestors.

## Sequence and outcome

The reader already knows:

- strict recursive list and tree traversal;
- persistent accumulator state;
- ordered-tree lookup and insertion;
- public opaque construction boundaries; and
- the red-black height argument from case 9.

The case adds one idea: an eager forward iterator can turn the implicit pending
path of in-order recursion into an explicit private stack. A reader completes
the case able to:

- explain why initialization stores the initial left spine;
- predict how one `next` call yields a pair and prepares the following state;
- distinguish source-level opacity from structural tool observation;
- derive worst-case and complete-traversal frame work; and
- explain why retaining and branching from an old state may repeat deferred
  work even though one linear traversal has amortized constant frame work per
  result.

The case belongs at
`content/cases/resuming-tree-traversal/`. Its prose, complete source modules,
accepted and rejected observations, and checks land together.

## Authority and target

The exact Ash target remains the published Modular Ash checkpoint:

```text
dca16039923475c48025c5f17beadeb6bcb6a4bf
```

The ash-doc `modular-ash` tag remains immutable at
`e963a1597176f86003926eef827498db2a661b75`. The new case remains unpublished
work on `main` and does not retarget the edition.

Language claims are limited to the pinned:

- [specification overview](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/README.md),
  especially pure modules, nominal data, and opacity;
- [syntax](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md)
  for parameterized nominal data, functions, matches, and modules;
- [public, private, and opaque declaration
  rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations);
- [function and application
  typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#functions-and-application)
  together with [pattern, match, and coverage
  typing](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#patterns-matches-and-coverage);
- strict dynamic [application
  rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#application)
  and [constructor and match
  rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#tuples-constructors-and-matches);
  and
- [observation
  rules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#observation).

Invocation, exact output, diagnostics, channels, and statuses come from the
pinned [`ash` tool
guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md).
The case-9 chapter and canonical dictionary source supply the inherited
dictionary representation and its proved project-level premises. Neither they
nor this design can add Ash semantics.

## Approaches considered

### Keep a private explicit stack of pending frames

The selected approach extends the defining `Dictionaries` module with one
private recursive frame stack and one public opaque iterator:

```text
FrameStack<K, V> =
    NoFrame
    | MoreFrame(K, V, Dictionary<K, V>, FrameStack<K, V>)

Iterator<K, V> = Iterator(FrameStack<K, V>)
```

One frame records the association to produce, its unentered right subtree, and
the rest of the pending ancestor path. Initialization descends the initial left
spine. A successful step removes one frame and descends the saved right
subtree's left spine.

This representation stores exactly the information needed for forward
in-order traversal. It meets the roadmap's height, worst-case step, and linear
sequence bounds without adding a generic cursor or a second collection API.

### Materialize every association as a list

An eager in-order conversion followed by a list cursor would make each `next`
simple. It would first traverse all `n` nodes, construct an `n`-element list,
and retain that complete new representation before returning the iterator.
Initialization and explicit iterator state would therefore be `O(n)`, not
`O(h)`, and the first result could not precede the complete traversal.

This approach is rejected because it hides the pause boundary behind eager
precomputation.

### Store a zipper or function-valued continuation

A bidirectional zipper is credible but carries focus replacement and movement
capabilities that a forward-only iterator does not need. A closure or thunk can
delay the remaining traversal, but it makes suspended computation rather than
explicit data the representation. It also conflicts with the roadmap's
deliberate exclusion of thunk and lazy encodings, and function observation
would reveal only `<function>`.

Both approaches are rejected. Deferring the representation choice would leave
the case unable to state or test its retained-state invariant and work account.

## Selected public and private boundary

The complete case-9 API remains available. The defining module adds exactly:

```text
pub opaque type Iterator<K, V> =
    Iterator(FrameStack<K, V>)

pub iterator : Dictionary<K, V> -> Iterator<K, V>

pub next : Iterator<K, V> -> Option<((K, V), Iterator<K, V>)>
```

The precise constructor layout above is design pseudocode until the exact-pin
source is accepted. `FrameStack`, `NoFrame`, `MoreFrame`, and the `Iterator`
constructor remain private to the defining module. Clients can name
`Iterator<K, V>`, retain it, pass it to `next`, and match the public `Option`
and tuple result. They cannot construct or pattern match the iterator
constructor.

Neither public function needs `Order<K>` evidence. They inspect a previously
constructed dictionary's branch structure and make no comparison. Sorted
output depends on the inherited dictionary invariant and ordering premises;
the iterator type does not encode or re-establish them.

The representation invariant for every iterator reached from `iterator` and
successive returned states is:

1. each frame's left subtree has already been exhausted;
2. the frame's association is the next association at that level;
3. its stored right subtree has not yet been entered;
4. the rest records unfinished ancestors in their later in-order sequence; and
5. the number of explicit frame forms is at most the dictionary height.

Opacity prevents a client from forging a state. It does not prove that the
defining module preserves this invariant, prevent the module from constructing
a malformed or cyclic state, or hide structural output from the tool.

## Data flow

The private helper has this conceptual behavior:

```text
push_left Empty frames = frames
push_left Node(left, key, value, right) frames =
    push_left left (MoreFrame(key, value, right, frames))
```

`iterator dictionary` calls `push_left dictionary NoFrame` and wraps the
result. This performs eager work along only the initial left spine.

`next` has two cases:

- `NoFrame` produces `None`; and
- `MoreFrame(key, value, right, rest)` produces the key-value pair and a new
  iterator over `push_left right rest`.

Ash evaluates the selected arm and its constructor arguments strictly. The
new state is complete ordinary nominal data when `next` returns. No thunk,
generator, mutation, or runtime iterator service is involved.

## Executable evidence

The implementation plan will fix the exact source and output, but the bounded
case owns four canonical files:

```text
content/cases/resuming-tree-traversal/src/dictionaries.ash
content/cases/resuming-tree-traversal/src/01-sequence.ash
content/cases/resuming-tree-traversal/src/02-retained-state.ash
content/cases/resuming-tree-traversal/src/03-opaque-pattern.ash
content/cases/resuming-tree-traversal/src/04-opaque-construction.ash
```

`dictionaries.ash` is a complete dependency module derived from the accepted
case-9 source. It removes the old entry-only private fixtures, retains the
public dictionary API and red-black implementation, and adds only the iterator
representation and operations needed here.

The accepted sequence entry builds a three-association dictionary, observes
the associations in increasing-key order, and establishes that the fourth
call produces `None`. It also observes `None` immediately for an empty
dictionary. Its client source can use only the public iterator API.

The accepted retained-state entry keeps one intermediate iterator, returns raw
iterator states as part of its result, resumes the intermediate state twice,
and observes the same next association and equivalent later result sequence
through both branches. Structural output can therefore display private
`Iterator` and frame constructor spellings before the rejection examples show
that observation grants no source access. Replaying the state establishes
source-level persistence for the fixed program. It also makes the amortization
boundary visible: a linear state chain does not charge work performed again
after branching from an older state.

One rejected entry attempts to pattern match the private `Iterator`
constructor. The other attempts to use that constructor as a value. Each must
produce empty standard output, status `1`, first standard error reason
`resolve.opaque-constructor`, and a primary causal label on its distinct client
constructor occurrence. Presentation prose, colors, gutters, and byte offsets
are not contracts.

Exact output cannot prove the general ordering, state, or work invariants. The
verifier must also assert the causal source relationships: one opaque iterator,
one private frame stack, the two `push_left` cases, the exact saved right and
rest fields, the two `next` cases, absence of iterator comparison requirements,
raw-state retention and replay, both distinct forbidden constructor contexts,
and every step in the accepted observations.

## Work, construction, and retained state

Let `d` be the number of nonempty nodes on one left-spine descent. A completed
`push_left` performs `d + 1` helper applications, including the terminal
`Empty` case, and constructs exactly `d` `MoreFrame` forms.

For a finite dictionary of height `h`, initialization has `d <= h`. It
therefore constructs at most `h` explicit frames and one `Iterator` wrapper.
The `O(h)` state claim counts the iterator's own frame forms. Each frame also
retains an existing key, value, right-subtree value, and remaining stack value.
The iterator may keep much or all of the original dictionary reachable; the
case makes no `O(h)` claim about all transitively reachable data or runtime
bytes.

An exhausted `next` selects `NoFrame` and returns `None`. A successful `next`
pops one frame, then pushes `d_i` frames for the saved right subtree's left
spine. Its frame work is `1 + d_i <= h`, so one call has worst-case `O(h)`
frame work. It also constructs one new `Iterator` and one `Some` result.

Across one complete linear traversal of a finite `n`-node dictionary, every
node enters a frame exactly once and leaves a frame exactly once. There are
exactly `n` pushes and `n` pops, or `2n` frame operations including
initialization. This is within `O(n + h)` and gives amortized constant frame
work per produced association. The exact final `None` call performs no frame
push or pop.

The amortized statement applies to one linear sequence of returned states.
Retaining an older iterator and calling `next` from it again can repeat the
same right-subtree left descent and construct another corresponding frame
path. The case claims persistence and repeatable results, not a global
amortized bound across an arbitrary branching history.

For a valid red-black dictionary, case 9 gives
`h <= 2 log2(n + 1)`. Under those inherited premises, explicit initial state
and one worst-case `next` use `O(log(n + 1))` frame work. A complete traversal
still visits every association and remains linear in `n`.

These are named source applications, constructor applications, and reachable
source values. They do not establish elapsed time, machine instructions,
native-stack depth, tail-call optimization, heap layout or bytes, garbage
collection, runtime pointer identity, physical sharing, or compiler
representation and optimization.

## Return, ordering, cycles, and observation

Return claims apply to finite acyclic dictionary spines reached through
completed public operations and to iterator states produced from them. An
initial left-edge cycle can prevent `iterator` from returning. A cycle in a
saved right subtree may allow earlier calls to return before a later `next`
enters that cycle. Defining-module code can construct such values even though
clients cannot.

The iterator performs no key comparison. For a dictionary satisfying the
inherited global ordering invariant, structural in-order traversal yields
associations in increasing key order. A malformed defining-module dictionary
can yield an out-of-order sequence; the iterator does not validate or sort it.
A cyclic key or value payload can be returned without being traversed, while
final structural observation may later render an active-path revisit as
`<cycle>`.

The tool may render `Iterator`, `MoreFrame`, or dictionary constructors when a
successful result contains those values. Observation does not export a source
name or grant constructor access. The rejection case tests the separate source
boundary.

## Teaching shape

The chapter continues case 9's final question rather than repeating setup or
red-black insertion:

1. contrast a complete eager traversal with the desire for one result now;
2. briefly reject eager list materialization because it pays for all nodes
   before the first result;
3. derive one pending frame from the usual left/current/right order;
4. predict and inspect initialization on a small tree;
5. predict and run three successful steps followed by `None`;
6. explain the private representation and its public opaque boundary;
7. retain and replay an intermediate state;
8. derive the worst-case and complete-linear-traversal frame accounts;
9. preserve the finite, ordering, cycle, reachability, and runtime exclusions;
   and
10. end by asking how a FIFO frontier changes persistent state and amortized
    reasoning.

Practice asks the reader to draw frame states, predict a right-subtree descent,
derive `2n` pushes and pops, explain the branching-history caveat, and contrast
the iterator's LIFO path with a FIFO queue.

## Source and adaptation boundary

No new external algorithm source is selected. The frame stack is an original
ash-doc representation derived directly from the case-9 tree equations and the
already selected eager recursive-algorithm method.

Existing records remain sufficient:

- `research/how-to-design-programs-recursive-algorithms.md` governs explicit
  state and source-level cost reasoning;
- `research/functional-programming-with-bananas.md` preserves the strict versus
  lazy boundary; and
- `research/persistent-red-black-insertion.md` supplies only the inherited tree
  representation and logarithmic-height result.

The case will not copy or closely translate an external iterator, zipper,
generator, or exercise. A new research record becomes necessary only if later
work selects a named external cursor tradition or directly adapts source
expression. Existing source licenses and attribution classifications remain
unchanged.

## Deliberate exclusions

The case introduces no:

- lazy list, thunk, generator, stream, coroutine, or infinite traversal;
- mutation, hidden mutable cursor, in-place update, or iterator invalidation;
- reverse step, insertion through a cursor, deletion, or generic zipper API;
- new dictionary ordering or balance proof;
- ordering comparison during iteration or retained runtime evidence registry;
- runtime representation secrecy from opacity;
- totality proposition for all nominal values;
- elapsed-time, machine-instruction, host-stack, heap-byte, pointer-identity,
  physical-sharing, garbage-collection, or compiler-optimization claim; or
- amortized bound over arbitrary branching reuse of old iterator states.

Case 11 remains provisional until this case verifies and closes. This design
authorizes no queue source, directory, prose, or tooling.

## Verification and completion

The implementation plan must use test-first evidence and name exact outputs,
source hashes, verifier mutation-sensitivity checks, and review order. Those
checks alter disposable copies of source or verifier inputs only to prove that
each intended assertion fails; they make no runtime mutation claim. The
complete case must pass:

- its local Bash verifier at the exact pin;
- exact success channels, outputs, types, and status;
- exact rejection reason, channels, status, and causal source occurrence;
- complete displayed-source agreement;
- Bash syntax and ShellCheck;
- Markdown structure and relative links;
- all Learn and Cases aggregators;
- focused pinned opacity tests;
- independent specification and instructional reviews;
- `git diff --check`; and
- exact ash-doc tag and Ash pin checks with clean worktrees.

Closure updates root and Cases navigation, replaces the active roadmap section
with a durable verified summary, promotes only case 11 to its bounded design
gate, removes this temporary design and the implementation plan, and merges a
reviewed clean branch locally without pushing.
