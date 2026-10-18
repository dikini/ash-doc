import sort as Sort
import reference as Reference

main : Unit -> ((Sort.Result, Int, Sort.Comparisons), Sort.Records)
main () = {
    let records = Sort.sample ()
    (Sort.run (records, 7), Reference.grouped records)
}
