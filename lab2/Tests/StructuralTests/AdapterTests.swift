import XCTest
@testable import StructuralCore

final class AdapterTests: XCTestCase {
    private let adapter = BNMExchangeRateAdapter(loadXML: { bnmXML })

    /// The adapter turns the BNM XML document into simple per-currency rates.
    func testTranslatesBNMXMLIntoRates() {
        XCTAssertEqual(adapter.rate(of: "EUR")!, 20.1773, accuracy: 0.00001)
        XCTAssertEqual(adapter.rate(of: "USD")!, 17.9274, accuracy: 0.00001)
        XCTAssertEqual(adapter.rate(of: "ron")!, 3.7751, accuracy: 0.00001)   // case-insensitive
    }

    /// BNM quotes some currencies per 10 or 100 units: Value / Nominal gives 1 unit.
    func testDividesValueByNominal() {
        let rate = BNMExchangeRateAdapter(loadXML: { nominalXML }).rate(of: "TST")
        XCTAssertEqual(rate!, 0.25, accuracy: 0.00001)
    }

    /// MDL is the base currency; a currency missing from the XML gives nil.
    func testBaseAndUnknownCurrencies() {
        XCTAssertEqual(adapter.rate(of: "MDL"), 1)
        XCTAssertNil(adapter.rate(of: "GBP"))
        XCTAssertNil(BNMExchangeRateAdapter(loadXML: { nil }).rate(of: "EUR"))   // download failed
    }

    /// Client code converts through the target interface only.
    func testConvertsThroughTargetInterface() {
        let provider: ExchangeRateProvider = adapter
        XCTAssertEqual(provider.convert(mdl: 1000, to: "EUR")!, 49.56, accuracy: 0.01)
    }

    /// The adapter asks BNM with the documented URL format.
    func testBuildsOfficialURL() {
        let day = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 11, day: 5, hour: 12))!
        XCTAssertEqual(BNMExchangeRateAdapter.url(for: day).absoluteString,
                       "https://www.bnm.md/en/official_exchange_rates?get_xml=1&date=05.11.2026")
    }
}
