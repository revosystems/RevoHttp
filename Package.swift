// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "Http",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Http",
            targets: ["Http"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/revosystems/foundation", from: "0.2.22")
    ],
    targets: [
        .target(
            name: "Http",
            dependencies: [
               .product(name: "RevoFoundation", package: "foundation")
            ],
            path: "RevoHttp/src"
        ),
        .testTarget(
            name: "HttpTests",
            dependencies: ["Http"]
        ),
    ]
)
