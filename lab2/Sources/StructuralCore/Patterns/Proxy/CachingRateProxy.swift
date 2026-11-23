// PROXY — a caching proxy for ExchangeRateProvider.
//
// Problem: every call to BNMExchangeRateAdapter.rate(of:) loads the whole BNM
// XML document again and parses it. Official rates change once a day, so
// asking the bank for every order is slow and wasteful.
//
// The proxy has exactly the same interface as the real subject
// (ExchangeRateProvider), so the checkout cannot tell them apart. It answers
// from memory when it can, and forwards to the real provider only on the first
// request for a currency. The answer passes through unchanged.

public final class CachingRateProxy: ExchangeRateProvider {
    private let realProvider: ExchangeRateProvider
    private var cache: [String: Double] = [:]

    /// How many requests actually reached the real provider (measurement).
    public private(set) var realRequests = 0

    public init(wrapping realProvider: ExchangeRateProvider) {
        self.realProvider = realProvider
    }

    public func rate(of currency: String) -> Double? {
        let code = currency.uppercased()
        if let cached = cache[code] {                        // hit: no download
            return cached
        }
        realRequests += 1                                   // miss: delegate
        guard let fresh = realProvider.rate(of: code) else {
            return nil                                      // unknown: not cached
        }
        cache[code] = fresh
        return fresh
    }
}
