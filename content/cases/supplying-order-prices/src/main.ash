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
