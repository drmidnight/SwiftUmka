// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

let package = Package(
    name: "Umka",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Umka",
            targets: ["Umka"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Umka",
            dependencies: ["CUmka"]
        ),
        
        .target(name: "CUmka", exclude: [], sources: sources, publicHeadersPath: "umka-lang/src", cSettings: []),
        .testTarget(
            name: "UmkaTests",
            dependencies: ["Umka"]),
    ]
)


var sources: [String] {
    let fileManager = FileManager.default
    let srcDir = URL(string:"\(fileManager.currentDirectoryPath)/Sources/CUmka/umka-lang/src/")!

    do {
        var sources: [String] = []
        let fileURLs = try fileManager.contentsOfDirectory(at: srcDir, includingPropertiesForKeys: nil)
        for file in fileURLs {
            if file.path.contains(".c") {
                sources.append("umka-lang/src/\(file.lastPathComponent)")
            } else {
                continue
            }
        }
        return sources
    } catch {
        print("Error while enumerating files \(srcDir.path): \(error.localizedDescription)")
        return []
    }

}
