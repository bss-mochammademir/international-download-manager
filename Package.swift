// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IntDM",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "IntDM", targets: ["IntDM"])
    ],
    dependencies: [
        // Add dependencies here as needed
    ],
    targets: [
        .executableTarget(
            name: "IntDM",
            dependencies: [],
            path: "IntDM",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "IntDMTests",
            dependencies: ["IntDM"],
            path: "IntDMTests"
        )
    ]
)
