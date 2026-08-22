//
//  main.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

// Initialise the service used to collect device information.
let deviceService = DeviceService()

// Run the device information collection and store the returned model.
let device = deviceService.getDeviceInfo()

// Encode the DeviceInfo model as JSON.
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

do {
    let jsonData = try encoder.encode(device)

    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
} catch {
    print("Failed to encode device information: \(error)")
}
