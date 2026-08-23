//
//  MemoryService.swift
//  mac-health
//
//  Created by Matt on 23/08/2026.
//

import Foundation

// Collects current memory pressure information from macOS.
struct MemoryService {

    // Returns a snapshot of the Mac's current memory pressure.
    func getMemoryInfo() -> MemoryInfo {
        let pressurePercentage = getMemoryPressurePercentage()

        let status: HealthStatus

        if let pressurePercentage {
            if pressurePercentage < 70 {
                status = .ok
            } else if pressurePercentage < 80 {
                status = .warning
            } else {
                status = .critical
            }
        } else {
            status = .info
        }

        return MemoryInfo(
            pressurePercentage: pressurePercentage,
            status: status
        )
    }

    private func getMemoryPressurePercentage() -> Double? {
        let process = Process()
        let pipe = Pipe()

        process.executableURL = URL(
            fileURLWithPath: "/usr/bin/memory_pressure"
        )

        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        guard process.terminationStatus == 0 else {
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()

        guard let output = String(
            data: data,
            encoding: .utf8
        ) else {
            return nil
        }

        for line in output.components(separatedBy: .newlines) {
            if line.contains("System-wide memory free percentage") {
                let parts = line.split(separator: ":")

                guard
                    let value = parts.last?
                        .trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "%", with: ""),
                    let percentage = Double(value)
                else {
                    return nil
                }

                return 100 - percentage
            }
        }

        return nil
    }
}
