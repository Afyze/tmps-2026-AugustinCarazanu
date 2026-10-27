# Laboratory Work No. 1 — Creational Design Patterns in Swift

**Discipline:** Techniques and Mechanisms of Software Design (TMPS)
**Student:** Augustin Carazanu, FAF-243
**Checked by:** assist. univ. Daniel Istrati

Three creational patterns implemented in one online-bookstore project:

| Pattern | Where | What it does here |
|---|---|---|
| **Singleton** | `Singleton/OrderNumberGenerator.swift` | One thread-safe generator of unique order numbers (`BK-1001`, ...) shared by the whole app |
| **Builder** | `Builder/Order.swift`, `Builder/OrderBuilder.swift` | Builds immutable `Order`s step by step with validation; `OrderDirector` has presets (gift, student pickup) |
| **Factory Method** | `FactoryMethod/Shipment.swift`, `FactoryMethod/DeliveryService.swift` | Each `DeliveryService` decides which `Shipment` to create via `makeShipment()`; `dispatch()` stays unchanged |

Prototype, Object Pool and Abstract Factory are explained (with Swift examples) in the report.

## Run

```bash
cd lab1
swift run CreationalDemo
swift test
```

In Xcode: **File → Open… → `lab1/Package.swift`**, scheme **CreationalDemo**, ⌘R to run, ⌘U for tests.
