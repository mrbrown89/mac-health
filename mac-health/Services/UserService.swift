//
//  UserService.swift
//  mac-health
//
//  Created by Matt on 26/08/2026.
//

import Foundation

// Collects information about local human user accounts.
struct UserService {

  // Returns all local user accounts with a UID of 500 or higher.
  func getUsers() -> [UserInfo] {
    guard
      let output = runCommand(
        executable: "/usr/bin/dscl",
        arguments: [
          ".",
          "list",
          "/Users",
          "UniqueID",
        ]
      )
    else {
      return []
    }

    let loggedInUser = getLoggedInUser()
    let fileVaultUsers = getFileVaultUsers()

    var users: [UserInfo] = []

    for line in output.components(separatedBy: .newlines) {
      let parts = line.split(
        whereSeparator: { $0.isWhitespace }
      )

      guard parts.count == 2 else {
        continue
      }

      let username = String(parts[0])

      guard let uid = Int(parts[1]) else {
        continue
      }

      // Ignore system and service accounts.
      guard uid >= 500 else {
        continue
      }

      guard !username.hasPrefix("_") else {
        continue
      }

      let homeDirectory = getHomeDirectory(
        for: username
      )

      let isAdmin = getAdminStatus(
        for: username
      )

      let hasFileVault =
        fileVaultUsers?.contains(username)

      let isLoggedIn =
        username == loggedInUser

      users.append(
        UserInfo(
          username: username,
          uid: uid,
          homeDirectory: homeDirectory,
          isAdmin: isAdmin,
          hasFileVault: hasFileVault,
          isLoggedIn: isLoggedIn
        )
      )
    }

    return users
  }

  private func getLoggedInUser() -> String? {
    runCommand(
      executable: "/usr/bin/stat",
      arguments: [
        "-f",
        "%Su",
        "/dev/console",
      ]
    )
  }

  private func getFileVaultUsers() -> Set<String>? {
    guard
      let output = runCommand(
        executable: "/usr/bin/fdesetup",
        arguments: ["list"]
      )
    else {
      return nil
    }

    var users = Set<String>()

    for line in output.components(separatedBy: .newlines) {
      guard !line.isEmpty else {
        continue
      }

      let username =
        line
        .split(separator: ",")
        .first
        .map(String.init)

      if let username {
        users.insert(username)
      }
    }

    return users
  }

  private func getHomeDirectory(
    for username: String
  ) -> String? {
    guard
      let output = runCommand(
        executable: "/usr/bin/dscl",
        arguments: [
          ".",
          "-read",
          "/Users/\(username)",
          "NFSHomeDirectory",
        ]
      )
    else {
      return nil
    }

    guard let separatorIndex = output.firstIndex(of: ":") else {
      return nil
    }

    let value = output[
      output.index(after: separatorIndex)...
    ]

    return value.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
  }

  private func getAdminStatus(
    for username: String
  ) -> Bool {
    guard
      let output = runCommand(
        executable: "/usr/sbin/dseditgroup",
        arguments: [
          "-o",
          "checkmember",
          "-m",
          username,
          "admin",
        ]
      )
    else {
      return false
    }

    return output.lowercased().contains("yes")
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
    )?.trimmingCharacters(
      in: .whitespacesAndNewlines
    )
  }
}
