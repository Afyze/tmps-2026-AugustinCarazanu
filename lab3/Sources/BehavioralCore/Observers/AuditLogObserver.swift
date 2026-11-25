/// Concrete Observer: keeps a log line for every status change.
public final class AuditLogObserver: OrderObserver {
    public let name = "audit"
    public private(set) var entries: [String] = []
    private let report: (String) -> Void

    public init(report: @escaping (String) -> Void = { _ in }) {
        self.report = report
    }

    public func orderStatusChanged(_ change: OrderStatusChange) {
        let entry = "\(change.orderNumber): \(change.from) -> \(change.to)" + (change.isUndo ? " (undo)" : "")
        entries.append(entry)
        report("[audit] \(entry)")
    }
}
