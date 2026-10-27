// BUILDER — the product
//
// An order has two required parts (customer, books) and many optional ones
// (shipping address, gift wrap, gift message, coupon, notes). Creating it
// with one initializer would mean a "telescoping" call with eight arguments,
// most of them nil/false:
//
//   Order(number: "BK-1", customerEmail: "a@b.md", items: [book],
//         shippingAddress: nil, isGiftWrapped: false, giftMessage: nil,
//         couponCode: nil, notes: [])
//
// The initializer is therefore internal: outside this module an Order can
// only be created through OrderBuilder, which also validates it.
// All properties are `let`, so a finished Order is immutable.

public struct Order {
    public let number: String
    public let customerEmail: String
    public let items: [Book]
    public let shippingAddress: String?      // nil = pickup in store
    public let isGiftWrapped: Bool
    public let giftMessage: String?
    public let couponCode: String?
    public let notes: [String]

    public var subtotal: Double { items.reduce(0) { $0 + $1.price } }
    public var discount: Double { couponCode == "FAF10" ? subtotal * 0.10 : 0 }
    public var giftWrapFee: Double { isGiftWrapped ? 25 : 0 }
    public var total: Double { subtotal - discount + giftWrapFee }

    public var summary: String {
        var lines = ["Order \(number) for \(customerEmail)"]
        lines.append("  Items: " + items.map(\.title).joined(separator: ", "))
        lines.append("  Delivery: " + (shippingAddress ?? "pickup in store"))
        if isGiftWrapped {
            lines.append("  Gift wrap: yes" + (giftMessage.map { " (\"\($0)\")" } ?? ""))
        }
        if let couponCode {
            lines.append("  Coupon: \(couponCode)")
        }
        for note in notes {
            lines.append("  Note: \(note)")
        }
        lines.append("  Subtotal \(money(subtotal)), discount \(money(discount)), "
                     + "gift wrap \(money(giftWrapFee)) -> total \(money(total))")
        return lines.joined(separator: "\n")
    }
}
