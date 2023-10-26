// swift-tools-version: 5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GenericDataAccess",
    products: [
        .library(
            name: "GenericDataAccess",
            targets: ["GenericDataAccess"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
    ],
    targets: [
        .target(
            name: "GenericDataAccess",
            dependencies: [.product(name: "SQLite", package: "SQLite.swift")]),
        .testTarget(
            name: "GenericDataAccessTests",
            dependencies: ["GenericDataAccess"]),
    ]
)
