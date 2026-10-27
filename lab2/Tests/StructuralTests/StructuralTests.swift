import XCTest
@testable import StructuralCore

final class AdapterTests: XCTestCase {
    func testBankCardAdapterConvertsMDLToBani() {
        let sdk = BankCardSDK()
        let status = BankCardAdapter(sdk: sdk).pay(amount: 873.5, customer: "a@b.md")
        XCTAssertEqual(sdk.lastAmountInBani, 87350)
        XCTAssertEqual(status, .approved(transactionID: "BC-7001"))
    }

    func testBankCardAdapterMapsCode51ToDeclined() {
        let status = BankCardAdapter().pay(amount: 7500, customer: "a@b.md")
        XCTAssertEqual(status, .declined(reason: "insufficient funds (code 51)"))
    }

    func testMPayAdapterParsesTextResponse() {
        let adapter = MPayAdapter()
        XCTAssertEqual(adapter.pay(amount: 873, customer: "a@b.md"), .approved(transactionID: "MP-5001"))
        XCTAssertEqual(adapter.pay(amount: 15000, customer: "a@b.md"), .declined(reason: "limit exceeded"))
    }

    func testClientCodeWorksWithAnyAdapter() {
        let processors: [PaymentProcessor] = [BankCardAdapter(), MPayAdapter()]
        for processor in processors {
            guard case .approved = processor.pay(amount: 100, customer: "a@b.md") else {
                return XCTFail("\(processor.name) should approve 100 MDL")
            }
        }
    }
}

final class DecoratorTests: XCTestCase {
    private let book = Book(title: "B", author: "A", price: 100)

    func testPlainBook() {
        XCTAssertEqual(BookItem(book).price, 100, accuracy: 0.001)
        XCTAssertEqual(BookItem(book).description, "B")
    }

    func testDecoratorsStack() {
        let item = BookItem(book).giftWrapped().express()
        XCTAssertEqual(item.price, 185, accuracy: 0.001)            // 100 + 25 + 60
        XCTAssertEqual(item.description, "B + gift wrap + express delivery")
        XCTAssertEqual(item.book, book)                             // still knows its book
    }

    func testOrderOfDecoratorsMatters() {
        let discountLast = BookItem(book).giftWrapped().studentDiscount()   // (100 + 25) * 0.9
        let discountFirst = BookItem(book).studentDiscount().giftWrapped()  // 100 * 0.9 + 25
        XCTAssertEqual(discountLast.price, 112.5, accuracy: 0.001)
        XCTAssertEqual(discountFirst.price, 115, accuracy: 0.001)
    }

    func testInsurance() {
        XCTAssertEqual(BookItem(book).insured().price, 102, accuracy: 0.001)
    }
}

final class FacadeTests: XCTestCase {
    private let book = Book(title: "B", author: "A", price: 100)

    /// Records how many times payment was requested.
    private final class SpyProcessor: PaymentProcessor {
        let name = "Spy"
        let approve: Bool
        var calls = 0
        init(approve: Bool) { self.approve = approve }
        func pay(amount: Double, customer: String) -> PaymentStatus {
            calls += 1
            return approve ? .approved(transactionID: "SPY-1") : .declined(reason: "test")
        }
    }

    func testSuccessfulOrderReservesStockAndSendsEmail() {
        let inventory = Inventory(stock: ["B": 2])
        let shop = CheckoutFacade(inventory: inventory)
        let result = shop.placeOrder(items: [BookItem(book).giftWrapped()], customer: "a@b.md",
                                     payWith: SpyProcessor(approve: true))
        XCTAssertEqual(result, .success(orderNumber: "BK-2001", total: 125, transactionID: "SPY-1"))
        XCTAssertEqual(inventory.count(of: "B"), 1)
        XCTAssertEqual(shop.emailService.outbox.count, 1)
    }

    func testOutOfStockNeverCallsPayment() {
        let spy = SpyProcessor(approve: true)
        let shop = CheckoutFacade(inventory: Inventory(stock: ["B": 0]))
        let result = shop.placeOrder(items: [BookItem(book)], customer: "a@b.md", payWith: spy)
        XCTAssertEqual(result, .failure(reason: "'B' is out of stock"))
        XCTAssertEqual(spy.calls, 0)
    }

    func testDeclinedPaymentKeepsStockAndSendsNothing() {
        let inventory = Inventory(stock: ["B": 1])
        let shop = CheckoutFacade(inventory: inventory)
        let result = shop.placeOrder(items: [BookItem(book)], customer: "a@b.md",
                                     payWith: SpyProcessor(approve: false))
        XCTAssertEqual(result, .failure(reason: "payment declined by Spy: test"))
        XCTAssertEqual(inventory.count(of: "B"), 1)
        XCTAssertTrue(shop.emailService.outbox.isEmpty)
    }
}
