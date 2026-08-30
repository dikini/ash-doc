pub type Tree<A> =
    Empty
    | Node(Tree<A>, A, Tree<A>)

pub type Natural =
    Zero
    | Next(Natural)

pub type Option<A> =
    None
    | Some(A)

pub fold_tree : (B -> A -> B -> B) -> B -> Tree<A> -> B
fold_tree combine base Empty = base
fold_tree combine base Node(left, value, right) = {
    let folded_left = fold_tree combine base left
    let folded_right = fold_tree combine base right
    combine folded_left value folded_right
}

pub size : Tree<A> -> Int
size tree = fold_tree (fn(left_size) {
    fn(ignored) {
        fn(right_size) {
            left_size + right_size + 1
        }
    }
}) 0 tree

pub map_tree : (A -> B) -> Tree<A> -> Tree<B>
map_tree transform tree = fold_tree (fn(mapped_left) {
    fn(value) {
        fn(mapped_right) {
            Node(mapped_left, transform value, mapped_right)
        }
    }
}) Empty tree

maximum : Natural -> Natural -> Natural
maximum Zero right = right
maximum left Zero = left
maximum Next(left) Next(right) = Next(maximum left right)

pub nodes_and_height : Tree<A> -> (Int, Natural)
nodes_and_height tree = fold_tree (fn(left_summary) {
    fn(ignored) {
        fn(right_summary) {
            let (left_nodes, left_height) = left_summary
            let (right_nodes, right_height) = right_summary
            (
                left_nodes + right_nodes + 1,
                Next(maximum left_height right_height)
            )
        }
    }
}) (0, Zero) tree

pub find_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_counted matches Empty = (None, 0)
find_counted matches Node(left, value, right) = match matches value {
    true => (Some(value), 1)
    false => {
        let (left_found, left_visits) = find_counted matches left
        match left_found {
            Some(found) => (Some(found), left_visits + 1)
            None => {
                let (right_found, right_visits) = find_counted matches right
                (right_found, left_visits + right_visits + 1)
            }
        }
    }
}

choose_counted : (A -> Bool) -> (Option<A>, Int) -> A -> (Option<A>, Int) -> (Option<A>, Int)
choose_counted matches (left_found, left_visits) value (right_found, right_visits) = {
    let visits = left_visits + right_visits + 1
    match matches value {
        true => (Some(value), visits)
        false => match left_found {
            Some(found) => (Some(found), visits)
            None => (right_found, visits)
        }
    }
}

pub find_through_fold_counted : (A -> Bool) -> Tree<A> -> (Option<A>, Int)
find_through_fold_counted matches tree = fold_tree (choose_counted matches) (None, 0) tree
