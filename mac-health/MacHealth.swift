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

    mutating func run() throws {
        let deviceService = DeviceService()
        let device = deviceService.getDeviceInfo()

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

        if json {
            let jsonData = try encodeJSON(device)

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

    private func encodeJSON(_ device: DeviceInfo) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return try encoder.encode(device)
    }
}
