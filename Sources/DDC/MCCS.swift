// MCCS 2.2a

extension DDC {
	/// A VCP code.
	///
	/// For the detailed description of VCP codes see the MCCS 2.2a specification.
	public enum VCPCode: UInt8, CaseIterable, CustomStringConvertible {
		// Preset Operations
		case codePage = 0x00
		case restoreFactoryDefaults = 0x04
		case restoreFactoryLuminanceContrastDefaults = 0x05
		case restoreFactoryGeometryDefaults = 0x06
		case restoreFactoryColorDefaults = 0x08
		case restoreFactoryTVDefaults = 0x0A
		case settings = 0xB0
		
		// Image Adjustment
		case userColorTemperatureIncrement = 0x0B
		case userColorTemperature = 0x0C
		case clock = 0x0E
		case luminance = 0x10
		case fleshToneEnhancement = 0x11
		case contrast = 0x12
		case _backlightControl = 0x13
		case selectColorPreset = 0x14
		case videoGainRed = 0x16
		case userColorVisionCompensation = 0x17
		case videoGainGreen = 0x18
		case videoGainBlue = 0x1A
		case focus = 0x1C
		case autoSetup = 0x1E
		case autoColorSetup = 0x1F
		case grayScaleExpansion = 0x2E
		case clockPhase = 0x3E
		case horizontalMoire = 0x56
		case verticalMoire = 0x58
		case sixAxisSaturationControlRed = 0x59
		case sixAxisSaturationControlYellow = 0x5A
		case sixAxisSaturationControlGreen = 0x5B
		case sixAxisSaturationControlCyan = 0x5C
		case sixAxisSaturationControlBlue = 0x5D
		case sixAxisSaturationControlMagenta = 0x5E
		case backlightLevelWhite = 0x6B
		case videoBlackLevelRed = 0x6C
		case backlightLevelRed = 0x6D
		case videoBlackLevelGreen = 0x6E
		case backlightLevelGreen = 0x6F
		case videoBlackLevelBlue = 0x70
		case backlightLevelBlue = 0x71
		case gamma = 0x72
		case lutSize = 0x73
		case singlePointLUTOperation = 0x74
		case blockLUTOperation = 0x75
		case adjustZoom = 0x7C
		case sharpness = 0x87
		case velocityScanModulation = 0x88
		case colorSaturation = 0x8A
		case tvSharpness = 0x8C
		case tvContrast = 0x8E
		case hue = 0x90
		case tvBlackLevel = 0x92
		case windowBackground = 0x9A
		case sixAxisHueControlRed = 0x9B
		case sixAxisHueControlYellow = 0x9C
		case sixAxisHueControlGreen = 0x9D
		case sixAxisHueControlCyan = 0x9E
		case sixAxisHueControlBlue = 0x9F
		case sixAxisHueControlMagenta = 0xA0
		case autoSetupOnOff = 0xA2
		case windowMaskControl = 0xA4
		case windowSelect = 0xA5
		case windowSize = 0xA6
		case windowTransparency = 0xA7
		case screenOrientation = 0xAA
		case stereoVideoMode = 0xD4
		case displayApplication = 0xDC
		
		// Display Control
		case horizontalFrequency = 0xAC
		case verticalFrequency = 0xAE
		case sourceTimingMode = 0xB4
		case sourceColorCoding = 0xB5
		case displayUsageTime = 0xC0
		case displayControllerID = 0xC8
		case displayFirmwareLevel = 0xC9
		case osdButtonControl = 0xCA
		case osdLanguage = 0xCC
		case powerMode = 0xD6
		case imageMode = 0xDB
		case vcpVersion = 0xDF
		
		// Geometry
		case horizontalPosition = 0x20
		case horizontalSize = 0x22
		case horizontalPincushion = 0x24
		case horizontalPincushionBalance = 0x26
		case horizontalConvergenceRB = 0x28
		case horizontalConvergenceMG = 0x29
		case horizontalLinearity = 0x2A
		case horizontalLinearityBalance = 0x2C
		case verticalPosition = 0x30
		case verticalSize = 0x32
		case verticalPincushion = 0x34
		case verticalPincushionBalance = 0x36
		case verticalConvergenceRB = 0x38
		case verticalConvergenceMG = 0x39
		case verticalLinearity = 0x3A
		case verticalLinearityBalance = 0x3C
		case horizontalParallelogram = 0x40
		case verticalParallelogram = 0x41
		case horizontalKeystone = 0x42
		case verticalKeystone = 0x43
		case rotation = 0x44
		case topCornerFlare = 0x46
		case topCornerHook = 0x48
		case bottomCornerFlare = 0x4A
		case bottomCornerHook = 0x4C
		case horizontalMirror = 0x82
		case verticalMirror = 0x84
		case displayScaling = 0x86
		case windowPositionTopLeftX = 0x95
		case windowPositionTopLeftY = 0x96
		case windowPositionBottomRightX = 0x97
		case windowPositionBottomRightY = 0x98
		case scanMode = 0xDA
		
