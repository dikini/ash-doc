newtype Points = Points(Int)

interface Reward<A> {
    reward : A -> Int
}

impl Reward<Int> {
    reward value = value
}

main : Unit -> Int
main () = reward (Points(4))
