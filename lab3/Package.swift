// swift-tools-version:5.9
import PackageDescription

// Lab 3 builds on Lab 2 (checkout Facade, decorated order items, notifications)
// and, through it, on Lab 1 (Book model, OrderNumberGenerator Singleton).
let package = Package(
    name: "BehavioralPatterns",
    dependencies: [
        .package(path: "../lab1"),
        .package(path: "../lab2")
    ],
    targets: [
        .target(
            name: "BehavioralCore",
            dependencies: [
                .product(name: "CreationalCore", package: "lab1"),
                .product(name: "StructuralCore", package: "lab2")
            ]
        ),
        .executableTarget(
            name: "BehavioralDemo",
            dependencies: [
                "BehavioralCore",
                .product(name: "CreationalCore", package: "lab1"),
                .product(name: "StructuralCore", package: "lab2")
            ]
        ),
        .testTarget(
            name: "BehavioralTests",
            dependencies: [
                "BehavioralCore",
                .product(name: "CreationalCore", package: "lab1"),
                .product(name: "StructuralCore", package: "lab2")
            ]
        )
    ]
)
