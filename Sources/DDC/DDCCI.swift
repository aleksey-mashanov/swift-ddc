// DDC/CI 1.1

import Dispatch

extension DDC {
	enum VCPType: UInt8 {
		case set = 0x00
		case momentary = 0x01
	}

	enum GetVCPFeatureResultCode: UInt8 {
		case noError = 0x00
		case unsupportedVCPCode = 0x01
	}

	public struct VCPFeatureReply {
		let code: VCPCode
		let type: VCPType
		let maximum: UInt16
		let present: UInt16
	}

	public func getVCPFeature(_ code: VCPCode, completion: @escaping (Result<VCPFeatureReply, Error>) -> Void) {
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
			0x01, // Get VCP Feature command
			code.rawValue, // VCP opcode
		])
	}

	public func setVCPFeature(_ code: VCPCode, to value: UInt16, completion: @escaping (Result<Void, Error>) -> Void) {
		enqueue(interval: DispatchTimeInterval.milliseconds(50)) {
			completion(Result { try self.sendSetVCPFeature(code, to: value) })
		}
	}

	func recvGetVCPFeature() throws -> VCPFeatureReply {
		let reply = try recvDDCCIResponse(to: 0x6F, from: 0x6E, length: 8)

		guard reply[0] == 0x02 else {
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

		return VCPFeatureReply(
			code: code,
			type: type,
			maximum: UInt16(reply[4]) << 8 | UInt16(reply[5]),
			present: UInt16(reply[6]) << 8 | UInt16(reply[7])
		)
	}

	func sendSetVCPFeature(_ code: VCPCode, to value: UInt16) throws {
		try sendDDCCIRequest(to: 0x6E, from: 0x51, data: [
			0x03, // Set VCP Feature command
			code.rawValue, // VCP opcode
			UInt8(value >> 8), // High byte
			UInt8(value & 0xFF), // Low byte
		])
	}

	func sendDDCCIRequest(to dest: UInt8, from src: UInt8, data: [UInt8]) throws {
		try sendRequest(to: dest, data: [src, 0x80 | UInt8(data.count)] + data + [data.reduce(dest) { $0 ^ $1 }])
	}

	func recvDDCCIResponse(to dest: UInt8, from src: UInt8, length: Int) throws -> [UInt8] {
		let buffer = try recvResponse(to: dest, length: length + 3)

		guard buffer[1] == 0x80 | UInt8(length) else {
			throw DDCCIError.invalidLength
		}
		guard buffer.dropLast().reduce(0x50, { $0 ^ $1 }) == buffer.last! else {
			throw DDCCIError.checksumMismatch
		}
		guard buffer[0] == src else {
			throw DDCCIError.unexpectedSource
		}

		return [UInt8](buffer[2 ..< buffer.endIndex - 1])
	}
}

enum DDCCIError: Error, CustomStringConvertible {
	case invalidLength
	case checksumMismatch
	case unexpectedSource
	case unexpectedCommand
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
		case .unknownData:
			return "DDC/CI reply contains unknown enumeration values"
		case .getVCPFeatureFailed(let result):
			return "DDC/CI command GetVCPFeature failed: \(result)"
		case .unexpectedVCPCode:
			return "Received GetVCPFeature reply with unexpected VCP Code"
		}
	}
}
