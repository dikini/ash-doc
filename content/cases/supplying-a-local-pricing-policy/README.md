# Supplying a local pricing policy

A shop can quote the same order under several tariffs. Its calculation needs
one unit price for each product; the caller chooses how those prices are
supplied. In [the earlier order calculation][order-case], an effect asked a
handler for that behavior. Here the calculation receives a function first,
then an interface requirement makes its policy choice explicit. A local
policy can capture a tariff, and a returned quoting function can retain that
choice after the block that supplied it has returned.

Consider two books at 2000 cents each and three pens at 300 cents each. The
base quote is `2 * 2000 + 3 * 300 = 4900` cents. A tariff of 100 cents per item
changes the unit prices to 2100 and 400, so the quote becomes
`2 * 2100 + 3 * 400 = 5400`. There are five items, although there are only two
lines. Charging the tariff once per line would answer a different question.

The program uses finite, nonnegative prices, quantities, and tariffs. These
are promises about the chosen inputs. The types below distinguish money from
counts; their constructors do not validate a range. Currency conversion,
rounding, and rejected negative inputs are outside this calculation.

## Give the calculation its units

`Money` represents cents and `Quantity` represents an item count. Both wrap
`Int`, but [nominal wrappers][wrappers] make them different source types.
`Product` has two choices, `Book` and `Pen`. A `Line` pairs one product with a
quantity; an `Order` contains exactly two lines. Thus the example is an order
with `Line(Book, Quantity(2))` followed by `Line(Pen, Quantity(3))`.

`Quote` answers two different questions: `Priced(Money(cents))` supplies an
available amount, while `Unavailable` supplies no amount. A price of zero is
still available. The unit-price function returns this same choice before any
quantity is applied. This model asks for both line prices, including prices
on zero-quantity lines. An unavailable price on either line makes the whole
order unavailable.

Work backward from the total. `quote_with` needs a `Product -> Quote` function
and an `Order`. When both prices are available, `line_total` multiplies one
`Money` amount by one `Quantity`, retaining `Money`; `add_money` then combines
the two amounts. Those contracts expose the units before their bodies use
integer arithmetic. Save these definitions together in `orders.ash`:

<!-- markdownlint-disable MD013 -->
<!-- source: src/orders.ash -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

`line_total` unwraps cents and count separately, multiplies them, and wraps the
result as money. `add_money` unwraps two money amounts and adds them. These
explicit constructor patterns and constructions cross the representation
boundary; they provide no implicit conversion between money and quantity.
The [newtype and application rules][applications] preserve that distinction.

In `quote_with`, both `unit_price` calls occur before the availability match.
The first arm handles an unavailable first price, regardless of the second.
The next arm handles an available first price and an unavailable second.
Only the final arm can calculate both line totals. These cases establish the
availability rule independently of the selected pricing function.

`base_price` supplies the two stated prices. `tariff_price` keeps the
availability distinction and adds its captured tariff to each available
unit price. It leaves quantity multiplication to `line_total`, so a tariff
of 100 contributes `2 * 100 + 3 * 100`, or 500 cents, to this order.

## Supply the pricing function directly

The calculation can already run with an ordinary function parameter:

<!-- source: src/01-explicit-policy.ash -->
```ash
import orders as Orders

main : Unit -> Orders.Quote
main () = Orders.quote_with (Orders.base_price, Orders.sample_order ())
```

Run the commands in this chapter from the `content/cases` directory. Predict
the quote from the two line totals, then run this entry:

```text
$ ash supplying-a-local-pricing-policy/src/01-explicit-policy.ash
Priced(4900) : Quote
```

The book line contributes 4000 cents and the pen line contributes 900 cents.
The printed `4900` is the representation of the `Money` inside `Priced`;
[the tool renders a newtype through its representation][output]. The source
result remains `Quote`, whose `Priced` field is `Money`.

Passing the function solves this calculation's dependency. The next question
is where a generic operation obtains behavior for a particular policy type.

## Select an imported policy

A policy token makes that choice part of an interface contract. In
`pricing.ash`, `PricePolicy<P>` requires `unit_price` to accept both a token
of type `P` and a product. The result is still an available unit price or
`Unavailable`. The generic `quote_order` accepts the same token and an order:

