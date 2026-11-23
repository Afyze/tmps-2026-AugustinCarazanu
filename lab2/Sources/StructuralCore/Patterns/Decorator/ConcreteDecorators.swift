// DECORATOR — Concrete Decorators.
//
// Each one adds one extra on top of whatever it wraps. Without decorators we
// would need a subclass per combination (GiftWrappedExpressBook,
// DiscountedInsuredBook, ...): four extras already give 15 combinations.

public final class GiftWrap: OrderItemDecorator {
    public override var description: String { super.description + " + gift wrap" }
    public override var price: Double { super.price + 25 }
}

public final class ExpressDelivery: OrderItemDecorator {
    public override var description: String { super.description + " + express delivery" }
    public override var price: Double { super.price + 60 }
}

public final class Insurance: OrderItemDecorator {
    public override var description: String { super.description + " + insurance 2%" }
    public override var price: Double { super.price * 1.02 }
}

public final class StudentDiscount: OrderItemDecorator {
    public override var description: String { super.description + " - student discount 10%" }
    public override var price: Double { super.price * 0.90 }
}

/// Fluent helpers, so a stack of decorators reads like a sentence:
/// BookItem(book).studentDiscount().giftWrapped().express()
public extension OrderItem {
    func giftWrapped() -> OrderItem { GiftWrap(self) }
    func express() -> OrderItem { ExpressDelivery(self) }
    func insured() -> OrderItem { Insurance(self) }
    func studentDiscount() -> OrderItem { StudentDiscount(self) }
}
