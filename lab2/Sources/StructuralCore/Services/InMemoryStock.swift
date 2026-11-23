import CreationalCore

/// Stock subsystem: how many copies of each book are left.
public final class InMemoryStock: StockService {
    private var copies: [String: Int]

    public init(_ copies: [String: Int]) {
        self.copies = copies
    }

    public func isAvailable(_ book: Book) -> Bool {
        (copies[book.title] ?? 0) > 0
    }

    public func reserve(_ book: Book) {
        copies[book.title] = max(0, (copies[book.title] ?? 0) - 1)
    }

    public func count(of title: String) -> Int {
        copies[title] ?? 0
    }
}
