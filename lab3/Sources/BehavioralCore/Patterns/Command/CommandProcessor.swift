// COMMAND — the Invoker.
//
// Runs commands now or from a queue, keeps the history of the ones that
// succeeded and undoes them in reverse order. It knows commands only through
// OrderCommand, so a new kind of command needs no change here.

public final class CommandProcessor {
    private var queue: [OrderCommand] = []
    private var history: [OrderCommand] = []      // succeeded commands, newest last
    public private(set) var log: [String] = []

    public init() {}

    public var queuedNames: [String] { queue.map(\.name) }
    public var historyNames: [String] { history.map(\.name) }

    /// Runs a command now. Only a successful command enters the history.
    @discardableResult
    public func run(_ command: OrderCommand) -> Bool {
        do {
            try command.execute()
            history.append(command)
            log.append("done: \(command.name)")
            return true
        } catch {
            log.append("rejected: \(command.name) - \(error)")
            return false
        }
    }

    public func enqueue(_ command: OrderCommand) {
        queue.append(command)
        log.append("queued: \(command.name)")
    }

    /// Runs the queue in order and stops at the first rejected command
    /// (the rest of the queue is dropped). Returns how many succeeded.
    @discardableResult
    public func runQueue() -> Int {
        var succeeded = 0
        while !queue.isEmpty {
            let command = queue.removeFirst()
            guard run(command) else {
                log.append("queue stopped, \(queue.count) command(s) dropped")
                queue.removeAll()
                break
            }
            succeeded += 1
        }
        return succeeded
    }

    /// Undoes the most recent successful command.
    @discardableResult
    public func undoLast() -> Bool {
        guard let command = history.popLast() else {
            log.append("nothing to undo")
            return false
        }
        command.undo()
        log.append("undone: \(command.name)")
        return true
    }
}
