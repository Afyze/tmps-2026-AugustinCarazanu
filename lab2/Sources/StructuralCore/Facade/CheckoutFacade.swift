// FACADE
//
// CheckoutFacade gives the client ONE simple method, placeOrder(...), and
// hides the subsystems behind it: stock check, price calculation (Decorator
// items), payment (Adapter processors), stock reservation, invoice and email.
//
// The subsystems are still public. Code that needs fine control can use
// them directly; the facade only makes the common case simple.

public enum CheckoutResult: Equatable {
    case success(orderNumber: String, total: Double, transactionID: String)
    case failure(reason: String)
}

public final class CheckoutFacade {
    private let inventory: Inventory
    private let invoices: InvoiceGenerator
    public let emailService: EmailService
    private var lastOrderNumber = 2000

    public init(inventory: Inventory,
                invoices: InvoiceGenerator = InvoiceGenerator(),
                emailService: EmailService = EmailService()) {
        self.inventory = inventory
        self.invoices = invoices
        self.emailService = emailService
    }

    public func placeOrder(items: [OrderItem], customer: String,
                           payWith processor: PaymentProcessor) -> CheckoutResult {
        // 1. Stock
        guard !items.isEmpty else {
            return .failure(reason: "the cart is empty")
        }
        for item in items where !inventory.isAvailable(item.book) {
            return .failure(reason: "'\(item.book.title)' is out of stock")
        }

        // 2. Price (each item may be decorated)
        let total = items.reduce(0) { $0 + $1.price }

        // 3. Payment (through any adapter)
        let status = processor.pay(amount: total, customer: customer)
        guard case .approved(let transactionID) = status else {
            if case .declined(let reason) = status {
                return .failure(reason: "payment declined by \(processor.name): \(reason)")
            }
            return .failure(reason: "payment failed")
        }

        // 4. Reserve stock, number the order, invoice and notify
        items.forEach { inventory.reserve($0.book) }
        lastOrderNumber += 1
        let number = "BK-\(lastOrderNumber)"
        let invoice = invoices.makeInvoice(number: number, customer: customer, items: items,
                                           total: total, paidWith: processor.name,
                                           transactionID: transactionID)
        emailService.send(to: customer,
                          subject: "Order \(number) confirmed (\(money(total)))",
                          body: invoice)
        return .success(orderNumber: number, total: total, transactionID: transactionID)
    }
}
