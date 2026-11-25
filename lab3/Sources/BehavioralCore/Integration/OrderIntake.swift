import StructuralCore

// BUILD ON LAB 2.
// An order enters its lifecycle through Lab 2's checkout: the CheckoutService
// (CheckoutFacade: stock -> rates via Proxy/Adapter -> payment -> number from
// the Lab 1 Singleton -> email) returns a Receipt, and OrderIntake turns it
// into an Order in the Placed state, wired to the event subject.

public final class OrderIntake {
    private let checkout: CheckoutService
    private let events: OrderSubject

    public init(checkout: CheckoutService, events: OrderSubject) {
        self.checkout = checkout
        self.events = events
    }

    /// `items` may be decorated (Lab 2 Decorator): BookItem(book).giftWrapped()...
    public func place(items: [OrderItem], customer: String, currency: String = "MDL") throws -> Order {
        switch checkout.placeOrder(items: items, customer: customer, currency: currency) {
        case .success(let receipt):
            return Order(number: receipt.orderNumber, customer: receipt.customer, events: events)
        case .failure(let reason):
            throw OrderError.checkoutFailed(reason: reason)
        }
    }
}
