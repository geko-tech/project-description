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
