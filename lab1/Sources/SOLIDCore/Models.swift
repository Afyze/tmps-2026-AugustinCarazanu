import Foundation

/// Shared domain model used by all examples: a small online bookstore.
public struct OrderItem: Equatable {
    public let name: String
    public let price: Double
    public let quantity: Int

    public init(name: String, price: Double, quantity: Int) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}

public struct Order: Equatable {
    public let id: Int
    public let customerEmail: String
    public let items: [OrderItem]

    public init(id: Int, customerEmail: String, items: [OrderItem]) {
        self.id = id
        self.customerEmail = customerEmail
        self.items = items
    }
}

/// Formats an amount as "123.45 MDL".
public func money(_ amount: Double) -> String {
    String(format: "%.2f MDL", amount)
}
