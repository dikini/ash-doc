pub type Entry<K, V> =
    Entry(K, V)

pub type Dictionary<K, V> =
    Empty
    | More(Entry<K, V>, Dictionary<K, V>)

pub type Option<A> =
    None
    | Some(A)

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
insert key value dictionary = More(Entry(key, value), dictionary)

pub lookup : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
lookup same_key query Empty = None
lookup same_key query More(Entry(key, value), rest) = match same_key query key {
    true => Some(value)
    false => lookup same_key query rest
}

pub lookup_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_counted same_key query Empty = (None, 0)
lookup_counted same_key query More(Entry(key, value), rest) = match same_key query key {
    true => (Some(value), 1)
    false => {
        let (found, later_comparisons) = lookup_counted same_key query rest
        (found, later_comparisons + 1)
    }
}

fold_entries : (Entry<K, V> -> B -> B) -> B -> Dictionary<K, V> -> B
fold_entries combine base Empty = base
fold_entries combine base More(entry, rest) = {
    let folded_rest = fold_entries combine base rest
    combine entry folded_rest
}

prefer_current : (K -> K -> Bool) -> K -> Entry<K, V> -> (Option<V>, Int) -> (Option<V>, Int)
prefer_current same_key query Entry(key, value) (found, comparisons) = match same_key query key {
    true => (Some(value), comparisons + 1)
    false => (found, comparisons + 1)
}

pub lookup_through_fold_counted : (K -> K -> Bool) -> K -> Dictionary<K, V> -> (Option<V>, Int)
lookup_through_fold_counted same_key query dictionary = fold_entries (prefer_current same_key query) (None, 0) dictionary
