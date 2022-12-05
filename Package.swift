// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "AoC-2022",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(name: "day.1", path: "1-1"), 
        .executableTarget(name: "day.2-1", path: "2-1"),
        .executableTarget(name: "day.2-2", path: "2-2"),
        .executableTarget(name: "day.3-1", path: "3-1"),
        .executableTarget(name: "day.3-2", path: "3-2"),
    ]
)
