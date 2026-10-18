# Cancel a stable sort

A comparison budget can stop a sort before it has an answer. That creates two
separate promises: a completed result must put records in the intended order,
and a cancelled result must report only the comparison work already allowed.
Calling an unfinished sequence sorted would hide the distinction.

Continue from [ordered tree search](../searching-ordered-tree/README.md),
[measuring comparisons](../measuring-tree-search/README.md), and
[bounded search](../bounding-search-work/README.md). Those Cases separated an
ordering invariant, a named unit of work, and a handler that can stop further
work. Here the algorithm also preserves the input order of equal-priority
records. That property is called *stability*.

## Choose the records and the complete result

A record has a priority and an identifier. Choose three priorities, ordered
`Low`, then `Normal`, then `High`. This is our application's relation, defined
by the comparator below; constructor declaration order supplies no such rule.
Identifiers let us recognize records and the original order of ties. They do
not participate in comparison.

Use this input, with slash notation meaning priority and identifier:

```text
Normal/1, Low/2, Normal/3, High/4, Low/5
```

The intended result is `Low/2, Low/5, Normal/1, Normal/3, High/4`. Low records
retain input IDs `2,5`; Normal records retain `1,3`. Preserving every complete
record is a separate requirement from putting its priority in order. A result
that lost one Low record could be ordered without being a permutation of the
input.

Derive two interfaces from complete versus cancelled work. Sorting returns
`Records`; only finishing that calculation allows its caller to construct
`Sorted(records)`. A handler that abandons it returns `Cancelled` instead.
Before comparing two records, insertion requests
`Compare.allow : Unit -> Unit`. An answer lets that comparison run; discard
abandons the pending comparison and the waiting `Sorted` construction.

We will return a triple: result, used comparison count, and a comparison trace.
The count belongs to the permission policy. The trace records operand IDs and
the ordering actually returned by the comparator. Keeping both observations
will show whether denied permission accidentally ran a comparison.

## Insert an earlier record into its sorted tail

Sort the tail first, then insert the original head into that result. Assume
the recursive result has three properties:

- its priorities are ordered by our fixed comparator;
- it contains exactly the tail's complete records; and
- equal-priority records remain in their original tail order.

Insertion must preserve those properties while adding the head. If the current
tail record has lower priority, retain it and insert into the remaining tail.
If it has equal or greater priority, put the incoming record before it.
At an empty tail, construct a singleton.

The equal case follows from the recursion direction. The incoming head
occurred before every record in its original tail, including equal-priority
ones. Inserting it before the first equal preserves that earlier position.
Inserting it after equals would reverse their order as successive earlier
heads are added.

These cases also preserve all records. The stopping case adds the incoming
record and retains the current record and rest. The advancing case retains the
current record while the recursive insertion adds the incoming one. The empty
case adds just that one record. With the ordered-tail assumption, advancing
passes only lower-priority records and stopping leaves no smaller record after
the inserted head. The recursive calls consume smaller finite lists.

Keep the representation, comparator, insertion, and budget handler in
`sort.ash`:

