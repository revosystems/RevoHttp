// swift-tools-version:5.5
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
    targets: [
        .target(
            name: "RevoHttp"
        ),
        .testTarget(
            name: "RevoHttpTests",
            dependencies: ["RevoHttp"]
        ),
    ]
)
