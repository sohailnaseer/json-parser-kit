// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "JsonParserKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "JsonParserKit",
            targets: ["JsonParserKit"]
        ),
        .executable(
            name: "BasicExample",
            targets: ["BasicExample"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0"),
    ],
    targets: [
        .target(
            name: "JsonParserKitCore",
            dependencies: []
        ),
        
        .macro(
            name: "JsonParserKitMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                "JsonParserKitCore"
            ]
        ),
        
        .target(
            name: "JsonParserKit",
            dependencies: [
                "JsonParserKitMacros",
                "JsonParserKitCore"
            ]
        ),
        
        .executableTarget(
            name: "BasicExample",
            dependencies: ["JsonParserKit"],
            path: "Examples"
        ),
        
        .testTarget(
            name: "JsonParserKitTests",
            dependencies: [
                "JsonParserKit",
                "JsonParserKitMacros",
                "JsonParserKitCore"
            ]
        ),
    ]
)
