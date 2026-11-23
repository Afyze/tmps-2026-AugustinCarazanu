import XCTest
import CreationalCore
@testable import StructuralCore

// Mocks: each one records its calls in a shared CallLog.

private final class MockStock: StockService {
    let log: CallLog
    let available: Bool
    init(_ log: CallLog, available: Bool = true) { self.log = log; self.available = available }
    func isAvailable(_ book: Book) -> Bool { log.entries.append("stock.isAvailable(\(book.title))"); return available }
    func reserve(_ book: Book) { log.entries.append("stock.reserve(\(book.title))") }
}

private final class MockRates: ExchangeRateProvider {
    let log: CallLog
    init(_ log: CallLog) { self.log = log }
    func rate(of currency: String) -> Double? {
        log.entries.append("rates.rate(\(currency))")
        return currency == "EUR" ? 20 : nil
    }
}

private final class MockPayment: PaymentService {
    let log: CallLog
    let approve: Bool
    let name = "Mock"
    init(_ log: CallLog, approve: Bool = true) { self.log = log; self.approve = approve }
    func charge(_ amountMDL: Double, customer: String) -> PaymentStatus {
        log.entries.append("payment.charge(\(String(format: "%.2f", amountMDL)))")
        return approve ? .approved(transactionID: "TX-1") : .declined(reason: "test")
    }
}

private final class MockNotifier: NotificationService {
    let log: CallLog
    init(_ log: CallLog) { self.log = log }
    func send(to recipient: String, subject: String, body: String) { log.entries.append("notifier.send(\(recipient))") }
}

private final class MockNumbers: OrderNumberSource {
    let log: CallLog
    init(_ log: CallLog) { self.log = log }
    func next() -> String { log.entries.append("numbers.next()"); return "T-1" }
}

final class FacadeTests: XCTestCase {
    private func makeFacade(_ log: CallLog, available: Bool = true, approve: Bool = true) -> CheckoutService {
        CheckoutFacade(stock: MockStock(log, available: available),
                       payment: MockPayment(log, approve: approve),
                       rates: MockRates(log),
                       notifier: MockNotifier(log),
                       orderNumbers: MockNumbers(log))
    }

    /// The facade calls the subsystems in the right order.
    func testCallsSubsystemsInTheRightOrder() {
        let log = CallLog()
        let result = makeFacade(log).placeOrder(items: [BookItem(testBook).giftWrapped()],
                                                customer: "a@b.md", currency: "EUR")
        XCTAssertEqual(log.entries, [
            "stock.isAvailable(B)",
            "rates.rate(EUR)",
            "payment.charge(125.00)",
            "stock.reserve(B)",
            "numbers.next()",
            "notifier.send(a@b.md)"
        ])
        guard case .success(let receipt) = result else { return XCTFail("expected success") }
        XCTAssertEqual(receipt.orderNumber, "T-1")
        XCTAssertEqual(receipt.totalInCurrency, 6.25, accuracy: 0.001)   // 125 MDL / 20
    }

    /// Out of stock: the facade stops before rates and payment.
    func testOutOfStockStopsBeforePayment() {
        let log = CallLog()
        let result = makeFacade(log, available: false).placeOrder(items: [BookItem(testBook)],
                                                                  customer: "a@b.md", currency: "EUR")
        XCTAssertEqual(result, .failure(reason: "'B' is out of stock"))
        XCTAssertEqual(log.entries, ["stock.isAvailable(B)"])
    }

    /// Unknown currency: nothing is charged.
    func testUnknownCurrencyIsNeverCharged() {
        let log = CallLog()
        let result = makeFacade(log).placeOrder(items: [BookItem(testBook)], customer: "a@b.md", currency: "GBP")
        XCTAssertEqual(result, .failure(reason: "no exchange rate for GBP"))
        XCTAssertFalse(log.entries.contains { $0.hasPrefix("payment") })
    }

    /// Declined payment: no stock reserved, no number used, no email sent.
    func testDeclinedPaymentReservesNothing() {
        let log = CallLog()
        let result = makeFacade(log, approve: false).placeOrder(items: [BookItem(testBook)],
                                                                customer: "a@b.md", currency: "EUR")
        XCTAssertEqual(result, .failure(reason: "payment declined by Mock: test"))
        XCTAssertEqual(log.entries, ["stock.isAvailable(B)", "rates.rate(EUR)", "payment.charge(100.00)"])
    }
}
