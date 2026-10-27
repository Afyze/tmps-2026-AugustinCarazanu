// BUILDER — the builder and the director
//
// OrderBuilder collects the parts of an order step by step through a fluent
// interface (every method returns the builder, so calls can be chained).
// `build()` checks that the combination is valid and only then creates the
// immutable Order, taking its number from the Singleton generator.

public enum OrderBuildError: Error, Equatable, CustomStringConvertible {
    case missingCustomer
    case emptyCart
    case giftMessageWithoutWrap

    public var description: String {
        switch self {
        case .missingCustomer:        return "customer email is missing or invalid"
        case .emptyCart:              return "the cart is empty"
        case .giftMessageWithoutWrap: return "a gift message requires gift wrapping"
        }
    }
}

public final class OrderBuilder {
    private var customerEmail: String?
    private var items: [Book] = []
    private var shippingAddress: String?
    private var isGiftWrapped = false
    private var giftMessage: String?
    private var couponCode: String?
    private var notes: [String] = []

    public init() {}

    @discardableResult
    public func customer(_ email: String) -> OrderBuilder {
        customerEmail = email
        return self
    }

    @discardableResult
    public func add(_ book: Book, quantity: Int = 1) -> OrderBuilder {
        items += Array(repeating: book, count: quantity)
        return self
    }

    @discardableResult
    public func shipTo(_ address: String) -> OrderBuilder {
        shippingAddress = address
        return self
    }

    @discardableResult
    public func giftWrap() -> OrderBuilder {
        isGiftWrapped = true
        return self
    }

    @discardableResult
    public func giftMessage(_ message: String) -> OrderBuilder {
        giftMessage = message
        return self
    }

    @discardableResult
    public func coupon(_ code: String) -> OrderBuilder {
        couponCode = code
        return self
    }

    @discardableResult
    public func note(_ text: String) -> OrderBuilder {
        notes.append(text)
        return self
    }

    /// Validates the collected parts and creates the final, immutable Order.
    public func build() throws -> Order {
        guard let email = customerEmail, email.contains("@") else {
            throw OrderBuildError.missingCustomer
        }
        guard !items.isEmpty else {
            throw OrderBuildError.emptyCart
        }
        if giftMessage != nil && !isGiftWrapped {
            throw OrderBuildError.giftMessageWithoutWrap
        }
        return Order(number: OrderNumberGenerator.shared.next(),
                     customerEmail: email,
                     items: items,
                     shippingAddress: shippingAddress,
                     isGiftWrapped: isGiftWrapped,
                     giftMessage: giftMessage,
                     couponCode: couponCode,
                     notes: notes)
    }
}

/// Director: knows the steps for common order types, so client code does
/// not repeat the same chain of builder calls.
public struct OrderDirector {
    public init() {}

    public func birthdayGift(for email: String, book: Book,
                             address: String, message: String) throws -> Order {
        try OrderBuilder()
            .customer(email)
            .add(book)
            .shipTo(address)
            .giftWrap()
            .giftMessage(message)
            .note("Deliver before the weekend")
            .build()
    }

    public func studentPickup(for email: String, books: [Book]) throws -> Order {
        let builder = OrderBuilder()
            .customer(email)
            .coupon("FAF10")
            .note("Pickup at FCIM, UTM")
        for book in books {
            builder.add(book)
        }
        return try builder.build()
    }
}