		// Miscellaneous
		case degauss = 0x01
		case newControlValue = 0x02
		case softControls = 0x03
		case activeControl = 0x52
		case performancePreservation = 0x54
		case inputSelect = 0x60
		case ambientLightSensor = 0x66
		case remoteProcedureCall = 0x76
		case displayIdentificationDataOperation = 0x78
		case tvChannelUpDown = 0x8B
		case flatPanelSubPixelLayout = 0xB2
		case displayTechnologyType = 0xB6
		case displayDescriptorLength = 0xC2
		case transmitDisplayDescriptor = 0xC3
		case enableDisplayOfDisplayDescriptor = 0xC4
		case applicationEnableKey = 0xC6
		case displayEnableKey = 0xC7
		case statusIndicator = 0xCD
		case auxiliaryDisplaySize = 0xCE
		case auxiliaryDisplayData = 0xCF
		case outputSelect = 0xD0
		case assetTag = 0xD2
		case auxiliaryPowerOutput = 0xD7
		case scratchPad = 0xDE
		
		// Audio
		case audioSpeakerVolume = 0x62
		case speakerSelect = 0x63
		case audioMicrophoneVolume = 0x64
		case audioJackConnectionStatus = 0x65
		case audioMuteScreenBlank = 0x8D
		case audioTreble = 0x8F
		case audioBass = 0x91
		case audioBalanceLR = 0x93
		case audioProcessorMode = 0x94
		
		// DPVL
		case monitorStatus = 0xB7
		case packetCount = 0xB8
		case monitorXOrigin = 0xB9
		case monitorYOrigin = 0xBA
		case headerErrorCount = 0xBB
		case bodyCRCErrorCount = 0xBC
		case clientID = 0xBD
		case linkControl = 0xBE
		
		public static let brightness = luminance
		
