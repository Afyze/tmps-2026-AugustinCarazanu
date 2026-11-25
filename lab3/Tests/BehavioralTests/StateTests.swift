import XCTest
@testable import BehavioralCore

final class StateTests: XCTestCase {
    /// The allowed path Placed -> Packed -> Shipped -> Delivered.
    func testValidTransitions() throws {
        let order = makeOrder()
        XCTAssertEqual(order.state.name, "Placed")
        try order.pack()
        XCTAssertEqual(order.state.name, "Packed")
        try order.ship()
        XCTAssertEqual(order.state.name, "Shipped")
        try order.deliver()
        XCTAssertEqual(order.state.name, "Delivered")
    }

    /// A forbidden action is rejected and the state does not change.
    func testForbiddenTransitionIsRejected() {
        let order = makeOrder()
        XCTAssertThrowsError(try order.ship()) { error in
            XCTAssertEqual(error as? OrderError, .forbidden(action: "ship", state: "Placed"))
        }
        XCTAssertEqual(order.state.name, "Placed")
    }

    /// Cancel is allowed only before shipping.
    func testCancelOnlyBeforeShipping() throws {
        let placed = makeOrder()
        try placed.cancel()
        XCTAssertEqual(placed.state.name, "Cancelled")

        let packed = makeOrder()
        try packed.pack()
        try packed.cancel()
        XCTAssertEqual(packed.state.name, "Cancelled")

        let shipped = makeOrder()
        try shipped.pack()
        try shipped.ship()
        XCTAssertThrowsError(try shipped.cancel())
        XCTAssertEqual(shipped.state.name, "Shipped")
    }

    /// Final states reject every action.
    func testFinalStatesRejectEverything() {
        for finalState in [DeliveredState(), CancelledState()] as [OrderState] {
            let order = Order(number: "T-2", customer: "a@b.md", events: OrderEventPublisher(), state: finalState)
            XCTAssertThrowsError(try order.pack())
            XCTAssertThrowsError(try order.ship())
            XCTAssertThrowsError(try order.deliver())
            XCTAssertThrowsError(try order.cancel())
            XCTAssertEqual(order.state.name, finalState.name)
        }
    }
}
