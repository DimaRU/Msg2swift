// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "Msg2swift",
    products: [
        .executable(name: "msg2swift", targets: ["Msg2swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Msg2swift",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
