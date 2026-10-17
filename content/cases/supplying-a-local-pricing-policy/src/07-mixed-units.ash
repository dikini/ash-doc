import orders (Money, line_total)

main : Unit -> Money
main () = line_total (Money(2000), Money(2))
