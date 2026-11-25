// COMMAND — the Command interface and the base command.
//
// A warehouse operator's action ("ship order BK-1001") becomes an object.
// That object can be run now, put in a queue and run later, kept in a history
// and undone (an operator clicked "ship" by mistake).
//
// The command does NOT contain business rules: it only calls the receiver
// (Order). Whether the action is allowed is decided by Order's current State.

public protocol OrderCommand {
    var name: String { get }
    func execute() throws
    func undo()
}

/// Base for commands that move an order to another state.
/// execute(): remember the state before, then ask the receiver to act.
/// undo():    give the receiver back the state remembered before.
open class OrderTransitionCommand: OrderCommand {
    public let order: Order                    // the Receiver
    private var stateBefore: OrderState?

    public init(order: Order) {
        self.order = order
    }

    /// The command's name, shown in the history.
    open var name: String { "transition" }

    /// The one call to the receiver. Subclasses override only this.
    open func perform() throws {}

    public final func execute() throws {
        let before = order.state
        try perform()                          // may throw: the state rejected it
        stateBefore = before                   // remembered only if it succeeded
    }

    public final func undo() {
        guard let before = stateBefore else { return }
        order.revert(to: before)
        stateBefore = nil
    }
}