<!-- source: src/sort.ash -->
```ash
import @builtin.cell as Cell

pub type Priority = Low
    | Normal
    | High
pub type Record = Record(Priority, Int)
pub type Records = End
    | More(Record, Records)
pub type Ordering = Before
    | Same
    | After
pub type Result = Sorted(Records)
    | Cancelled
pub type Comparisons = Done
    | Comparison(Int, Int, Ordering, Comparisons)

pub effect Compare {
    allow : Unit -> Unit
}

pub effect Trace {
    compared : (Int, Int, Ordering) -> Unit
}

order : (Priority, Priority) -> Ordering
order (Low, Low) = Same
order (Low, Normal) = Before
order (Low, High) = Before
order (Normal, Low) = After
order (Normal, Normal) = Same
order (Normal, High) = Before
order (High, Low) = After
order (High, Normal) = After
order (High, High) = Same

pub compare : (Record, Record) -> Ordering ! {Trace}
compare (Record(left, left_id), Record(right, right_id)) = {
    let ordering = order (left, right)
    let ignored = perform Trace.compared (left_id, right_id, ordering)
    ordering
}

pub insert : (Record, Records) -> Records ! {Compare, Trace}
insert (record, End) = More(record, End)
insert (record, More(current, rest)) = {
    let ignored = perform Compare.allow ()
    match compare (record, current) {
        Before => More(record, More(current, rest))
        Same => More(record, More(current, rest))
        After => More(current, insert (record, rest))
    }
}

pub stable_sort : Records -> Records ! {Compare, Trace}
stable_sort End = End
stable_sort (More(record, rest)) = {
    let ordered_tail = stable_sort rest
    insert (record, ordered_tail)
}

pub sample : Unit -> Records
sample () = More (
    Record(Normal, 1), More (
        Record(Low, 2), More (
            Record(Normal, 3), More (
                Record(High, 4), More(Record(Low, 5), End)
            )
        )
    )
)

pub equals : Unit -> Records
equals () = More (
    Record(Normal, 11), More (
        Record(Normal, 12), More(Record(Normal, 13), End)
    )
)

pub run : (Records, Int) -> (Result, Int, Comparisons)
run (records, budget) = resource cell<R> used = 0 {
    handle {
        let result = handle (Sorted (stable_sort records)) with Compare {
            allow () => match Cell.read used == budget {
                true => {
                    let ignored = discard
                    Cancelled
                }
                false => {
                    let count = Cell.read used
                    let ignored = Cell.write (used, count + 1)
                    resume ()
                }
            }
        }
        (result, Cell.read used, Done)
    } with Trace {
        compared (left_id, right_id, ordering) => {
            let (result, count, later) = resume ()
            (result, count, Comparison(left_id, right_id, ordering, later))
        }
    }
}
```

The nine equations for `order` define the finite relation explicitly. `compare`
computes that ordering, records it through `Trace.compared`, and returns it.
In each nonempty insertion step, `Compare.allow` precedes the call to
`compare`. Empty insertion needs neither permission nor a comparison.
The [evaluation rules][completion] explain why a denied request never reaches
the expression following it when its continuation is discarded.

The `run` policy assumes a nonnegative budget. Its cell starts at zero and
increases by one on each admitted comparison until equality reaches the limit.
The denial branch increments nothing. It discards the owned continuation and
returns `Cancelled`; it does not fabricate a partial `Sorted` value. The cell
surrounds both handlers, so its previous writes remain available when `run`
reads the used count.

The trace handler resumes once before prepending its current observation to
the later trace. Thus later budget decisions do not leave that clause's
capability unconsumed, and the returned trace follows actual comparison order.
The [effect rules][effects] check consumption and whether discard can close
this owned work. They do not establish the sort's ordering or stability.

## Calculate the seven comparisons

Before running, work from the end of the input toward its beginning. Inserting
`Low/5` into empty needs no comparison. `High/4` passes `Low/5`. `Normal/3`
passes `Low/5` and stops before `High/4`. `Low/2` stops before equal `Low/5`.
Finally, `Normal/1` passes the two Low records and stops before equal
`Normal/3`. The count is `0 + 1 + 2 + 1 + 3 = 7`.

Here is the complete comparison sequence derived from those insertions.
`Before`, `Same`, and `After` compare the left record's priority with the
right record's priority:

<!-- comparison-trace: src/01-complete.ash -->
| Call | Left ID | Right ID | Ordering |
| --- | --- | --- | --- |
| 1 | `4` | `5` | `After` |
| 2 | `3` | `5` | `After` |
| 3 | `3` | `4` | `Before` |
| 4 | `2` | `5` | `Same` |
| 5 | `1` | `2` | `After` |
| 6 | `1` | `5` | `After` |
| 7 | `1` | `3` | `Same` |

Check the result against an independent pure calculation. `reference.ash`
filters the input separately for Low, Normal, and High, preserving order in
each pass, then concatenates those three groups. It shares the record
representation but uses neither insertion nor the comparator:

