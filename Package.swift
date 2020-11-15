// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "swift-ddc",
	products: [
		.library(name: "DDC", targets: ["DDC"]),
	],
	targets: [
		.target(name: "DDC"),
	]
)
