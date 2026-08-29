//
//  SecurityService.swift
//  mac-health
//
//  Created by Matt on 23/08/2026.
//

import Foundation

// Collects security information from macOS.
struct SecurityService {

  // Returns a snapshot of the Mac's current security configuration.
  func getSecurityInfo() -> SecurityInfo {
    return SecurityInfo(
      fileVaultEnabled: getFileVaultStatus(),
      sipEnabled: getSIPStatus(),
      gatekeeperEnabled: getGatekeeperStatus(),
      firewallEnabled: getFirewallStatus(),
      stealthModeEnabled: getStealthModeStatus(),
      xProtectVersion: getXProtectVersion()
    )
  }

  private func getFileVaultStatus() -> Bool? {
    guard
      let output = runCommand(
        executable: "/usr/bin/fdesetup",
        arguments: ["status"]
      )
    else {
      return nil
    }

    if output.contains("FileVault is On") {
      return true
    }

    if output.contains("FileVault is Off") {
      return false
    }

    return nil
  }

  private func getSIPStatus() -> Bool? {
    guard
      let output = runCommand(
        executable: "/usr/bin/csrutil",
        arguments: ["status"]
      )
    else {
      return nil
    }

    if output.contains("System Integrity Protection status: enabled") {
      return true
    }

    if output.contains("System Integrity Protection status: disabled") {
      return false
    }

    return nil
  }

  private func getGatekeeperStatus() -> Bool? {
    guard
      let output = runCommand(
        executable: "/usr/sbin/spctl",
        arguments: ["--status"]
      )
    else {
      return nil
    }

    if output.contains("assessments enabled") {
      return true
    }

    if output.contains("assessments disabled") {
      return false
    }

    return nil
  }

  private func getFirewallStatus() -> Bool? {
    guard
      let output = runCommand(
        executable: "/usr/libexec/ApplicationFirewall/socketfilterfw",
        arguments: ["--getglobalstate"]
      )
    else {
      return nil
    }

    if output.contains("Firewall is enabled") {
      return true
    }

    if output.contains("Firewall is disabled") {
      return false
    }

    return nil
  }

  private func getStealthModeStatus() -> Bool? {
    guard
      let output = runCommand(
        executable: "/usr/libexec/ApplicationFirewall/socketfilterfw",
        arguments: ["--getstealthmode"]
      )
    else {
      return nil
    }

    let normalizedOutput = output.lowercased()

    if normalizedOutput.contains("is on") {
      return true
    }

    if normalizedOutput.contains("is off") {
      return false
    }

    return nil
  }

  private func getXProtectVersion() -> String? {
    let paths = [
      "/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Info.plist"
    ]

    for path in paths {
      if let version = runCommand(
        executable: "/usr/bin/defaults",
        arguments: [
          "read",
          path,
          "CFBundleShortVersionString",
        ]
      ) {
        return version
      }

      if let version = runCommand(
        executable: "/usr/bin/defaults",
        arguments: [
          "read",
          path,
          "CFBundleVersion",
        ]
      ) {
        return version
      }
    }

    return nil
  }

  private func runCommand(
    executable: String,
    arguments: [String]
  ) -> String? {
    let process = Process()
    let pipe = Pipe()

    process.executableURL = URL(
      fileURLWithPath: executable
    )

    process.arguments = arguments
    process.standardOutput = pipe
    process.standardError = pipe

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return nil
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    guard process.terminationStatus == 0 else {
      return nil
    }

    return String(
      data: data,
      encoding: .utf8
    )?.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
