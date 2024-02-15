// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "msg2swift",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "msg2swift", targets: ["msg2swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/DimaRU/PackageBuildInfo", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "msg2swift",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            plugins: [
                .plugin(name: "PackageBuildInfoPlugin", package: "PackageBuildInfo")
            ]
        ),
        .testTarget(
            name: "msg2swiftTests",
            dependencies: ["msg2swift"],
            resources: [
                .copy("Resource/BatteryState.msg"),
                .copy("Resource/CameraInfo.msg"),
            ]
        ),
    ]
)
