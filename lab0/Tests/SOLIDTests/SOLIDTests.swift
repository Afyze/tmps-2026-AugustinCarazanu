import XCTest
@testable import SOLIDCore

final class SRPTests: XCTestCase {
    private let order = Order(id: 1, customerEmail: "a@b.md", items: [
        OrderItem(name: "Book", price: 300, quantity: 2)
    ])

    func testValidatorRejectsEmptyOrder() {
        let empty = Order(id: 7, customerEmail: "a@b.md", items: [])
        XCTAssertThrowsError(try SRPAfter.OrderValidator().validate(empty)) { error in
            XCTAssertEqual(error as? SRPAfter.OrderError, .noItems(orderID: 7))
        }
    }

    func testCalculatorAppliesDiscountAboveThreshold() {
        XCTAssertEqual(SRPAfter.PriceCalculator().total(for: order), 540, accuracy: 0.001)
    }

    func testServiceSavesAndNotifies() {
        let service = SRPAfter.OrderService()
        _ = service.process(order)
        XCTAssertEqual(service.repository.orders, [order])
        XCTAssertEqual(service.notifier.sentEmails.count, 1)
    }
}

final class OCPTests: XCTestCase {
    /// A brand-new method defined only inside the test: the processor
    /// accepts it without any modification.
    private struct GiftCardPayment: PaymentMethod {
        let name = "GiftCard"
        func fee(for amount: Double) -> Double { -amount * 0.05 }
        func confirmation(for total: Double) -> String { "Gift card: \(money(total))" }
    }

    func testProcessorWorksWithNewMethod() {
        let result = OCPAfter.PaymentProcessor().pay(100, with: GiftCardPayment())
        XCTAssertEqual(result, "[GiftCard] Gift card: 95.00 MDL")
    }

    func testMPayFee() {
        XCTAssertEqual(OCPAfter.MPayPayment().fee(for: 1000), 2)
    }
}

final class DIPTests: XCTestCase {
    /// Test double — only possible because the service depends on a protocol.
    private final class MockSender: MessageSender {
        var messages: [(String, String)] = []
        func send(to recipient: String, body: String) { messages.append((recipient, body)) }
    }

    func testServiceUsesInjectedSender() {
        let mock = MockSender()
        DIPAfter.NotificationService(sender: mock).notifyShipped(orderID: 42, contact: "x@y.md")
        XCTAssertEqual(mock.messages.count, 1)
        XCTAssertEqual(mock.messages.first?.0, "x@y.md")
        XCTAssertEqual(mock.messages.first?.1, "Order #42 has been shipped")
    }
}
