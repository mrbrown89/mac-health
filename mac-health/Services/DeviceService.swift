//
//  DeviceService.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

// Collects general device information from macOS.
struct DeviceService {
    // Returns a snapshot of the current Mac's device information.
    func getDeviceInfo() -> DeviceInfo {
        let processInfo = ProcessInfo.processInfo

        let computerName = Host.current().localizedName ?? "Unknown"
        let hostName = processInfo.hostName

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
            architecture: architecture
        )
    }
}
