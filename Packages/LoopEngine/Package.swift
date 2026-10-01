// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LoopEngine",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "LoopEngine", targets: ["LoopEngine"])],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../SafetyKit"),
    ],
    targets: [
        .target(name: "LoopEngine", dependencies: ["Domain", "SafetyKit"]),
        .testTarget(name: "LoopEngineTests", dependencies: ["LoopEngine"]),
    ]
)
