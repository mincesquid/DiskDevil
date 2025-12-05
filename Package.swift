// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "MadScientist",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "MadScientist", targets: ["MadScientist"]),
    ],
    targets: [
        .executableTarget(
            name: "MadScientist",
            path: "Models"
        ),
    ]
)
