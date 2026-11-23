/// Notification subsystem: keeps sent emails in an outbox (no real SMTP).
public final class EmailOutbox: NotificationService {
    public private(set) var sent: [Email] = []

    public init() {}

    public func send(to recipient: String, subject: String, body: String) {
        sent.append(Email(to: recipient, subject: subject, body: body))
    }
}
