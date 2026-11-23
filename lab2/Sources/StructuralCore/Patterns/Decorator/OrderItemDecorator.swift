import CreationalCore

// DECORATOR — Base Decorator.
//
// It IS an OrderItem and HAS an OrderItem (the wrapped one). By default it
// forwards every call unchanged. Concrete decorators subclass it and change
// only what they add, calling `super` for the wrapped part.
//
// It is `open`, so new decorators can be written in another module (even in
// the tests) without editing this file.

open class OrderItemDecorator: OrderItem {
    public let wrapped: OrderItem

    public init(_ wrapped: OrderItem) {
        self.wrapped = wrapped
    }

    open var book: Book { wrapped.book }
    open var description: String { wrapped.description }
    open var price: Double { wrapped.price }
}
