// Dependency Inversion Principle — AFTER
//
// Both the high-level `NotificationService` and the low-level senders depend
// on the `MessageSender` abstraction. The concrete sender is injected
// through the initializer, so it can be swapped (email, SMS, several
// channels, a test double) without touching the service.

/// The abstraction owned by the high-level module.
public protocol MessageSender: AnyObject {
    func send(to recipient: String, body: String)
}

public enum DIPAfter {

    public final class EmailSender: MessageSender {
        public private(set) var outbox: [String] = []
        public init() {}
        public func send(to recipient: String, body: String) {
            outbox.append("EMAIL -> \(recipient): \(body)")
        }
    }

    public final class SMSSender: MessageSender {
        public private(set) var outbox: [String] = []
        public init() {}
        public func send(to recipient: String, body: String) {
            outbox.append("SMS -> \(recipient): \(body)")
        }
    }

    /// Composite: sends through several channels, still just a MessageSender.
    public final class MultiChannelSender: MessageSender {
        private let senders: [MessageSender]
        public init(_ senders: [MessageSender]) { self.senders = senders }
        public func send(to recipient: String, body: String) {
            senders.forEach { $0.send(to: recipient, body: body) }
        }
    }

    /// High-level policy: knows only the abstraction.
    public final class NotificationService {
        private let sender: MessageSender

        public init(sender: MessageSender) {     // dependency injection
            self.sender = sender
        }

        public func notifyShipped(orderID: Int, contact: String) {
            sender.send(to: contact, body: "Order #\(orderID) has been shipped")
        }
    }
}
