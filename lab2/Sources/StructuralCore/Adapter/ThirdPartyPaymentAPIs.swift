import Foundation

// ADAPTER — the adaptees
//
// Two third-party payment libraries. We cannot change their code, and their
// interfaces do not match PaymentProcessor:
//   - BankCardSDK works in bani (1 MDL = 100 bani, Int) and answers with
//     numeric codes (0 = OK, 51 = insufficient funds).
//   - MPayService takes the amount as text and answers with a text
//     response such as "STATUS=OK;TXN=MP-5001".

/// Card-processing SDK provided by a bank.
public final class BankCardSDK {
    public private(set) var lastAmountInBani: Int?
    private var lastReference = 7000
    private let limitInBani = 500_000          // 5000 MDL per transaction

    public init() {}

    public func authorize(amountInBani: Int, cardholderEmail: String) -> (code: Int, reference: String) {
        lastAmountInBani = amountInBani
        guard amountInBani <= limitInBani else {
            return (code: 51, reference: "")
        }
        lastReference += 1
        return (code: 0, reference: "BC-\(lastReference)")
    }
}

/// Government payment service with a text-based API.
public final class MPayService {
    private var lastTransaction = 5000
    private let limit = 10_000.0               // MDL per payment

    public init() {}

    public func submitPayment(sum: String, payerID: String) -> String {
        guard let value = Double(sum), value > 0 else {
            return "STATUS=ERROR;MSG=invalid sum"
        }
        guard value <= limit else {
            return "STATUS=ERROR;MSG=limit exceeded"
        }
        lastTransaction += 1
        return "STATUS=OK;TXN=MP-\(lastTransaction)"
    }
}
