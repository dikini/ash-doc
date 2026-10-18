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
