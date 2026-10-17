import orders as Orders
pub import pricing (PricePolicy)
import pricing (unit_price)

pub newtype BasePolicy = BasePolicy(Unit)

pub impl PricePolicy<BasePolicy> {
    unit_price (BasePolicy(ignored), product) = Orders.base_price product
}
