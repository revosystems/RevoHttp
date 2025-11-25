// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "RevoHttp",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "RevoHttp",
            targets: ["RevoHttp"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/revosystems/foundation", .upToNextMinor(from: "0.3.1")
        ),
    ],
    targets: [
        .target(
            name: "RevoHttp",
            dependencies: ["foundation"]
        ),
        .testTarget(
            name: "RevoHttpTests",
            dependencies: ["RevoHttp"]
        ),
    ]
)
