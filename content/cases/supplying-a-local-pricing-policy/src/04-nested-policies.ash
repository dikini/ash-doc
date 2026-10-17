import orders as Orders
import pricing (PricePolicy, unit_price, quote_order)

main : Unit -> (Orders.Quote, Orders.Quote, Orders.Quote)
main () = {
    newtype OuterPolicy = OuterPolicy(Unit)
    let order = Orders.sample_order ()
    let tariff = 100
    with PricePolicy<OuterPolicy> {
        unit_price (OuterPolicy(ignored), product) = Orders.tariff_price tariff product
    }
    let before = quote_order (OuterPolicy(()), order)
    let inside = {
        newtype InnerPolicy = InnerPolicy(Unit)
        let tariff = 200
        with PricePolicy<InnerPolicy> {
            unit_price (InnerPolicy(ignored), product) = Orders.tariff_price tariff product
        }
        quote_order (InnerPolicy(()), order)
    }
    let after = quote_order (OuterPolicy(()), order)
    (before, inside, after)
}
