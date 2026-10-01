// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SimulationKit",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "SimulationKit", targets: ["SimulationKit"])],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../PumpPort"),
    ],
    targets: [
        .target(name: "SimulationKit", dependencies: ["Domain", "PumpPort"]),
        .testTarget(name: "SimulationKitTests", dependencies: ["SimulationKit"]),
    ]
)
