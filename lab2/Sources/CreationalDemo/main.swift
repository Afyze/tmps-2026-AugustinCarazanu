import CreationalCore

func section(_ title: String) {
    print("\n========== \(title) ==========")
}

let cleanCode = Book(title: "Clean Code", author: "Robert C. Martin", price: 450)
let designPatterns = Book(title: "Design Patterns", author: "Gamma et al.", price: 520)
let swiftBook = Book(title: "Swift Programming", author: "Big Nerd Ranch", price: 320)

// MARK: - Singleton

func runSingleton() {
    section("SINGLETON - one shared order-number generator")
    let checkout = OrderNumberGenerator.shared
    let adminPanel = OrderNumberGenerator.shared
    // let other = OrderNumberGenerator()   // does not compile: 'init' is private
    print("Same instance: \(checkout === adminPanel)")
    print("Checkout gets:    \(checkout.next())")
    print("Admin panel gets: \(adminPanel.next())")
    print("Checkout gets:    \(checkout.next())")
}

// MARK: - Builder

func runBuilder() throws -> [Order] {
    section("BUILDER - step-by-step order construction")
    let order = try OrderBuilder()
        .customer("augustin@example.md")
        .add(cleanCode)
        .add(designPatterns)
        .shipTo("str. Studenților 7, Chișinău")
        .coupon("FAF10")
        .build()
    print(order.summary)

    print("\nDirector presets:")
    let director = OrderDirector()
    let gift = try director.birthdayGift(for: "ana@example.md", book: swiftBook,
                                         address: "bd. Ștefan cel Mare 168, Chișinău",
                                         message: "La mulți ani!")
    print(gift.summary)
    let pickup = try director.studentPickup(for: "student@utm.md",
                                            books: [designPatterns, swiftBook])
    print(pickup.summary)

    print("\nInvalid builds are rejected:")
    let invalid: [(String, OrderBuilder)] = [
        ("no customer", OrderBuilder().add(cleanCode)),
        ("empty cart", OrderBuilder().customer("a@b.md")),
        ("message without wrap", OrderBuilder().customer("a@b.md").add(cleanCode).giftMessage("Hi"))
    ]
    for (name, builder) in invalid {
        do {
            _ = try builder.build()
        } catch {
            print("  \(name): \(error)")
        }
    }
    return [order, gift, pickup]
}

// MARK: - Factory Method

func deliveryService(for order: Order) -> DeliveryService {
    if order.shippingAddress == nil {
        return StorePickupService()
    }
    return CourierDeliveryService()
}

func runFactoryMethod(_ orders: [Order]) {
    section("FACTORY METHOD - each service creates its own shipment")
    let services: [DeliveryService] = [CourierDeliveryService(), PostDeliveryService(), StorePickupService()]
    for service in services {
        print(service.dispatch(orders[0]))
    }

    print("\nService chosen per order:")
    for order in orders {
        print(deliveryService(for: order).dispatch(order))
    }
}

// MARK: - Run

runSingleton()
do {
    let orders = try runBuilder()
    runFactoryMethod(orders)
} catch {
    print("Unexpected error: \(error)")
}
