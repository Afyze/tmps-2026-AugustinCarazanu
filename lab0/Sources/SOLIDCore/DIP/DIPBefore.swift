// Dependency Inversion Principle — BEFORE
//
// The high-level `NotificationService` creates and depends directly on the
// low-level `EmailSender`. Switching to SMS, sending through several
// channels, or replacing the sender with a fake in unit tests is impossible
// without rewriting the service.

public enum DIPBefore {

    /// Low-level detail.
    public final class EmailSender {
        public private(set) var outbox: [String] = []
        public init() {}

        public func sendEmail(to address: String, body: String) {
            outbox.append("EMAIL -> \(address): \(body)")
        }
    }

    /// High-level policy, hard-wired to the detail above.
    public final class NotificationService {
        public let sender = EmailSender()          // concrete, created inside
        public init() {}

        public func notifyShipped(orderID: Int, contact: String) {
            sender.sendEmail(to: contact, body: "Order #\(orderID) has been shipped")
        }
    }
}
