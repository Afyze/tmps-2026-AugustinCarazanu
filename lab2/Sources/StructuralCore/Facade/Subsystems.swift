// FACADE — the subsystems
//
// Placing an order touches several independent parts of the shop. Each one
// is simple on its own, but the client would have to call them in the right
// order and handle every failure in between.

/// Keeps how many copies of each book are in stock.
public final class Inventory {
    private var stock: [String: Int]

    public init(stock: [String: Int]) {
        self.stock = stock
    }

    public func isAvailable(_ book: Book) -> Bool {
        (stock[book.title] ?? 0) > 0
    }

    public func reserve(_ book: Book) {
        stock[book.title] = max(0, (stock[book.title] ?? 0) - 1)
    }

    public func count(of title: String) -> Int {
        stock[title] ?? 0
    }
}

/// Builds the text of an invoice.
public struct InvoiceGenerator {
    public init() {}

    public func makeInvoice(number: String, customer: String, items: [OrderItem],
                            total: Double, paidWith: String, transactionID: String) -> String {
        var lines = ["INVOICE \(number) - \(customer)"]
        for item in items {
            lines.append("  \(item.description): \(money(item.price))")
        }
        lines.append("  TOTAL: \(money(total)) (paid via \(paidWith), \(transactionID))")
        return lines.joined(separator: "\n")
    }
}

public struct Email: Equatable {
    public let to: String
    public let subject: String
    public let body: String
}

/// Sends emails (here: keeps them in an outbox).
public final class EmailService {
    public private(set) var outbox: [Email] = []
    public init() {}

    public func send(to: String, subject: String, body: String) {
        outbox.append(Email(to: to, subject: subject, body: body))
    }
}
