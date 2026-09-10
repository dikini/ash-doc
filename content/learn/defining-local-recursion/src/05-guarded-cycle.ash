type Trail = Step(Int, Trail)

main : Unit -> (Int, Int)
main () = {
    let rec first : Trail = Step(20, second)
    and second : Trail = Step(22, first)
    match first {
        Step(left, rest) => match rest {
            Step(right, ignored) => (left, right)
        }
    }
}
