import XCTest
import StructuralCore
@testable import BehavioralCore

final class ObserverTests: XCTestCase {
    /// All subscribed observers are notified; unsubscribed ones are not.
    func testSubscribedNotifiedUnsubscribedNot() throws {
        let events = OrderEventPublisher()
        let first = RecordingObserver("first")
        let second = RecordingObserver("second")
        events.subscribe(first)
        events.subscribe(second)
        let order = makeOrder(events)

        try order.pack()
        events.unsubscribe(second)
        try order.ship()

        XCTAssertEqual(first.received.map(\.to), ["Packed", "Shipped"])
        XCTAssertEqual(second.received.map(\.to), ["Packed"])
    }

    /// Subscribing twice does not notify twice.
    func testNoDuplicateSubscriptions() throws {
        let events = OrderEventPublisher()
        let observer = RecordingObserver("x")
        events.subscribe(observer)
        events.subscribe(observer)
        try makeOrder(events).pack()
        XCTAssertEqual(observer.received.count, 1)
        XCTAssertEqual(events.subscriberNames, ["x"])
    }

    /// The change carries everything an observer needs.
    func testNotificationContent() throws {
        let events = OrderEventPublisher()
        let observer = RecordingObserver("x")
        events.subscribe(observer)
        try makeOrder(events).cancel()
        XCTAssertEqual(observer.received, [
            OrderStatusChange(orderNumber: "T-1", customer: "a@b.md", from: "Placed", to: "Cancelled", isUndo: false)
        ])
    }

    /// Concrete observers: the courier reacts only to shipping, and to its undo.
    func testCourierReactsOnlyToShipping() throws {
        let events = OrderEventPublisher()
        let courier = CourierDispatchObserver()
        events.subscribe(courier)
        let order = makeOrder(events)
        let processor = CommandProcessor()

        processor.run(PackCommand(order: order))
        XCTAssertTrue(courier.bookedOrders.isEmpty)
        processor.run(ShipCommand(order: order))
        XCTAssertEqual(courier.bookedOrders, ["T-1"])
        processor.undoLast()
        XCTAssertTrue(courier.bookedOrders.isEmpty)
    }

    /// The email observer sends through Lab 2's NotificationService.
    func testEmailObserverUsesLab2Notifier() throws {
        let outbox = EmailOutbox()
        let events = OrderEventPublisher()
        events.subscribe(CustomerEmailObserver(notifier: outbox))
        try makeOrder(events).pack()
        XCTAssertEqual(outbox.sent.map(\.subject), ["Order T-1 is now Packed"])
        XCTAssertEqual(outbox.sent.first?.to, "a@b.md")
    }
}
