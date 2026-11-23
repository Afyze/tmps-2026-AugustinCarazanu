import Foundation
import CreationalCore
@testable import StructuralCore

/// Excerpt of the official BNM rates of 05.11.2026, in bnm.md's XML format.
let bnmXML = Data("""
<?xml version="1.0" encoding="UTF-8"?>
<ValCurs Date="05.11.2026" name="Official exchange rate">
  <Valute><NumCode>978</NumCode><CharCode>EUR</CharCode><Nominal>1</Nominal><Name>Euro</Name><Value>20.1773</Value></Valute>
  <Valute><NumCode>840</NumCode><CharCode>USD</CharCode><Nominal>1</Nominal><Name>US Dollar</Name><Value>17.9274</Value></Valute>
  <Valute><NumCode>946</NumCode><CharCode>RON</CharCode><Nominal>1</Nominal><Name>Romanian Leu</Name><Value>3.7751</Value></Valute>
</ValCurs>
""".utf8)

/// Synthetic test data (not real rates): a currency quoted per 10 units.
let nominalXML = Data("""
<ValCurs Date="01.01.2026" name="Test">
  <Valute><CharCode>TST</CharCode><Nominal>10</Nominal><Value>2.5000</Value></Valute>
</ValCurs>
""".utf8)

let testBook = Book(title: "B", author: "A", price: 100)

/// Shared list of calls, used to check the order in which the facade calls its subsystems.
final class CallLog {
    var entries: [String] = []
}

/// Stand-in for the real provider that counts how often it is asked.
final class CountingRateProvider: ExchangeRateProvider {
    private let rates: [String: Double]
    private(set) var calls = 0
    init(_ rates: [String: Double]) { self.rates = rates }
    func rate(of currency: String) -> Double? {
        calls += 1
        return rates[currency]
    }
}
