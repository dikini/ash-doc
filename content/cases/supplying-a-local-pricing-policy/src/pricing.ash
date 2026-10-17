import orders as Orders

pub interface PricePolicy<P> {
    unit_price : (P, Orders.Product) -> Orders.Quote
}

pub quote_order : (P, Orders.Order) -> Orders.Quote where PricePolicy<P>
quote_order (policy, order) = {
    let price = fn(product) {
        unit_price (policy, product)
    }
    Orders.quote_with (price, order)
}
