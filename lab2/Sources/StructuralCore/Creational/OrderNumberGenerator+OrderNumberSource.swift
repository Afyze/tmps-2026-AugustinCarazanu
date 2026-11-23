import CreationalCore

// REUSE FROM LAB 1 — Singleton.
// OrderNumberGenerator.shared (Lab 1) already has `next() -> String`, so it
// conforms to OrderNumberSource without any change to Lab 1's code.
// CheckoutFacade uses OrderNumberGenerator.shared by default, so every order
// in the whole program gets a unique number (BK-1001, BK-1002, ...).
extension OrderNumberGenerator: OrderNumberSource {}
