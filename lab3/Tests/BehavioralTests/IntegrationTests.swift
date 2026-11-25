import XCTest
import CreationalCore
import StructuralCore
@testable import BehavioralCore

/// One execution path through all patterns:
/// Lab 2 checkout (Facade) -> Order; Command -> State change -> Observers.
final class IntegrationTests: XCTestCase {
    private func makeCheckout(_ outbox: EmailOutbox, stock: Int = 3) -> CheckoutService {
        CheckoutFacade(stock: InMemoryStock(["Clean Code": stock]),
                       payment: CardGateway(),
                       rates: BNMRatesFactory(loadXML: { nil }).makeProvider(),
                       notifier: outbox)
    }

    private let book = Book(title: "Clean Code", author: "Robert C. Martin", price: 450)

    func testCommandChangesStateAndObserversAreNotified() throws {
        let outbox = EmailOutbox()
        let events = OrderEventPublisher()
        let audit = AuditLogObserver()
        events.subscribe(audit)
        events.subscribe(CustomerEmailObserver(notifier: outbox))

        let order = try OrderIntake(checkout: makeCheckout(outbox), events: events)
            .place(items: [BookItem(book).giftWrapped()], customer: "a@b.md")
        XCTAssertTrue(order.number.hasPrefix("BK-"))             // Lab 1 Singleton via Lab 2
        XCTAssertEqual(order.state.name, "Placed")

        let processor = CommandProcessor()
        processor.run(PackCommand(order: order))                   // Command
        processor.run(ShipCommand(order: order))
        processor.undoLast()

        XCTAssertEqual(order.state.name, "Packed")                 // State
        XCTAssertEqual(audit.entries, [                            // Observer
            "\(order.number): Placed -> Packed",
            "\(order.number): Packed -> Shipped",
            "\(order.number): Shipped -> Packed (undo)"
        ])
        // 1 checkout confirmation (Lab 2) + 3 status emails (Lab 3)
        XCTAssertEqual(outbox.sent.count, 4)
    }

    func testFailedCheckoutCreatesNoOrder() {
        let intake = OrderIntake(checkout: makeCheckout(EmailOutbox(), stock: 0), events: OrderEventPublisher())
        XCTAssertThrowsError(try intake.place(items: [BookItem(book)], customer: "a@b.md")) { error in
            XCTAssertEqual(error as? OrderError, .checkoutFailed(reason: "'Clean Code' is out of stock"))
        }
    }
}
