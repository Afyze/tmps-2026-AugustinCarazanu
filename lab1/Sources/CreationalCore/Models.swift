import Foundation

/// A book sold by the online bookstore (the same domain as Lab 0).
public struct Book: Equatable {
    public let title: String
    public let author: String
    public let price: Double

    public init(title: String, author: String, price: Double) {
        self.title = title
        self.author = author
        self.price = price
    }
}

/// Formats an amount as "123.45 MDL".
public func money(_ amount: Double) -> String {
    String(format: "%.2f MDL", amount)
}
