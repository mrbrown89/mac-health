//
//  MemoryInfo.swift
//  mac-health
//
//  Created by Matt on 23/08/2026.
//

import Foundation

// Represents the current memory health of the Mac.
struct MemoryInfo: Codable {
  let pressurePercentage: Double?
  let status: HealthStatus
}
