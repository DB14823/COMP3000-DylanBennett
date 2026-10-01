// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OrefAdapter",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "OrefAdapter", targets: ["OrefAdapter"])],
    dependencies: [
        .package(path: "../Domain"),
    ],
    targets: [
        .target(name: "OrefAdapter", dependencies: ["Domain"]),
        .testTarget(name: "OrefAdapterTests", dependencies: ["OrefAdapter"]),
    ]
)