		public var description: String {
			switch self {
			// Preset Operations
			case .codePage: return "Code Page"
			case .restoreFactoryDefaults: return "Restore Factory Defaults"
			case .restoreFactoryLuminanceContrastDefaults: return "Restore Factory Luminance/Contrast Defaults"
			case .restoreFactoryGeometryDefaults: return "Restore Factory Geometry Defaults"
			case .restoreFactoryColorDefaults: return "Restore Factory Color Defaults"
			case .restoreFactoryTVDefaults: return "Restore Factory TV Defaults"
			case .settings: return "Settings"
				
			// Image Adjustment
			case .userColorTemperatureIncrement: return "User Color Temperature Increment"
			case .userColorTemperature: return "User Color Temperature"
			case .clock: return "Clock"
			case .luminance: return "Luminance"
			case .fleshToneEnhancement: return "Flesh Tone Enhancement"
			case .contrast: return "Contrast"
			case ._backlightControl: return "Backlight Control"
			case .selectColorPreset: return "Select Color Preset"
			case .videoGainRed: return "Video Gain (Drive): Red"
			case .userColorVisionCompensation: return "User Color Vision Compensation"
			case .videoGainGreen: return "Video Gain (Drive): Green"
			case .videoGainBlue: return "Video Gain (Drive): Blue"
			case .focus: return "Focus"
			case .autoSetup: return "Auto Setup"
			case .autoColorSetup: return "Auto Color Setup"
			case .grayScaleExpansion: return "Gray Scale Expansion"
			case .clockPhase: return "Clock Phase"
			case .horizontalMoire: return "Horizontal Moire"
			case .verticalMoire: return "Vertical Moire"
			case .sixAxisSaturationControlRed: return "Six Axis Saturation Control: Red"
			case .sixAxisSaturationControlYellow: return "Six Axis Saturation Control: Yellow"
			case .sixAxisSaturationControlGreen: return "Six Axis Saturation Control: Green"
			case .sixAxisSaturationControlCyan: return "Six Axis Saturation Control: Cyan"
			case .sixAxisSaturationControlBlue: return "Six Axis Saturation Control: Blue"
			case .sixAxisSaturationControlMagenta: return "Six Axis Saturation Control: Magenta"
			case .backlightLevelWhite: return "Backlight Level: White"
			case .videoBlackLevelRed: return "Video Black Level: Red"
			case .backlightLevelRed: return "Backlight Level: Red"
			case .videoBlackLevelGreen: return "Video Black Level: Green"
			case .backlightLevelGreen: return "Backlight Level: Green"
			case .videoBlackLevelBlue: return "Video Black Level: Blue"
			case .backlightLevelBlue: return "Backlight Level: Blue"
			case .gamma: return "Gamma"
			case .lutSize: return "LUT Size"
			case .singlePointLUTOperation: return "Single Point LUT Operation"
			case .blockLUTOperation: return "Block LUT Operation"
			case .adjustZoom: return "Adjust Zoom"
			case .sharpness: return "Sharpness"
			case .velocityScanModulation: return "Velocity Scan Modulation"
			case .colorSaturation: return "Color Saturation"
			case .tvSharpness: return "TV Sharpness"
			case .tvContrast: return "TV Contrast"
			case .hue: return "Hue"
			case .tvBlackLevel: return "TV Black Level"
			case .windowBackground: return "Window Background"
			case .sixAxisHueControlRed: return "Six Axis Hue Control: Red"
			case .sixAxisHueControlYellow: return "Six Axis Hue Control: Yellow"
			case .sixAxisHueControlGreen: return "Six Axis Hue Control: Green"
			case .sixAxisHueControlCyan: return "Six Axis Hue Control: Cyan"
			case .sixAxisHueControlBlue: return "Six Axis Hue Control: Blue"
			case .sixAxisHueControlMagenta: return "Six Axis Hue Control: Magenta"
			case .autoSetupOnOff: return "Auto Setup On/Off"
			case .windowMaskControl: return "Window Mask Control"
			case .windowSelect: return "Window Select"
			case .windowSize: return "Window Size"
			case .windowTransparency: return "Window Transparency"
			case .screenOrientation: return "Screen Orientation"
			case .stereoVideoMode: return "Stereo Video Mode"
			case .displayApplication: return "Display Application"
				
			// Display Control
			case .horizontalFrequency: return "Horizontal Frequency"
			case .verticalFrequency: return "Vertical Frequency"
			case .sourceTimingMode: return "Source Timing Mode"
			case .sourceColorCoding: return "Source Color Coding"
			case .displayUsageTime: return "Display Usage Time"
			case .displayControllerID: return "Display Controller ID"
			case .displayFirmwareLevel: return "Display Firmware Level"
			case .osdButtonControl: return "OSD/Button Control"
			case .osdLanguage: return "OSD Language"
			case .powerMode: return "Power Mode"
			case .imageMode: return "Image Mode"
			case .vcpVersion: return "VCP Version"
				
			// Geometry
			case .horizontalPosition: return "Horizontal Position"
			case .horizontalSize: return "Horizontal Size"
			case .horizontalPincushion: return "Horizontal Pincushion"
			case .horizontalPincushionBalance: return "Horizontal Pincushion Balance"
			case .horizontalConvergenceRB: return "Horizontal Convergence R/B"
			case .horizontalConvergenceMG: return "Horizontal Convergence M/G"
			case .horizontalLinearity: return "Horizontal Linearity"
			case .horizontalLinearityBalance: return "Horizontal Linearity Balance"
			case .verticalPosition: return "Vertical Position"
			case .verticalSize: return "Vertical Size"
			case .verticalPincushion: return "Vertical Pincushion"
			case .verticalPincushionBalance: return "Vertical Pincushion Balance"
			case .verticalConvergenceRB: return "Vertical Convergence R/B"
			case .verticalConvergenceMG: return "Vertical Convergence M/G"
			case .verticalLinearity: return "Vertical Linearity"
			case .verticalLinearityBalance: return "Vertical Linearity Balance"
			case .horizontalParallelogram: return "Horizontal Parallelogram"
			case .verticalParallelogram: return "Vertical Parallelogram"
			case .horizontalKeystone: return "Horizontal Keystone"
			case .verticalKeystone: return "Vertical Keystone"
			case .rotation: return "Rotation"
			case .topCornerFlare: return "Top Corner Flare"
			case .topCornerHook: return "Top Corner Hook"
			case .bottomCornerFlare: return "Bottom Corner Flare"
			case .bottomCornerHook: return "Bottom Corner Hook"
			case .horizontalMirror: return "Horizontal Mirror"
			case .verticalMirror: return "Vertical Mirror"
			case .displayScaling: return "Display Scaling"
			case .windowPositionTopLeftX: return "Window Position Top Left X"
			case .windowPositionTopLeftY: return "Window Position Top Left Y"
			case .windowPositionBottomRightX: return "Window Position Bottom Right X"
			case .windowPositionBottomRightY: return "Window Position Bottom Right Y"
			case .scanMode: return "Scan Mode"
				
			// Miscellaneous
			case .degauss: return "Degauss"
			case .newControlValue: return "New Control Value"
			case .softControls: return "Soft Controls"
			case .activeControl: return "Active Control"
			case .performancePreservation: return "Performance Preservation"
			case .inputSelect: return "Input Select"
			case .ambientLightSensor: return "Ambient Light Sensor"
			case .remoteProcedureCall: return "Remote Procedure Call"
			case .displayIdentificationDataOperation: return "Display Identification Data Operation"
			case .tvChannelUpDown: return "TV Channel Up/Down"
			case .flatPanelSubPixelLayout: return "Flat Panel Sub-Pixel Layout"
			case .displayTechnologyType: return "Display Technology Type"
			case .displayDescriptorLength: return "Display Descriptor Length"
			case .transmitDisplayDescriptor: return "Transmit Display Descriptor"
			case .enableDisplayOfDisplayDescriptor: return "Enable Display Of Display Descriptor"
			case .applicationEnableKey: return "Application Enable Key"
			case .displayEnableKey: return "Display Enable Key"
			case .statusIndicator: return "Status Indicator"
			case .auxiliaryDisplaySize: return "Auxiliary Display Size"
			case .auxiliaryDisplayData: return "Auxiliary Display Data"
			case .outputSelect: return "Output Select"
			case .assetTag: return "Asset Tag"
			case .auxiliaryPowerOutput: return "Auxiliary Power Output"
			case .scratchPad: return "Scratch Pad"
				
			// Audio
			case .audioSpeakerVolume: return "Audio: Speaker Volume"
			case .speakerSelect: return "Speaker Select"
			case .audioMicrophoneVolume: return "Audio: Microphone Volume"
			case .audioJackConnectionStatus: return "Audio: Jack Connection Status"
			case .audioMuteScreenBlank: return "Audio Mute/Screen Blank"
			case .audioTreble: return "Audio Treble"
			case .audioBass: return "Audio Bass"
			case .audioBalanceLR: return "Audio Balance L/R"
			case .audioProcessorMode: return "Audio Processor Mode"
				
			// DPVL
			case .monitorStatus: return "Monitor Status"
			case .packetCount: return "Packet Count"
			case .monitorXOrigin: return "Monitor X Origin"
			case .monitorYOrigin: return "Monitor Y Origin"
			case .headerErrorCount: return "Header Error Count"
			case .bodyCRCErrorCount: return "Body CRC Error Count"
			case .clientID: return "Client ID"
			case .linkControl: return "Link Control"
			}
		}

