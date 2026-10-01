// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SafetyKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "SafetyKit", targets: ["SafetyKit"])],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../PumpPort"),
    ],
    targets: [
        .target(name: "SafetyKit", dependencies: ["Domain", "PumpPort"]),
        .testTarget(name: "SafetyKitTests", dependencies: ["SafetyKit"]),
    ]
)
