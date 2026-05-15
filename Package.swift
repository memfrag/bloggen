// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "bloggen",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "bloggen", targets: ["bloggen"]),
        .library(name: "bloggenKit", targets: ["bloggenKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.7.1"),
        .package(url: "https://github.com/apparata/SystemKit", exact: "1.8.1"),
        .package(url: "https://github.com/apparata/CollectionKit", exact: "1.1.1"),
        .package(url: "https://github.com/apparata/TemplateKit", exact: "0.7.3"),
        .package(url: "https://github.com/apparata/TextToolbox", exact: "1.4.0"),
        .package(url: "https://github.com/apparata/Markin.git", exact: "1.0.2"),
    ],
    targets: [
        .executableTarget(name: "bloggen", dependencies: [
            "bloggenKit",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "SystemKit"
        ]),
        .target(name: "bloggenKit", dependencies: [
            "Markin",
            "SystemKit",
            "TemplateKit",
            "CollectionKit",
            "TextToolbox"
        ])
    ]
)
