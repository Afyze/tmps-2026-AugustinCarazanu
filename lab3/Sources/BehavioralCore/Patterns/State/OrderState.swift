// STATE — the State interface.
//
// What an order may do depends on where it is in its life:
//   Placed -> Packed -> Shipped -> Delivered,  and Placed/Packed -> Cancelled.
// Instead of a `switch` on a status enum inside Order, every status is its own
// class. Each one implements only the actions it allows and decides the next
// state. Every other action is rejected by the default implementation below.

public protocol OrderState {
    var name: String { get }
    func pack(_ order: Order) throws
    func ship(_ order: Order) throws
    func deliver(_ order: Order) throws
    func cancel(_ order: Order) throws
}

/// Default: an action is forbidden unless a concrete state allows it.
public extension OrderState {
    func pack(_ order: Order) throws { throw OrderError.forbidden(action: "pack", state: name) }
    func ship(_ order: Order) throws { throw OrderError.forbidden(action: "ship", state: name) }
    func deliver(_ order: Order) throws { throw OrderError.forbidden(action: "deliver", state: name) }
    func cancel(_ order: Order) throws { throw OrderError.forbidden(action: "cancel", state: name) }
}
