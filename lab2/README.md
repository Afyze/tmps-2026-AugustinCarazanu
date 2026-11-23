# Laboratory Work No. 2 — Structural Design Patterns in Swift

**Discipline:** Techniques and Mechanisms of Software Design (TMPS)
**Student:** Augustin Carazanu, FAF-243
**Checked by:** assist. univ. Daniel Istrati

The online bookstore from Lab 0 and Lab 1, extended with a **multi-currency checkout** that uses the **official exchange rates of the National Bank of Moldova** (public BNM XML API).

| Pattern | Where | Role in the project |
|---|---|---|
| **Adapter** | `Patterns/Adapter/` | `BNMExchangeRateAdapter` turns the BNM XML API (read with Foundation's event-driven `XMLParser`, neither written by us) into `ExchangeRateProvider.rate(of:)` |
| **Proxy** | `Patterns/Proxy/` | `CachingRateProxy` has the same interface and downloads/parses the rates only once per currency |
| **Decorator** | `Patterns/Decorator/` | `OrderItemDecorator` (base) + `GiftWrap`, `ExpressDelivery`, `Insurance`, `StudentDiscount`, stacked around a `BookItem` at runtime |
| **Facade** | `Patterns/Facade/` | `CheckoutFacade.placeOrder(...)` runs stock → rates → payment → reserve → number → email, all through interfaces |
| *From Lab 1* | `Creational/` | **Singleton** `OrderNumberGenerator.shared` numbers the orders; **Factory Method** `BNMRatesFactory` builds the Proxy → Adapter chain |

Execution path through the patterns: **client → `CheckoutFacade` → `CachingRateProxy` → `BNMExchangeRateAdapter` → bnm.md**.

📄 **Report:** [report/REPORT.md](report/REPORT.md): domain, UML class diagram, code and tests for each pattern, conclusions.

## Requirements

- Swift 5.9+ (Xcode 15+ on macOS, or the Swift toolchain on Linux)
- The `lab1` folder next to `lab2` (Lab 2 depends on it as a local package)

## Build, run, test

```bash
cd lab2
swift build
swift run StructuralDemo             # live rates from bnm.md (falls back to a saved copy if offline)
swift run StructuralDemo --offline   # saved copy of the official rates of 05.11.2026, same output every time
swift test                           # all unit tests
```

In Xcode: **File → Open… → `lab2/Package.swift`**, scheme **StructuralDemo**, ⌘R to run (add `--offline` under *Edit Scheme → Arguments* if needed), ⌘U for tests.

## Structure

```
Sources/StructuralCore/
  Domain/       Receipt, CheckoutResult, PaymentStatus, Email
  Patterns/     Adapter/  Proxy/  Decorator/  Facade/
  Creational/   Factory Method + Lab 1 Singleton integration
  Services/     InMemoryStock, CardGateway, EmailOutbox (subsystems)
Sources/StructuralDemo/   client code (main.swift) + saved BNM rates
Tests/StructuralTests/    Adapter, Proxy, Decorator, Facade and integration tests
```
