pub type Natural =
    Zero
    | Next(Natural)

pub type List<A> =
    Empty
    | More(A, List<A>)

pub type Step<S, A> =
    Stop
    | Emit(A, S)

pub unfold : (S -> Step<S, A>) -> S -> List<A>
unfold transition state = match transition state {
    Stop => Empty
    Emit(value, next_state) => {
        let produced_rest = unfold transition next_state
        More(value, produced_rest)
    }
}

pub unfold_counted : (S -> Step<S, A>) -> S -> (List<A>, Int)
unfold_counted transition state = match transition state {
    Stop => (Empty, 1)
    Emit(value, next_state) => {
        let (produced_rest, later_steps) = unfold_counted transition next_state
        (More(value, produced_rest), later_steps + 1)
    }
}

pub map : (A -> B) -> List<A> -> List<B>
map transform Empty = Empty
map transform More(first, rest) = {
    let mapped_rest = map transform rest
    More(transform first, mapped_rest)
}

pub repeat_step : Int -> Natural -> Step<Natural, Int>
repeat_step value Zero = Stop
repeat_step value Next(rest) = Emit(value, rest)
