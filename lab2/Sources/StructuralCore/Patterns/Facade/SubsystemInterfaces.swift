import CreationalCore

// FACADE — the subsystem interfaces.
// The facade depends on these abstractions only, never on concrete classes,
// so any subsystem can be replaced (or mocked in tests) without editing it.

public protocol StockService {
    func isAvailable(_ book: Book) -> Bool
    func reserve(_ book: Book)
}

public protocol PaymentService {
    var name: String { get }
    func charge(_ amountMDL: Double, customer: String) -> PaymentStatus
}

public protocol NotificationService {
    func send(to recipient: String, subject: String, body: String)
}

/// Source of unique order numbers. Lab 1's OrderNumberGenerator (Singleton)
/// conforms to it (see Creational/OrderNumberGenerator+OrderNumberSource.swift).
public protocol OrderNumberSource {
    func next() -> String
}

/// The one interface the client code sees for placing an order.
public protocol CheckoutService {
    func placeOrder(items: [OrderItem], customer: String, currency: String) -> CheckoutResult
}
