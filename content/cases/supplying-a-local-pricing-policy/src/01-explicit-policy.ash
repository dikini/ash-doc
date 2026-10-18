import orders as Orders

main : Unit -> Orders.Quote
main () = Orders.quote_with (Orders.base_price, Orders.sample_order ())