<!-- source: src/pricing.ash -->
```ash
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
```

The [interface requirement][interfaces] supplies behavior for the complete
application `PricePolicy<P>`. Inside `quote_order`, `price` retains the token
and calls the required method with each product. It has the ordinary function
shape that `Orders.quote_with` needs. The order itself still comes from the
caller; the adapter changes how prices are supplied, not which order is priced.

`base_policy.ash` owns a public nominal token and its implementation:

<!-- source: src/base_policy.ash -->
```ash
import orders as Orders
pub import pricing (PricePolicy)
import pricing (unit_price)

pub newtype BasePolicy = BasePolicy(Unit)

pub impl PricePolicy<BasePolicy> {
    unit_price (BasePolicy(ignored), product) = Orders.base_price product
}
```

`BasePolicy` carries unit because this implementation needs no configuration.
Its method ignores that unit and uses `base_price`. The public import exposes
the existing `PricePolicy` identity through this module so clients can select
its implementation. The private method import makes the `unit_price` spelling
available for the implementation body.

The entry imports the operation and explicitly selects the public fact:

<!-- source: src/02-imported-policy.ash -->
```ash
import orders as Orders
import pricing (quote_order)
import base_policy (BasePolicy, impl PricePolicy)

main : Unit -> Orders.Quote
main () = quote_order (BasePolicy(()), Orders.sample_order ())
```

`BasePolicy` imports the type and its public constructor. The separate
`impl PricePolicy` item selects implementation evidence; it binds no source
name. [Importing names alone does not select implementations][imports].
Follow the token to `PricePolicy<BasePolicy>`, then predict the quote:

```text
$ ash supplying-a-local-pricing-policy/src/02-imported-policy.ash
Priced(4900) : Quote
```

The answer is again 4900 cents because the selected method supplies the same
unit prices. Selection is checked before execution. The method then runs as
an ordinary function, without a runtime policy registry.

## Capture a tariff in a local method

An imported implementation has a module-owned policy type. A caller can
instead introduce a local nominal key and supply exact behavior in a block,
following [scoped evidence][scoped]. `TariffPolicy` below carries unit as well:
the tariff belongs to the method's ordinary capture, not the token payload.

<!-- markdownlint-disable MD013 -->
<!-- source: src/03-local-policy.ash -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

Each block binds its integer tariff before `with`. The supplied method can
capture that preceding value. The declaration supplies the complete
application `PricePolicy<TariffPolicy>` only in its following lexical remainder,
which includes that block's `quote_order` call. It is exact evidence rather
than a local implementation search.

The two evidence sources have disjoint scopes. The second begins after the
first block has returned, so they never compete for the same active key.
Predict both amounts from the five items:

```text
$ ash supplying-a-local-pricing-policy/src/03-local-policy.ash
(Priced(5400), Priced(5900)) : (Quote, Quote)
```

The second tariff adds 1000 cents to the base total:
`2 * 2200 + 3 * 500 = 5900`. The distinction between the blocks concerns
which method a source occurrence selects. It does not add runtime nominal
creation or a dynamically replaced global policy. The [exact-evidence rules][evidence]
define the source scope and the ordinary captures separately.

## Keep nested choices distinct

Nested choices need distinct active keys. Reusing the same complete key in
two overlapping `with` declarations would supply duplicate evidence, rather
than shadowing the outer source. This version introduces `OuterPolicy` and
`InnerPolicy`:

<!-- markdownlint-disable MD013 -->
<!-- source: src/04-nested-policies.ash -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

The `before` and `after` calls both pass an `OuterPolicy` token and therefore
need `PricePolicy<OuterPolicy>`. The inner call passes an `InnerPolicy` token
and needs `PricePolicy<InnerPolicy>`. Both sources are active in the inner
remainder, but their nominal keys differ. Predict which tariff each call uses:

```text
$ ash supplying-a-local-pricing-policy/src/04-nested-policies.ash
(Priced(5400), Priced(5900), Priced(5400)) : (Quote, Quote, Quote)
```

