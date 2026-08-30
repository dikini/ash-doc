pub type Tree<K, V> =
    Empty
    | Node(Tree<K, V>, K, V, Tree<K, V>)

pub type Ordering =
    Less
    | Equal
    | Greater

pub type Option<A> =
    None
    | Some(A)

pub type Natural =
    Zero
    | Next(Natural)

pub compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Zero = Equal
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

pub lookup : (K -> K -> Ordering) -> K -> Tree<K, V> -> Option<V>
lookup compare query Empty = None
lookup compare query Node(left, key, value, right) = match compare query key {
    Less => lookup compare query left
    Equal => Some(value)
    Greater => lookup compare query right
}

pub insert : (K -> K -> Ordering) -> K -> V -> Tree<K, V> -> Tree<K, V>
insert compare key value Empty = Node(Empty, key, value, Empty)
insert compare key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert compare key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert compare key value right)
}

pub lookup_counted : (K -> K -> Ordering) -> K -> Tree<K, V> -> (Option<V>, Int)
lookup_counted compare query Empty = (None, 0)
lookup_counted compare query Node(left, key, value, right) = match compare query key {
    Less => {
        let (found, later_comparisons) = lookup_counted compare query left
        (found, later_comparisons + 1)
    }
    Equal => (Some(value), 1)
    Greater => {
        let (found, later_comparisons) = lookup_counted compare query right
        (found, later_comparisons + 1)
    }
}

maximum : Natural -> Natural -> Natural
maximum Zero right = right
maximum left Zero = left
maximum Next(left) Next(right) = Next(maximum left right)

pub height : Tree<K, V> -> Natural
height Empty = Zero
height Node(left, ignored_key, ignored_value, right) = Next(maximum (height left) (height right))
