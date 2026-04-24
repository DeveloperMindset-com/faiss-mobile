// swift-tools-version:5.9
import PackageDescription

let version = "1.14.1"
// checksums are updated automatically by ./faiss.sh build
let checksum = "0000000000000000000000000000000000000000000000000000000000000000"
let checksum_c = "0000000000000000000000000000000000000000000000000000000000000000"

let package = Package(
    name: "FAISS",
    platforms: [
        .macOS(.v13),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "FAISS",
            targets: ["FAISS"]),
        .library(
            name: "FAISS_C",
            targets: ["FAISS_C"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "FAISS",
            url: "https://github.com/DeveloperMindset-com/faiss-mobile/releases/download/v\(version)/faiss.xcframework.zip",
            checksum: checksum
        ),
        .binaryTarget(
            name: "FAISS_C",
            url: "https://github.com/DeveloperMindset-com/faiss-mobile/releases/download/v\(version)/faiss_c.xcframework.zip",
            checksum: checksum_c
        )
    ]
)