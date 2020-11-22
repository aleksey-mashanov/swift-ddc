# DDC (Swift library + command line tool)

This package provides the command line tool and the DDC library for Swift which can be used
to get/set settings of displays compatible with the DDC/CI specification.

## Usage

### Command line tool

```zsh
% ddc get-vcp-feature contrast  
Contrast = 75 / 100
% ddc get-vcp-feature brightness   
Luminance = 60 / 100
% ddc set-vcp-feature brightness 80
% ddc --help                         
OVERVIEW: Configures display settings over a DDC interface.

USAGE: ddc <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  list-displays           Lists connected displays.
  capabilities            Executes the Capabilities DDC/CI command.
  list-vcp-features       Lists VCP codes supported by the display.
  get-vcp-feature         Executes the Get VCP Feature DDC/CI command.
  set-vcp-feature         Executes the Set VCP Feature DDC/CI command.

  See 'ddc help <subcommand>' for detailed help.
```

### Swift library

```swift
import DDC
let sem = DispatchSemaphore(value: 0)
let brightness: UInt16 = 75
let ddc = try DDC(framebuffer: framebuffer)
ddc.setVCPFeature(.brightness, to: brightness) {
	switch $0 {
	case .success(_):
		print("Brightness set to \(brightness)%")
	case .failure(let error):
		print("Failed to set brightness to \(brightness)%: \(String(describing: error))")
	}
	sem.signal()
}
ddc.getVCPFeature(.brightness) {
	switch $0 {
	case .success(let reply):
		print("Brightness: \(reply.present)%")
	case .failure(let error):
		print("Failed to get brightness: \(String(describing: error))")
	}
	sem.signal()
}
sem.wait()
sem.wait()
```

## Credits

The original idea was taken from:
- https://github.com/reitermarkus/DDC.swift
- https://github.com/kfix/ddcctl
- https://github.com/jontaylor/DDC-CI-Tools-for-OS-X

The main area of improvements is better stability through correct time
intervals between DDC commands in accordance with the DDC/CI specification.  
