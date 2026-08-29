//
//  SoftwareUpdateInfo.swift
//  mac-health
//
//  Created by Matt on 25/08/2026.
//

import Foundation

// Represents available macOS software updates.
struct SoftwareUpdateInfo: Codable {
  let updatesAvailable: Bool
  let updateCount: Int
  let updateNames: [String]
  let status: HealthStatus
}
