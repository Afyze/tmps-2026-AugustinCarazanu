// COMMAND — the Concrete Commands. Each one is a single call to the receiver.

public final class PackCommand: OrderTransitionCommand {
    public override var name: String { "pack \(order.number)" }
    public override func perform() throws { try order.pack() }
}

public final class ShipCommand: OrderTransitionCommand {
    public override var name: String { "ship \(order.number)" }
    public override func perform() throws { try order.ship() }
}

public final class DeliverCommand: OrderTransitionCommand {
    public override var name: String { "deliver \(order.number)" }
    public override func perform() throws { try order.deliver() }
}

public final class CancelCommand: OrderTransitionCommand {
    public override var name: String { "cancel \(order.number)" }
    public override func perform() throws { try order.cancel() }
}
