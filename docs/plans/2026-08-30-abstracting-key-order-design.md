# Abstracting key order design

Status: approved on 2026-08-30 after independent specification and quality review

## Reader and maintainer problem

The ordered-tree case passes the same explicit comparator through every
`lookup`, `insert`, and `lookup_counted` call. The reader now asks how modules
can reuse that ordering capability without threading a comparator value through
the public API.

The observable boundary crosses from an ordinary source argument to evidence
selected during checking. A constrained tree operation still compares the same
keys and enters the same branch, but its `Order<K>` requirement is not part of
the source value type. At an imported call, ordinary typing determines `K`, and
the direct dependency's public implementation may then satisfy the resulting
obligation. A complete call whose key type has no available implementation is
rejected before evaluation.

The command-line tool can show that a complete program checks and produces the
same value and type as the explicit-comparator version. It can also show the
stable missing-evidence rejection. Successful output cannot reveal which
implementation identity was selected or isolate the Core lowering step. Those
conclusions must remain attached to the pinned specification and retained
implementation tests.

## Authority and version boundary

Every executable observation targets Modular Ash commit
`dca16039923475c48025c5f17beadeb6bcb6a4bf`. Language behavior comes from the
[specification at that commit](https://github.com/dikini/ash-lang/tree/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec).
Commands, values, types, output channels, diagnostics, and statuses come from
the [pinned tool
guide](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md)
and executable.

The published ash-doc `modular-ash` tag remains immutable. This case
is unpublished work for `main`; it neither changes the edition target nor
imports language behavior from current `ash-lang/main`.

Verification must receive a clean Ash checkout whose `HEAD` is the exact
commit above. It builds from inside that checkout with locked dependencies and
invokes that checkout's executable on every complete entry. It also runs three
focused retained tests from that checkout to verify claims that CLI output
cannot isolate:

```text
cargo test --locked --test interfaces \
    cross_module_constraint_lowers_to_method_evidence -- --exact
cargo test --locked --test interface_selection \
    recursive_constrained_global_reuses_its_declared_abstract_evidence \
    -- --exact
cargo test --locked --test interfaces \
    generic_exact_current_self_carries_abstract_prerequisite_evidence \
    -- --exact
```

These retained tests support the specified checking and lowering account. They
are not additional Ash semantics and do not make Core structure observable to
an Ash program.

The governing pinned sections are:

- the [specification overview's interface
  example](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/README.md#interfaces-and-selected-evidence)
  for the complete source shape and the distinction between selected evidence
  and runtime behavior;
- the [syntax
  grammar](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#grammar)
  and [global function
  presentations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/syntax.md#global-function-presentations)
  for method-only interfaces, anonymous implementations, `where` clauses,
  equations, and constrained global signatures;
- [imports and
  namespaces](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#imports-and-namespaces),
  [interface and implementation
  identities](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#interface-implementation-and-requirement-identities),
  [public and private
  declarations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#public-private-and-opaque-declarations),
  and [global
  scope](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/name-resolution.md#global-scope)
  for direct-dependency implementation availability, anonymous public facts,
  method identity, and recursive implementation methods and globals;
- [interfaces and constrained
  schemes](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#interfaces-and-constrained-schemes),
  [implementations](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#implementations),
  [constraint satisfaction and checked
  evidence](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#constraint-satisfaction-and-checked-evidence),
  and [globals and
  modules](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/static-semantics.md#globals-and-modules)
  for explicit requirements, abstract-before-concrete selection, exact current
  implementation evidence, unsatisfied obligations, and complete entry
  checking;
- [interface-evidence
  lowering](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/elaboration.md#interface-evidence-lowering)
  for ordered ordinary function binders and applications generated from
  checked evidence;
- [generated interface
  evidence](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/spec/dynamic-semantics.md#generated-interface-evidence)
  for evaluation through ordinary functions without a runtime interface value,
  registry, lookup, or dispatch; and
- the tool guide's [successful-output
  contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#successful-output)
  and [failure
  contract](https://github.com/dikini/ash-lang/blob/dca16039923475c48025c5f17beadeb6bcb6a4bf/docs/tools/ash.md#failures)
  for exact output, empty opposite channels, stable reason
  `constraint.unsatisfied`, and statuses `0` and `1`.

The ordering invariant, comparator laws, correctness argument, and cost model
remain properties of the selected programs. An `Order<A>` requirement does not
turn those properties into Ash semantics or prove them.

## Reader model and prerequisites

The reader has completed the six earlier Cases chapters. They know the public
transparent `Tree<K, V>`, `Ordering`, `Option<A>`, and unary `Natural` forms;
the global descendant invariant; coherent-order premises; one-branch lookup;
duplicate replacement; malformed transparent values; height; and the split
between visited tree nodes and recursive comparator work.

This case changes how the operation receives comparison. In the preceding API,
the caller supplies `compare_natural` as the first value argument. In the new
API, each generic operation states `where Order<K>`, and its body calls the
interface method `compare`. Recursive calls reuse the operation's declared
abstract evidence. At an entry-module call with `K = Natural`, checking selects
the direct dependency's public `Order<Natural>` implementation.

The method equations remain the same. For completed comparisons of finite
unary Naturals, `C(q, k) = min(|q|, |k|) + 1` still counts recursive `compare`
method applications, including the terminal equation. `lookup_counted` still
counts visited `Node` forms and top-level method applications. Generated
evidence applications are ordinary Core work, but they are outside both named
source counts.

## Approaches considered

### Combine every observation into one entry

One approach would keep one shared module, place successful lookup, replacement,
malformation, ascending insertion, height, and the missing-implementation
boundary into one large entry, and return a deeply nested tuple. This reduces
the source-file count but makes the observation difficult to predict and
obscures which source relationship supports each result. A rejected program
must still be separate, so the approach does not reduce the number of tool
cycles to one.

### Split the interface from the key type and tree API

A second approach would put `Order<A>` in one module and place `Natural`, its
public implementation, and the tree operations in another. The specified
orphan rule permits the owner of the outer nominal implementation head to
declare the implementation, and public export closure should retain the
foreign interface identity.

An exact-pin minimal prototype of that credible split passes source checking
but fails before evaluation with status `2` and
`evidence.validation.unknown-identity`. The same-module shape below succeeds.
This mismatch is classified as an Ash regression candidate, not as language
behavior or a lesson boundary. The case will not teach the internal failure,
add a runtime interpretation, or depend on the failing split. A separate
upstream evidence record would require its own bounded decision and immutable
completed-case reference.

Another working split can keep the interface, Natural, and implementation in
one ordering module while the tree API imports them. Every entry would then
need the implementation-defining module as a direct dependency because public
implementation facts are not re-exported. That is useful future material but
adds an import-availability question before the reader needs it.

### Keep one capability-and-tree module with four focused entries

The selected design keeps `Order`, its example key implementation, and the
transparent tree API in one lesson-local module. It carries forward the three
case-6 accepted entries with comparator arguments removed, so the values and
types remain byte-for-byte comparable. A fourth entry supplies the smallest
missing-implementation rejection.

This is the smallest replaceable choice that answers the reader's question,
preserves continuity, and keeps each observation focused. Deferring the choice
would leave successful output unable to distinguish explicit parameter passing
from selected evidence and would leave the required rejection untested. The
case needs no new shared library, manifest, renderer, dependency, CI service,
research record, or lab harness.

## Lesson-local representation and API

Create `content/cases/abstracting-key-order/` only after this design receives
independent approval and a temporary implementation plan becomes active. The
case contains exactly five canonical sources:

- `src/ordered_trees.ash`;
- `src/01-lookup.ash`;
- `src/02-replace-and-malformed.ash`;
- `src/03-ascending.ash`; and
- `src/04-missing-order.ash`.

The shared module retains the case-6 transparent representations. It replaces
the ordinary `compare_natural` global with this public interface and public
anonymous implementation:

```ash
pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}
```

The interface is method-only. Its parameter occurs in the method type, the
outer type constructor is a function arrow, and the method introduces no other
free type variable. The implementation is public because each entry is a
direct dependent that must use its anonymous fact. The recursive method call
in the final equation uses exact current-implementation evidence.

The public tree operations become:

```ash
pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>
pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>
pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>
```

Their `Node` equations invoke `compare` once and keep the case-6 branch bodies,
replacement policy, and counted additions. Their recursive occurrences omit a
comparator value argument and reuse the declared abstract requirement. `height`
and its private unary `maximum` helper remain unconstrained because they do not
compare keys.

The three accepted entries retain the preceding tree construction, binding
order, and result types. Their only source change removes every
`Trees.compare_natural` argument. That exact correspondence makes the behavior
preservation reviewable without claiming that the generated Core or machine
cost is identical.

## Evidence selection and lowering model

At a call such as `Trees.lookup_counted three valid`, ordinary typing fixes the
key argument to `Trees.Natural`. Instantiating the imported constrained global
creates an `Order<Trees.Natural>` obligation. The entry directly imports the
module that defines the public `Order<Natural>` implementation, so the
effective environment contains one matching concrete implementation.

Inside `lookup_counted`, the method occurrence and recursive constrained
occurrences use its declared abstract `Order<K>` requirement. Abstract evidence
precedes concrete evidence in the selection order. Inside the recursive
`compare` implementation equation, exact current-implementation evidence
reuses the same rigid implementation head rather than selecting another
candidate.

After checking and linked-evidence validation, a constrained global lowers to
ordinary Core function binders for its flattened evidence methods. A call uses
type application first, then evidence applications, then source value
applications. Abstract selections lower to evidence binders; concrete
selections lower to hidden implementation-method binders. The identities and
selection records erase after this authenticated lowering.

The evaluator therefore has no runtime interface value, named implementation,
registry, registration step, implementation search, interface lookup, or
interface-specific dispatch. This does not mean that evidence has zero runtime
work: the generated evidence functions and applications use ordinary
evaluation. The lesson must not claim identical Core, zero overhead, or a
machine-cost result.

The CLI proves only the complete program's accepted output or rejected source
boundary. The lowering account comes from the pinned elaboration and dynamic
semantics plus the three retained tests named above. The chapter will label
that evidence boundary directly instead of asking output to establish an
unobservable compiler step.

## Complete observations

`src/01-lookup.ash` retains the manually valid balanced three-node Natural tree
and performs the same successful and missing counted lookups without an
explicit comparator argument. Its exact output remains:

```text
((Some(30), 2), (None, 2)) : ((Option<Int>, Int), (Option<Int>, Int))
```

The successful query still performs `7` internal Natural `compare`
applications, and the missing query performs `2`; both report two visited tree
nodes and two top-level method applications.

`src/02-replace-and-malformed.ash` retains the original, replacement, and
malformed observations. Its exact output remains:

```text
(Some(10), Some(99), None) : (Option<Int>, Option<Int>, Option<Int>)
```

The public implementation changes how comparison is supplied, not the
coherent-order premises, representative-key replacement policy, persistence of
the older value, transparency, or malformed miss.

`src/03-ascending.ash` retains ascending insertion, unary height, and counted
lookup. Its exact output remains:

<!-- markdownlint-disable MD013 -->
```text
(Node(Empty, Next(Zero), 10, Node(Empty, Next(Next(Zero)), 20, Node(Empty, Next(Next(Next(Zero))), 30, Empty))), Next(Next(Next(Zero))), (Some(30), 3)) : (Tree<Natural, Int>, Natural, (Option<Int>, Int))
```
<!-- markdownlint-enable MD013 -->

The example still observes a three-node right chain, height `3`, and three
visited nodes. An interface requirement supplies no balancing guarantee.

`src/04-missing-order.ash` is a complete entry that imports the shared module,
constructs a tree with an `Int` key, and retains this exact failing call:

```ash
Trees.lookup 1 tree
```

The shared module provides only `Order<Natural>`. Ordinary typing fixes the
missing goal as `Order<Int>`, and no abstract, exact-current, or matching
concrete evidence is available. The exact observation is:

- status `1`;
- empty standard output;
- first standard-error line `constraint.unsatisfied`;
- a primary causal label on the `Trees.lookup` occurrence; and
- related labels for the constrained declaration, direct import, and `Order`
  interface.

The verifier must not teach colors, gutters, byte offsets, or diagnostic prose
as the contract. It asserts the stable reason and causal source relationship.
The failure occurs during checking; there is no runtime attempt to find an
implementation.

## Preserved invariant, return, and cost boundaries

The interface type does not enforce comparator laws. Fix one implementation
whose comparisons required by an argument return, whose `Equal` result is the
chosen equivalence, whose reversed strict comparisons reverse `Less` and
`Greater`, whose strict order is transitive, and whose equivalent keys have the
same relationship to every other key. The case retains the global descendant
invariant. For a finite valid input tree, when every comparison on the entered
insertion path returns, a completed insertion preserves that invariant under
those premises.

For a completed lookup on a finite tree whose query and visited keys `k_1`
through `k_m` are finite unary Naturals, let `C(query, k_i)` count completed
`compare` method applications for that pair, including the terminal equation.
Let `h` be the greatest number of `Node` forms on a root-to-`Empty` path. The
exact comparison sub-work remains the sum from `i = 1` to `m` of
`C(query, k_i)`, surrounding named source work is `O(m)`, and one-branch lookup
has `m <= h`. Only when `C(query, k_i) <= Cmax` for every visited key, with
`Cmax >= 1`, may the combined account be summarized as `O(h * Cmax)`.

The generated evidence applications are ordinary Core applications but are
not counted as visited nodes, top-level source method calls at nodes, or
recursive Natural method applications. The lesson makes no broader elapsed-
time or machine-work comparison with explicit parameter passing.

A finite entered path and returning comparisons on that path are required for
a lookup return claim. A required nonreturning comparison or a reachable
constructor-guarded cycle may prevent return. The nominal type and interface
requirement establish neither finiteness nor termination. `height` continues to
enter both branches and perform separate private `maximum` work.

## Teaching sequence

The chapter begins with the repeated explicit-comparator argument from the
previous case and asks which knowledge every call is carrying. It then:

1. introduces the one-method `Order<A>` capability and its Natural
   implementation;
2. rewrites the tree signatures with explicit `where Order<K>` requirements;
3. follows selection at one imported Natural lookup from ordinary typing to the
   direct public implementation;
4. runs the unchanged lookup, replacement/malformation, and ascending outputs;
5. separates CLI-observable success from specification-and-test evidence for
   lowering;
6. runs the complete missing-`Order<Int>` entry and explains the owned failure;
7. restores the comparator-law, finiteness, cost, and transparency boundaries;
   and
8. asks how an opaque dictionary can prevent clients from constructing the
   malformed tree that remains accepted here.

Practice asks the reader to identify the obligation at an `insert` call, state
why a private implementation in the dependency would not satisfy an entry
call, and predict the missing-evidence result after changing a Natural key to
an unsupported key type. It does not ask the reader to infer compiler Core from
success output.

## Verification and mutation boundary

The lesson-local `checks/verify.sh` uses the existing shared Bash helper. It
must:

- fail first when `src/ordered_trees.ash` is absent, then when the unit README
  is absent;
- require exactly the five canonical sources and five marked `ash` blocks;
- check exact agreement between every displayed block and its canonical file;
- retain exact complete source for the transparent representations, public
  one-method interface, public four-equation Natural implementation, and
  constrained tree API;
- assert `lookup`, `insert`, and `lookup_counted` each have exactly one
  `where Order<K>` requirement and no comparator value parameter;
- assert each `Node` equation makes the intended `compare` method occurrence,
  selects only the intended branch, and passes no comparator through recursive
  calls;
- assert the recursive Natural method keeps the two payloads and calls
  `compare left right`;
- assert all three accepted entries contain no `Trees.compare_natural` and
  retain their case-6 tree construction and observation calls;
- assert the negative entry constructs the unsupported `Int` tree and retains
  exactly `Trees.lookup 1 tree` as the failing occurrence;
- run the three accepted entries with exact value-and-type output, empty
  standard error, and status `0`;
- run the negative entry with empty standard output, status `1`, first reason
  `constraint.unsatisfied`, and causal evidence naming the constrained lookup;
  and
- report five verified canonical sources at the exact pin.

The temporary implementation plan must enumerate focused source mutations for
at least interface visibility, implementation visibility, one Natural base
equation, recursive current-implementation use, each constrained signature,
one abstract recursive lookup call, insertion replacement, counted addition,
removal of an old explicit comparator argument, and movement of the negative
failure away from `Trees.lookup`. Each mutation must fail for the intended
causal assertion and restore to GREEN.

One clean exact-pin verification run also executes the three focused upstream
tests named in the authority section. Those commands belong to implementation
and closure verification rather than the permanent lesson-local verifier, so
ordinary aggregate lesson checks do not rebuild the upstream test binaries on
every run.

Before closure, run Bash syntax, ShellCheck, Markdown, spelling when available,
relative-link checks, the local verifier, all Learn checks, all Cases checks,
source counts, `git diff --check`, tag and pin checks, and clean-status checks.
Read every changed file as source. Independent specification and quality
review must approve the design, implementation, and repository integration.

## Repository integration and closure

The root README extends the recursive-algorithm summary from six to seven
verified unpublished cases. The Cases index adds item 7 after searching an
ordered tree. The roadmap moves this outcome under `Verified increments`,
records the exact accepted and rejected observations, selected-evidence and
lowering boundaries, preserved invariant and costs, and exclusions, then
promotes case 8, `Protecting the dictionary invariant`, to `Next` with its
bounded-design and temporary-plan gate.

Cases 9 through 12 remain provisional and byte-for-byte unchanged. The
regression candidate discovered while comparing module splits is not presented
as a specified boundary and does not alter their order. A future upstream
evidence record is outside this lesson unless a separate bounded decision
selects it after the completed case has an immutable commit.

During integration review, the roadmap links this approved design and its
active temporary implementation plan. Only after independent closure reviews
and a fresh full verification pass may the live links and exactly those two
temporary files be removed. Git history retains them. The completed branch is
merged locally without pushing, verified on `main`, and cleaned up before case
8 design begins.

## Attribution, exclusions, and replacement condition

This case continues the original ordered-tree program developed in the
preceding ash-doc case. It needs no new external source tradition, adaptation,
license record, or attribution. The pinned specification and tests are
authorities and executable support, not tutorial source material.

The case deliberately excludes:

- enforcement of total-order, equivalence, finiteness, or termination laws by
  `Order<A>`;
- inferred global requirements, associated declarations, default methods,
  named implementations, overlapping implementations, generic prerequisites,
  or transitive implementation re-export;
- runtime interface values, registries, lookup, registration, dynamic
  dispatch, or interface-specific evaluation rules;
- claims that CLI output exposes implementation identity, abstract versus
  concrete selection, evidence order, Core shape, or lowering;
- zero-overhead, identical-Core, elapsed-time, machine-instruction, native-
  stack, heap-byte, garbage-collection, pointer-identity, physical-sharing,
  compiler-optimization, or arbitrary-precision bit-cost claims;
- opacity, invariant enforcement, balancing, deletion, mutation, iteration,
  and generic tree infrastructure; and
- teaching the minimized `evidence.validation.unknown-identity` regression
  candidate as Ash behavior.

Replace the one-module lesson shape only when a later complete case needs a
separate ordering package and can teach direct implementation availability
without relying on the pinned regression. Revisit the local verifier only when
the shared helper cannot express a complete observation. No current need
selects a manifest, renderer, shared tree library, CI service, or publication
mechanism.
