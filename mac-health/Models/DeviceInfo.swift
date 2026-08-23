//
//  DeviceInfo.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

// Represents general information collected about the Mac.
struct DeviceInfo: Codable {
    let computerName: String
    let hostName: String
    let serialNumber: String?
    let modelName: String?
    let modelIdentifier: String?
    let chip: String?
    let cpuCoreCount: Int
    let gpuCoreCount: Int?
    let memoryBytes: UInt64
    let uptimeSeconds: TimeInterval
    let macOSVersion: String
    let architecture: String
}
