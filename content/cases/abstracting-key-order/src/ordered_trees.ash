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

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub lookup : K -> Tree<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(left, key, value, right) = match compare query key {
    Less => lookup query left
    Equal => Some(value)
    Greater => lookup query right
}

pub insert : K -> V -> Tree<K, V> -> Tree<K, V> where Order<K>
insert key value Empty = Node(Empty, key, value, Empty)
insert key value Node(left, current_key, current_value, right) = match compare key current_key {
    Less => Node(insert key value left, current_key, current_value, right)
    Equal => Node(left, current_key, value, right)
    Greater => Node(left, current_key, current_value, insert key value right)
}

pub lookup_counted : K -> Tree<K, V> -> (Option<V>, Int) where Order<K>
lookup_counted query Empty = (None, 0)
lookup_counted query Node(left, key, value, right) = match compare query key {
    Less => {
        let (found, later_comparisons) = lookup_counted query left
        (found, later_comparisons + 1)
    }
    Equal => (Some(value), 1)
    Greater => {
        let (found, later_comparisons) = lookup_counted query right
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
