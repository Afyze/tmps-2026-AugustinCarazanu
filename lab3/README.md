# Laboratory Work No. 3 — Behavioral Design Patterns in Swift

**Discipline:** Techniques and Mechanisms of Software Design (TMPS)
**Student:** Augustin Carazanu, FAF-243
**Checked by:** assist. univ. Daniel Istrati

The online bookstore from Lab 0 – Lab 2, extended with the **order lifecycle** after checkout: Placed → Packed → Shipped → Delivered (or Cancelled), driven by operator commands with queue and undo, and announced to subscribed observers.

| Pattern | Where | Role in the project |
|---|---|---|
| **State** | `Patterns/State/` | `Order` (context) delegates every action to its current `OrderState`; each state allows only its own transitions |
| **Command** | `Patterns/Command/`, `Commands/` | `PackCommand`, `ShipCommand`, `DeliverCommand`, `CancelCommand` run through `CommandProcessor` (invoker) with queue, history and undo |
| **Observer** | `Patterns/Observer/`, `Observers/` | `OrderEventPublisher` notifies the email, audit and courier observers; they can subscribe/unsubscribe at runtime |
| *From Lab 2/1* | `Integration/` | orders are placed through Lab 2's `CheckoutFacade` (decorated items, Lab 1 Singleton numbers); emails go through Lab 2's `NotificationService` |

Execution path: **typed command → `CommandProcessor` → `ShipCommand` → `Order` → `PackedState` → `OrderEventPublisher` → observers**.

📄 **Report:** [report/REPORT.md](report/REPORT.md): domain, UML class diagram, code and tests for each pattern, conclusions.

## Requirements

- Swift 5.9+ (Xcode 15+ on macOS, or the Swift toolchain on Linux)
- The `lab1` and `lab2` folders next to `lab3` (Lab 3 depends on them as local packages)

## Build, run, test

```bash
cd lab3
swift build
swift run BehavioralDemo                      # built-in scenario
swift run BehavioralDemo --interactive        # type commands: pack, ship, undo, queue deliver, run-queue,
                                              # subscribe|unsubscribe email|audit|courier, status, history, help, quit
swift run BehavioralDemo --script steps.txt   # the same commands from a file, one per line
swift test                                    # all unit tests
```

In Xcode: **File → Open… → `lab3/Package.swift`**, scheme **BehavioralDemo**, ⌘R to run (add `--interactive` under *Edit Scheme → Arguments*), ⌘U for tests.

## Structure

```
Sources/BehavioralCore/
  Domain/        OrderStatusChange, OrderError
  Patterns/      State/  Command/  Observer/
  Commands/      concrete commands
  Observers/     concrete observers
  Integration/   OrderIntake (Lab 2 checkout -> Order)
Sources/BehavioralDemo/   client code: main.swift, OrderConsole.swift, DemoScenario.swift
Tests/BehavioralTests/    State, Command, Observer and integration tests
```
