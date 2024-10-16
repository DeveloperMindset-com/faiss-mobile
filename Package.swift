// swift-tools-version:5.9
import PackageDescription

let version = "1.9.0"
let checksum = "3e115c741526b8a7be1d5f8bf18df40310fa20501aee7fac810b7eda460afa5d"
let checksum_c = "d34248be86d770474d07bc508416f1f034941895079750b43a1477c0bf351dbd"

let package = Package(
    name: "FAISS",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
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