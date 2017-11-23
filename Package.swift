// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Archit",
    dependencies: [
        .package(url: "https://github.com/alexruperez/XcodeGen.git", .branch("master"))
    ]
)