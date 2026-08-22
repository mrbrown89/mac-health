//
//  HealthStatus.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

enum HealthStatus: String, Codable {
    case ok
    case warning
    case critical
    case info
}
