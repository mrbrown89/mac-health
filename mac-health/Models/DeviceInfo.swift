//
//  DeviceInfo.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

// Represents general information collected about the Mac.
struct DeviceInfo: Codable {
    let computerName: String
    let hostName: String
    let macOSVersion: String
    let architecture: String
}
