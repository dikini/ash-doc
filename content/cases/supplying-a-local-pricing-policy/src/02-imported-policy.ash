import orders as Orders
import pricing (quote_order)
import base_policy (BasePolicy, impl PricePolicy)

main : Unit -> Orders.Quote
main () = quote_order (BasePolicy(()), Orders.sample_order ())
