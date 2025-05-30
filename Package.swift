// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "RustSPMSDK",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "RustSPMSDK",
            targets: ["RustSPMSDK"]
        ),
    ],
    targets: [
        .target(
            name: "RustSPMSDK",
            dependencies: ["RustSPMSDKC"],
            path: "Sources/RustSPMSDK"
        ),
        .target(
            name: "RustSPMSDKC",
            dependencies: ["RustCore"],
            path: "Sources/RustSPMSDKC",
            publicHeadersPath: "include"
        ),
        .binaryTarget(
            name: "RustCore",
            path: "RustCore.xcframework"
        ),
        .testTarget(
            name: "RustSPMSDKTests",
            dependencies: ["RustSPMSDK"],
            path: "Tests/RustSPMSDKTests"
        ),
    ]
) 