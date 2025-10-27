// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Oolang",
    products: [
        .executable(name: "ooc", targets: ["Oolang"])
    ],
    targets: [
        .executableTarget(
            name: "Oolang",
            resources: [
                .copy("headers")
            ]
        ),
        .testTarget(
            name: "OolangTests",
            dependencies: ["Oolang"],
            resources: [
                .copy("c-files")
            ]
        ),
    ]
)
