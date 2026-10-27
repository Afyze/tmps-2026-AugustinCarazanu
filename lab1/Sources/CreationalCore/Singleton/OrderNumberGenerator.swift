import Foundation

// SINGLETON
//
// Every order in the shop needs a unique number (BK-1001, BK-1002, ...).
// If the checkout screen and the admin panel each created their own
// generator, both would start at 1001 and hand out duplicate numbers.
// The generator must therefore exist exactly once, and everyone must use
// that single instance.
//
// How Swift guarantees it:
//   - `static let shared` is created lazily, exactly once, and thread-safely
//     (the runtime wraps it in dispatch_once).
//   - `private init()` stops any other code from writing
//     `OrderNumberGenerator()`, so a second instance cannot exist.
//   - The NSLock makes `next()` safe when called from many threads at once.

public final class OrderNumberGenerator {

    /// The one and only instance.
    public static let shared = OrderNumberGenerator()

    public let prefix = "BK"
    private var lastNumber = 1000
    private let lock = NSLock()

    /// Private: `OrderNumberGenerator()` does not compile outside this class.
    private init() {}

    /// Returns the next unique order number, e.g. "BK-1001".
    public func next() -> String {
        lock.lock()
        defer { lock.unlock() }
        lastNumber += 1
        return "\(prefix)-\(lastNumber)"
    }
}
