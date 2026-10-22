type Natural =
    Zero
    | Next(Natural)

type Ordering =
    Less
    | Equal
    | Greater

compare_natural : Natural -> Natural -> Ordering
compare_natural Zero Next(right) = Less
compare_natural Next(left) Zero = Greater
compare_natural Next(left) Next(right) = compare_natural left right

main : Unit -> Ordering
main () = compare_natural Zero Zero
