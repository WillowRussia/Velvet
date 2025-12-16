// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VelvetUI",
    products: [
        .library(
            name: "VelvetUI",
            targets: ["VelvetUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "VelvetUI",
            dependencies: [
                    .product(name: "Markdown", package: "swift-markdown"),
                ]),
        .testTarget(
            name: "VelvetUITests",
            dependencies: ["VelvetUI"]
        ),
    ]
)
