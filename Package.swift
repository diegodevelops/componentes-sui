// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ComponentesSUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "ComponentesSUI",
            targets: ["ComponentesSUI"]
        )
    ],
    dependencies: [
        // Add external dependencies here if needed
        // .package(url: "https://github.com/...", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ComponentesSUI"
        ),
        .testTarget(
            name: "ComponentesSUITests",
            dependencies: ["ComponentesSUI"]
        ),
    ]
)