<!-- source: src/reference.ash -->
```ash
import sort as Sort

keep_low : Sort.Records -> Sort.Records
keep_low Sort.End = Sort.End
keep_low (Sort.More(record, rest)) = {
    let Sort.Record(priority, ignored_id) = record
    match priority {
        Sort.Low => Sort.More(record, keep_low rest)
        other => keep_low rest
    }
}

keep_normal : Sort.Records -> Sort.Records
keep_normal Sort.End = Sort.End
keep_normal (Sort.More(record, rest)) = {
    let Sort.Record(priority, ignored_id) = record
    match priority {
        Sort.Normal => Sort.More(record, keep_normal rest)
        other => keep_normal rest
    }
}

keep_high : Sort.Records -> Sort.Records
keep_high Sort.End = Sort.End
keep_high (Sort.More(record, rest)) = {
    let Sort.Record(priority, ignored_id) = record
    match priority {
        Sort.High => Sort.More(record, keep_high rest)
        other => keep_high rest
    }
}

append : (Sort.Records, Sort.Records) -> Sort.Records
append (Sort.End, right) = right
append (Sort.More(record, rest), right) = Sort.More (
    record, append (rest, right)
)

pub grouped : Sort.Records -> Sort.Records
grouped records = append (
    keep_low records, append (keep_normal records, keep_high records)
)
```

Each filter retains an entire selected record before filtering the rest, so
it preserves the selected records' input order. The three constructors cover
all priorities exactly once across the filters. Concatenating the groups in
the chosen order therefore supplies an independent stable reference for this
finite priority domain.

Enter `cancelling-a-stable-sort/src` from the Cases directory. Predict the
complete result and count of `01-complete.ash`, then run it:

<!-- source: src/01-complete.ash -->
```ash
import sort as Sort
import reference as Reference

main : Unit -> ((Sort.Result, Int, Sort.Comparisons), Sort.Records)
main () = {
    let records = Sort.sample ()
    (Sort.run (records, 7), Reference.grouped records)
}
```

Run `ash 01-complete.ash`. It returns a pair whose first field is the result,
count, and trace triple; the second is the reference sequence. The trace
matches the seven rows above, the used count is `7`, and the result constructor
is `Sorted`. The following table summarizes every complete record in both
returned sequences; tuple and list structure are omitted:

<!-- complete-records: src/01-complete.ash -->
| Position | Sorted priority | Sorted ID | Reference priority | Reference ID |
| --- | --- | --- | --- | --- |
| 0 | `Low` | `2` | `Low` | `2` |
| 1 | `Low` | `5` | `Low` | `5` |
| 2 | `Normal` | `1` | `Normal` | `1` |
| 3 | `Normal` | `3` | `Normal` | `3` |
| 4 | `High` | `4` | `High` | `4` |

Agreement with the reference is one observation. Comparing these complete
records with the original also checks preservation and per-priority input
order. The invariant argument explains why insertion preserves those
properties for every finite input under the fixed relation; this one run
checks the chosen example and its exact seven-call calculation.

## Bound source work after naming its unit

The seven calls describe one finite input. To obtain a general bound, let an
insertion receive an ordered tail of length `m`. It makes at most `m`
comparisons and reconstructs the passed prefix. The stopping case constructs
both `More(record, ...)` and the current list node; reaching empty constructs
one node. Altogether one insertion constructs at most `m + 1` list nodes.

Sorting `n` records inserts into tails of lengths `0` through `n - 1`.
Consequently, comparisons are bounded by `n(n - 1)/2` and cumulative newly
constructed record-list nodes by `n(n + 1)/2`. The original nodes and unused
tails are immutable; these allocation counts do not describe peak live memory
or physical stack use. The trace adds one observation node per comparison.

Three possible priorities still permit quadratic work. Consider `k` High
records followed by `k` Low records. Sorting the Low block keeps it together.
Each earlier High must pass all `k` Low records before reaching the High group
or the end. Those crossings alone contribute `k * k` comparisons and prefix
reconstruction. This is a source-work argument using comparisons and
constructor operations as units; it is not a timing benchmark or a claim about
evaluator handler search and physical representation costs.

Insertion keeps its equality position and charge point visible. A merge sort
would offer a different work bound, but would need separate splitting, merging,
and tie-order arguments. The present algorithm answers this smaller question
with those two decisions next to each other.

