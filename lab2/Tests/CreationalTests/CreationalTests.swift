import XCTest
@testable import CreationalCore

final class SingletonTests: XCTestCase {
    func testAlwaysTheSameInstance() {
        XCTAssertTrue(OrderNumberGenerator.shared === OrderNumberGenerator.shared)
    }

    func testNumbersAreUniqueAcrossThreads() {
        let lock = NSLock()
        var numbers: [String] = []
        DispatchQueue.concurrentPerform(iterations: 1000) { _ in
            let number = OrderNumberGenerator.shared.next()
            lock.lock()
            numbers.append(number)
            lock.unlock()
        }
        XCTAssertEqual(numbers.count, 1000)
        XCTAssertEqual(Set(numbers).count, 1000)
    }
}

final class BuilderTests: XCTestCase {
    private let book = Book(title: "Test Book", author: "Author", price: 500)

    func testBuildsCompleteOrder() throws {
        let order = try OrderBuilder()
            .customer("a@b.md")
            .add(book, quantity: 2)
            .coupon("FAF10")
            .giftWrap()
            .build()
        XCTAssertEqual(order.items.count, 2)
        XCTAssertEqual(order.subtotal, 1000, accuracy: 0.001)
        XCTAssertEqual(order.total, 925, accuracy: 0.001)   // 1000 - 100 + 25
        XCTAssertTrue(order.number.hasPrefix("BK-"))
    }

    func testRejectsMissingCustomer() {
        XCTAssertThrowsError(try OrderBuilder().add(book).build()) { error in
            XCTAssertEqual(error as? OrderBuildError, .missingCustomer)
        }
    }

    func testRejectsEmptyCart() {
        XCTAssertThrowsError(try OrderBuilder().customer("a@b.md").build()) { error in
            XCTAssertEqual(error as? OrderBuildError, .emptyCart)
        }
    }

    func testRejectsGiftMessageWithoutWrap() {
        let builder = OrderBuilder().customer("a@b.md").add(book).giftMessage("Hi")
        XCTAssertThrowsError(try builder.build()) { error in
            XCTAssertEqual(error as? OrderBuildError, .giftMessageWithoutWrap)
        }
    }

    func testDirectorBirthdayGift() throws {
        let order = try OrderDirector().birthdayGift(for: "a@b.md", book: book,
                                                     address: "Chișinău", message: "Hi")
        XCTAssertTrue(order.isGiftWrapped)
        XCTAssertEqual(order.giftMessage, "Hi")
        XCTAssertEqual(order.total, 525, accuracy: 0.001)
    }
}

final class FactoryMethodTests: XCTestCase {
    private func makeOrder(price: Double) throws -> Order {
        try OrderBuilder()
            .customer("a@b.md")
            .add(Book(title: "B", author: "A", price: price))
            .shipTo("Chișinău")
            .build()
    }

    func testEachServiceCreatesItsOwnShipment() {
        XCTAssertTrue(CourierDeliveryService().makeShipment() is CourierShipment)
        XCTAssertTrue(PostDeliveryService().makeShipment() is PostShipment)
        XCTAssertTrue(StorePickupService().makeShipment() is StorePickup)
    }

    func testCourierIsFreeFrom800() throws {
        let courier = CourierShipment()
        let small = try makeOrder(price: 799)
        let large = try makeOrder(price: 800)
        XCTAssertEqual(courier.cost(for: small), 50)
        XCTAssertEqual(courier.cost(for: large), 0)
    }

    // A brand-new carrier defined only in the test file:
    // dispatch(_:) works with it without any change.
    private struct DroneShipment: Shipment {
        let carrier = "Drone"
        let estimate = "30 minutes"
        let trackingPrefix = "DR"
        func cost(for order: Order) -> Double { 99 }
    }

    private struct DroneDeliveryService: DeliveryService {
        func makeShipment() -> Shipment { DroneShipment() }
    }

    func testNewServiceWorksWithoutChangingDispatch() throws {
        let order = try makeOrder(price: 100)
        let text = DroneDeliveryService().dispatch(order)
        XCTAssertEqual(text, "\(order.number) -> Drone: shipping 99.00 MDL, 30 minutes, tracking DR-\(order.number)")
    }
}
