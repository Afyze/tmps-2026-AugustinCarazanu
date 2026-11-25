import StructuralCore

/// Concrete Observer: emails the customer on every status change.
/// Sends through Lab 2's NotificationService (e.g. EmailOutbox).
public final class CustomerEmailObserver: OrderObserver {
    public let name = "email"
    private let notifier: NotificationService
    private let report: (String) -> Void

    public init(notifier: NotificationService, report: @escaping (String) -> Void = { _ in }) {
        self.notifier = notifier
        self.report = report
    }

    public func orderStatusChanged(_ change: OrderStatusChange) {
        let subject = change.isUndo
            ? "Order \(change.orderNumber) is back to \(change.to) (correction)"
            : "Order \(change.orderNumber) is now \(change.to)"
        notifier.send(to: change.customer, subject: subject,
                      body: "Status changed from \(change.from) to \(change.to).")
        report("[email] to \(change.customer): \(subject)")
    }
}
