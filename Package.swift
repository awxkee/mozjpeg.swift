// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mozjpeg.swift",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "mozjpeg.swift",
            targets: ["mozjpeg.swift", "mozjpeg.c"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "mozjpeg.swift",
            dependencies: ["mozjpeg.c"]),
        .target(
            name: "mozjpeg.c",
            dependencies: [],
            path: "Sources/mozjpeg.c",
            sources: [
                "jcapimin.c",
                "jcapistd.c",
                "jccoefct.c",
                "jccolor.c",
                "jcdctmgr.c",
                "jcext.c",
                "jchuff.c",
                "jcinit.c",
                "jcmainct.c",
                "jcmarker.c",
                "jcmaster.c",
                "jcomapi.c",
                "jcparam.c",
                "jcphuff.c",
                "jcprepct.c",
                "jcsample.c",
                "jctrans.c",
                "jdapimin.c",
                "jdapistd.c",
                "jdatadst.c",
                "jdatasrc.c",
                "jdcoefct.c",
                "jdcolor.c",
                "jddctmgr.c",
                "jdhuff.c",
                "jdinput.c",
                "jdmainct.c",
                "jdmarker.c",
                "jdmaster.c",
                "jdmerge.c",
                "jdphuff.c",
                "jdpostct.c",
                "jdsample.c",
                "jdtrans.c",
                "jerror.c",
                "jfdctflt.c",
                "jfdctfst.c",
                "jfdctint.c",
                "jidctflt.c",
                "jidctfst.c",
                "jidctint.c",
                "jidctred.c",
                "jquant1.c",
                "jquant2.c",
                "jutils.c",
                "jmemmgr.c",
                "jaricom.c",
                "jcarith.c",
                "jdarith.c",
                "transupp.c",
                "jmemnobs.c",
                "jsimd_none.c",
                "jerror.h",
                "jinclude.h",
                "jconfig.h",
                "jmorecfg.h",
                "jpeglib.h",
                "jpegint.h",
                "transupp.h",
                "bmp.h",
                "cderror.h",
                "cdjpeg.h",
                "jchuff.h",
                "jcmaster.h",
                "jconfigint.h",
                "jdcoefct.h",
                "jdct.h",
                "jdhuff.h",
                "jdmainct.h",
                "jdmaster.h",
                "jdsample.h",
                "jmemsys.h",
                "jpeg_nbits_table.h",
                "jpegcomp.h",
                "jsimd.h",
                "jsimddct.h",
                "jversion.h",
                "wrppm.h",
                "transupp.h",
                "MozjpegBinding.m"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("."),
            ]),
        .testTarget(
            name: "mozjpeg.swiftTests",
            dependencies: ["mozjpeg.swift"]),
    ]
)
