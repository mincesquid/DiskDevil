// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "DiskDevil",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "DiskDevil", targets: ["DiskDevil"]),
    ],
    targets: [
        .executableTarget(
            name: "DiskDevil",
            path: "Models"
        ),
    ]
)
