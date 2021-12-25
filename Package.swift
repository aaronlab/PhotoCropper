// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "PhotoCropper",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "PhotoCropper", targets: ["PhotoCropper"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/devxoul/Then.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "PhotoCropper",
            dependencies: ["RxSwift", "RxCocoa", "RxGesture", "SnapKit", "Then"],
            path: "PhotoCropper/Classes"
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