The inner integer binding named `tariff` does not change the 100 already
captured by the outer method. Leaving the inner block also leaves the outer
source available to `after`. The result follows the call's token type and
lexical evidence, not the most recently written tariff value.

## Return the quoting function

A caller may want to choose a tariff once and retain a function that prices
later orders. The public contract needed for that task is
`Order -> Quote`; it does not need to mention the local policy type.
`make_pricer` builds precisely that function:

<!-- markdownlint-disable MD013 -->
<!-- source: src/05-returned-closure.ash -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

The returned function's body occurs after `with`, so `quote_order` selects
`PricePolicy<TariffPolicy>` there. The checked closure retains the selected
method function, its tariff capture, and the token needed by the call. The
[local nominal scope rule][nominals] permits this result because its exposed
`Orders.Order -> Orders.Quote` type contains no local identity.

`main` constructs both quoting functions before calling either one. The two
factory calls use the same lexical nominal declaration; their ordinary tariff
captures differ. No runtime-fresh nominal identity is needed. Predict the
three calls, including the repeated call to `first` after `second` exists:

```text
$ ash supplying-a-local-pricing-policy/src/05-returned-closure.ash
(Priced(5400), Priced(5900), Priced(5400)) : (Quote, Quote, Quote)
```

Both evidence blocks have returned by the time these functions run. Each
closure uses its retained method and values. Calling it does not select new
evidence in the caller's scope or export an evidence fact for other calls.
This is the separation between lexical availability and retained behavior
specified by the [scoped exact evidence rules][evidence].

## Distinguish zero from unavailable

The sample order alone cannot distinguish a zero price from a missing price,
or reveal what happens on a zero-quantity line. `06-boundary-orders.ash`
compares those cases. `zero_price` makes every product available for zero
cents; `books_only` and `pens_only` leave one product unavailable. The final
three calls also pass these behaviors through local interface evidence:

<!-- markdownlint-disable MD013 -->
<!-- source: src/06-boundary-orders.ash -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

Before running, trace the availability match for each call. An order with no
books still asks for the book price. Likewise, an order with no pens still
asks for the pen price. Check the collected observation:

```text
ash supplying-a-local-pricing-policy/src/06-boundary-orders.ash
```

The following are all nine quote fields of that one captured result, in tuple
order. The surrounding tuple syntax and repeated `Quote` type names are
omitted. Quantities are shown as `(books, pens)`:

| Field | Price source | Quantities | Observed quote |
| --- | --- | --- | --- |
| 1 | Explicit zero prices | `(2, 3)` | `Priced(0)` |
| 2 | Explicit base prices | `(0, 0)` | `Priced(0)` |
| 3 | Explicit books only | `(2, 3)` | `Unavailable` |
| 4 | Explicit pens only | `(0, 3)` | `Unavailable` |
| 5 | Explicit books only | `(2, 0)` | `Unavailable` |
| 6 | Explicit books only | `(0, 0)` | `Unavailable` |
| 7 | Local missing-pen policy | `(2, 3)` | `Unavailable` |
| 8 | Local missing-pen policy | `(2, 0)` | `Unavailable` |
| 9 | Local free policy | `(2, 3)` | `Priced(0)` |

Fields 1 and 9 price five items at zero; field 2 multiplies available prices
by zero quantities. All three yield an available zero total. Fields 4 and 5
show that zero quantity does not excuse a missing price, and field 6 applies
that rule even when both quantities are zero. Fields 7 and 8 preserve the
same distinction through `quote_order` and local evidence. Availability is a
choice in this application contract, rather than a consequence of multiplication
by zero or an implicit meaning of an Ash constructor.

## Repair three crossed boundaries

The accepted programs rely on separate boundaries: the units of an argument,
the evidence available at a call's source position, and the identity exposed
by a block's result. Isolate each failure before changing the calculation.

### Keep money separate from quantity

This entry supplies money in both positions of `line_total`:

<!-- source: src/07-mixed-units.ash -->
```ash
import orders (Money, line_total)

main : Unit -> Money
main () = line_total (Money(2000), Money(2))
```

The function expects `(Money, Quantity)`. Predict which argument and contract
the tool will connect, then run the rejected entry:

