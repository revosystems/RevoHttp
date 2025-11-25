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
            dependencies: [
                .product(name: "RevoFoundation", package: "foundation")
            ],
            swiftSettings: [
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_FORWARD_TRAILING_CLOSURES"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_DYNAMIC_ACTOR_ISOLATION"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_GLOBAL_ACTOR_ISOLATED_TYPES_USABILITY"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_GLOBAL_CONCURRENCY"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_IMPLICIT_OPEN_EXISTENTIALS"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_IMPORT_OBJC_FORWARD_DECLS"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_ISOLATED_DEFAULT_VALUES"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_NONFROZEN_ENUM_EXHAUSTIVITY"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_NONISOLATED_NONSENDING_BY_DEFAULT"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_REGION_BASED_ISOLATION"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_DISABLE_OUTWARD_ACTOR_ISOLATION"),
                .enableUpcomingFeature("SWIFT_ENABLE_BARE_SLASH_REGEX"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_CONCISE_MAGIC_FILE"),
                .enableUpcomingFeature("SWIFT_UPCOMING_FEATURE_DEPRECATE_APPLICATION_MAIN"),
                
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "RevoHttpTests",
            dependencies: ["RevoHttp"]
        ),
    ]
)