		// MCCS 2.2a section 1.4.3
		/// A VCP code function.
		public enum Function {
			case continuous
			case nonContinuous
			case table
		}

		/// A VCP code function.
		public var function: Function {
			switch self {
			case
				.restoreFactoryDefaults,
				.restoreFactoryLuminanceContrastDefaults,
				.restoreFactoryGeometryDefaults,
				.restoreFactoryColorDefaults,
				.restoreFactoryTVDefaults,
				.settings,
				.userColorTemperatureIncrement,
				.fleshToneEnhancement,
				.selectColorPreset,
				.autoSetup,
				.autoColorSetup,
				.grayScaleExpansion,
				.gamma,
				.autoSetupOnOff,
				.screenOrientation,
				.stereoVideoMode,
				.displayApplication,
				.osdButtonControl,
				.sourceColorCoding,
				.displayControllerID,
				.osdLanguage,
				.powerMode,
				.imageMode,
				.vcpVersion,
				.horizontalMirror,
				.verticalMirror,
				.displayScaling,
				.scanMode,
				.degauss,
				.newControlValue,
				.softControls,
				.activeControl,
				.performancePreservation,
				.inputSelect,
				.ambientLightSensor,
				.tvChannelUpDown,
				.flatPanelSubPixelLayout,
				.displayTechnologyType,
				.enableDisplayOfDisplayDescriptor,
				.applicationEnableKey,
				.displayEnableKey,
				.statusIndicator,
				.auxiliaryDisplaySize,
				.outputSelect,
				.auxiliaryPowerOutput,
				.scratchPad,
				.audioSpeakerVolume,
				.speakerSelect,
				.audioJackConnectionStatus,
				.audioMuteScreenBlank,
				.audioTreble,
				.audioBass,
				.audioBalanceLR,
				.audioProcessorMode,
				.monitorStatus,
				.linkControl:
				return .nonContinuous
			case
				.codePage,
				.lutSize,
				.singlePointLUTOperation,
				.blockLUTOperation,
				.windowMaskControl,
				.sourceTimingMode,
				.remoteProcedureCall,
				.displayIdentificationDataOperation,
				.transmitDisplayDescriptor,
				.auxiliaryDisplayData,
				.assetTag:
				return .table
			default:
				return .continuous
			}
		}
	}
}

