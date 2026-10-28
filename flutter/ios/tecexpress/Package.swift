// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "tecexpress",
    platforms: [.iOS("13.0")],
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
