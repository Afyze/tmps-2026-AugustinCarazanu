// Single Responsibility Principle — AFTER
//
// Each class now has exactly one reason to change. `OrderService` only
// coordinates the workflow; the actual work is delegated.

public enum SRPAfter {

    public enum OrderError: Error, Equatable, CustomStringConvertible {
        case noItems(orderID: Int)
        case invalidEmail(String)

        public var description: String {
            switch self {
            case .noItems(let id): return "Error: order #\(id) has no items"
            case .invalidEmail(let email): return "Error: invalid email '\(email)'"
            }
        }
    }

    /// Changes only when validation rules change.
    public struct OrderValidator {
        public init() {}

        public func validate(_ order: Order) throws {
            guard !order.items.isEmpty else { throw OrderError.noItems(orderID: order.id) }
            guard order.customerEmail.contains("@") else { throw OrderError.invalidEmail(order.customerEmail) }
        }
    }

    /// Changes only when the pricing / discount policy changes.
    public struct PriceCalculator {
        public let discountThreshold: Double
        public let discountRate: Double

        public init(discountThreshold: Double = 500, discountRate: Double = 0.10) {
            self.discountThreshold = discountThreshold
            self.discountRate = discountRate
        }

        public func total(for order: Order) -> Double {
            let subtotal = order.items.reduce(0) { $0 + $1.price * Double($1.quantity) }
            return subtotal > discountThreshold ? subtotal * (1 - discountRate) : subtotal
        }
    }

    /// Changes only when the storage mechanism changes.
    public final class OrderRepository {
        public private(set) var orders: [Order] = []
        public init() {}

        public func save(_ order: Order) {
            orders.append(order)
        }
    }

    /// Changes only when the notification format/channel changes.
    public final class OrderNotifier {
        public private(set) var sentEmails: [String] = []
        public init() {}

        public func sendConfirmation(for order: Order, total: Double) {
            sentEmails.append("To: \(order.customerEmail) | Order #\(order.id) confirmed, total \(money(total))")
        }
    }

    /// Coordinates the use case; contains no business logic of its own.
    public final class OrderService {
        private let validator: OrderValidator
        private let calculator: PriceCalculator
        public let repository: OrderRepository
        public let notifier: OrderNotifier

        public init(validator: OrderValidator = OrderValidator(),
                    calculator: PriceCalculator = PriceCalculator(),
                    repository: OrderRepository = OrderRepository(),
                    notifier: OrderNotifier = OrderNotifier()) {
            self.validator = validator
            self.calculator = calculator
            self.repository = repository
            self.notifier = notifier
        }

        public func process(_ order: Order) -> String {
            do {
                try validator.validate(order)
            } catch let error as OrderError {
                return error.description
            } catch {
                return "Error: \(error)"
            }
            let total = calculator.total(for: order)
            repository.save(order)
            notifier.sendConfirmation(for: order, total: total)
            return "Order #\(order.id) processed, total \(money(total))"
        }
    }
}
