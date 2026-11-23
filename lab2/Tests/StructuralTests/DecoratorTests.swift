import XCTest
import CreationalCore
@testable import StructuralCore

/// A new decorator written only here, in another module: no existing class is edited.
final class Engraving: OrderItemDecorator {
    override var description: String { super.description + " + engraving" }
    override var price: Double { super.price + 40 }
}

final class DecoratorTests: XCTestCase {
    /// Additive decorators stacked in any order give the same price.
    func testStackedInAnyOrderGiveSameResult() {
        let orders: [OrderItem] = [
            GiftWrap(ExpressDelivery(Engraving(BookItem(testBook)))),
            GiftWrap(Engraving(ExpressDelivery(BookItem(testBook)))),
            ExpressDelivery(GiftWrap(Engraving(BookItem(testBook)))),
            ExpressDelivery(Engraving(GiftWrap(BookItem(testBook)))),
            Engraving(GiftWrap(ExpressDelivery(BookItem(testBook)))),
            Engraving(ExpressDelivery(GiftWrap(BookItem(testBook))))
        ]
        for item in orders {
            XCTAssertEqual(item.price, 225, accuracy: 0.001)   // 100 + 25 + 60 + 40
        }
    }

    /// The base decorator alone forwards everything unchanged.
    func testBaseDecoratorForwardsUnchanged() {
        let plain = BookItem(testBook)
        let wrapped = OrderItemDecorator(plain)
        XCTAssertEqual(wrapped.price, plain.price)
        XCTAssertEqual(wrapped.description, plain.description)
        XCTAssertEqual(wrapped.book, testBook)
    }

    /// Each decorator adds its part on top of the wrapped result.
    func testEachDecoratorAddsItsPart() {
        let item = BookItem(testBook).studentDiscount().giftWrapped().express().insured()
        XCTAssertEqual(item.price, (100 * 0.9 + 25 + 60) * 1.02, accuracy: 0.001)   // 178.50
        XCTAssertEqual(item.description,
                       "B - student discount 10% + gift wrap + express delivery + insurance 2%")
        XCTAssertEqual(item.book, testBook)
    }

    /// A percentage decorator depends on what it wraps, so its position matters.
    func testDiscountDependsOnWhatItWraps() {
        XCTAssertEqual(BookItem(testBook).giftWrapped().studentDiscount().price, 112.5, accuracy: 0.001)
        XCTAssertEqual(BookItem(testBook).studentDiscount().giftWrapped().price, 115, accuracy: 0.001)
    }
}
