import BehavioralCore

/// CLIENT CODE. Turns typed lines into commands and subscriptions at runtime.
/// It works only with the abstractions: OrderCommand (via factories),
/// OrderObserver, OrderSubject and CommandProcessor.
/// A new command or observer is added by registering one more entry in main.swift.
final class OrderConsole {
    private let order: Order
    private let processor: CommandProcessor
    private let subject: OrderSubject
    private let observers: [String: OrderObserver]
    private let commands: [String: (Order) -> OrderCommand]
    private let output: (String) -> Void
    private var subscribed: [String] = []

    init(order: Order,
         processor: CommandProcessor,
         subject: OrderSubject,
         observers: [OrderObserver],
         commands: [String: (Order) -> OrderCommand],
         output: @escaping (String) -> Void) {
        self.order = order
        self.processor = processor
        self.subject = subject
        self.observers = Dictionary(uniqueKeysWithValues: observers.map { ($0.name, $0) })
        self.commands = commands
        self.output = output
    }

    /// Handles one line. Returns false when the user wants to quit.
    func handle(_ line: String) -> Bool {
        let words = line.split(separator: " ").map { String($0).lowercased() }
        guard let verb = words.first else { return true }
        output("> \(line)")
        let logBefore = processor.log.count

        switch verb {
        case "quit", "exit":
            return false
        case "help":
            output("  actions: \(commands.keys.sorted().joined(separator: ", "))")
            output("  also: queue <action>, run-queue, undo, history, status,")
            output("        subscribe|unsubscribe <\(observers.keys.sorted().joined(separator: "|"))>, quit")
        case "status":
            let list = subscribed.isEmpty ? "none" : subscribed.joined(separator: ", ")
            output("  \(order.number) is \(order.state.name); subscribed observers: \(list)")
        case "subscribe", "unsubscribe":
            guard words.count == 2, let observer = observers[words[1]] else {
                output("  unknown observer; available: \(observers.keys.sorted().joined(separator: ", "))")
                return true
            }
            if verb == "subscribe" {
                subject.subscribe(observer)
                if !subscribed.contains(observer.name) { subscribed.append(observer.name) }
            } else {
                subject.unsubscribe(observer)
                subscribed.removeAll { $0 == observer.name }
            }
            output("  \(observer.name) \(verb)d")
        case "queue":
            guard words.count == 2, let make = commands[words[1]] else {
                output("  usage: queue <\(commands.keys.sorted().joined(separator: "|"))>")
                return true
            }
            processor.enqueue(make(order))
        case "run-queue":
            processor.runQueue()
        case "undo":
            processor.undoLast()
        case "history":
            let names = processor.historyNames
            output("  " + (names.isEmpty ? "(empty)" : names.joined(separator: ", ")))
        default:
            guard let make = commands[verb] else {
                output("  unknown command '\(verb)', type help")
                return true
            }
            processor.run(make(order))
        }

        for entry in processor.log.dropFirst(logBefore) {   // what the invoker did
            output("  \(entry)")
        }
        return true
    }
}
