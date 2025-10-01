// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TTSKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .visionOS(.v1),
        .watchOS(.v9),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TTSKit",
            targets: ["TTSKit"]
        ),
        .library(
            name: "TTSVoice",
            targets: ["TTSVoice"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TTSKit",
            dependencies: ["FliteWrapper"],
        ),
        .target(
            name: "FliteWrapper",
            dependencies: ["Flite"],
        ),
        .target(
            name: "Flite",
            exclude: [
                "lang/cmulex/cmu_lex_data_raw.c",
                "lang/cmulex/cmu_lex_entries_huff_table.c",
                "lang/cmulex/cmu_lex_phones_huff_table.c",
                "lang/cmulex/cmu_lex_num_bytes.c"
            ],
            cSettings: [
                .headerSearchPath("lang/usenglish"),
                .headerSearchPath("lang/cmulex"),
            ]
        ),
        .target(
            name: "TTSVoice",
            path: "Voices/TTSVoice",
            resources: [.copy("cmu_us_clb.flitevox")]
        ),
        .testTarget(
            name: "TTSKitTests",
            dependencies: ["TTSKit", "TTSVoice", "FliteWrapper"]
        ),
    ]
)

