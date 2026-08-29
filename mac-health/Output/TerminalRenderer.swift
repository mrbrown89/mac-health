//
//  TerminalRenderer.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

struct TerminalRenderer {

  private let green = "\u{001B}[32m"
  private let yellow = "\u{001B}[33m"
  private let red = "\u{001B}[31m"
  private let blue = "\u{001B}[34m"
  private let reset = "\u{001B}[0m"

  func status(_ status: HealthStatus, message: String) {
    switch status {
    case .ok:
      print("\(green)[OK]\(reset) \(message)")

    case .warning:
      print("\(yellow)[WARN]\(reset) \(message)")

    case .critical:
      print("\(red)[BAD]\(reset) \(message)")

    case .info:
      print("\(blue)[INFO]\(reset) \(message)")
    }
  }
}
