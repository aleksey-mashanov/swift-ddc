import ArgumentParser
import DDC
import Foundation

struct DDCCtl: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "ddc",
		abstract: "Configures display settings over a DDC interface.",
		subcommands: [ListDisplays.self, Capabilities.self, ListVCPFeatures.self, GetVCPFeature.self, SetVCPFeature.self]
	)

	static var vcpCodeSequence: [(String, DDC.VCPCode)] = {
		let vcpCodeRegex = try! NSRegularExpression(pattern: "[^\\w]+", options: [])
		return DDC.VCPCode.allCases.map {
			let str = String(describing: $0).lowercased()
			let name = vcpCodeRegex.stringByReplacingMatches(in: str, range: NSRange(location: 0, length: str.count), withTemplate: "-")
			return (name, $0)
		} + [("brightness", DDC.VCPCode.brightness)]
	}()

	static var vcpCodes = [String: DDC.VCPCode](uniqueKeysWithValues: vcpCodeSequence)
	static var vcpCodeNames = vcpCodeSequence.map { $0.0 }
	static var vcpNames = [DDC.VCPCode: [String]](vcpCodeSequence.map { ($0.1, [$0.0]) }, uniquingKeysWith: { $0 + $1 })

	static func forEachDisplay(action: (Int, io_service_t) throws -> Void) throws {
		var iterator = io_iterator_t()
		guard IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("AppleDisplay"), &iterator) == kIOReturnSuccess else {
			throw Error.ioServiceGetMatchingServices
		}
		defer { IOObjectRelease(iterator) }
		var i = 0
		while case let service = IOIteratorNext(iterator), service != 0 {
			i += 1
			try action(i, service)
			IOObjectRelease(service)
		}
	}
	
	static func execute<T>(display: Int, action: (DDC, @escaping (Result<T, Swift.Error>) -> Void) throws -> Void) throws -> T {
		var result = Result<T, Swift.Error>.failure(Error.displayNotFound)
		let sem = DispatchSemaphore(value: 0)
		try DDCCtl.forEachDisplay {
			guard $0 == display else {
				return
			}
			let ddc = try DDC.init(display: $1)
			try action(ddc) {
				result = $0
				sem.signal()
			}
			withExtendedLifetime(ddc) {
				sem.wait()
			}
		}
		return try result.get()
	}
	
	struct Common: ParsableArguments {
		@Option(help: "A display number returned by the list-display subcommand.")
		var display: Int = 1
	}

	struct Feature: ParsableArguments {
		@Argument(help: ArgumentHelp("A VCP code.", discussion: """
			A list of VCP codes supported by the display can be retrieved by the list-vcp-features subcommand. \
			The VCP codes defined by the MCCS 2.2a standard are: \(DDCCtl.vcpCodeNames.joined(separator: ", ")).
			"""))
		var code: DDC.VCPCode
	}
	
	struct ListDisplays: ParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Lists connected displays.")

		func run() throws {
			try DDCCtl.forEachDisplay {
				print("\($0): \(Self.getDisplayName($1) ?? "Unknown")")
			}
		}

		static func getDisplayName(_ display: io_service_t) -> String? {
			let info = IODisplayCreateInfoDictionary(display, IOOptionBits(kIODisplayOnlyPreferredName)).takeRetainedValue() as NSDictionary
			return (info[kDisplayProductName] as? NSDictionary)?.allValues.first.flatMap { $0 as? String }
		}
	}

	struct Capabilities: ParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Executes the Capabilities DDC/CI command.")

		@OptionGroup var common: Common

		@Flag(help: "Print a capability string returned by the display as is.")
		var raw = false

		func run() throws {
			let capabilities = try DDCCtl.execute(display: common.display) {
				$0.capabilities(completion: $1)
			}
			if raw {
				print(capabilities)
			} else {
				let caps = try DDC.Capabilities(capabilities)
				print("prot: \(caps.prot)")
				print("type: \(caps.type)")
				print("model: \(caps.model)")
				print("cmds:")
				for cmd in caps.cmds {
					print("  \(cmd)")
				}
				print("vcp:")
				for vcp in caps.vcp {
					print("  \(vcp.code)\(vcp.values.isEmpty ? "" : " [\(vcp.values.map { String(format: "%02X", $0) }.joined(separator: " "))]")")
				}
			}
		}
	}

	struct ListVCPFeatures: ParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Lists VCP codes supported by the display.")

		@OptionGroup var common: Common

		func run() throws {
			let capabilities = try DDCCtl.execute(display: common.display) {
				$0.capabilities(completion: $1)
			}
			let caps = try DDC.Capabilities(capabilities)
			for vcp in caps.vcp {
				if let names = DDCCtl.vcpNames[vcp.code] {
					print(
						names.joined(separator: " || "),
						vcp.values.isEmpty ? "" : "[\(vcp.values.map { String(format: "%02X", $0) }.joined(separator: " "))]"
					)
				}
			}
		}
	}

	struct GetVCPFeature: ParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Executes the Get VCP Feature DDC/CI command.")

		@OptionGroup var common: Common
		@OptionGroup var feature: Feature

		@Flag(help: "Print a current value only.")
		var quiet = false

		func run() throws {
			let result = try DDCCtl.execute(display: common.display) {
				$0.getVCPFeature(feature.code, completion: $1)
			}
			if quiet {
				print(result.present)
			} else {
				print("\(feature.code) = \(result.present)\(feature.code.function == .continuous ? " / \(result.maximum)" : "")")
			}
		}
	}

	struct SetVCPFeature: ParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Executes the Set VCP Feature DDC/CI command.")

		@OptionGroup var common: Common
		@OptionGroup var feature: Feature

		@Argument(help: "A new value.")
		var value: UInt16

		func run() throws {
			try DDCCtl.execute(display: common.display) {
				$0.setVCPFeature(feature.code, to: value, completion: $1)
			}
		}
	}

	enum Error: Swift.Error, CustomStringConvertible {
		case ioServiceGetMatchingServices
		case displayNotFound
		
		var description: String {
			switch self {
			case .ioServiceGetMatchingServices: return "IOServiceGetMatchingServices failed"
			case .displayNotFound: return "Display not found"
			}
		}
	}
}

extension DDC.VCPCode: ExpressibleByArgument {
	public init?(argument: String) {
		guard let code = DDCCtl.vcpCodes[argument] else {
			return nil
		}
		self = code
	}
	public static var allValueStrings: [String] {
		DDCCtl.vcpCodeNames
	}
	
	public static var defaultCompletionKind: CompletionKind {
		.list(allValueStrings)
	}
}

DDCCtl.main()
