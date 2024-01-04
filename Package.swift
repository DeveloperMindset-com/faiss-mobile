// swift-tools-version:5.5
import PackageDescription

let version = "1.7.4"
let checksum = "85526c0384812d1b3c113dabb67ee779afe9b5225a9a57fbe936298a610b6f86"
let checksum_c = "581024fc0495a42acf5305d96bb29fc98b6a23a4005ac495b0706a929c41c5a9"
 
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