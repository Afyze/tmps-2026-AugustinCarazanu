// OBSERVER — the Observer and Subject interfaces.
//
// When an order changes status, several independent parts of the shop must
// react (email the customer, keep an audit log, book a courier). The order
// must not know them: it only tells its subject "this changed", and every
// observer that is subscribed at that moment gets the change.

public protocol OrderObserver: AnyObject {
    /// Short name used by the console to subscribe/unsubscribe ("email", "audit", ...).
    var name: String { get }
    func orderStatusChanged(_ change: OrderStatusChange)
}

public protocol OrderSubject: AnyObject {
    func subscribe(_ observer: OrderObserver)
    func unsubscribe(_ observer: OrderObserver)
    func notify(_ change: OrderStatusChange)
}
