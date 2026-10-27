// FACTORY METHOD — the creators
//
// DeliveryService (the creator) contains the shared dispatch logic, but it
// does not decide WHICH shipment to create. That decision is delegated to
// the factory method `makeShipment()`, which every concrete service
// implements. In Swift the "abstract creator" is a protocol and the shared
// logic lives in a protocol extension.
//
// Adding a new carrier = one new Shipment + one new service.
// `dispatch(_:)` is never edited (Open/Closed Principle from Lab 1).

public protocol DeliveryService {
    /// The factory method.
    func makeShipment() -> Shipment
}

public extension DeliveryService {
    /// Shared business logic. It works with whatever `makeShipment()` returns.
    func dispatch(_ order: Order) -> String {
        let shipment = makeShipment()
        let cost = shipment.cost(for: order)
        return "\(order.number) -> \(shipment.carrier): shipping \(money(cost)), "
             + "\(shipment.estimate), tracking \(shipment.trackingPrefix)-\(order.number)"
    }
}

public struct CourierDeliveryService: DeliveryService {
    public init() {}
    public func makeShipment() -> Shipment { CourierShipment() }
}

public struct PostDeliveryService: DeliveryService {
    public init() {}
    public func makeShipment() -> Shipment { PostShipment() }
}

public struct StorePickupService: DeliveryService {
    public init() {}
    public func makeShipment() -> Shipment { StorePickup() }
}
