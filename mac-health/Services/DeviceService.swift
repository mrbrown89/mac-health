//
//  DeviceService.swift
//  mac-health
//
//  Created by Matt on 22/08/2026.
//

import Darwin
import Foundation
import IOKit

// Collects general device information from macOS.
struct DeviceService {

  private struct SystemProfilerResult: Decodable {
    let SPHardwareDataType: [HardwareData]
    let SPDisplaysDataType: [DisplayData]
  }

  private struct HardwareData: Decodable {
    let machine_name: String?
  }

  private struct DisplayData: Decodable {
    let sppci_cores: String?
  }

  // Returns a snapshot of the current Mac's device information.
  func getDeviceInfo() -> DeviceInfo {
    let processInfo = ProcessInfo.processInfo
    let uptimeSeconds = getUptimeSeconds()
    let cpuCoreCount = processInfo.processorCount
    let memoryBytes = processInfo.physicalMemory
    let computerName = Host.current().localizedName ?? "Unknown"
    let hostName = processInfo.hostName
    let serialNumber = getSerialNumber()
    let modelIdentifier = getModelIdentifier()
    let profilerInfo = getSystemProfilerInfo()
    let modelName = profilerInfo.modelName
    let gpuCoreCount = profilerInfo.gpuCoreCount
    let chip = getChipName()
    let version = processInfo.operatingSystemVersion
    let macOSVersion =
      "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

    #if arch(arm64)
      let architecture = "arm64"
    #elseif arch(x86_64)
      let architecture = "x86_64"
    #else
      let architecture = "unknown"
    #endif

    return DeviceInfo(
      computerName: computerName,
      hostName: hostName,
      serialNumber: serialNumber,
      modelName: modelName,
      modelIdentifier: modelIdentifier,
      chip: chip,
      cpuCoreCount: cpuCoreCount,
      gpuCoreCount: gpuCoreCount,
      memoryBytes: memoryBytes,
      uptimeSeconds: uptimeSeconds,
      macOSVersion: macOSVersion,
      architecture: architecture
    )
  }

  private func getSerialNumber() -> String? {
    let platformExpert = IOServiceGetMatchingService(
      kIOMainPortDefault,
      IOServiceMatching("IOPlatformExpertDevice")
    )

    guard platformExpert != 0 else {
      return nil
    }

    defer {
      IOObjectRelease(platformExpert)
    }

    guard
      let serialNumber = IORegistryEntryCreateCFProperty(
        platformExpert,
        "IOPlatformSerialNumber" as CFString,
        kCFAllocatorDefault,
        0
      )?.takeRetainedValue() as? String
    else {
      return nil
    }

    return serialNumber
  }

  private func getModelIdentifier() -> String? {
    var size = 0

    guard
      sysctlbyname(
        "hw.model",
        nil,
        &size,
        nil,
        0
      ) == 0
    else {
      return nil
    }

    var model = [CChar](repeating: 0, count: size)

    guard
      sysctlbyname(
        "hw.model",
        &model,
        &size,
        nil,
        0
      ) == 0
    else {
      return nil
    }

    return String(cString: model)
  }

  private func getChipName() -> String? {
    var size = 0

    guard
      sysctlbyname(
        "machdep.cpu.brand_string",
        nil,
        &size,
        nil,
        0
      ) == 0
    else {
      return nil
    }

    var chip = [CChar](repeating: 0, count: size)

    guard
      sysctlbyname(
        "machdep.cpu.brand_string",
        &chip,
        &size,
        nil,
        0
      ) == 0
    else {
      return nil
    }

    return String(cString: chip)
  }

  private func getSystemProfilerInfo() -> (
    modelName: String?,
    gpuCoreCount: Int?
  ) {
    let process = Process()
    let pipe = Pipe()

    process.executableURL = URL(
      fileURLWithPath: "/usr/sbin/system_profiler"
    )

    process.arguments = [
      "-json",
      "SPHardwareDataType",
      "SPDisplaysDataType",
    ]

    process.standardOutput = pipe
    process.standardError = pipe

    do {
      try process.run()
      process.waitUntilExit()
    } catch {
      return (nil, nil)
    }

    guard process.terminationStatus == 0 else {
      return (nil, nil)
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    guard !data.isEmpty else {
      return (nil, nil)
    }

    do {
      let profilerData = try JSONDecoder().decode(
        SystemProfilerResult.self,
        from: data
      )

      let modelName =
        profilerData.SPHardwareDataType.first?.machine_name

      let gpuCoreString =
        profilerData.SPDisplaysDataType.first?.sppci_cores

      let gpuCoreCount =
        gpuCoreString.flatMap { Int($0) }

      return (
        modelName,
        gpuCoreCount
      )

    } catch {
      return (nil, nil)
    }
  }

  private func getUptimeSeconds() -> TimeInterval {
    var bootTime = timeval()
    var size = MemoryLayout<timeval>.size

    var mib: [Int32] = [
      CTL_KERN,
      KERN_BOOTTIME,
    ]

    let result = sysctl(
      &mib,
      u_int(mib.count),
      &bootTime,
      &size,
      nil,
      0
    )

    guard result == 0 else {
      return 0
    }

    let bootDate = Date(
      timeIntervalSince1970: TimeInterval(bootTime.tv_sec)
    )

    return Date().timeIntervalSince(bootDate)
  }
}
