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
    dependencies: [
        .package(
            name:"RevoFoundation", 
            url: "https://github.com/revosystems/foundation", .upToMinor(from: "0.3.1")
        ),
    ],
    targets: [
        .target(
            name: "RevoHttp",
            dependencies: ["RevoFoundation"],
            path: "RevoHttp/src"
        ),
        .testTarget(
            name: "RevoHttpTests",
            dependencies: ["RevoHttp"]
        ),
    ]
)
