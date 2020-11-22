// E-DDC 1.2

import Dispatch
import IOKit.i2c

/// A DDC interface connection.
public final class DDC {
	var connect: IOI2CConnectRef?
	private let queue: Queue
	
	/// Opens a DDC interface.
	/// - Parameters:
	///   - framebuffer: A IOFramebuffer of a display.
	///   - queue: A DispatchQueue to use for asynchronous operations.
	/// - Throws: If failed to open an I2C interface.
	public init(framebuffer: io_service_t, queue: DispatchQueue = DispatchQueue.global(qos: .background)) throws {
		var busCount: IOItemCount = 0
		guard IOFBGetI2CInterfaceCount(framebuffer, &busCount) == kIOReturnSuccess else {
			throw DDCError.ioFBGetI2CInterfaceCount
		}
		guard busCount > 0 else {
			throw DDCError.noI2CInterfacesFound
		}

		var interface = io_service_t()
		guard IOFBCopyI2CInterfaceForBus(framebuffer, 0, &interface) == kIOReturnSuccess else {
			throw DDCError.ioFBCopyI2CInterfaceForBus
		}
		defer { IOObjectRelease(interface) }
		guard IOI2CInterfaceOpen(interface, IOOptionBits(), &connect) == kIOReturnSuccess else {
			throw DDCError.ioI2CInterfaceOpen
		}

		self.queue = Queue(dispatchQueue: queue)
	}

	/// Opens a DDC interface.
	/// - Parameters:
	///   - display: A IODisplay of a dispaly.
	///   - queue: A DispatchQueue to use for asynchronous operations.
	/// - Throws: If failed to open an I2C interface.
	public convenience init(display: io_service_t, queue: DispatchQueue = DispatchQueue.global(qos: .background)) throws {
		var displayConnect: io_service_t = 0
		guard IORegistryEntryGetParentEntry(display, kIOServicePlane, &displayConnect) == kIOReturnSuccess else {
			throw DDCError.ioRegistryEntryGetParentEntry
		}
		defer { IOObjectRelease(displayConnect) }
		var framebuffer: io_service_t = 0
		guard IORegistryEntryGetParentEntry(displayConnect, kIOServicePlane, &framebuffer) == kIOReturnSuccess else {
			throw DDCError.ioRegistryEntryGetParentEntry
		}
		defer { IOObjectRelease(framebuffer) }
		try self.init(framebuffer: framebuffer, queue: queue)
	}

	deinit {
		IOI2CInterfaceClose(connect, IOOptionBits())
	}

	func sendRequest(to dest: UInt8, data: [UInt8]) throws {
		try data.withUnsafeBytes {
			var request = IOI2CRequest()
			request.sendTransactionType = IOOptionBits(kIOI2CSimpleTransactionType)
			request.sendAddress = UInt32(dest)
			request.sendBuffer = vm_address_t(bitPattern: $0.baseAddress)
			request.sendBytes = UInt32($0.count)

			guard IOI2CSendRequest(connect, IOOptionBits(), &request) == kIOReturnSuccess else {
				throw DDCError.ioI2CSendRequest
			}
			guard request.result == kIOReturnSuccess else {
				throw DDCError.transactionFailed(request.result)
			}
		}
	}

	func recvResponse(to dest: UInt8, length: Int) throws -> [UInt8] {
		let data = try [UInt8](unsafeUninitializedCapacity: length) {
			var request = IOI2CRequest()
			request.replyTransactionType = IOOptionBits(kIOI2CSimpleTransactionType)
			request.replyAddress = UInt32(dest)
			request.replyBuffer = vm_address_t(bitPattern: $0.baseAddress)
			request.replyBytes = UInt32($0.count)
			guard IOI2CSendRequest(connect, IOOptionBits(), &request) == kIOReturnSuccess else {
				throw DDCError.ioI2CSendRequest
			}
			guard request.result == kIOReturnSuccess else {
				throw DDCError.transactionFailed(request.result)
			}
			$1 = Int(request.replyBytes)
		}

		guard data.count == length else {
			throw DDCError.unexpectedReplyLength
		}

		return data
	}

	func enqueue(interval: DispatchTimeInterval, first: Bool = false, command: @escaping () -> Void) {
		queue.enqueue(interval: interval, first: first, command: command)
	}

	private class Queue {
		let dispatchQueue: DispatchQueue
		var mutex = DispatchSemaphore(value: 1)
		var queue: [Command] = []
		var active = false

		init(dispatchQueue: DispatchQueue) {
			self.dispatchQueue = dispatchQueue
		}

		func enqueue(interval: DispatchTimeInterval, first: Bool = false, command: @escaping () -> Void) {
			mutex.wait()
			queue.insert(Command(command: command, interval: interval), at: first ? queue.startIndex : queue.endIndex)
			if !active {
				dispatchQueue.async { self.process() }
				active = true
			}
			mutex.signal()
		}

		func process() {
			mutex.wait()
			if queue.isEmpty {
				active = false
				mutex.signal()
				return
			}
			let cmd = queue.removeFirst()
			mutex.signal()
			cmd.command()
			dispatchQueue.asyncAfter(deadline: DispatchTime.now() + cmd.interval) { self.process() }
		}

		struct Command {
			let command: () -> Void
			let interval: DispatchTimeInterval
		}
	}
}

enum DDCError: Error, CustomStringConvertible {
	case ioRegistryEntryGetParentEntry
	case ioFBGetI2CInterfaceCount
	case noI2CInterfacesFound
	case ioFBCopyI2CInterfaceForBus
	case ioI2CInterfaceOpen
	case ioI2CSendRequest
	case transactionFailed(IOReturn)
	case unexpectedReplyLength

	var description: String {
		switch self {
		case .ioRegistryEntryGetParentEntry:
			return "IORegistryEntryGetParentEntry failed"
		case .ioFBGetI2CInterfaceCount:
			return "IOFBGetI2CInterfaceCount failed"
		case .noI2CInterfacesFound:
			return "No I2C interfaces found"
		case .ioFBCopyI2CInterfaceForBus:
			return "IOFBCopyI2CInterfaceForBus failed"
		case .ioI2CInterfaceOpen:
			return "IOI2CInterfaceOpen failed"
		case .ioI2CSendRequest:
			return "IOI2CSendRequest failed"
		case .transactionFailed(let err):
			return "I2C transaction failed: \(String(cString: mach_error_string(err)))"
		case .unexpectedReplyLength:
			return "Received reply of unexpected length"
		}
	}
}
