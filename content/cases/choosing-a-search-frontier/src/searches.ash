pub type Vertex =
    Start
    | Short
    | LongOne
    | LongTwo
    | WideOne
    | WideTwo
    | Goal
    | Isolated

pub type List<A> =
    End
    | More(A, List<A>)

pub type Natural =
    Zero
    | Next(Natural)

pub type SearchResult =
    Missing(Int, Natural)
    | Found(List<Vertex>, Int, Natural)

type Option<A> =
    Absent
    | Present(A)

type Entry<K, V> =
    Entry(K, V)

type Dictionary<K, V> =
    NoEntries
    | MoreEntry(Entry<K, V>, Dictionary<K, V>)

type Work =
    Work(Vertex, List<Vertex>)

type SearchState<F> =
    SearchState(F, Dictionary<Vertex, Unit>, Natural, Natural, Int)

type Queue<A> =
    Queue(List<A>, List<A>)

same_vertex : Vertex -> Vertex -> Bool
same_vertex Start Start = true
same_vertex Short Short = true
same_vertex LongOne LongOne = true
same_vertex LongTwo LongTwo = true
same_vertex WideOne WideOne = true
same_vertex WideTwo WideTwo = true
same_vertex Goal Goal = true
same_vertex Isolated Isolated = true
same_vertex ignored_left ignored_right = false

neighbors : Vertex -> List<Vertex>
neighbors Start = More(Short, More(LongOne, End))
neighbors Short = More(WideOne, More(WideTwo, More(Goal, End)))
neighbors LongOne = More(LongTwo, End)
neighbors LongTwo = More(Start, More(Goal, End))
neighbors WideOne = End
neighbors WideTwo = End
neighbors Goal = End
neighbors Isolated = End

empty_dictionary : Unit -> Dictionary<K, V>
empty_dictionary () = NoEntries

insert_dictionary : K -> V -> Dictionary<K, V> -> Dictionary<K, V>
insert_dictionary key value dictionary = MoreEntry(Entry(key, value), dictionary)

lookup_dictionary : (K -> K -> Bool) -> K -> Dictionary<K, V> -> Option<V>
lookup_dictionary same_key query NoEntries = Absent
lookup_dictionary same_key query MoreEntry(Entry(key, value), rest) = match same_key query key {
    true => Present(value)
    false => lookup_dictionary same_key query rest
}

stack_add : A -> List<A> -> List<A>
stack_add value stack = More(value, stack)

stack_remove : List<A> -> Option<(A, List<A>)>
stack_remove End = Absent
stack_remove More(first, rest) = Present((first, rest))

queue_empty : Unit -> Queue<A>
queue_empty () = Queue(End, End)

queue_add : A -> Queue<A> -> Queue<A>
queue_add value Queue(front, rear) = Queue(front, More(value, rear))

reverse_into : List<A> -> List<A> -> List<A>
reverse_into End reversed = reversed
reverse_into More(first, rest) reversed = {
    reverse_into rest (More(first, reversed))
}

queue_remove : Queue<A> -> Option<(A, Queue<A>)>
queue_remove Queue(End, End) = Absent
queue_remove Queue(More(first, rest), rear) = {
    Present((first, Queue(rest, rear)))
}
queue_remove Queue(End, rear) = {
    let front = reverse_into rear End
    queue_remove (Queue(front, End))
}

decrement : Natural -> Natural
decrement Zero = Zero
decrement Next(rest) = rest

greater : Natural -> Natural -> Bool
greater Zero ignored_right = false
greater Next(ignored_left) Zero = true
greater Next(left) Next(right) = greater left right

retain_greater : Natural -> Natural -> Natural
retain_greater candidate retained = match greater candidate retained {
    true => candidate
    false => retained
}

forward_path : Work -> List<Vertex>
forward_path Work(current, predecessors) = {
    reverse_into predecessors (More(current, End))
}

schedule : (Work -> F -> F) -> List<Vertex> -> Work -> SearchState<F> -> SearchState<F>
schedule add End parent state = state
schedule add More(next, rest) parent state = match state {
    SearchState(frontier, visited, pending, maximum, expanded) => match lookup_dictionary same_vertex next visited {
        Present(ignored_value) => schedule add rest parent state
        Absent => {
            let next_visited = insert_dictionary next () visited
            match parent {
                Work(current, predecessors) => {
                    let next_work = Work(next, More(current, predecessors))
                    let next_frontier = add next_work frontier
                    let next_pending = Next(pending)
                    let next_maximum = retain_greater next_pending maximum
                    let next_state = SearchState(
                        next_frontier,
                        next_visited,
                        next_pending,
                        next_maximum,
                        expanded
                    )
                    schedule add rest parent next_state
                }
            }
        }
    }
}

continue_search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> Dictionary<Vertex, Unit> -> Natural -> Natural -> Int -> Option<(Work, F)> -> SearchResult
continue_search add remove target visited pending maximum expanded Absent = Missing(expanded, maximum)
continue_search add remove target visited pending maximum expanded Present((Work(current, predecessors), later_frontier)) = {
    let later_pending = decrement pending
    match same_vertex current target {
        true => Found(forward_path (Work(current, predecessors)), expanded, maximum)
        false => {
            let next_state = SearchState(
                later_frontier,
                visited,
                later_pending,
                maximum,
                expanded + 1
            )
            let scheduled = schedule add (neighbors current) (Work(current, predecessors)) next_state
            search add remove target scheduled
        }
    }
}

search : (Work -> F -> F) -> (F -> Option<(Work, F)>) -> Vertex -> SearchState<F> -> SearchResult
search add remove target SearchState(frontier, visited, pending, maximum, expanded) = {
    let removed = remove frontier
    continue_search add remove target visited pending maximum expanded removed
}

pub depth_first : Vertex -> Vertex -> SearchResult
depth_first start target = {
    let visited = insert_dictionary start () (empty_dictionary ())
    let initial_work = Work(start, End)
    let frontier = stack_add initial_work End
    let initial_size = Next(Zero)
    let initial_state = SearchState(frontier, visited, initial_size, initial_size, 0)
    search stack_add stack_remove target initial_state
}

pub breadth_first : Vertex -> Vertex -> SearchResult
breadth_first start target = {
    let visited = insert_dictionary start () (empty_dictionary ())
    let initial_work = Work(start, End)
    let frontier = queue_add initial_work (queue_empty ())
    let initial_size = Next(Zero)
    let initial_state = SearchState(frontier, visited, initial_size, initial_size, 0)
    search queue_add queue_remove target initial_state
}
