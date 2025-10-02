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
            name: "TTSVoiceLibrary",
            targets: ["TTSVoiceLibrary"]
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
            name: "TTSVoiceLibrary",
            dependencies: ["TTSKit"],
            path: "Voices/TTSVoiceLibrary",
            resources: [
                .copy("cmu_us_aew.flitevox"),
                .copy("cmu_us_awb.flitevox"),
                .copy("cmu_us_axb.flitevox"),
                .copy("cmu_us_aup.flitevox"),
                .copy("cmu_us_bdl.flitevox"),
                .copy("cmu_us_eey.flitevox"),
                .copy("cmu_us_fem.flitevox"),
                .copy("cmu_us_gka.flitevox"),
                .copy("cmu_us_jmk.flitevox"),
                .copy("cmu_us_ksp.flitevox"),
                .copy("cmu_us_ljm.flitevox"),
                .copy("cmu_us_rms.flitevox"),
                .copy("cmu_us_rxr.flitevox"),
                .copy("cmu_us_slt.flitevox")
            ],
        ),
        .testTarget(
            name: "TTSKitTests",
            dependencies: ["TTSKit"]
        ),
        .testTarget(
            name: "FliteWrapperTests",
            dependencies: ["FliteWrapper"]
        ),
        .testTarget(
            name: "TTSVoiceLibraryTests",
            dependencies: ["TTSVoiceLibrary"]
        ),
    ]
)
