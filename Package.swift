// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mozjpeg",
    platforms: [
        .iOS(.v12),
        .macOS(.v11),
        .macCatalyst(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "mozjpeg",
            targets: ["mozjpeg"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "mozjpeg",
            dependencies: [
                .target(name: "mozjpegc")
            ]),
        .target(
            name: "mozjpegc",
            dependencies: ["libturbojpeg"],
            path: "Sources/mozjpegc",
            sources: [
                "JPEGCompression.mm",
                "MJDecompress.mm",
                "MJEncoder.mm",
                "MozjpegImage.mm"
            ], publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
            ],
            linkerSettings: [.linkedFramework("Accelerate")]),
        .binaryTarget(name: "libturbojpeg", path: "Sources/libturbojpeg.xcframework"),
        .testTarget(
            name: "mozjpeg.swiftTests",
            dependencies: [.target(name: "mozjpeg")]),
    ]
)
