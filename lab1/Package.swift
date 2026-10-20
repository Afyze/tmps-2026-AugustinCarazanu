// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SOLID",
    targets: [
        .target(name: "SOLIDCore"),
        .executableTarget(name: "SOLIDDemo", dependencies: ["SOLIDCore"]),
        .testTarget(name: "SOLIDTests", dependencies: ["SOLIDCore"])
    ]
)
