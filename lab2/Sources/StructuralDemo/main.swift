import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import CreationalCore
import StructuralCore

// CLIENT CODE. It works with the abstractions (CheckoutService,
// ExchangeRateProvider, OrderItem); the concrete classes are chosen in one
// place below and could be swapped without touching the rest.
//
// Run:  swift run StructuralDemo            (live BNM rates, saved copy if offline)
//       swift run StructuralDemo --offline  (always the saved copy: same output every time)

func section(_ title: String) {
    print("\n========== \(title) ==========")
}

func fixed(_ value: Double, _ digits: Int = 2) -> String {
    String(format: "%.\(digits)f", value)
}

// MARK: - Where the BNM XML comes from

let offline = CommandLine.arguments.contains("--offline")
var xmlLoads = 0                       // measurement: how many times the XML is read

func downloadToday() -> Data? {
    guard !offline else { return nil }
    let url = BNMExchangeRateAdapter.url(for: Date())
    guard let data = try? Data(contentsOf: url),
          String(decoding: data, as: UTF8.self).contains("<Valute") else { return nil }
    return data
}

let liveXML = downloadToday()
let xmlDocument = liveXML ?? SampleRates.xml
let sourceLabel = liveXML != nil
    ? "live: official BNM rates downloaded from bnm.md today"
    : "offline: saved copy of the official BNM rates of \(SampleRates.date)"

/// Every call reads the whole XML document again (this is what the adapter does).
let loadXML: () -> Data? = {
    xmlLoads += 1
    return xmlDocument
}

// MARK: - Books (Book model from Lab 1)

let cleanCode = Book(title: "Clean Code", author: "Robert C. Martin", price: 450)
let designPatterns = Book(title: "Design Patterns", author: "Gamma et al.", price: 520)
let swiftBook = Book(title: "Swift Programming", author: "Big Nerd Ranch", price: 320)
let collectors = Book(title: "Collector's Edition", author: "Various", price: 6000)

// MARK: - 1. Adapter

section("ADAPTER - official BNM XML API behind ExchangeRateProvider")
print("Source: \(sourceLabel)")
let adapter: ExchangeRateProvider = BNMExchangeRateAdapter(loadXML: loadXML)
for code in ["EUR", "USD", "RON", "GBP"] {
    if let rate = adapter.rate(of: code) {
        print("  1 \(code) = \(fixed(rate, 4)) MDL")
    } else {
        print("  1 \(code) = not published in this XML")
    }
}
if let euros = adapter.convert(mdl: 1000, to: "EUR") {
    print("  1000.00 MDL = \(fixed(euros)) EUR")
}

// MARK: - 2. Proxy

section("PROXY - CachingRateProxy in front of the adapter")
let lookups = ["EUR", "EUR", "USD", "EUR"]

xmlLoads = 0
let direct: ExchangeRateProvider = BNMExchangeRateAdapter(loadXML: loadXML)
let directAnswers = lookups.map { direct.rate(of: $0) }
let loadsWithoutProxy = xmlLoads

xmlLoads = 0
let proxy = CachingRateProxy(wrapping: BNMExchangeRateAdapter(loadXML: loadXML))
let proxiedAnswers = lookups.map { proxy.rate(of: $0) }
let loadsWithProxy = xmlLoads

print("Lookups: \(lookups.joined(separator: ", "))")
print("  without proxy: \(lookups.count) lookups -> \(loadsWithoutProxy) XML loads")
print("  with proxy:    \(lookups.count) lookups -> \(loadsWithProxy) XML loads (\(proxy.realRequests) reached the adapter)")
print("  same answers through the proxy: \(directAnswers == proxiedAnswers)")

// MARK: - 3. Decorator

section("DECORATOR - extras wrapped around a book at runtime")
let cart: [OrderItem] = [
    BookItem(cleanCode),
    BookItem(designPatterns).giftWrapped(),
    BookItem(designPatterns).insured(),
    BookItem(swiftBook).studentDiscount().giftWrapped().express()
]
for item in cart {
    print("  \(item.description): \(money(item.price))")
}
print("Additive extras give the same price in any order:")
for item in [BookItem(cleanCode).giftWrapped().express(), BookItem(cleanCode).express().giftWrapped()] {
    print("  \(item.description): \(money(item.price))")
}
print("A discount depends on what it wraps:")
for item in [BookItem(designPatterns).giftWrapped().studentDiscount(),
             BookItem(designPatterns).studentDiscount().giftWrapped()] {
    print("  \(item.description): \(money(item.price))")
}

// MARK: - 4. Facade  (client -> Facade -> Proxy -> Adapter)

section("FACADE - one call places the whole order")
let stock = InMemoryStock([cleanCode.title: 3, designPatterns.title: 1, swiftBook.title: 0, collectors.title: 1])
let outbox = EmailOutbox()
let ratesFactory: ExchangeRateProviderFactory = BNMRatesFactory(loadXML: loadXML)   // Proxy -> Adapter
let checkout: CheckoutService = CheckoutFacade(stock: stock,
                                               payment: CardGateway(),
                                               rates: ratesFactory.makeProvider(),
                                               notifier: outbox)   // order numbers: Lab 1 Singleton

let orders: [(customer: String, currency: String, items: [OrderItem])] = [
    ("augustin@example.md", "EUR", [BookItem(cleanCode), BookItem(designPatterns).giftWrapped()]),
    ("ana@example.md", "MDL", [BookItem(designPatterns)]),
    ("student@utm.md", "RON", [BookItem(cleanCode).studentDiscount().express()]),
    ("collector@example.md", "EUR", [BookItem(collectors)]),
    ("guest@example.co.uk", "GBP", [BookItem(cleanCode)])
]

xmlLoads = 0
for (index, order) in orders.enumerated() {
    let result = checkout.placeOrder(items: order.items, customer: order.customer, currency: order.currency)
    let label = "Order \(index + 1) (\(order.customer), \(order.currency))"
    switch result {
    case .success(let receipt):
        print("\(label): SUCCESS \(receipt.orderNumber), \(fixed(receipt.totalMDL)) MDL = "
              + "\(fixed(receipt.totalInCurrency)) \(receipt.currency), transaction \(receipt.transactionID)")
    case .failure(let reason):
        print("\(label): FAILED: \(reason)")
    }
}
print("BNM XML loads during checkout: \(xmlLoads) (EUR, RON, GBP; the second EUR came from the proxy cache)")

print("\nEmails sent:")
for email in outbox.sent {
    print("  To \(email.to): \(email.subject)")
}
if let first = outbox.sent.first {
    print("\nFirst receipt:")
    print(first.body)
}

let titles = [cleanCode.title, designPatterns.title, swiftBook.title, collectors.title]
print("\nStock left: " + titles.map { "\($0) \(stock.count(of: $0))" }.joined(separator: ", "))
