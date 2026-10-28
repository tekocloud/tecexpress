// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "tecexpress",
    platforms: [.macOS("10.15")],
    products: [
        .library(name: "tecexpress", targets: ["tecexpress"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "tecexpress",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
