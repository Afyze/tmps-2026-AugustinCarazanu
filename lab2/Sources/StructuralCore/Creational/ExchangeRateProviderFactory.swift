import Foundation

// CREATIONAL PATTERN FROM LAB 1 — Factory Method.
//
// Client code asks a factory for "an ExchangeRateProvider" and never learns
// that it gets a CachingRateProxy wrapped around a BNMExchangeRateAdapter.
// A different source of rates later (another bank, a test stub) means a new
// factory type; the checkout and the client code stay unchanged.

public protocol ExchangeRateProviderFactory {
    func makeProvider() -> ExchangeRateProvider
}

/// Builds the BNM chain: Proxy (cache) -> Adapter (BNM XML API).
public struct BNMRatesFactory: ExchangeRateProviderFactory {
    private let loadXML: () -> Data?

    /// `loadXML` returns the BNM XML document (downloaded, or a saved copy).
    public init(loadXML: @escaping () -> Data?) {
        self.loadXML = loadXML
    }

    /// Official rates of `date`, downloaded from bnm.md.
    public static func official(on date: Date = Date()) -> BNMRatesFactory {
        let endpoint = BNMExchangeRateAdapter.url(for: date)
        return BNMRatesFactory { try? Data(contentsOf: endpoint) }
    }

    public func makeProvider() -> ExchangeRateProvider {
        CachingRateProxy(wrapping: BNMExchangeRateAdapter(loadXML: loadXML))
    }
}
