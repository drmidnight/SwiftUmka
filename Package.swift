// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "Umka",
    products: [
        .library(
            name: "Umka",
            targets: ["Umka"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Umka",
            dependencies: ["CUmka"],
            exclude: [ "test.um" ]
        ),
        
        .target(name: "CUmka", exclude: ["umka-lang/src/umka.c"], sources: ["umka-lang/src/"], publicHeadersPath: "umka-lang/src/", cSettings: []),
        .testTarget(
            name: "UmkaTests",
            dependencies: ["Umka"]),
    ]
)