## Stop before the next comparison

`02-budgets.ash` runs the same input with budgets zero, six, seven, and eight.
Predict which budget first permits a complete sort. Also predict whether a
denied request appears in the returned trace:

<!-- source: src/02-budgets.ash -->
```ash
import sort as Sort

main : Unit -> (
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons)
)
main () = {
    let records = Sort.sample ()
    (
        Sort.run (records, 0), Sort.run (records, 6),
        Sort.run (records, 7), Sort.run (records, 8)
    )
}
```

Run `ash 02-budgets.ash`. It returns four result/count/trace triples in budget
order. The table summarizes those fields from this one captured result.
Trace rows refer to the complete seven-row table above:

<!-- budget-observations: src/02-budgets.ash -->
| Budget | Result constructor | Used | Trace rows |
| --- | --- | --- | --- |
| `0` | `Cancelled` | `0` | None |
| `6` | `Cancelled` | `6` | 1–6 |
| `7` | `Sorted` | `7` | 1–7 |
| `8` | `Sorted` | `7` | 1–7 |

Both completed results contain the same complete records shown above. At six,
the next comparison would be `Normal/1` against `Normal/3`. The handler denies
its permission request, so that seventh call is absent and the result is
`Cancelled`. At seven, that call runs and insertion completes without another
request. A larger budget does not force an extra comparison.

Cancellation reports earlier allowed work without returning a partial sequence.
Discard does not undo the counter writes or earlier trace entries. The
selected continuation contains pending insertion work and the final `Sorted`
construction; abandoning it prevents both from finishing. These are
synchronous permission points in this calculation, not asynchronous interrupts.

Small inputs check the boundary where no comparison is needed, and three
identical priorities make the stability condition visible:

<!-- source: src/03-small-inputs.ash -->
```ash
import sort as Sort

main : Unit -> (
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons)
)
main () = (
    Sort.run (Sort.End, 0),
    Sort.run (Sort.More(Sort.Record(Sort.High, 9), Sort.End), 0),
    Sort.run (Sort.equals (), 2)
)
```

<!-- observation: src/03-small-inputs.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 03-small-inputs.ash
((Sorted(End), 0, Done), (Sorted(More(Record(High, 9), End)), 0, Done), (Sorted(More(Record(Normal, 11), More(Record(Normal, 12), More(Record(Normal, 13), End)))), 2, Comparison(12, 13, Same, Comparison(11, 12, Same, Done)))) : ((Result, Int, Comparisons), (Result, Int, Comparisons), (Result, Int, Comparisons))
```
<!-- markdownlint-enable MD013 -->

The empty and singleton inputs complete with budget zero and an empty trace.
The three Normal records retain IDs `11,12,13`. Their two comparisons both stop
at equality, first inserting `12` before `13`, then `11` before `12`.

## An ordered result can still be unstable

Change only the equality action: after `Same`, retain the current record and
continue inserting. `04-unstable.ash` uses this alternative with the same
three equal-priority records. Its handlers permit every comparison and ignore
the trace:

<!-- source: src/04-unstable.ash -->
```ash
import sort as Sort

insert_after : (
    Sort.Record, Sort.Records
) -> Sort.Records ! {Sort.Compare, Sort.Trace}
insert_after (record, Sort.End) = Sort.More(record, Sort.End)
insert_after (record, Sort.More(current, rest)) = {
    let ignored = perform Sort.Compare.allow ()
    match Sort.compare (record, current) {
        Sort.Before => Sort.More(record, Sort.More(current, rest))
        Sort.Same => Sort.More(current, insert_after (record, rest))
        Sort.After => Sort.More(current, insert_after (record, rest))
    }
}

unstable_sort : Sort.Records -> Sort.Records ! {Sort.Compare, Sort.Trace}
unstable_sort Sort.End = Sort.End
unstable_sort (Sort.More(record, rest)) = {
    let ordered_tail = unstable_sort rest
    insert_after (record, ordered_tail)
}