<!-- diagnostic: src/07-mixed-units.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en supplying-a-local-pricing-policy/src/07-mixed-units.ash
This function argument must have type `(Money, Quantity)`, but has type `(Money, Money)`.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/07-mixed-units.ash:4:22
4 | main () = line_total (Money(2000), Money(2))
  |                      ^ This has type `(Money, Money)`.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/orders.ash:13:5
13 | pub line_total : (Money, Quantity) -> Money
   |     ^ This function requires an argument of type `(Money, Quantity)`.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/07-mixed-units.ash:4:11
4 | main () = line_total (Money(2000), Money(2))
  |           ^ This is the containing function application.
reason: type.argument
```
<!-- markdownlint-enable MD013 -->

The primary label identifies the pair of money values. The second label points
to `line_total`, whose signature requires a quantity in the second field; the
last label identifies the containing application. Two integer representations
do not make those source types equal. Correct the unit at construction:

<!-- source: src/07-mixed-units-fixed.ash -->
```ash
import orders (Money, Quantity, line_total)

main : Unit -> Money
main () = line_total (Money(2000), Quantity(2))
```

```text
$ ash supplying-a-local-pricing-policy/src/07-mixed-units-fixed.ash
4000 : Money
```

The corrected pair means 2000 cents per item and two items. Multiplication
produces 4000 cents, still typed as money.

### Supply evidence before its call

A later `with` cannot supply an earlier occurrence:

<!-- markdownlint-disable MD013 -->
<!-- source: src/08-before-evidence.ash -->
```ash
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
```
<!-- markdownlint-enable MD013 -->

The token and order fix this call's requirement to
`PricePolicy<TariffPolicy>`. Identify the following remainder of `with` and
compare it with the position of `let before`:

<!-- diagnostic: src/08-before-evidence.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en supplying-a-local-pricing-policy/src/08-before-evidence.ash
No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/08-before-evidence.ash:8:18
8 |     let before = quote_order (TariffPolicy(()), Orders.sample_order ())
  |                  ^ No available evidence satisfies this interface requirement.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/pricing.ash:7:5
7 | pub quote_order : (P, Orders.Order) -> Orders.Quote where PricePolicy<P>
  |     ^ This declaration introduced the interface requirement.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/08-before-evidence.ash:2:42
2 | import pricing (PricePolicy, unit_price, quote_order)
  |                                          ^ This import made the declaration available.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/pricing.ash:3:1
3 | pub interface PricePolicy<P> {
  | ^ This interface participates in the failing evidence selection.
4 |     unit_price : (P, Orders.Product) -> Orders.Quote
  | ^ This interface participates in the failing evidence selection.
5 | }
  | ^ This interface participates in the failing evidence selection.
reason: constraint.unsatisfied
```
<!-- markdownlint-enable MD013 -->

The first label locates the call that lacks evidence. The remaining labels
connect it to the constrained declaration, its import, and the interface.
The method body itself is well formed; its evidence source is unavailable at
that earlier call. Inference does not move the occurrence into a later lexical
scope. Move the call into the following remainder:

<!-- markdownlint-disable MD013 -->
<!-- source: src/08-before-evidence-fixed.ash -->
```ash
import orders as Orders
import pricing (PricePolicy, unit_price, quote_order)

main : Unit -> Orders.Quote
main () = {
    newtype TariffPolicy = TariffPolicy(Unit)
    let tariff = 100
    with PricePolicy<TariffPolicy> {
        unit_price (TariffPolicy(ignored), product) = Orders.tariff_price tariff product
    }
    let quoted = quote_order (TariffPolicy(()), Orders.sample_order ())
    quoted
}
```
<!-- markdownlint-enable MD013 -->

```text
$ ash supplying-a-local-pricing-policy/src/08-before-evidence-fixed.ash
Priced(5400) : Quote
```

The tariff is still captured before `with`, and the quote calculation is the
same. The changed order places the occurrence where its evidence is available.

### Keep local identities out of outward types

Even an unused local token cannot leave its owning block:

<!-- source: src/09-local-escape.ash -->
```ash
main : Unit -> Int
main () = {
    let escaped = {
        newtype TariffPolicy = TariffPolicy(Unit)
        TariffPolicy(())
    }
    0
}
```

