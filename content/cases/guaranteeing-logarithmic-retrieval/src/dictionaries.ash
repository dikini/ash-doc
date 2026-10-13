pub type Ordering =
    Less
    | Equal
    | Greater

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub type List<A> =
    End
    | More(A, List<A>)

type Color =
    Red
    | Black

pub opaque type Dictionary<K, V> =
    Empty
    | Node(Color, Dictionary<K, V>, K, V, Dictionary<K, V>)

type BalanceCheck =
    Invalid
    | Valid(Int)

type RArg<K, V> = RArg(Dictionary<K, V>, K, V)

pub interface Order<A> {
    compare : A -> A -> Ordering
}

pub impl Order<Natural> {
    compare Zero Zero = Equal
    compare Zero Next(right) = Less
    compare Next(left) Zero = Greater
    compare Next(left) Next(right) = compare left right
}

pub empty : Unit -> Dictionary<K, V>
empty () = Empty

pub lookup : K -> Dictionary<K, V> -> Option<V> where Order<K>
lookup query Empty = None
lookup query Node(ignored_color, left, current_key, current_value, right) = match compare query current_key {
    Less => lookup query left
    Equal => Some(current_value)
    Greater => lookup query right
}

restore_three : (
    RArg<K, V> -> RArg<K, V> -> RArg<K, V> ->
    Dictionary<K, V> -> Dictionary<K, V>
)
restore_three first second third d = {
    let RArg(a, k1, v1) = first
    let RArg(b, k2, v2) = second
    let RArg(c, k3, v3) = third
    Node(
        Red,
        Node(Black, a, k1, v1, b),
        k2,
        v2,
        Node(Black, c, k3, v3, d)
    )
}

restore : Color -> RArg<K, V> -> Dictionary<K, V> -> Dictionary<K, V>
restore Black RArg(
    Node(Red, Node(Red, a, k1, v1, b), k2, v2, c),
    k3,
    v3
) d = (restore_three
        (RArg(a, k1, v1))
        (RArg(b, k2, v2))
        (RArg(c, k3, v3))
        d
    )
restore Black RArg(
    Node(Red, a, k1, v1, Node(Red, b, k2, v2, c)),
    k3,
    v3
) d = (restore_three
        (RArg(a, k1, v1))
        (RArg(b, k2, v2))
        (RArg(c, k3, v3))
        d
    )
restore Black RArg(a, k1, v1) Node(
    Red,
    Node(Red, b, k2, v2, c),
    k3,
    v3,
    d
) = (restore_three
        (RArg(a, k1, v1))
        (RArg(b, k2, v2))
        (RArg(c, k3, v3))
        d
    )
restore Black RArg(a, k1, v1) Node(
    Red,
    b,
    k2,
    v2,
    Node(Red, c, k3, v3, d)
) = (restore_three
        (RArg(a, k1, v1))
        (RArg(b, k2, v2))
        (RArg(c, k3, v3))
        d
    )
restore color RArg(a, k, v) b = Node(color, a, k, v, b)

insert_colored : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert_colored key value Empty = Node(Red, Empty, key, value, Empty)
insert_colored key value Node(color, a, k, v, b) = match compare key k {
    Less => restore color (RArg(insert_colored key value a, k, v)) b
    Equal => Node(color, a, k, value, b)
    Greater => restore color (RArg(a, k, v)) (insert_colored key value b)
}

blacken_root : Dictionary<K, V> -> Dictionary<K, V>
blacken_root dictionary = match dictionary {
    Empty => Empty
    Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) => dictionary
    Node(Red, left, key, value, right) => Node(Black, left, key, value, right)
}

pub insert : K -> V -> Dictionary<K, V> -> Dictionary<K, V> where Order<K>
insert key value dictionary = blacken_root (insert_colored key value dictionary)

fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated End = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

insert_entry : Dictionary<K, V> -> (K, V) -> Dictionary<K, V> where Order<K>
insert_entry dictionary entry = match entry {
    (key, value) => insert key value dictionary
}

