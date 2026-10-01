// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FoodVision",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "FoodVision", targets: ["FoodVision"])],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(name: "FoodVision", dependencies: ["Domain"]),
        .testTarget(name: "FoodVisionTests", dependencies: ["FoodVision"]),
    ]
)
