pub type List<A> =
    Empty
    | More(A, List<A>)

pub map : (A -> B) -> List<A> -> List<B>
map transform Empty = Empty
map transform More(first, rest) = More(transform first, map transform rest)
