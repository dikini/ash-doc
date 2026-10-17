pub newtype Money = Money(Int)
pub newtype Quantity = Quantity(Int)

pub type Product = Book
    | Pen

pub type Line = Line(Product, Quantity)
pub type Order = Order(Line, Line)

pub type Quote = Priced(Money)
    | Unavailable

pub line_total : (Money, Quantity) -> Money
line_total (Money(cents), Quantity(count)) = Money(cents * count)

pub add_money : (Money, Money) -> Money
add_money (Money(left), Money(right)) = Money(left + right)

pub quote_with : (Product -> Quote, Order) -> Quote
quote_with (unit_price, Order(Line(first, first_count), Line(second, second_count))) = {
    let first_price = unit_price first
    let second_price = unit_price second
    match (first_price, second_price) {
        (Unavailable, ignored) => Unavailable
        (Priced(left), Unavailable) => Unavailable
        (Priced(left), Priced(right)) => Priced(add_money (
            line_total (left, first_count),
            line_total (right, second_count)
        ))
    }
}

pub base_price : Product -> Quote
base_price Book = Priced(Money(2000))
base_price Pen = Priced(Money(300))

pub tariff_price : Int -> Product -> Quote
tariff_price tariff product = match base_price product {
    Unavailable => Unavailable
    Priced(Money(cents)) => Priced(Money(cents + tariff))
}

pub sample_order : Unit -> Order
sample_order () = Order(Line(Book, Quantity(2)), Line(Pen, Quantity(3)))
