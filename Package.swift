// swift-tools-version:5.5
import PackageDescription

let version = "1.7.4"
let checksum = "6b67724ba59798c3b1f51c7c2293b56b5a14c6c3a342eeee763891a45ce32169"
 
let package = Package(
    name: "FAISS",
    platforms: [
        .macOS(.v13_3), .iOS(.v13), .watchOS(.v6_0), .tvOS(.v6_0)
    ],
    products: [
        .library(
            name: "FAISS",
            targets: ["FAISS"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "FAISS",
            url: "https://github.com/eugenehp/faiss-mobile/releases/download/v\(version)/faiss.xcframework.zip"
            checksum: checksum
        )
    ]
)