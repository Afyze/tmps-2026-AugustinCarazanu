// OBSERVER — the Concrete Subject.
//
// Keeps the list of subscribed observers and notifies all of them, in the
// order they subscribed. It knows them only through OrderObserver.
// Observers can join and leave at any time while the program runs.

public final class OrderEventPublisher: OrderSubject {
    private var observers: [OrderObserver] = []

    public init() {}

    public var subscriberNames: [String] { observers.map(\.name) }

    public func subscribe(_ observer: OrderObserver) {
        guard !observers.contains(where: { $0 === observer }) else { return }   // no duplicates
        observers.append(observer)
    }

    public func unsubscribe(_ observer: OrderObserver) {
        observers.removeAll { $0 === observer }
    }

    public func notify(_ change: OrderStatusChange) {
        let current = observers            // copy: an observer may unsubscribe while being notified
        for observer in current {
            observer.orderStatusChanged(change)
        }
    }
}
