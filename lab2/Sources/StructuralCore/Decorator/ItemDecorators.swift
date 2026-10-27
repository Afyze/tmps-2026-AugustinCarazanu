// DECORATOR — the decorators
//
// Each decorator IS an OrderItem and HAS an OrderItem (the wrapped one).
// It forwards the call to the wrapped item and adds its own behaviour on
// top. Decorators can be stacked in any number and any order at runtime:
//
//   BookItem(swift).studentDiscount().giftWrapped().express()
//
// Without decorators we would need a subclass for every combination
// (GiftWrappedExpressBook, DiscountedInsuredBook, ...): 4 extras already
// give 15 combinations.

public struct GiftWrapped: OrderItem {
    let wrapped: OrderItem
    public var book: Book { wrapped.book }
    public var description: String { wrapped.description + " + gift wrap" }
    public var price: Double { wrapped.price + 25 }
}

public struct ExpressDelivery: OrderItem {
    let wrapped: OrderItem
    public var book: Book { wrapped.book }
    public var description: String { wrapped.description + " + express delivery" }
    public var price: Double { wrapped.price + 60 }
}

public struct Insured: OrderItem {
    let wrapped: OrderItem
    public var book: Book { wrapped.book }
    public var description: String { wrapped.description + " + insurance 2%" }
    public var price: Double { wrapped.price * 1.02 }
}

public struct StudentDiscount: OrderItem {
    let wrapped: OrderItem
    public var book: Book { wrapped.book }
    public var description: String { wrapped.description + " - student discount 10%" }
    public var price: Double { wrapped.price * 0.90 }
}

/// Fluent helpers, so decorators read like a sentence.
public extension OrderItem {
    func giftWrapped() -> OrderItem { GiftWrapped(wrapped: self) }
    func express() -> OrderItem { ExpressDelivery(wrapped: self) }
    func insured() -> OrderItem { Insured(wrapped: self) }
    func studentDiscount() -> OrderItem { StudentDiscount(wrapped: self) }
}
