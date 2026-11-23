// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CreationalPatterns",
    products: [
        // Lab 2 builds on this library (reuses the Singleton and the Book model).
        .library(name: "CreationalCore", targets: ["CreationalCore"])
    ],
    targets: [
        .target(name: "CreationalCore"),
        .executableTarget(name: "CreationalDemo", dependencies: ["CreationalCore"]),
        .testTarget(name: "CreationalTests", dependencies: ["CreationalCore"])
    ]
)
