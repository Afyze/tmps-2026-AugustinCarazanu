// DECORATOR — the component and the concrete component
//
// Every line in the cart is an OrderItem: it has a description and a price.
// A plain book is the simplest item. Extras (gift wrap, express delivery,
// insurance, discounts) are added by wrapping it in decorators.

public protocol OrderItem {
    var book: Book { get }
    var description: String { get }
    var price: Double { get }
}

/// Concrete component: a book with no extras.
public struct BookItem: OrderItem {
    public let book: Book
    public init(_ book: Book) { self.book = book }
    public var description: String { book.title }
    public var price: Double { book.price }
}
