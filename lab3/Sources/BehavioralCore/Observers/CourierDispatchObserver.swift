/// Concrete Observer: books a courier when an order is shipped, and cancels
/// the booking if the shipment is undone. Ignores every other change.
public final class CourierDispatchObserver: OrderObserver {
    public let name = "courier"
    public private(set) var bookedOrders: [String] = []
    private let report: (String) -> Void

    public init(report: @escaping (String) -> Void = { _ in }) {
        self.report = report
    }

    public func orderStatusChanged(_ change: OrderStatusChange) {
        if change.to == "Shipped" && !change.isUndo {
            bookedOrders.append(change.orderNumber)
            report("[courier] pickup booked for \(change.orderNumber)")
        } else if change.from == "Shipped" && change.isUndo {
            bookedOrders.removeAll { $0 == change.orderNumber }
            report("[courier] pickup cancelled for \(change.orderNumber)")
        }
    }
}
