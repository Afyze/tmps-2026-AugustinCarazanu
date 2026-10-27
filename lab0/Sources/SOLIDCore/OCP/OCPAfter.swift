// Open/Closed Principle — AFTER
//
// `PaymentProcessor` depends on the `PaymentMethod` abstraction. New payment
// methods are added as new types (see MPayPayment.swift) — the processor and
// the existing methods are never edited again.

/// The extension point. Any new payment method just conforms to it.
public protocol PaymentMethod {
    var name: String { get }
    func fee(for amount: Double) -> Double
    func confirmation(for total: Double) -> String
}

public enum OCPAfter {

    public struct CardPayment: PaymentMethod {
        public let name = "Card"
        public init() {}
        public func fee(for amount: Double) -> Double { amount * 0.015 }
        public func confirmation(for total: Double) -> String { "Charged \(money(total)) to the bank card" }
    }

    public struct PayPalPayment: PaymentMethod {
        public let name = "PayPal"
        public init() {}
        public func fee(for amount: Double) -> Double { amount * 0.034 + 5 }
        public func confirmation(for total: Double) -> String { "Sent \(money(total)) through PayPal" }
    }

    public struct CashPayment: PaymentMethod {
        public let name = "Cash"
        public init() {}
        public func fee(for amount: Double) -> Double { 0 }
        public func confirmation(for total: Double) -> String { "Collect \(money(total)) in cash on delivery" }
    }

    /// Closed for modification: no switch, no knowledge of concrete methods.
    public final class PaymentProcessor {
        public init() {}

        public func pay(_ amount: Double, with method: PaymentMethod) -> String {
            let total = amount + method.fee(for: amount)
            return "[\(method.name)] " + method.confirmation(for: total)
        }
    }
}