extension DDC {
	// MCCS 2.2a section 6
	// DDC/CI 1.1 section 6.7.3
	/// A display information and supported VCP codes.
	public struct Capabilities {
		/// Used to specify the protocol class.
		public var prot: String = ""
		/// Identifies type of display.
		public var type: String = ""
		/// The display model number (may be alpha-numeric).
		public var model: String = ""
		/// A list of supported VCP commands.
		public var cmds: [VCPCommand] = []
		/// A list of supported VCP codes.
		public var vcp: [VCP] = []

		/// Parses capability string.
		/// - Parameter string: A capability string.
		/// - Throws: If failed to parse.
		public init(_ string: String) throws {
			guard string.first == "(" else {
				throw Error.openBracketExpected
			}

			var index = string.index(after: string.startIndex)
			while index < string.endIndex {
				if string[index] == ")" {
					guard string.index(after: index) == string.endIndex else {
						throw Error.unpairedBrackets
					}
					return
				}

				guard let open = string[index...].firstIndex(of: "(") else {
					throw Error.openBracketExpected
				}
				let name = string[index..<open]

				index = string.index(after: open)
				var level = 1
				let cl = string[index...].firstIndex {
					switch $0 {
					case "(":
						level += 1
						return false
					case ")":
						level -= 1
						return level == 0
					default:
						return false
					}
				}
				guard let close = cl else {
					throw Error.unpairedBrackets
				}
				let value = string[index..<close]
				index = string.index(after: close)

				switch name {
				case "prot":
					prot = String(value)
				case "type":
					type = String(value)
				case "model":
					model = String(value)
				case "cmds":
					cmds = value.split(separator: " ")
						.compactMap { UInt8($0, radix: 16) }
						.compactMap { VCPCommand(rawValue: $0) }
				case "vcp":
					var idx = value.startIndex
					while idx < value.endIndex {
						var hasValues = false
						let next = value[idx...].firstIndex {
							if $0 == "(" {
								hasValues = true
								return true
							} else {
								return $0 == " "
							}
						}
						let values: [UInt16]
						if let next = next, hasValues {
							guard let close = value[value.index(after: next)...].firstIndex(of: ")") else {
								throw Error.unpairedBrackets
							}
							values = string[idx..<close].split(separator: " ")
								.compactMap { UInt16($0, radix: 16) }
						} else {
							values = []
						}
						if let code = UInt8(value[idx..<(next ?? value.endIndex)], radix: 16).flatMap({ VCPCode(rawValue: $0) }) {
							vcp.append(VCP(code: code, values: values))
						}
						if let next = next {
							idx = value.index(after: next)
						} else {
							break
						}
					}
				default:
					break
				}
			}
			throw Error.unpairedBrackets
		}

		/// A description of a supported VCP code.
		public struct VCP {
			/// A VCP code.
			public let code: VCPCode
			/// A list of supported values for non-contiguous VCP codes.
			public let values: [UInt16]
		}

		enum Error: Swift.Error {
			case unpairedBrackets
			case openBracketExpected
		}
	}
}
