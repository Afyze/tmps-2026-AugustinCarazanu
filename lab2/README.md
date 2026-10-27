# Laboratory Work No. 2 — Structural Design Patterns in Swift

**Discipline:** Techniques and Mechanisms of Software Design (TMPS)
**Student:** Augustin Carazanu, FAF-243
**Checked by:** assist. univ. Daniel Istrati

Three structural patterns implemented in one checkout flow of the online bookstore:

| Pattern | Where | What it does here |
|---|---|---|
| **Adapter** | `Adapter/PaymentProcessor.swift`, `Adapter/ThirdPartyPaymentAPIs.swift`, `Adapter/PaymentAdapters.swift` | `BankCardAdapter` and `MPayAdapter` make two incompatible third-party payment APIs (bani + numeric codes, text + text responses) usable through one `PaymentProcessor` interface |
| **Decorator** | `Decorator/OrderItem.swift`, `Decorator/ItemDecorators.swift` | Gift wrap, express delivery, insurance and student discount are stacked around a `BookItem` at runtime: `BookItem(book).studentDiscount().giftWrapped().express()` |
| **Facade** | `Facade/Subsystems.swift`, `Facade/CheckoutFacade.swift` | `CheckoutFacade.placeOrder(...)` hides stock check, pricing, payment, stock reservation, invoice and email behind one call |

Bridge, Composite, Flyweight and Proxy are explained (with Swift examples and UML diagrams) in the report.

📄 **Report:** [report/REPORT.md](report/REPORT.md) · [PDF](report/Lab2_Structural_Patterns_Report.pdf) · [Word](report/Lab2_Structural_Patterns_Report.docx)

## Run

```bash
cd lab2
swift run StructuralDemo
swift test
```

In Xcode: **File → Open… → `lab2/Package.swift`**, scheme **StructuralDemo**, ⌘R to run, ⌘U for tests.
