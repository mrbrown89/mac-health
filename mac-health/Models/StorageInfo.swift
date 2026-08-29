//
//  StorageInfo.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

// Represents storage information collected from the Mac's root filesystem.
struct StorageInfo: Codable {
  let totalBytes: Int64
  let availableBytes: Int64
  let usedPercentage: Double
  let status: HealthStatus
}
