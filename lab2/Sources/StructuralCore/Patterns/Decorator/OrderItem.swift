import CreationalCore

// DECORATOR — Component and Concrete Component.
//
// Every line in the cart is an OrderItem. A plain book is the simplest one;
// extras (gift wrap, express delivery, insurance, discount) are added by
// wrapping it in decorators, in any number and order, at runtime.

/// Component
public protocol OrderItem {
    var book: Book { get }
    var description: String { get }
    var price: Double { get }          // MDL
}

/// Concrete Component: a book with no extras.
public struct BookItem: OrderItem {
    public let book: Book

    public init(_ book: Book) {
        self.book = book
    }

    public var description: String { book.title }
    public var price: Double { book.price }
}
