// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PumpPort",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "PumpPort", targets: ["PumpPort"])],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(name: "PumpPort", dependencies: ["Domain"]),
        .testTarget(name: "PumpPortTests", dependencies: ["PumpPort"]),
    ]
)
