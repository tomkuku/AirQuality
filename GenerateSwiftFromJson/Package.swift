// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
    name: "GenerateSwiftFromJson",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.14.0"),
        .package(url: "https://github.com/SwiftGen/StencilSwiftKit.git", from: "2.9.0")
    ],
    targets: [
        .executableTarget(
            name: "GenerateSwiftFromJson",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Stencil", package: "Stencil"),
                .product(name: "StencilSwiftKit", package: "StencilSwiftKit")
            ],
            path: "Sources/GenerateSwiftFromJson"
        )
    ]
)
