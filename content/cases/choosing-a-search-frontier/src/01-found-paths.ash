import searches as Searches

main : Unit -> (Searches.SearchResult, Searches.SearchResult)
main () = (
    Searches.depth_first Searches.Start Searches.Goal,
    Searches.breadth_first Searches.Start Searches.Goal
)
