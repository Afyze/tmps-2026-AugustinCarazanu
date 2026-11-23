import XCTest
import CreationalCore
@testable import StructuralCore

/// One execution path through several patterns: client -> Facade -> Proxy -> Adapter,
/// with objects created by the factory and the Lab 1 Singleton.
final class IntegrationTests: XCTestCase {
    func testClientToFacadeToProxyToAdapter() {
        var xmlLoads = 0
        let rates = BNMRatesFactory(loadXML: { xmlLoads += 1; return bnmXML }).makeProvider()
        let outbox = EmailOutbox()
        let checkout: CheckoutService = CheckoutFacade(stock: InMemoryStock(["B": 5]),
                                                       payment: CardGateway(),
                                                       rates: rates,
                                                       notifier: outbox)

        let first = checkout.placeOrder(items: [BookItem(testBook).giftWrapped()], customer: "a@b.md", currency: "EUR")
        let second = checkout.placeOrder(items: [BookItem(testBook)], customer: "c@d.md", currency: "EUR")

        guard case .success(let r1) = first, case .success(let r2) = second else { return XCTFail("expected success") }
        XCTAssertEqual(r1.totalInCurrency, 125 / 20.1773, accuracy: 0.0001)       // decorated price, BNM rate
        XCTAssertEqual(r2.totalInCurrency, 100 / 20.1773, accuracy: 0.0001)
        XCTAssertEqual(xmlLoads, 1)                                             // second EUR came from the proxy
        XCTAssertTrue(r1.orderNumber.hasPrefix("BK-"))                          // Lab 1 Singleton
        XCTAssertNotEqual(r1.orderNumber, r2.orderNumber)
        XCTAssertEqual(outbox.sent.count, 2)
    }

    /// The factory hides the concrete chain: the client only sees ExchangeRateProvider.
    func testFactoryReturnsProxyAroundAdapter() {
        let provider = BNMRatesFactory(loadXML: { bnmXML }).makeProvider()
        XCTAssertTrue(provider is CachingRateProxy)
        XCTAssertEqual(provider.rate(of: "USD")!, 17.9274, accuracy: 0.00001)
    }
}
