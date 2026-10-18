import orders as Orders
import pricing (PricePolicy, unit_price, quote_order)

main : Unit -> (Orders.Quote, Orders.Quote)
main () = {
    newtype TariffPolicy = TariffPolicy(Unit)
    let order = Orders.sample_order ()
    let first = {
        let tariff = 100
        with PricePolicy<TariffPolicy> {
            unit_price (TariffPolicy(ignored), product) = Orders.tariff_price tariff product
        }
        quote_order (TariffPolicy(()), order)
    }
    let second = {
        let tariff = 200
        with PricePolicy<TariffPolicy> {
            unit_price (TariffPolicy(ignored), product) = Orders.tariff_price tariff product
        }
        quote_order (TariffPolicy(()), order)
    }
    (first, second)
}
