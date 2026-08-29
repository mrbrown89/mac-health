//
//  StorageService.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

// Collects storage information from the Mac's root filesystem.
struct StorageService {

  // Returns a snapshot of the current root filesystem storage usage.
  func getStorageInfo() -> StorageInfo? {
    let rootURL = URL(fileURLWithPath: "/")

    do {
      let values = try rootURL.resourceValues(
        forKeys: [
          .volumeTotalCapacityKey,
          .volumeAvailableCapacityForImportantUsageKey,
        ]
      )

      guard
        let totalBytes = values.volumeTotalCapacity,
        let availableBytes = values.volumeAvailableCapacityForImportantUsage
      else {
        return nil
      }

      let usedBytes = Int64(totalBytes) - availableBytes

      let usedPercentage =
        (Double(usedBytes) / Double(totalBytes)) * 100

      let status = getStorageStatus(for: usedPercentage)

      return StorageInfo(
        totalBytes: Int64(totalBytes),
        availableBytes: availableBytes,
        usedPercentage: usedPercentage,
        status: status
      )

    } catch {
      return nil
    }
  }
}

private func getStorageStatus(for usedPercentage: Double) -> HealthStatus {
  if usedPercentage < 70 {
    return .ok
  } else if usedPercentage < 80 {
    return .warning
  } else {
    return .critical
  }
}
