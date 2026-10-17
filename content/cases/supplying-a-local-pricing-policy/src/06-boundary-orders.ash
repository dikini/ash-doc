import orders as Orders
import orders (Money, Quantity, Product, Quote, Book, Pen, Line, Order, Priced, Unavailable)
import pricing (PricePolicy, unit_price, quote_order)

zero_price : Product -> Quote
zero_price product = Priced(Money(0))

books_only : Product -> Quote
books_only Book = Priced(Money(2000))
books_only Pen = Unavailable

pens_only : Product -> Quote
pens_only Book = Unavailable
pens_only Pen = Priced(Money(300))

main : Unit -> (Quote, Quote, Quote, Quote, Quote, Quote, Quote, Quote, Quote)
main () = {
    let empty_order = Order(Line(Book, Quantity(0)), Line(Pen, Quantity(0)))
    let no_books = Order(Line(Book, Quantity(0)), Line(Pen, Quantity(3)))
    let no_pens = Order(Line(Book, Quantity(2)), Line(Pen, Quantity(0)))
    newtype MissingPenPolicy = MissingPenPolicy(Unit)
    with PricePolicy<MissingPenPolicy> {
        unit_price (MissingPenPolicy(ignored), product) = books_only product
    }
    newtype FreePolicy = FreePolicy(Unit)
    with PricePolicy<FreePolicy> {
        unit_price (FreePolicy(ignored), product) = zero_price product
    }
    (
        Orders.quote_with (zero_price, Orders.sample_order ()),
        Orders.quote_with (Orders.base_price, empty_order),
        Orders.quote_with (books_only, Orders.sample_order ()),
        Orders.quote_with (pens_only, no_books),
        Orders.quote_with (books_only, no_pens),
        Orders.quote_with (books_only, empty_order),
        quote_order (MissingPenPolicy(()), Orders.sample_order ()),
        quote_order (MissingPenPolicy(()), no_pens),
        quote_order (FreePolicy(()), Orders.sample_order ())
    )
}
