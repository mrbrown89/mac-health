//
//  SecurityInfo.swift
//  mac-health
//
//  Created by Matt on 23/08/2026.
//

import Foundation

// Represents security information collected from macOS.
struct SecurityInfo: Codable {
    let fileVaultEnabled: Bool?
    let sipEnabled: Bool?
    let gatekeeperEnabled: Bool?
    let firewallEnabled: Bool?
    let stealthModeEnabled: Bool?
    let xProtectVersion: String?
}
