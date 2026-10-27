// ADAPTER — the target interface
//
// This is the only payment interface the bookstore knows: an amount in MDL
// (Double), a customer, and a clear result. Every payment provider must be
// usable through it, no matter what its own API looks like.

public enum PaymentStatus: Equatable {
    case approved(transactionID: String)
    case declined(reason: String)
}

public protocol PaymentProcessor {
    var name: String { get }
    func pay(amount: Double, customer: String) -> PaymentStatus
}
