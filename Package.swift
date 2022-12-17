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
        .executableTarget(name: "day.4-1", path: "4-1"),
        .executableTarget(name: "day.5-1", path: "5-1"),
        .executableTarget(name: "day.5-2", path: "5-2"),
        .executableTarget(name: "day.6-1", path: "6-1"),
        .executableTarget(name: "day.7-1", path: "7-1"),
        .executableTarget(name: "day.8-1", path: "8-1"),
        .executableTarget(name: "day.8-2", path: "8-2"),
        .executableTarget(name: "day.9-1", path: "9-1"),
        .executableTarget(name: "day.10-1", path: "10-1"),
        .executableTarget(name: "day.10-2", path: "10-2"),
        .executableTarget(
            name: "day.11-1",
            path: "11-1",
            swiftSettings: [.unsafeFlags(["-enable-bare-slash-regex"])]
        ),
    ]
)
