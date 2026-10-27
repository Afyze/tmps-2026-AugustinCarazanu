import Foundation

// ADAPTER — the adapters
//
// Each adapter implements the target interface (PaymentProcessor) and
// translates the call into the adaptee's own language:
//   MDL Double -> bani Int / text amount, and
//   numeric code / text response -> PaymentStatus.
// The rest of the shop never sees BankCardSDK or MPayService directly.

public struct BankCardAdapter: PaymentProcessor {
    public let name = "Bank card"
    private let sdk: BankCardSDK

    public init(sdk: BankCardSDK = BankCardSDK()) {
        self.sdk = sdk
    }

    public func pay(amount: Double, customer: String) -> PaymentStatus {
        let bani = Int((amount * 100).rounded())                 // MDL -> bani
        let result = sdk.authorize(amountInBani: bani, cardholderEmail: customer)
        switch result.code {                                      // code -> status
        case 0:  return .approved(transactionID: result.reference)
        case 51: return .declined(reason: "insufficient funds (code 51)")
        default: return .declined(reason: "bank error (code \(result.code))")
        }
    }
}

public struct MPayAdapter: PaymentProcessor {
    public let name = "MPay"
    private let service: MPayService

    public init(service: MPayService = MPayService()) {
        self.service = service
    }

    public func pay(amount: Double, customer: String) -> PaymentStatus {
        let sum = String(format: "%.2f", amount)                  // Double -> text
        let response = service.submitPayment(sum: sum, payerID: customer)
        let fields = parse(response)                              // text -> status
        if fields["STATUS"] == "OK", let txn = fields["TXN"] {
            return .approved(transactionID: txn)
        }
        return .declined(reason: fields["MSG"] ?? "unknown MPay error")
    }

    /// "STATUS=OK;TXN=MP-5001" -> ["STATUS": "OK", "TXN": "MP-5001"]
    private func parse(_ response: String) -> [String: String] {
        var fields: [String: String] = [:]
        for pair in response.split(separator: ";") {
            let parts = pair.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                fields[String(parts[0])] = String(parts[1])
            }
        }
        return fields
    }
}
