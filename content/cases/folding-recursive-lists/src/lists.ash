pub type List<A> =
    Empty
    | More(A, List<A>)

pub type Option<A> =
    None
    | Some(A)

pub fold : (A -> B -> B) -> B -> List<A> -> B
fold combine base Empty = base
fold combine base More(first, rest) = {
    let folded_rest = fold combine base rest
    combine first folded_rest
}

pub sum : List<Int> -> Int
sum list = fold (fn(first) {
    fn(total) {
        first + total
    }
}) 0 list

pub length : List<A> -> Int
length list = fold (fn(ignored) {
    fn(count) {
        count + 1
    }
}) 0 list

pub map : (A -> B) -> List<A> -> List<B>
map transform list = fold (fn(first) {
    fn(mapped_rest) {
        More(transform first, mapped_rest)
    }
}) Empty list

pub filter : (A -> Bool) -> List<A> -> List<A>
filter keep list = fold (fn(first) {
    fn(filtered_rest) {
        match keep first {
            true => More(first, filtered_rest)
            false => filtered_rest
        }
    }
}) Empty list

pub first_and_visits : List<A> -> (Option<A>, Int)
first_and_visits list = fold (fn(first) {
    fn(summary) {
        let (ignored, visits) = summary
        (Some(first), visits + 1)
    }
}) (None, 0) list
