import SOLIDCore

func section(_ title: String) {
    print("\n========== \(title) ==========")
}

let validOrder = Order(id: 1, customerEmail: "augustin@example.md", items: [
    OrderItem(name: "Clean Code", price: 450, quantity: 1),
    OrderItem(name: "Swift Programming", price: 320, quantity: 1)
])
let emptyOrder = Order(id: 2, customerEmail: "augustin@example.md", items: [])
let badEmailOrder = Order(id: 3, customerEmail: "augustin.example.md", items: [
    OrderItem(name: "Design Patterns", price: 380, quantity: 1)
])
let orders = [validOrder, emptyOrder, badEmailOrder]

// MARK: - SRP
section("SRP - BEFORE (one class, four responsibilities)")
let manager = SRPBefore.OrderManager()
orders.forEach { print(manager.process($0)) }

section("SRP - AFTER (validator, calculator, repository, notifier)")
let service = SRPAfter.OrderService()
orders.forEach { print(service.process($0)) }
print("Saved orders: \(service.repository.orders.map(\.id))")
service.notifier.sentEmails.forEach { print($0) }

// MARK: - OCP
let amount = 1000.0

section("OCP - BEFORE (switch over PaymentType)")
let oldProcessor = OCPBefore.PaymentProcessor()
for type in [OCPBefore.PaymentType.card, .payPal, .cash] {
    print(oldProcessor.pay(amount, type: type))
}

section("OCP - AFTER (PaymentMethod protocol, MPay added without edits)")
let processor = OCPAfter.PaymentProcessor()
let methods: [PaymentMethod] = [
    OCPAfter.CardPayment(),
    OCPAfter.PayPalPayment(),
    OCPAfter.CashPayment(),
    OCPAfter.MPayPayment()
]
methods.forEach { print(processor.pay(amount, with: $0)) }

// MARK: - DIP
section("DIP - BEFORE (service creates EmailSender itself)")
let oldNotifier = DIPBefore.NotificationService()
oldNotifier.notifyShipped(orderID: 1, contact: "augustin@example.md")
oldNotifier.sender.outbox.forEach { print($0) }

section("DIP - AFTER (sender injected through MessageSender)")
let email = DIPAfter.EmailSender()
let sms = DIPAfter.SMSSender()
DIPAfter.NotificationService(sender: email).notifyShipped(orderID: 1, contact: "augustin@example.md")
DIPAfter.NotificationService(sender: sms).notifyShipped(orderID: 1, contact: "+373 69 000 000")
let both = DIPAfter.NotificationService(sender: DIPAfter.MultiChannelSender([email, sms]))
both.notifyShipped(orderID: 3, contact: "customer")
(email.outbox + sms.outbox).forEach { print($0) }
