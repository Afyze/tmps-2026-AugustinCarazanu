// Open/Closed Principle — EXTENSION
//
// A new requirement: support MPay (the Moldovan government payment service).
// It is added in its own file. No existing line of code was modified.

public extension OCPAfter {

    struct MPayPayment: PaymentMethod {
        public let name = "MPay"
        public init() {}
        public func fee(for amount: Double) -> Double { 2 }
        public func confirmation(for total: Double) -> String { "Paid \(money(total)) via MPay" }
    }
}
