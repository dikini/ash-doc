import orders as Orders
import pricing (PricePolicy, unit_price, quote_order)

main : Unit -> Orders.Quote
main () = {
    newtype TariffPolicy = TariffPolicy(Unit)
    let tariff = 100
    let before = quote_order (TariffPolicy(()), Orders.sample_order ())
    with PricePolicy<TariffPolicy> {
        unit_price (TariffPolicy(ignored), product) = Orders.tariff_price tariff product
    }
    before
}
