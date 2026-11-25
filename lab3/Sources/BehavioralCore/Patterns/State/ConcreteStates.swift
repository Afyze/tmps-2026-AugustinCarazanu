// STATE — the Concrete States.
// Each one overrides only the actions it allows and names the next state.
// The transitions live here, not in Order and not in the client code.

public struct PlacedState: OrderState {
    public let name = "Placed"
    public init() {}
    public func pack(_ order: Order) throws { order.transition(to: PackedState()) }
    public func cancel(_ order: Order) throws { order.transition(to: CancelledState()) }
}

public struct PackedState: OrderState {
    public let name = "Packed"
    public init() {}
    public func ship(_ order: Order) throws { order.transition(to: ShippedState()) }
    public func cancel(_ order: Order) throws { order.transition(to: CancelledState()) }
}

public struct ShippedState: OrderState {
    public let name = "Shipped"
    public init() {}
    public func deliver(_ order: Order) throws { order.transition(to: DeliveredState()) }
}

/// Final state: every action is rejected.
public struct DeliveredState: OrderState {
    public let name = "Delivered"
    public init() {}
}

/// Final state: every action is rejected.
public struct CancelledState: OrderState {
    public let name = "Cancelled"
    public init() {}
}
