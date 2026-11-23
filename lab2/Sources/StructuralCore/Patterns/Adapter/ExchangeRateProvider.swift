// ADAPTER — the Target interface.
//
// This is the only exchange-rate interface the shop knows: "how many MDL does
// one unit of this currency cost?". The checkout uses it to show the total in
// the customer's currency.

public protocol ExchangeRateProvider {
    /// MDL for one unit of `currency` (e.g. "EUR" -> 20.1773), or nil if unknown.
    func rate(of currency: String) -> Double?
}

public extension ExchangeRateProvider {
    /// Converts an amount in MDL into `currency` using `rate(of:)`.
    func convert(mdl amount: Double, to currency: String) -> Double? {
        guard let rate = rate(of: currency), rate > 0 else { return nil }
        return amount / rate
    }
}