main : Unit -> Sort.Records
main () = handle {
    handle (unstable_sort (Sort.equals ())) with Sort.Compare {
        allow () => resume ()
    }
} with Sort.Trace {
    compared ignored => resume ()
}
```

Predict the ID order before running. Does satisfying the types also preserve
our tie-order invariant?

<!-- observation: src/04-unstable.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 04-unstable.ash
More(Record(Normal, 13), More(Record(Normal, 12), More(Record(Normal, 11), End))) : Records
```
<!-- markdownlint-enable MD013 -->

The priority sequence remains ordered and all complete records survive, but
the IDs are reversed. Tail-first recursion inserts each earlier equal record
after all the later ones. This is an accepted sorting counterexample. The
compiler checks the effects and connected value types; the definition of
`Records` does not certify stability, and a `Sorted` constructor would not
certify it either.

## One permission request gets one continuation use

The unstable program makes a wrong algorithmic choice. A handler that tries
to resume the same permission request twice crosses a different boundary.
`05-double-resume.ash` isolates that mistake without the sorting data:

<!-- source: src/05-double-resume.ash -->
```ash
effect Compare {
    allow : Unit -> Unit
}

main : Unit -> Unit
main () = handle (perform Compare.allow ()) with Compare {
    allow () => {
        let ignored = resume ()
        resume ()
    }
}
```

The first `resume ()` runs the waiting work. Identify what right remains before
the second use, then inspect the complete message from the same `src`
directory:

<!-- diagnostic: src/05-double-resume.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en 05-double-resume.ash
This path has already resumed or discarded the continuation; it cannot do so again.
  --> /path/to/ash-doc/content/cases/cancelling-a-stable-sort/src/05-double-resume.ash:9:9
9 |         resume ()
  |         ^ This path has already resumed or discarded the continuation; it cannot do so again.
reason: effect.resume-already-consumed
```
<!-- markdownlint-enable MD013 -->

The label selects the second `resume ()`. The preceding resumption has already
consumed this clause's capability, so it cannot be used again. The secondary
reason is `effect.resume-already-consumed`. Under the [effect rules][effects],
returning the ordinary result of the first resumption is permitted; a second
resumption is not an alternative way to explore another answer.

`06-single-resume.ash` makes that repair and uses the handler around the full
sort. Each request resumes once; the clause then returns the result it received:

<!-- source: src/06-single-resume.ash -->
```ash
import sort as Sort

main : Unit -> Sort.Result
main () = handle {
    handle (Sort.Sorted (Sort.stable_sort (Sort.sample ()))) with Sort.Compare {
        allow () => {
            let result = resume ()
            result
        }
    }
} with Sort.Trace {
    compared ignored => resume ()
}
```

<!-- observation: src/06-single-resume.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash 06-single-resume.ash
Sorted(More(Record(Low, 2), More(Record(Low, 5), More(Record(Normal, 1), More(Record(Normal, 3), More(Record(High, 4), End)))))) : Result
```
<!-- markdownlint-enable MD013 -->

Alternatives require ordinary data representing choices or a fresh call to the
calculation. They cannot reuse a consumed continuation. These full diagnostic
words and source labels describe this edition's tool presentation; the
consumption requirement is the language boundary. Neither that requirement
nor the successful repaired run establishes the sorting invariant by itself.

## Practice: preserve the intended promise

Make scratch copies outside this lesson's `src` directory. Keep `sort.ash` and
`reference.ash` beside entries that import them, and predict each result before
running the changed program.

1. Move `Low/5` to the front of the main sample. Derive the new trace and
   determine which equal-priority ID order must be preserved.
2. Give the three-equal-record input a budget of one. Predict both the result
   and the recorded comparison prefix.
3. In the unstable example, change only its `Same` arm to the stable action.
   Explain why that one branch repairs the equal-priority result for this
   recursion direction.
4. Add a fourth priority to your scratch copies. Identify which comparator
   equations, reference filters, and invariant premises need to change before
   claiming a complete stable order.

A complete sort promises ordering, preservation, and stable ties only because
its algorithm maintains those properties. A cancelled run promises an explicit
absence of a completed result and a count of allowed comparison work. The
next question is how to check that a representation survives a round trip when
its producer and consumer use different calculations.

[effects]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#effects
[completion]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#effect-handlers-and-completion
