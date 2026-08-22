//
//  BatteryService.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Foundation
import IOKit
import IOKit.ps

// Collects battery and power information from macOS.
struct BatteryService {

    // Returns battery information, or nil if the Mac has no battery.
    func getBatteryInfo() -> BatteryInfo? {
        guard
            let powerSourcesInfo = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
            let powerSources = IOPSCopyPowerSourcesList(powerSourcesInfo)?.takeRetainedValue() as? [CFTypeRef]
        else {
            return nil
        }

        for powerSource in powerSources {
            guard
                let description = IOPSGetPowerSourceDescription(
                    powerSourcesInfo,
                    powerSource
                )?.takeUnretainedValue() as? [String: Any]
            else {
                continue
            }

            guard
                let type = description[kIOPSTypeKey] as? String,
                type == kIOPSInternalBatteryType
            else {
                continue
            }

            let currentCapacity = description[kIOPSCurrentCapacityKey] as? Int
            let maxCapacity = description[kIOPSMaxCapacityKey] as? Int

            let chargePercentage: Int?

            if let currentCapacity, let maxCapacity, maxCapacity > 0 {
                chargePercentage = Int(
                    (Double(currentCapacity) / Double(maxCapacity)) * 100
                )
            } else {
                chargePercentage = nil
            }

            let isCharging = description[kIOPSIsChargingKey] as? Bool

            let powerSourceState =
                description[kIOPSPowerSourceStateKey] as? String

            let powerSource: String?

            if powerSourceState == kIOPSACPowerValue {
                powerSource = "AC Power"
            } else if powerSourceState == kIOPSBatteryPowerValue {
                powerSource = "Battery Power"
            } else {
                powerSource = powerSourceState
            }

            // Collect additional battery health information.
            let batteryHealth = getBatteryHealth()

            let status: HealthStatus?

            if let capacity = batteryHealth.maximumCapacityPercentage {
                if capacity >= 80 {
                    status = .ok
                } else if capacity >= 70 {
                    status = .warning
                } else {
                    status = .critical
                }
            } else {
                status = nil
            }

            return BatteryInfo(
                chargePercentage: chargePercentage,
                maximumCapacityPercentage: batteryHealth.maximumCapacityPercentage,
                cycleCount: batteryHealth.cycleCount,
                isCharging: isCharging,
                powerSource: powerSource,
                condition: nil,
                status: status
            )
        }

        return nil
    }

    // Returns battery health information from the I/O Registry.
    // Returns battery health information from the I/O Registry.
    private func getBatteryHealth() -> (
        maximumCapacityPercentage: Int?,
        cycleCount: Int?
    ) {
        let batteryService = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("AppleSmartBattery")
        )

        guard batteryService != 0 else {
            return (nil, nil)
        }

        defer {
            IOObjectRelease(batteryService)
        }

        let cycleCount = getIntegerProperty(
            from: batteryService,
            key: "CycleCount"
        )

        let designCapacity = getIntegerProperty(
            from: batteryService,
            key: "DesignCapacity"
        )

        let maximumCapacity =
            getIntegerProperty(
                from: batteryService,
                key: "AppleRawMaxCapacity"
            )
            ?? getIntegerProperty(
                from: batteryService,
                key: "MaxCapacity"
            )

        var maximumCapacityPercentage: Int?

        if let designCapacity,
           let maximumCapacity,
           designCapacity > 0 {

            let maximumCapacityDouble = Double(maximumCapacity)
            let designCapacityDouble = Double(designCapacity)

            let percentage =
                (maximumCapacityDouble / designCapacityDouble) * 100

            maximumCapacityPercentage = Int(percentage)
        }

        return (
            maximumCapacityPercentage,
            cycleCount
        )
    }
    
    // Reads an integer property from an I/O Registry entry.
    private func getIntegerProperty(
        from service: io_registry_entry_t,
        key: String
    ) -> Int? {
        guard let value = IORegistryEntryCreateCFProperty(
            service,
            key as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() else {
            return nil
        }

        return (value as? NSNumber)?.intValue
    }
}
