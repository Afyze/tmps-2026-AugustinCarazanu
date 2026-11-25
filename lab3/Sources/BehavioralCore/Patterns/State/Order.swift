// STATE — the Context.
//
// Order keeps a reference to its current OrderState and delegates every
// action to it. It never checks its own status: the state object decides
// whether the action is allowed and which state comes next. Every change is
// announced to the observers through the OrderSubject (Observer pattern).

public final class Order {
    public let number: String          // from Lab 2's receipt (Lab 1 Singleton numbering)
    public let customer: String
    public private(set) var state: OrderState
    private let events: OrderSubject

    public init(number: String, customer: String, events: OrderSubject, state: OrderState = PlacedState()) {
        self.number = number
        self.customer = customer
        self.events = events
        self.state = state
    }

    // The actions: pure delegation to the current state.
    public func pack() throws { try state.pack(self) }
    public func ship() throws { try state.ship(self) }
    public func deliver() throws { try state.deliver(self) }
    public func cancel() throws { try state.cancel(self) }

    /// Called by the states when an action is allowed.
    public func transition(to next: OrderState) {
        change(to: next, isUndo: false)
    }

    /// Called by a command's undo: puts back the state it saved before executing.
    public func revert(to previous: OrderState) {
        change(to: previous, isUndo: true)
    }

    private func change(to next: OrderState, isUndo: Bool) {
        let old = state
        state = next
        events.notify(OrderStatusChange(orderNumber: number, customer: customer,
                                        from: old.name, to: next.name, isUndo: isUndo))
    }
}
