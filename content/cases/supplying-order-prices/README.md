# Supplying an order's dependencies

An order calculation needs prices and a discount policy. Those dependencies
can be function arguments, as the earlier tree lookup accepted a comparator.
Effects offer another arrangement: the calculation requests the behavior, and
the enclosing handler supplies it. Calls between the request and handler carry
`Pricing` in their effect rows without carrying the individual functions.

This example follows [requesting a value](../../effects/requesting-a-value/README.md).
`order_total` prices a book and a pen, then asks for a discount on their combined
price. `Unavailable` is an ordinary answer, so the calculation decides how to
respond to it. The three handlers supply a regular price, a promotion for this
particular bundle, and an unavailable pen.

From the Cases directory, enter `supplying-order-prices/src`. Read the program
and predict the three quotes before running `ash main.ash`.

<!-- source: src/main.ash -->
```ash
type Product = Book
    | Pen

type Quote = Priced(Int)
    | Unavailable

effect Pricing {
    price : Product -> Quote
    discount : Int -> Int
}

order_total : (Product, Product) -> Quote ! {Pricing}
order_total (first, second) = match perform Pricing.price first {
    Unavailable => Unavailable
    Priced(left) => match perform Pricing.price second {
        Unavailable => Unavailable
        Priced(right) => Priced(perform Pricing.discount (left + right))
    }
}

regular_price : Product -> Quote
regular_price Book = Priced(20)
regular_price Pen = Priced(3)

regular : Unit -> Quote
regular () = handle (order_total (Book, Pen)) with Pricing {
    price product => resume (regular_price product)
    discount total => resume total
}

promotion : Unit -> Quote
promotion () = handle (order_total (Book, Pen)) with Pricing {
    price product => resume (regular_price product)
    discount total => resume (match total == 23 {
        true => 21
        false => total
    })
}

unavailable : Unit -> Quote
unavailable () = handle (order_total (Book, Pen)) with Pricing {
    price product => resume (match product {
        Book => Priced(20)
        Pen => Unavailable
    })
    discount total => resume total
}

main : Unit -> (Quote, Quote, Quote)
main () = (regular (), promotion (), unavailable ())
```

```text
$ ash main.ash
(Priced(23), Priced(21), Unavailable) : (Quote, Quote, Quote)
```

The same `order_total` produces `Priced(23)`, `Priced(21)`, and `Unavailable`.
The promotion maps this bundle's total of 23 to 21; other totals stay unchanged.
The unavailable response follows the calculation's ordinary match branch.
It does not abandon a continuation or manufacture a compiler error.

Each handler supplies both operations and resumes with the requested answer.
Its enclosing function has an empty effect row because it handles `Pricing`.
This is dependency injection through a scoped handler: the calculation states
what it needs, and the surrounding program selects the behavior. Fixed
responses also make the calculation reproducible without an external service.

As an exercise, change only the promotion handler to supply a different pen
price. Predict whether its bundle discount still applies. For a later extension,
add a third product and decide explicitly how an unavailable item affects the
order. A general checkout system is unnecessary for this comparison.

Continue with [a scripted session](../running-a-scripted-session/README.md),
where the supplied behavior changes across successive requests.
