import XCTest
@testable import StructuralCore

final class ProxyTests: XCTestCase {
    /// Through the proxy, the client gets exactly what the real provider returns.
    func testPassesAnswersThroughUnchanged() {
        let real = BNMExchangeRateAdapter(loadXML: { bnmXML })
        let proxy: ExchangeRateProvider = CachingRateProxy(wrapping: real)
        for code in ["EUR", "USD", "RON", "GBP", "MDL"] {
            XCTAssertEqual(proxy.rate(of: code), real.rate(of: code), code)
        }
    }

    /// The real provider is asked only once per currency; later calls come from the cache.
    func testCallsRealProviderOncePerCurrency() {
        let real = CountingRateProvider(["EUR": 20.1773, "USD": 17.9274])
        let proxy = CachingRateProxy(wrapping: real)
        _ = proxy.rate(of: "EUR")
        _ = proxy.rate(of: "EUR")
        _ = proxy.rate(of: "eur")
        _ = proxy.rate(of: "USD")
        XCTAssertEqual(real.calls, 2)
        XCTAssertEqual(proxy.realRequests, 2)
    }

    /// An unknown currency is not cached, so it can appear later.
    func testDoesNotCacheMissingRates() {
        let real = CountingRateProvider([:])
        let proxy = CachingRateProxy(wrapping: real)
        XCTAssertNil(proxy.rate(of: "GBP"))
        XCTAssertNil(proxy.rate(of: "GBP"))
        XCTAssertEqual(real.calls, 2)
    }
}
