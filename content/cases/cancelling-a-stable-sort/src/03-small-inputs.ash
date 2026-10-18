import sort as Sort

main : Unit -> (
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons),
    (Sort.Result, Int, Sort.Comparisons)
)
main () = (
    Sort.run (Sort.End, 0),
    Sort.run (Sort.More(Sort.Record(Sort.High, 9), Sort.End), 0),
    Sort.run (Sort.equals (), 2)
)
