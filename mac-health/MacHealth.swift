//
//  main.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import ArgumentParser
import Foundation

@main
struct MacHealth: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "mac-health",
        abstract: "Run health checks against the local Mac."
    )

    @Flag(
        name: .long,
        help: "Output to JSON"
    )
    var json = false
    
    @Option(
        name: [.short, .long],
        help: "Write JSON output to a file."
    )
    var output: String?
    
    @Flag(
        name: [.short, .long],
        help: "Show storage health information only."
    )
    var storage = false
    
    @Flag(
        name: [.short, .long],
        help: "Show battery and power information only."
    )
    var battery = false

    mutating func run() throws {
        let deviceService = DeviceService()
        let device = deviceService.getDeviceInfo()
        let storageService = StorageService()
        let storageInfo = storageService.getStorageInfo()
        let renderer = TerminalRenderer()
        let batteryService = BatteryService()
        let batteryInfo = batteryService.getBatteryInfo()
        
        let report = HealthReport(
            device: device,
            storage: storageInfo,
            battery: batteryInfo
        )
        
        if storage {
            printStorage(storageInfo, renderer: renderer)
        } else if battery {
            printBattery(batteryInfo, renderer: renderer)
        } else {
            printDevice(device)
            printStorage(storageInfo, renderer: renderer)
            printBattery(batteryInfo, renderer: renderer)
        }

        if json {
            let jsonData = try encodeJSON(report)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print()
                print(jsonString)
            }

            if let output {
                let outputURL = URL(fileURLWithPath: output)

                try jsonData.write(to: outputURL)

                print()
                print("JSON written to: \(outputURL.path)")
            }
        }
    }

    private func encodeJSON(_ report: HealthReport) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try encoder.encode(report)
    }
    
    private func printDevice(_ device: DeviceInfo) {
        print("mac-health")
        print("==========")
        print()
        print("Device")
        print("----------------------------------------")
        print("Computer Name: \(device.computerName)")
        print("Host Name: \(device.hostName)")
        print("Serial Number: \(device.serialNumber ?? "Unknown")")
        print("Model Name: \(device.modelName ?? "Unknown")")
        print("Model Identifier: \(device.modelIdentifier ?? "Unknown")")
        print("Chip: \(device.chip ?? "Unknown")")
        print("macOS: \(device.macOSVersion)")
        print("Architecture: \(device.architecture)")
    }

    private func printStorage(
        _ storageInfo: StorageInfo?,
        renderer: TerminalRenderer
    ) {
        print()
        print("Storage")
        print("----------------------------------------")

        if let storageInfo {
            print("Total Space: \(formatBytes(storageInfo.totalBytes))")
            print("Available Space: \(formatBytes(storageInfo.availableBytes))")

            renderer.status(
                storageInfo.status,
                message: String(
                    format: "Disk Usage: %.1f%%",
                    storageInfo.usedPercentage
                )
            )
        } else {
            print("Storage information unavailable")
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        ByteCountFormatter.string(
            fromByteCount: bytes,
            countStyle: .decimal
        )
    }
}

private func printBattery(
    _ batteryInfo: BatteryInfo?,
    renderer: TerminalRenderer
) {
    print()
    print("Battery & Power")
    print("----------------------------------------")

    guard let batteryInfo else {
        print("Battery: Not Present")
        return
    }

    if let chargePercentage = batteryInfo.chargePercentage {
        print("Charge: \(chargePercentage)%")
    }

    if let powerSource = batteryInfo.powerSource {
        print("Power Source: \(powerSource)")
    }

    if let isCharging = batteryInfo.isCharging {
        print("Charging: \(isCharging ? "Yes" : "No")")
    }

    if let maximumCapacity = batteryInfo.maximumCapacityPercentage {
        print("Maximum Capacity: \(maximumCapacity)%")
    }

    if let cycleCount = batteryInfo.cycleCount {
        print("Cycle Count: \(cycleCount)")
    }

    if let status = batteryInfo.status,
       let maximumCapacity = batteryInfo.maximumCapacityPercentage {

        renderer.status(
            status,
            message: "Battery Health: \(maximumCapacity)%"
        )
    }
}

