// Single Responsibility Principle — BEFORE
//
// `OrderManager` validates the order, calculates the price, stores the order
// and emails the customer. It has four reasons to change: a new validation
// rule, a new discount policy, a new database, or a new email template.

public enum SRPBefore {

    public final class OrderManager {
        public private(set) var savedOrders: [Order] = []
        public private(set) var sentEmails: [String] = []

        public init() {}

        public func process(_ order: Order) -> String {
            // Responsibility 1: validation
            if order.items.isEmpty {
                return "Error: order #\(order.id) has no items"
            }
            if !order.customerEmail.contains("@") {
                return "Error: invalid email '\(order.customerEmail)'"
            }

            // Responsibility 2: pricing (10% discount over 500 MDL)
            var total = 0.0
            for item in order.items {
                total += item.price * Double(item.quantity)
            }
            if total > 500 {
                total *= 0.9
            }

            // Responsibility 3: persistence
            savedOrders.append(order)

            // Responsibility 4: notification
            let email = "To: \(order.customerEmail) | Order #\(order.id) confirmed, total \(money(total))"
            sentEmails.append(email)

            return "Order #\(order.id) processed, total \(money(total))"
        }
    }
}
