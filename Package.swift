// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "renderrer",
    dependencies:[
    .package(url: "git@github.com:Santhosh-KS/CSDL2.git", branch: "master")
    ],
    targets: [
        .executableTarget(
            name: "renderrer",
            dependencies: [.product(name: "CSDL", package: "CSDL2")],
            path: "Sources"),
    ]
)
