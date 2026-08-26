//
//  UserInfo.swift
//  mac-health
//
//  Created by Matt on 26/08/2026.
//

import Foundation

// Represents a local human user account on the Mac.
struct UserInfo: Codable {
    let username: String
    let uid: Int
    let homeDirectory: String?
    let isAdmin: Bool
    let hasFileVault: Bool
    let isLoggedIn: Bool
}
