import XCTest
@testable import BehavioralCore

/// A new command written only here: no existing class is edited.
final class PackAndShipCommand: OrderTransitionCommand {
    override var name: String { "pack+ship \(order.number)" }
    override func perform() throws {
        try order.pack()
        try order.ship()
    }
}

final class CommandTests: XCTestCase {
    /// Executing a command and undoing it restores the original state.
    func testExecuteThenUndoRestoresState() {
        let order = makeOrder()
        let processor = CommandProcessor()
        XCTAssertTrue(processor.run(PackCommand(order: order)))
        XCTAssertEqual(order.state.name, "Packed")
        XCTAssertTrue(processor.undoLast())
        XCTAssertEqual(order.state.name, "Placed")
    }

    /// Undo works backwards through the history, one command at a time.
    func testUndoGoesBackThroughHistory() {
        let order = makeOrder()
        let processor = CommandProcessor()
        processor.run(PackCommand(order: order))
        processor.run(ShipCommand(order: order))
        XCTAssertEqual(processor.historyNames, ["pack T-1", "ship T-1"])
        processor.undoLast()
        XCTAssertEqual(order.state.name, "Packed")
        processor.undoLast()
        XCTAssertEqual(order.state.name, "Placed")
        XCTAssertFalse(processor.undoLast())                    // nothing left
    }

    /// A rejected command does not enter the history, so undo skips it.
    func testRejectedCommandIsNotInHistory() {
        let order = makeOrder()
        let processor = CommandProcessor()
        processor.run(PackCommand(order: order))
        XCTAssertFalse(processor.run(DeliverCommand(order: order)))   // Packed cannot be delivered
        XCTAssertEqual(processor.historyNames, ["pack T-1"])
        processor.undoLast()
        XCTAssertEqual(order.state.name, "Placed")
    }

    /// The queue runs in order and stops at the first rejected command.
    func testQueueRunsInOrderAndStopsAtFailure() {
        let order = makeOrder()
        let processor = CommandProcessor()
        processor.enqueue(PackCommand(order: order))
        processor.enqueue(DeliverCommand(order: order))          // rejected: not shipped yet
        processor.enqueue(ShipCommand(order: order))             // dropped
        XCTAssertEqual(processor.runQueue(), 1)
        XCTAssertEqual(order.state.name, "Packed")
        XCTAssertTrue(processor.queuedNames.isEmpty)
    }

    /// A command added in another module works with the invoker and its undo.
    func testNewCommandWithoutEditingExistingClasses() {
        let order = makeOrder()
        let processor = CommandProcessor()
        XCTAssertTrue(processor.run(PackAndShipCommand(order: order)))
        XCTAssertEqual(order.state.name, "Shipped")
        processor.undoLast()
        XCTAssertEqual(order.state.name, "Placed")
    }
}
