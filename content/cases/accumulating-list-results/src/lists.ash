pub type List<A> =
    Empty
    | More(A, List<A>)

pub append : List<A> -> List<A> -> List<A>
append Empty right = right
append More(first, rest) right = {
    let appended_rest = append rest right
    More(first, appended_rest)
}

pub reverse_through_append : List<A> -> List<A>
reverse_through_append Empty = Empty
reverse_through_append More(first, rest) = {
    let reversed_rest = reverse_through_append rest
    append reversed_rest (More(first, Empty))
}

append_revisits : List<A> -> List<A> -> (List<A>, Int)
append_revisits Empty right = (right, 0)
append_revisits More(first, rest) right = {
    let (appended_rest, later_revisits) = append_revisits rest right
    (More(first, appended_rest), later_revisits + 1)
}

reverse_revisits : List<A> -> (List<A>, Int)
reverse_revisits Empty = (Empty, 0)
reverse_revisits More(first, rest) = {
    let (reversed_rest, earlier_revisits) = reverse_revisits rest
    let singleton = More(first, Empty)
    let (reversed, current_revisits) = append_revisits reversed_rest singleton
    (reversed, earlier_revisits + current_revisits)
}

pub reverse_through_append_with_revisits : List<A> -> (List<A>, Int)
reverse_through_append_with_revisits list = reverse_revisits list

pub fold_left : (B -> A -> B) -> B -> List<A> -> B
fold_left combine accumulated Empty = accumulated
fold_left combine accumulated More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left combine next_accumulated rest
}

pub prepend : List<A> -> A -> List<A>
prepend accumulated first = More(first, accumulated)

pub reverse_with_accumulator : List<A> -> List<A>
reverse_with_accumulator list = fold_left prepend Empty list

fold_left_visits : (B -> A -> B) -> B -> Int -> List<A> -> (B, Int)
fold_left_visits combine accumulated visits Empty = (accumulated, visits)
fold_left_visits combine accumulated visits More(first, rest) = {
    let next_accumulated = combine accumulated first
    fold_left_visits combine next_accumulated (visits + 1) rest
}

pub reverse_with_accumulator_and_visits : List<A> -> (List<A>, Int)
reverse_with_accumulator_and_visits list = fold_left_visits prepend Empty 0 list
