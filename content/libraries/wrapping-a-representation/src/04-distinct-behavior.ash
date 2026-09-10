newtype Points = Points(Int)

interface Reward<A> {
    reward : A -> Int
}

impl Reward<Int> {
    reward value = value
}

impl Reward<Points> {
    reward (Points(value)) = value * 10
}

main : Unit -> (Int, Int)
main () = (reward 4, reward (Points(4)))
