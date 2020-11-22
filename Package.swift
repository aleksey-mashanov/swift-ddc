// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "swift-ddc",
	products: [
		.library(name: "DDC", targets: ["DDC"]),
		.executable(name: "ddc", targets: ["ddcctl"]),
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.0")),
	],
	targets: [
		.target(name: "DDC"),
		.target(name: "ddcctl", dependencies: [
			.target(name: "DDC"),
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
		]),
	]
)
