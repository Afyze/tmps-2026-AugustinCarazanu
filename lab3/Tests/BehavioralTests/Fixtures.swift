@testable import BehavioralCore

/// Observer that only records what it receives.
final class RecordingObserver: OrderObserver {
    let name: String
    private(set) var received: [OrderStatusChange] = []
    init(_ name: String) { self.name = name }
    func orderStatusChanged(_ change: OrderStatusChange) { received.append(change) }
}

/// A fresh order in the Placed state, with its own subject.
func makeOrder(_ events: OrderSubject = OrderEventPublisher()) -> Order {
    Order(number: "T-1", customer: "a@b.md", events: events)
}
