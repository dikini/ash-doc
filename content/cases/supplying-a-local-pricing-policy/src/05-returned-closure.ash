import orders as Orders
import pricing (PricePolicy, unit_price, quote_order)

make_pricer : Int -> (Orders.Order -> Orders.Quote)
make_pricer tariff = {
    newtype TariffPolicy = TariffPolicy(Unit)
    let policy = TariffPolicy(())
    with PricePolicy<TariffPolicy> {
        unit_price (TariffPolicy(ignored), product) = Orders.tariff_price tariff product
    }
    fn(order) {
        quote_order (policy, order)
    }
}

main : Unit -> (Orders.Quote, Orders.Quote, Orders.Quote)
main () = {
    let first = make_pricer 100
    let second = make_pricer 200
    let order = Orders.sample_order ()
    (first order, second order, first order)
}
