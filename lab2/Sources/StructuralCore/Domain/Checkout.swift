import Foundation

// Domain models of the checkout. They hold data only; no pattern logic here.
// (Book and money() come from Lab 1's CreationalCore.)

public enum PaymentStatus: Equatable {
    case approved(transactionID: String)
    case declined(reason: String)
}

/// What the customer gets after a successful order.
public struct Receipt: Equatable {
    public let orderNumber: String
    public let customer: String
    public let lines: [String]
    public let totalMDL: Double
    public let currency: String
    public let totalInCurrency: Double
    public let paidWith: String
    public let transactionID: String

    public var text: String {
        var out = ["RECEIPT \(orderNumber) - \(customer)"]
        out += lines.map { "  " + $0 }
        out.append("  TOTAL: \(String(format: "%.2f", totalMDL)) MDL = "
                   + "\(String(format: "%.2f", totalInCurrency)) \(currency) (official BNM rate)")
        out.append("  Paid via \(paidWith), transaction \(transactionID)")
        return out.joined(separator: "\n")
    }
}

public enum CheckoutResult: Equatable {
    case success(Receipt)
    case failure(reason: String)
}

public struct Email: Equatable {
    public let to: String
    public let subject: String
    public let body: String
}
