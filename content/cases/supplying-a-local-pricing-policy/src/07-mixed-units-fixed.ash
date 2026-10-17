import orders (Money, Quantity, line_total)

main : Unit -> Money
main () = line_total (Money(2000), Quantity(2))
