// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "NTNULectures",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-postgresql", from: "1.0.0"),
        
        
        .package(url: "https://github.com/vapor/url-encoded-form.git", from: "1.0.0"),
        
        // Adding more complex query commands
        .package(url: "https://github.com/MihaelIsaev/FluentQuery.git", from: "0.4.30")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentQuery", "URLEncodedForm", "FluentPostgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

