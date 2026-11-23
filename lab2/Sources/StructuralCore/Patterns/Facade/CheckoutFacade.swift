import Foundation
import CreationalCore

// FACADE
//
// Placing an order touches five subsystems, in a fixed order:
//   stock check -> price in the customer's currency (rates) -> payment ->
//   reserve stock -> order number -> email.
// Every failure must stop at the right point: an out-of-stock book or an
// unknown currency is never charged, and a declined payment reserves nothing.
//
// CheckoutFacade gives the client ONE call, placeOrder(...), and only
// coordinates: each step is delegated to a subsystem, through an interface.
// It holds no business rules of its own (prices come from the decorated
// items, rates from the provider, limits from the payment service).

public final class CheckoutFacade: CheckoutService {
    private let stock: StockService
    private let payment: PaymentService
    private let rates: ExchangeRateProvider
    private let notifier: NotificationService
    private let orderNumbers: OrderNumberSource

    public init(stock: StockService,
                payment: PaymentService,
                rates: ExchangeRateProvider,
                notifier: NotificationService,
                orderNumbers: OrderNumberSource = OrderNumberGenerator.shared) {   // Lab 1 Singleton
        self.stock = stock
        self.payment = payment
        self.rates = rates
        self.notifier = notifier
        self.orderNumbers = orderNumbers
    }

    public func placeOrder(items: [OrderItem], customer: String, currency: String) -> CheckoutResult {
        guard !items.isEmpty else {
            return .failure(reason: "the cart is empty")
        }
        if let missing = items.first(where: { !stock.isAvailable($0.book) }) {          // 1. stock
            return .failure(reason: "'\(missing.book.title)' is out of stock")
        }
        let totalMDL = items.reduce(0) { $0 + $1.price }                                 // 2. decorated prices
        guard let totalInCurrency = rates.convert(mdl: totalMDL, to: currency) else {     // 3. rates (Proxy -> Adapter)
            return .failure(reason: "no exchange rate for \(currency.uppercased())")
        }
        switch payment.charge(totalMDL, customer: customer) {                            // 4. payment
        case .declined(let reason):
            return .failure(reason: "payment declined by \(payment.name): \(reason)")
        case .approved(let transactionID):
            items.forEach { stock.reserve($0.book) }                                     // 5. reserve
            let receipt = Receipt(orderNumber: orderNumbers.next(),                     // 6. number (Singleton)
                                  customer: customer,
                                  lines: items.map { "\($0.description): \(money($0.price))" },
                                  totalMDL: totalMDL,
                                  currency: currency.uppercased(),
                                  totalInCurrency: totalInCurrency,
                                  paidWith: payment.name,
                                  transactionID: transactionID)
            notifier.send(to: customer,                                                  // 7. email
                          subject: "Order \(receipt.orderNumber) confirmed",
                          body: receipt.text)
            return .success(receipt)
        }
    }
}
