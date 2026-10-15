// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OrefSpike",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "../../../References/Trio/AlgorithmPackage"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "OrefSpike",
            dependencies: [
                .product(name: "Trio", package: "algorithmpackage"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "OrefSpikeTests",
            dependencies: ["OrefSpike"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
