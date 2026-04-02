// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Wandr",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Wandr",
            targets: ["Wandr"]
        )
    ],
    targets: [
        .target(
            name: "Wandr",
            path: "Sources"
        )
    ]
)
