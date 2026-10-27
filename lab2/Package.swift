// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CreationalPatterns",
    targets: [
        .target(name: "CreationalCore"),
        .executableTarget(name: "CreationalDemo", dependencies: ["CreationalCore"]),
        .testTarget(name: "CreationalTests", dependencies: ["CreationalCore"])
    ]
)
