// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "ProjectDescription",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "ProjectDescription",
            type: .dynamic,
            targets: ["ProjectDescription"]
        ),
        .library(
            name: "ProjectDescriptionStatic",
            type: .static,
            targets: ["ProjectDescription"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3"),
    ],
    targets: [
        .target(
            name: "ProjectDescription",
            dependencies: [],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
            ]
        ),
    ]
)
