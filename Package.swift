// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "PureMP3",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "PureMP3",
            targets: ["PureMP3"]
        ),
        .library(
            name: "PureMP3Core",
            targets: ["PureMP3Core"]
        )
    ],
    targets: [
        .executableTarget(
            name: "PureMP3",
            dependencies: ["PureMP3Core"],
            path: "Sources/PureMP3App"
        ),
        .target(
            name: "PureMP3Core",
            path: "Sources/PureMP3Core"
        ),
        .testTarget(
            name: "PureMP3CoreTests",
            dependencies: ["PureMP3Core"],
            path: "Tests/PureMP3CoreTests"
        )
    ]
)
