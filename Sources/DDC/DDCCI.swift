// DDC/CI 1.1

import Dispatch

extension DDC {
	// DDC/CI 1.1 section 12
	/// A VCP command.
	public enum VCPCommand: UInt8, CustomStringConvertible {
		case identificationRequest = 0xF1
		case identificationReply = 0xE1
		case capabilitiesRequest = 0xF3
		case capabilitiesReply = 0xE3
		case displaySelfTestRequest = 0xB1
		case displaySelfTestReply = 0xA1
		case displayTimingRequest = 0x07
		case displayTimingReply = 0x06
		case vcpRequest = 0x01
		case vcpReply = 0x02
		case vcpSet = 0x03
		case vcpReset = 0x09
		case tableReadRequest = 0xE2
		case tableReadReply = 0xE4
		case tableWrite = 0xE7
		case enableApplicationReport = 0xF5
		case saveCurrentSettings = 0x0C

		public var description: String {
			switch self {
			case .identificationRequest: return "Identification request"
			case .identificationReply: return "Identification reply"
			case .capabilitiesRequest: return "Capabilities request"
			case .capabilitiesReply: return "Capabilities reply"
			case .displaySelfTestRequest: return "Display self-test request"
			case .displaySelfTestReply: return "Display self-test reply"
			case .displayTimingRequest: return "Display timing request"
			case .displayTimingReply: return "Display timing reply"
			case .vcpRequest: return "VCP request"
			case .vcpReply: return "VCP reply"
			case .vcpSet: return "VCP set"
			case .vcpReset: return "VCP reset"
			case .tableReadRequest: return "Table read request"
			case .tableReadReply: return "Table read reply"
			case .tableWrite: return "Table write"
			case .enableApplicationReport: return "Enable application report"
			case .saveCurrentSettings: return "Save current settings"
			}
		}
	}

