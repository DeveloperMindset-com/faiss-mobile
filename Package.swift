// swift-tools-version:5.5
import PackageDescription

let version = "1.7.4"
let checksum = "85526c0384812d1b3c113dabb67ee779afe9b5225a9a57fbe936298a610b6f86"
let checksum_c = "85526c0384812d1b3c113dabb67ee779afe9b5225a9a57fbe936298a610b6f86"
 
let package = Package(
    name: "FAISS",
    platforms: [
        .macOS(.v13_3), .iOS(.v13), .watchOS(.v6_0), .tvOS(.v6_0)
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
            url: "https://github.com/eugenehp/faiss-mobile/releases/download/v\(version)/faiss.xcframework.zip"
            checksum: checksum
        ),
        .binaryTarget(
            name: "FAISS_C",
            url: "https://github.com/eugenehp/faiss-mobile/releases/download/v\(version)/faiss_c.xcframework.zip"
            checksum: checksum_c
        )
    ]
)