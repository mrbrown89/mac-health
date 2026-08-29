//
//  SoftwareUpdateService.swift
//  mac-health
//
//  Created by Matt on 25/08/2026.
//

import Foundation

// Collects available macOS software updates.
struct SoftwareUpdateService {

  // Returns the current software update status.
  func getSoftwareUpdateInfo() -> SoftwareUpdateInfo {
    guard let output = runSoftwareUpdateList() else {
      return SoftwareUpdateInfo(
        updatesAvailable: false,
        updateCount: 0,
        updateNames: [],
        status: .info
      )
    }

    if output.contains("No new software available") {
      return SoftwareUpdateInfo(
        updatesAvailable: false,
        updateCount: 0,
        updateNames: [],
        status: .ok
      )
    }

    let updateNames = parseUpdateNames(from: output)

    if !updateNames.isEmpty {
      return SoftwareUpdateInfo(
        updatesAvailable: true,
        updateCount: updateNames.count,
        updateNames: updateNames,
        status: .warning
      )
    }

    return SoftwareUpdateInfo(
      updatesAvailable: false,
      updateCount: 0,
      updateNames: [],
      status: .info
    )
  }

  private func runSoftwareUpdateList() -> String? {
    let process = Process()
    let pipe = Pipe()

    process.executableURL = URL(
      fileURLWithPath: "/usr/sbin/softwareupdate"
    )

    process.arguments = ["--list"]
    process.standardOutput = pipe
    process.standardError = pipe

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return nil
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    return String(
      data: data,
      encoding: .utf8
    )?.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func parseUpdateNames(
    from output: String
  ) -> [String] {
    var updates: [String] = []

    for line in output.components(separatedBy: .newlines) {
      let trimmedLine = line.trimmingCharacters(
        in: .whitespaces
      )

      if trimmedLine.hasPrefix("* Label:") {
        let name =
          trimmedLine
          .replacingOccurrences(
            of: "* Label:",
            with: ""
          )
          .trimmingCharacters(
            in: .whitespaces
          )

        updates.append(name)
      }
    }

    return updates
  }
}
