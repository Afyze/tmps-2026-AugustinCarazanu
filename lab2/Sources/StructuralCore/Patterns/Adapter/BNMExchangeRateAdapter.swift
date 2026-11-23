import Foundation
#if canImport(FoundationXML)
import FoundationXML          // XMLParser lives here on Linux
#endif
#if canImport(FoundationNetworking)
import FoundationNetworking   // Data(contentsOf:) over HTTP on Linux
#endif

// ADAPTER — the Adapter.
//
// The Adaptee is code we did not design and cannot change:
//   1. the public API of the National Bank of Moldova (BNM), which publishes
//      the official rates as XML:
//        <ValCurs Date="05.11.2026" name="Official exchange rate">
//          <Valute ID="..."><NumCode>978</NumCode><CharCode>EUR</CharCode>
//            <Nominal>1</Nominal><Name>Euro</Name><Value>20.1773</Value></Valute>
//          ...
//   2. Foundation's XMLParser, an event-driven (SAX) parser: instead of
//      returning values it calls delegate methods for every tag and text.
//
// Neither matches ExchangeRateProvider. The adapter translates:
//   rate(of: "EUR")  ->  load the XML  ->  drive XMLParser  ->  collect
//   CharCode / Nominal / Value  ->  Value / Nominal  ->  20.1773

public struct BNMExchangeRateAdapter: ExchangeRateProvider {
    private let loadXML: () -> Data?

    /// `loadXML` returns the BNM XML document (downloaded, or a saved copy).
    public init(loadXML: @escaping () -> Data?) {
        self.loadXML = loadXML
    }

    /// The official BNM endpoint for a given day.
    public static func url(for date: Date) -> URL {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd.MM.yyyy"
        let day = formatter.string(from: date)
        return URL(string: "https://www.bnm.md/en/official_exchange_rates?get_xml=1&date=\(day)")!
    }

    /// An adapter that downloads the official rates of `date` from BNM.
    public static func official(on date: Date) -> BNMExchangeRateAdapter {
        let endpoint = BNMExchangeRateAdapter.url(for: date)
        return BNMExchangeRateAdapter { try? Data(contentsOf: endpoint) }
    }

    public func rate(of currency: String) -> Double? {
        let code = currency.uppercased()
        if code == "MDL" { return 1 }                          // the base currency
        guard let xml = loadXML() else { return nil }          // 1. adaptee: XML document
        let table = BNMRatesParser.parse(xml)                  // 2. XMLParser events -> table
        guard let entry = table[code], entry.nominal > 0 else { return nil }
        return entry.value / entry.nominal                     // 3. "Value per Nominal" -> per 1 unit
    }
}

/// Receives XMLParser's delegate callbacks and collects one entry per <Valute>.
final class BNMRatesParser: NSObject, XMLParserDelegate {
    typealias Entry = (nominal: Double, value: Double)

    private var table: [String: Entry] = [:]
    private var text = ""
    private var code = ""
    private var nominal = 1.0
    private var value = 0.0

    static func parse(_ data: Data) -> [String: Entry] {
        let delegate = BNMRatesParser()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        parser.parse()
        return delegate.table
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        text = ""
        if elementName == "Valute" {
            code = ""
            nominal = 1
            value = 0
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        text += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?) {
        let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch elementName {
        case "CharCode": code = content.uppercased()
        case "Nominal":  nominal = Double(content) ?? 1
        case "Value":    value = Double(content.replacingOccurrences(of: ",", with: ".")) ?? 0
        case "Valute":   if !code.isEmpty { table[code] = (nominal: nominal, value: value) }
        default:         break
        }
        text = ""
    }
}
