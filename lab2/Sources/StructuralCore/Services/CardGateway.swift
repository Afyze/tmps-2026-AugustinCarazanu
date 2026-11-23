import CreationalCore

/// Payment subsystem: a simulated card gateway with a per-order limit.
public final class CardGateway: PaymentService {
    public let name = "Bank card"
    private let limitMDL: Double
    private var lastTransaction = 7000

    public init(limitMDL: Double = 5000) {
        self.limitMDL = limitMDL
    }

    public func charge(_ amountMDL: Double, customer: String) -> PaymentStatus {
        guard amountMDL <= limitMDL else {
            return .declined(reason: "insufficient funds (limit \(money(limitMDL)))")
        }
        lastTransaction += 1
        return .approved(transactionID: "BC-\(lastTransaction)")
    }
}
