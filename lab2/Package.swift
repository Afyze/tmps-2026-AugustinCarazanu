// swift-tools-version:5.9
import PackageDescription

// Lab 2 builds on Lab 1: it depends on the CreationalCore library
// (Book model + the OrderNumberGenerator Singleton).
let package = Package(
    name: "StructuralPatterns",
    products: [
        // Lab 3 builds on this library (checkout Facade, decorated items, notifications).
        .library(name: "StructuralCore", targets: ["StructuralCore"])
    ],
    dependencies: [
        .package(path: "../lab1")
    ],
    targets: [
        .target(
            name: "StructuralCore",
            dependencies: [.product(name: "CreationalCore", package: "lab1")]
        ),
        .executableTarget(
            name: "StructuralDemo",
            dependencies: ["StructuralCore", .product(name: "CreationalCore", package: "lab1")]
        ),
        .testTarget(
            name: "StructuralTests",
            dependencies: ["StructuralCore", .product(name: "CreationalCore", package: "lab1")]
        )
    ]
)