The inner block attempts to return `TariffPolicy(())` into `escaped`. `main`
would eventually return an integer, but the intermediate binding already
crosses the nominal boundary:

<!-- diagnostic: src/09-local-escape.ash -->
<!-- markdownlint-disable MD013 -->
```text
$ ash --message-format human --locale en supplying-a-local-pricing-policy/src/09-local-escape.ash
This type or effect row exposes a local nominal type outside its scope.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/09-local-escape.ash:5:9
5 |         TariffPolicy(())
  |         ^ This type or effect row exposes a local nominal type outside its scope.
  --> /path/to/ash-doc/content/cases/supplying-a-local-pricing-policy/src/09-local-escape.ash:4:9
4 |         newtype TariffPolicy = TariffPolicy(Unit)
  |         ^ This scope owns the local nominal type.
reason: type.local-nominal-escape
```
<!-- markdownlint-enable MD013 -->

The labels connect the escaping expression to the declaration that owns its
local identity. Ignoring `escaped` afterward cannot repair its outward type.
For the pricing task, keep the token inside and return the function that
consumes it. The complete accepted repair is
[`05-returned-closure.ash`](src/05-returned-closure.ash), shown above. Its
`make_pricer` returns `Order -> Quote`, and its checked calls demonstrate the
retained tariffs after the local scope returns. The repair changes the outward
contract to the result the caller needs, without exporting the token or evidence.

## Account for the work

For this two-line representation, a successful quote calls its price function
twice, multiplies twice, and adds the line totals once. A tariff policy also
adds a tariff to each available unit price. Both price requests happen before
the availability match, while unavailable quotes skip the line arithmetic.
There is no order-length recursion in this fixed representation. These are
constant counts of operations; integer arithmetic cost also depends on the
sizes of the integer values.

The [lowering rules][lowering] turn selected methods into ordinary functions
and applications. The [execution rules][execution] erase newtype wrappers
without allocating wrapper cells. Constructed `Order`, `Line`, and `Quote` values,
tuples, and retained closures still have their ordinary representation costs.
This account does not infer allocation behavior or running time from the
printed amounts.

## Practice: choose and retain a policy

Work in a scratch copy of this directory so the relative module imports remain
available.

1. Change the tariff in the first block of `03-local-policy.ash` to 50.
   Calculate its quote from the unit prices and quantities, then run it.
   Explain why the second quote keeps its original tariff.
2. In `04-nested-policies.ash`, use an `OuterPolicy` token for the inner call.
   Predict its complete interface requirement and all three quotes before
   checking the result. Keep the two evidence declarations distinct.
3. In `05-returned-closure.ash`, pass an order containing one book and four
   pens to both returned functions. Update only the order construction,
   predict both quotes, and explain which captured values they use.
4. Change the application contract so a zero-quantity line needs no price.
   Work first on `Orders.quote_with` in the scratch copy. Use integer `==`
   to identify zero counts, retain `Money` and `Quantity` at the boundary,
   and predict which rows of the boundary table should change. Run both the
   direct and local-policy calls to compare the revised contract.

The quote calculation now has explicit units, an availability rule, and a
choice of behavior supplied directly, through an imported implementation, or
in a local lexical remainder. A retained quoting function can carry the chosen
method and tariff while exposing only `Order -> Quote`. The next design
question is what an order representation should do when it contains a varying
number of lines; that change would need its own data cases and cost argument.

[order-case]: ../supplying-order-prices/README.md
[wrappers]: ../../libraries/wrapping-a-representation/README.md
[scoped]: ../../libraries/supplying-scoped-evidence/README.md
[applications]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#tuples-and-constructors
[interfaces]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#interfaces-and-constrained-schemes
[imports]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/name-resolution.md#imports-and-namespaces
[evidence]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#scoped-exact-evidence
[nominals]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/static-semantics.md#local-nominal-scope
[output]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/docs/tools/ash.md#successful-output
[lowering]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/elaboration.md#interface-evidence-lowering
[execution]: https://github.com/dikini/ash-lang/blob/354c76b391fe4af665cf6a03479a9874a57cb3e3/spec/dynamic-semantics.md#tuples-constructors-and-matches
