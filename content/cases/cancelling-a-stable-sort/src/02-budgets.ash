import sort as Sort

main : Unit -> (
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons)
)
main () = {
    let records = Sort.sample ()
    (
        Sort.run (records, 0), Sort.run (records, 6),
        Sort.run (records, 7), Sort.run (records, 8)
    )
}
