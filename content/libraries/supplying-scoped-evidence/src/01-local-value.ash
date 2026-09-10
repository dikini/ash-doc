main : Unit -> Int
main () = {
    newtype Points = Points(Int)
    let points = Points(40)
    match points {
        Points(value) => value + 2
    }
}
