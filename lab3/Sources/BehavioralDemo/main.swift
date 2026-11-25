import Foundation
import CreationalCore
import StructuralCore
import BehavioralCore

// CLIENT CODE.
// Run:  swift run BehavioralDemo                      (built-in scenario)
//       swift run BehavioralDemo --interactive        (type the commands yourself)
//       swift run BehavioralDemo --script steps.txt   (commands from a file, one per line)

let arguments = CommandLine.arguments
let report: (String) -> Void = { print("  " + $0) }

// 1. Lab 2: the order is placed through the checkout Facade
//    (stock -> rates via Proxy/Adapter -> payment -> Lab 1 Singleton number -> email).
let cleanCode = Book(title: "Clean Code", author: "Robert C. Martin", price: 450)
let designPatterns = Book(title: "Design Patterns", author: "Gamma et al.", price: 520)

let outbox = EmailOutbox()
let checkout: CheckoutService = CheckoutFacade(
    stock: InMemoryStock([cleanCode.title: 5, designPatterns.title: 5]),
    payment: CardGateway(),
    rates: BNMRatesFactory(loadXML: { nil }).makeProvider(),   // MDL needs no download
    notifier: outbox)

let events = OrderEventPublisher()                               // Observer: subject
let intake = OrderIntake(checkout: checkout, events: events)

print("========== Lab 3 - order lifecycle (State + Command + Observer) ==========")
let order: BehavioralCore.Order          // Lab 1 also has an `Order` (Builder product)
do {
    order = try intake.place(items: [BookItem(cleanCode), BookItem(designPatterns).giftWrapped()],
                             customer: "augustin@example.md")
} catch {
    print("Checkout failed: \(error)")
    exit(1)
}
print("Order \(order.number) placed through Lab 2's CheckoutFacade, state: \(order.state.name)")

// 2. What the user can type. New commands/observers = one more entry here.
let console = OrderConsole(
    order: order,
    processor: CommandProcessor(),                               // Command: invoker
    subject: events,
    observers: [CustomerEmailObserver(notifier: outbox, report: report),
                AuditLogObserver(report: report),
                CourierDispatchObserver(report: report)],
    commands: ["pack": { PackCommand(order: $0) },
               "ship": { ShipCommand(order: $0) },
               "deliver": { DeliverCommand(order: $0) },
               "cancel": { CancelCommand(order: $0) }],
    output: { print($0) })

// 3. Where the input comes from: the user, a file, or the built-in scenario.
if arguments.contains("--interactive") {
    print("Type a command (help for the list, quit to exit).")
    while let line = readLine(), console.handle(line) {}
} else if let index = arguments.firstIndex(of: "--script"), index + 1 < arguments.count,
          let text = try? String(contentsOfFile: arguments[index + 1], encoding: .utf8) {
    for line in text.split(separator: "\n") {
        guard console.handle(String(line)) else { break }
    }
} else {
    for line in DemoScenario.lines {
        guard console.handle(line) else { break }
    }
}
