type Trail = Step(Int, Trail)

keep : Trail -> Trail
keep value = value

main : Unit -> Int
main () = {
    let rec trail : Trail = Step(42, keep trail)
    0
}
