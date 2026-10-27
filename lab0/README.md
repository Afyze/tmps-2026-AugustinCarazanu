# Laboratory Work No. 0 — SOLID Principles in Swift

**Discipline:** Techniques and Mechanisms of Software Design (TMPS)
**Student:** Augustin Carazanu, FAF-243
**Checked by:** assist. univ. Daniel Istrati

Three SOLID principles applied to a small online bookstore, each with a
*before* (violating) and *after* (refactored) version.

| Principle | Before | After |
|---|---|---|
| **S** — Single Responsibility | `OrderManager` validates, prices, saves and emails | `OrderValidator`, `PriceCalculator`, `OrderRepository`, `OrderNotifier`, coordinated by `OrderService` |
| **O** — Open/Closed | `PaymentProcessor` switches over a `PaymentType` enum | `PaymentMethod` protocol; `MPayPayment` added in a new file with zero edits |
| **D** — Dependency Inversion | `NotificationService` creates a concrete `EmailSender` | Service depends on `MessageSender`, injected via `init` (email, SMS, multi-channel, mock) |

## Structure

```
lab0/
├── Package.swift
├── Sources/
│   ├── SOLIDCore/
│   │   ├── Models.swift
│   │   ├── SRP/  SRPBefore.swift  SRPAfter.swift
│   │   ├── OCP/  OCPBefore.swift  OCPAfter.swift  MPayPayment.swift
│   │   └── DIP/  DIPBefore.swift  DIPAfter.swift
│   └── SOLIDDemo/main.swift
├── Tests/SOLIDTests/SOLIDTests.swift
└── report/Lab0_SOLID_Report.docx
```

## Run

```bash
cd lab0
swift run SOLIDDemo   # prints before/after output for every principle
swift test            # unit tests (incl. a mock sender for DIP)
```

Requires Swift 5.9+ (Xcode 15+ on macOS, or the Swift toolchain on Linux).
