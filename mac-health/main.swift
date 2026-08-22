//
//  main.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation

let deviceService = DeviceService()
let device = deviceService.getDeviceInfo()

print("mac-health")
print("==========")
print()
print("Computer Name: \(device.computerName)")
print("Host Name: \(device.hostName)")
print("macOS: \(device.macOSVersion)")
print("Architecture: \(device.architecture)")
