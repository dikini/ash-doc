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
