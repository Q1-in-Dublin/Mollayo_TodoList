// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TodoApp",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "TodoApp", path: "Sources/TodoApp", resources: [.process("Resources")])
    ]
)
