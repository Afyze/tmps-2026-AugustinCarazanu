import StructuralCore

func section(_ title: String) {
    print("\n========== \(title) ==========")
}

func describe(_ status: PaymentStatus) -> String {
    switch status {
    case .approved(let id): return "approved, transaction \(id)"
    case .declined(let reason): return "declined: \(reason)"
    }
}

func describe(_ result: CheckoutResult) -> String {
    switch result {
    case .success(let number, let total, let txn):
        return "SUCCESS \(number), \(money(total)), transaction \(txn)"
    case .failure(let reason):
        return "FAILED: \(reason)"
    }
}

let cleanCode = Book(title: "Clean Code", author: "Robert C. Martin", price: 450)
let designPatterns = Book(title: "Design Patterns", author: "Gamma et al.", price: 520)
let swiftBook = Book(title: "Swift Programming", author: "Big Nerd Ranch", price: 320)
let collectors = Book(title: "Collector's Edition", author: "Various", price: 6000)

// MARK: - Adapter

func runAdapter() {
    section("ADAPTER - two foreign payment APIs behind one interface")
    let processors: [PaymentProcessor] = [BankCardAdapter(), MPayAdapter()]
    for amount in [873.0, 7500.0] {
        for processor in processors {
            let status = processor.pay(amount: amount, customer: "augustin@example.md")
            print("[\(processor.name)] \(money(amount)) -> \(describe(status))")
        }
    }
}

// MARK: - Decorator

func runDecorator() {
    section("DECORATOR - extras wrapped around a book at runtime")
    let items: [OrderItem] = [
        BookItem(cleanCode),
        BookItem(designPatterns).giftWrapped(),
        BookItem(designPatterns).insured(),
        BookItem(swiftBook).studentDiscount().giftWrapped().express()
    ]
    for item in items {
        print("  \(item.description): \(money(item.price))")
    }

    print("\nThe order of decorators matters:")
    let discountLast = BookItem(designPatterns).giftWrapped().studentDiscount()
    let discountFirst = BookItem(designPatterns).studentDiscount().giftWrapped()
    print("  \(discountLast.description): \(money(discountLast.price))")
    print("  \(discountFirst.description): \(money(discountFirst.price))")
}

// MARK: - Facade

func runFacade() {
    section("FACADE - one call places the whole order")
    let inventory = Inventory(stock: [
        cleanCode.title: 3,
        designPatterns.title: 1,
        swiftBook.title: 0,
        collectors.title: 1
    ])
    let shop = CheckoutFacade(inventory: inventory)
    let card = BankCardAdapter()
    let mpay = MPayAdapter()

    let orders: [(String, [OrderItem], String, PaymentProcessor)] = [
        ("Order 1", [BookItem(cleanCode), BookItem(designPatterns).giftWrapped()], "augustin@example.md", card),
        ("Order 2", [BookItem(designPatterns)], "ana@example.md", card),
        ("Order 3", [BookItem(cleanCode).studentDiscount().express()], "student@utm.md", mpay),
        ("Order 4", [BookItem(collectors)], "collector@example.md", card)
    ]
    for (label, items, customer, processor) in orders {
        let result = shop.placeOrder(items: items, customer: customer, payWith: processor)
        print("\(label) (\(customer), \(processor.name)): \(describe(result))")
    }

    print("\nEmails sent:")
    for email in shop.emailService.outbox {
        print("  To \(email.to): \(email.subject)")
    }
    if let first = shop.emailService.outbox.first {
        print("\nFirst invoice:")
        print(first.body)
    }

    let titles = [cleanCode.title, designPatterns.title, swiftBook.title, collectors.title]
    let stockLine = titles.map { "\($0) \(inventory.count(of: $0))" }.joined(separator: ", ")
    print("\nStock left: \(stockLine)")
}

// MARK: - Run

runAdapter()
runDecorator()
runFacade()
