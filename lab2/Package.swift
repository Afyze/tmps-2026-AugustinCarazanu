// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "StructuralPatterns",
    targets: [
        .target(name: "StructuralCore"),
        .executableTarget(name: "StructuralDemo", dependencies: ["StructuralCore"]),
        .testTarget(name: "StructuralTests", dependencies: ["StructuralCore"])
    ]
)
