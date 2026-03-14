// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "msg2swift",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "msg2swift", targets: ["msg2swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "msg2swift",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "msg2swiftTests",
            dependencies: ["msg2swift"],
            resources: [
                .process("Resource"),
            ]
        ),
    ]
)
