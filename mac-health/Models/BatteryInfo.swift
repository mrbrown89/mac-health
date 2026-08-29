//
//  BatteryInfo.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

// Represents battery and power information collected from the Mac.
struct BatteryInfo: Codable {
  let chargePercentage: Int?
  let maximumCapacityPercentage: Int?
  let cycleCount: Int?
  let isCharging: Bool?
  let powerSource: String?
  let condition: String?
  let status: HealthStatus?
}