	/// Sends Capabilities requests and receives Capabilities replies until a complete capability string received.
	/// - Parameter completion: A completion callback which will be called when all requests are done.
	public func capabilities(completion: @escaping (Result<String, Error>) -> Void) {
		capabilitiesChunk(prefix: []) {
			switch $0 {
			case .success(let data):
				let end = data.firstIndex(of: 0) ?? data.endIndex
				completion(.success(String(decoding: data[0..<end], as: UTF8.self)))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	func capabilitiesChunk(prefix: [UInt8], completion: @escaping (Result<[UInt8], Error>) -> Void) {
		enqueue(interval: DispatchTimeInterval.milliseconds(40)) {
			do {
				try self.sendCapabilities(offset: UInt16(prefix.count))
				self.enqueue(interval: DispatchTimeInterval.milliseconds(50), first: true) {
					do {
						let (offset, data) = try self.recvCapabilities()
						guard offset == prefix.count else {
							throw DDCCIError.unexpectedOffset
						}
						if data.isEmpty {
							completion(.success(prefix + data))
						} else {
							self.capabilitiesChunk(prefix: prefix + data, completion: completion)
						}
					} catch {
						completion(.failure(error))
					}
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	func sendCapabilities(offset: UInt16) throws {
		try sendDDCCIRequest(to: 0x6E, from: 0x51, data: [
			VCPCommand.capabilitiesRequest.rawValue, // Capabilities command
			UInt8(offset >> 8), // High byte
			UInt8(offset & 0xFF), // Low byte
		])
	}
	
	func recvCapabilities() throws -> (UInt16, [UInt8]) {
		let reply = try recvDDCCIResponse(to: 0x6F, from: 0x6E, length: 3...35)
		guard reply[0] == VCPCommand.capabilitiesReply.rawValue else {
			throw DDCCIError.unexpectedCommand
		}
		return (UInt16(reply[1]) << 8 | UInt16(reply[2]), [UInt8](reply[3...]))
	}

	// DDC/CI 1.1 section 4.3
	enum GetVCPFeatureResultCode: UInt8, CustomStringConvertible {
		case noError = 0x00
		case unsupportedVCPCode = 0x01
		
		var description: String {
			switch self {
			case .noError: return "No error"
			case .unsupportedVCPCode: return "Unsupported VCP code"
			}
		}
	}

	// DDC/CI 1.1 section 4.3
	/// A VCP type.
	public enum VCPType: UInt8 {
		case set = 0x00
		case momentary = 0x01
	}

	// DDC/CI 1.1 section 4.3
	/// A reply of successful Get VCP Feature request.
	public struct VCPReply {
		public let code: VCPCode
		public let type: VCPType
		public let maximum: UInt16
		public let present: UInt16
	}

	// DDC/CI 1.1 section 4.3
	/// Sends Get VCP Feature request and receives reply.
	/// - Parameters:
	///   - code: A VCP Code of the feature.
	///   - completion: A completion callback which will be called when the request is done.
	public func getVCPFeature(_ code: VCPCode, completion: @escaping (Result<VCPReply, Error>) -> Void) {
		enqueue(interval: DispatchTimeInterval.milliseconds(40)) {
			do {
				try self.sendGetVCPFeature(code)
				self.enqueue(interval: DispatchTimeInterval.milliseconds(0), first: true) {
					completion(Result {
						let reply = try self.recvGetVCPFeature()
						guard reply.code == code else {
							throw DDCCIError.unexpectedVCPCode
						}
						return reply
					})
				}
			} catch {
				completion(Result.failure(error))
			}
		}
	}

	func sendGetVCPFeature(_ code: VCPCode) throws {
		try sendDDCCIRequest(to: 0x6E, from: 0x51, data: [
			VCPCommand.vcpRequest.rawValue, // Get VCP Feature command
			code.rawValue, // VCP opcode
		])
	}
	
	func recvGetVCPFeature() throws -> VCPReply {
		let reply = try recvDDCCIResponse(to: 0x6F, from: 0x6E, length: 8...8)

		guard reply[0] == VCPCommand.vcpReply.rawValue else {
			throw DDCCIError.unexpectedCommand
		}
		guard
			let result = GetVCPFeatureResultCode(rawValue: reply[1]),
			let code = VCPCode(rawValue: reply[2]),
			let type = VCPType(rawValue: reply[3])
		else {
			throw DDCCIError.unknownData
		}
		guard result == .noError else {
			throw DDCCIError.getVCPFeatureFailed(result)
		}

		return VCPReply(
			code: code,
			type: type,
			maximum: UInt16(reply[4]) << 8 | UInt16(reply[5]),
			present: UInt16(reply[6]) << 8 | UInt16(reply[7])
		)
	}

	// DDC/CI 1.1 section 4.4
	/// Sends Set VCP Feature command.
	/// - Parameters:
	///   - code: A VCP Code of the feature.
	///   - value: A new value.
	///   - completion: A completion callback which will be called when the request is done.
	public func setVCPFeature(_ code: VCPCode, to value: UInt16, completion: @escaping (Result<Void, Error>) -> Void) {
		enqueue(interval: DispatchTimeInterval.milliseconds(50)) {
			completion(Result { try self.sendSetVCPFeature(code, to: value) })
		}
	}

	func sendSetVCPFeature(_ code: VCPCode, to value: UInt16) throws {
		try sendDDCCIRequest(to: 0x6E, from: 0x51, data: [
			VCPCommand.vcpSet.rawValue, // Set VCP Feature command
			code.rawValue, // VCP opcode
			UInt8(value >> 8), // High byte
			UInt8(value & 0xFF), // Low byte
		])
	}

	func sendDDCCIRequest(to dest: UInt8, from src: UInt8, data: [UInt8]) throws {
		try sendRequest(to: dest, data: [src, 0x80 | UInt8(data.count)] + data + [data.reduce(dest) { $0 ^ $1 }])
	}

	func recvDDCCIResponse(to dest: UInt8, from src: UInt8, length: ClosedRange<Int>) throws -> [UInt8] {
		let buffer = try recvResponse(to: dest, length: length.upperBound + 3)

		let len = Int(buffer[1] & ~0x80)
		guard length.contains(len) else {
			throw DDCCIError.invalidLength
		}
		let data = buffer[0 ..< len + 3]
		guard data.dropLast().reduce(0x50, { $0 ^ $1 }) == data.last! else {
			throw DDCCIError.checksumMismatch
		}
		guard data[0] == src else {
			throw DDCCIError.unexpectedSource
		}

		return [UInt8](data[2 ..< data.endIndex - 1])
	}
}

enum DDCCIError: Error, CustomStringConvertible {
	case invalidLength
	case checksumMismatch
	case unexpectedSource
	case unexpectedCommand
	case unexpectedOffset
	case unknownData
	case getVCPFeatureFailed(DDC.GetVCPFeatureResultCode)
	case unexpectedVCPCode

	var description: String {
		switch self {
		case .invalidLength:
			return "Invalid DDC/CI reply length"
		case .checksumMismatch:
			return "DDC/CI reply checksum mismatch"
		case .unexpectedSource:
			return "DDC/CI reply from unexpected source"
		case .unexpectedCommand:
			return "DDC/CI reply with unexpected command"
		case .unexpectedOffset:
			return "Received Capabilities reply with unexpected offset"
		case .unknownData:
			return "DDC/CI reply contains unknown enumeration values"
		case .getVCPFeatureFailed(let result):
			return "DDC/CI command GetVCPFeature failed: \(result)"
		case .unexpectedVCPCode:
			return "Received GetVCPFeature reply with unexpected VCP Code"
		}
	}
}
