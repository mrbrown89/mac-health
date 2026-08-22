//
//  DeviceService.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation
import IOKit
import Darwin

// Collects general device information from macOS.
struct DeviceService {

    // Returns a snapshot of the current Mac's device information.
    func getDeviceInfo() -> DeviceInfo {
        let processInfo = ProcessInfo.processInfo

        let computerName = Host.current().localizedName ?? "Unknown"
        let hostName = processInfo.hostName

        let serialNumber = getSerialNumber()
        let modelIdentifier = getModelIdentifier()
        let modelName: String? = nil
        let chip = getChipName()

        let version = processInfo.operatingSystemVersion
        let macOSVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

        #if arch(arm64)
        let architecture = "arm64"
        #elseif arch(x86_64)
        let architecture = "x86_64"
        #else
        let architecture = "unknown"
        #endif

        return DeviceInfo(
            computerName: computerName,
            hostName: hostName,
            macOSVersion: macOSVersion,
            architecture: architecture,
            serialNumber: serialNumber,
            modelName: modelName,
            modelIdentifier: modelIdentifier,
            chip: chip
        )
    }

    private func getSerialNumber() -> String? {
        let platformExpert = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )

        guard platformExpert != 0 else {
            return nil
        }

        defer {
            IOObjectRelease(platformExpert)
        }

        guard let serialNumber = IORegistryEntryCreateCFProperty(
            platformExpert,
            "IOPlatformSerialNumber" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? String else {
            return nil
        }

        return serialNumber
    }

    private func getModelIdentifier() -> String? {
        var size = 0

        guard sysctlbyname("hw.model", nil, &size, nil, 0) == 0 else {
            return nil
        }

        var model = [CChar](repeating: 0, count: size)

        guard sysctlbyname("hw.model", &model, &size, nil, 0) == 0 else {
            return nil
        }

        return String(cString: model)
    }

    private func getChipName() -> String? {
        var size = 0

        guard sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0) == 0 else {
            return nil
        }

        var chip = [CChar](repeating: 0, count: size)

        guard sysctlbyname("machdep.cpu.brand_string", &chip, &size, nil, 0) == 0 else {
            return nil
        }

        return String(cString: chip)
    }
}
