// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EditableEquationKit",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EditableEquationCore",
            targets: ["EditableEquationCore"]),
        .library(
            name: "EditableEquationKit",
            targets: ["EditableEquationKit", "EditableEquationCore"]),
        .library(
            name: "EditableEquationUI",
            targets: ["EditableEquationUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/alexandrehsaad/swift-rationals.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EditableEquationCore",
            dependencies: [
                .product(name: "Rationals", package: "swift-rationals")
            ]),
        .target(
            name: "EditableEquationKit",
            dependencies: ["EditableEquationCore"]),
        .target(
            name: "EditableEquationUI",
            dependencies: ["EditableEquationKit", "EditableEquationCore"]),
        .testTarget(
            name: "EditableEquationKitTests",
            dependencies: ["EditableEquationKit"])
    ]
)
