// Open/Closed Principle — BEFORE
//
// Every new payment method forces us to edit the `PaymentType` enum AND
// every `switch` inside `PaymentProcessor`. The class is not closed for
// modification, and each edit risks breaking methods that already work.

public enum OCPBefore {

    public enum PaymentType {
        case card
        case payPal
        case cash
        // Adding MPay means: add a case here, then edit both switches below.
    }

    public final class PaymentProcessor {
        public init() {}

        public func fee(for amount: Double, type: PaymentType) -> Double {
            switch type {
            case .card:   return amount * 0.015
            case .payPal: return amount * 0.034 + 5
            case .cash:   return 0
            }
        }

        public func pay(_ amount: Double, type: PaymentType) -> String {
            let total = amount + fee(for: amount, type: type)
            switch type {
            case .card:   return "Charged \(money(total)) to the bank card"
            case .payPal: return "Sent \(money(total)) through PayPal"
            case .cash:   return "Collect \(money(total)) in cash on delivery"
            }
        }
    }
}