pub build : List<(K, V)> -> Dictionary<K, V> where Order<K>
build entries = fold_left insert_entry (empty ()) entries

above_lower : Option<K> -> K -> Bool where Order<K>
above_lower None key = true
above_lower Some(lower) key = match compare lower key {
    Less => true
    Equal => false
    Greater => false
}

below_upper : K -> Option<K> -> Bool where Order<K>
below_upper key None = true
below_upper key Some(upper) = match compare key upper {
    Less => true
    Equal => false
    Greater => false
}

both : Bool -> Bool -> Bool
both true right = right
both false right = false

valid_between : Option<K> -> Option<K> -> Dictionary<K, V> -> Bool where Order<K>
valid_between lower upper Empty = true
valid_between lower upper Node(ignored_color, left, key, ignored_value, right) = {
    let respects_lower = above_lower lower key
    let respects_upper = below_upper key upper
    let left_valid = valid_between lower (Some(key)) left
    let right_valid = valid_between (Some(key)) upper right
    both respects_lower (both respects_upper (both left_valid right_valid))
}

is_black : Dictionary<K, V> -> Bool
is_black Empty = true
is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

children_colors_hold : Color -> Dictionary<K, V> -> Dictionary<K, V> -> Bool
children_colors_hold Black left right = true
children_colors_hold Red left right = both (is_black left) (is_black right)

add_black : Color -> Int -> Int
add_black Red height = height
add_black Black height = height + 1

balance_summary : Dictionary<K, V> -> BalanceCheck
balance_summary Empty = Valid(1)
balance_summary Node(color, left, ignored_key, ignored_value, right) = {
    let left_result = balance_summary left
    let right_result = balance_summary right
    let children_hold = children_colors_hold color left right
    match (left_result, right_result) {
        (Invalid, ignored_right_result) => Invalid
        (Valid(ignored_left_height), Invalid) => Invalid
        (Valid(left_height), Valid(right_height)) => match children_hold {
            false => Invalid
            true => match left_height == right_height {
                false => Invalid
                true => Valid(add_black color left_height)
            }
        }
    }
}

balance_holds : Dictionary<K, V> -> Bool
balance_holds dictionary = match balance_summary dictionary {
    Invalid => false
    Valid(ignored_height) => true
}

root_is_black : Dictionary<K, V> -> Bool
root_is_black Empty = true
root_is_black Node(Black, ignored_left, ignored_key, ignored_value, ignored_right) = true
root_is_black Node(Red, ignored_left, ignored_key, ignored_value, ignored_right) = false

pub invariant_holds : Dictionary<K, V> -> Bool where Order<K>
invariant_holds dictionary = {
    let ordered = valid_between None None dictionary
    let balanced = balance_holds dictionary
    let black_root = root_is_black dictionary
    both ordered (both balanced black_root)
}

main : Unit -> (Bool, Bool, Bool, Bool, Bool)
main () = {
    let one = Next(Zero)
    let two = Next(one)
    let three = Next(two)
    let four = Next(three)
    let valid = Node(Black, Empty, one, 10, Empty)
    let invalid_order = Node(
        Black,
        Node(Black, Empty, one, 10, Node(Red, Empty, three, 30, Empty)),
        two,
        20,
        Node(Black, Empty, four, 40, Empty)
    )
    let red_root = Node(Red, Empty, one, 10, Empty)
    let red_red = Node(
        Black,
        Node(
            Red,
            Node(Red, Empty, one, 10, Empty),
            two,
            20,
            Node(Red, Empty, three, 30, Empty)
        ),
        four,
        40,
        Empty
    )
    let uneven_black_height = Node(
        Black,
        Node(Black, Empty, one, 10, Empty),
        two,
        20,
        Empty
    )
    (
        invariant_holds valid,
        invariant_holds invalid_order,
        invariant_holds red_root,
        invariant_holds red_red,
        invariant_holds uneven_black_height
    )
}
