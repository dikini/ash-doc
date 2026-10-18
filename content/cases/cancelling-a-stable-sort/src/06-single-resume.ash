import sort as Sort

main : Unit -> Sort.Result
main () = handle {
    handle (Sort.Sorted (Sort.stable_sort (Sort.sample ()))) with Sort.Compare {
        allow () => {
            let result = resume ()
            result
        }
    }
} with Sort.Trace {
    compared ignored => resume ()
}
