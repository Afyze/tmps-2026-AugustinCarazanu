// FACTORY METHOD — the products
//
// Every way of delivering an order is a Shipment. The rest of the code only
// talks to this protocol, never to the concrete types.

public protocol Shipment {
    var carrier: String { get }
    var estimate: String { get }
    var trackingPrefix: String { get }
    func cost(for order: Order) -> Double
}

/// Courier in Chișinău: 50 MDL, free for orders of 800 MDL or more.
public struct CourierShipment: Shipment {
    public let carrier = "Courier"
    public let estimate = "next day"
    public let trackingPrefix = "CR"
    public init() {}
    public func cost(for order: Order) -> Double { order.subtotal >= 800 ? 0 : 50 }
}

/// National post: flat 35 MDL, slower.
public struct PostShipment: Shipment {
    public let carrier = "Poșta Moldovei"
    public let estimate = "3-5 days"
    public let trackingPrefix = "PM"
    public init() {}
    public func cost(for order: Order) -> Double { 35 }
}

/// The customer picks the order up from the shop.
public struct StorePickup: Shipment {
    public let carrier = "Store pickup"
    public let estimate = "ready in 2 hours"
    public let trackingPrefix = "PU"
    public init() {}
    public func cost(for order: Order) -> Double { 0 }
}
