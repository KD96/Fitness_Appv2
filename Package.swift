// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fitness_Appv2",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Fitness_Appv2",
            targets: ["Fitness_Appv2"]
        ),
    ],
    dependencies: [
        // Supabase Swift SDK
        .package(
            url: "https://github.com/supabase/supabase-swift",
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "Fitness_Appv2",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "Fitness_Appv2"
        ),
        .testTarget(
            name: "Fitness_Appv2Tests",
            dependencies: [
                "Fitness_Appv2",
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "Fitness_Appv2Tests"
        ),
    ]
) 