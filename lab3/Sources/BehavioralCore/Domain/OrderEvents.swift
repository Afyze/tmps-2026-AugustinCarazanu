// Domain models of the order lifecycle. Data only, no pattern logic.

/// What observers receive when an order changes its status.
public struct OrderStatusChange: Equatable {
    public let orderNumber: String
    public let customer: String
    public let from: String
    public let to: String
    /// true when the change comes from undoing a command.
    public let isUndo: Bool

    public init(orderNumber: String, customer: String, from: String, to: String, isUndo: Bool) {
        self.orderNumber = orderNumber
        self.customer = customer
        self.from = from
        self.to = to
        self.isUndo = isUndo
    }
}

public enum OrderError: Error, Equatable, CustomStringConvertible {
    /// The current state does not allow this action (e.g. cancel a delivered order).
    case forbidden(action: String, state: String)
    /// The Lab 2 checkout refused the order.
    case checkoutFailed(reason: String)

    public var description: String {
        switch self {
        case .forbidden(let action, let state):
            return "cannot \(action) an order that is \(state)"
        case .checkoutFailed(let reason):
            return "checkout failed: \(reason)"
        }
    }
}
