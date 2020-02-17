//
//  SystemInfo.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack
import SystemKit
import SMCKit

class SystemInfo {
    // MARK: -
    // MARK: Structure Definitions
    struct TimeDuration {
        let days: Int
        let hours: Int
        let minutes: Int
        let seconds: Int
    }

    // MARK: -
    // MARK: Instance Variables
    let skSystem: SKSystem

    // MARK: -
    // MARK: Static Variables
    let cpu: CpuInfo
    let gpu: GpuInfo
    let disk: DiskInfo
    let battery: BatteryInfo
    let memory: MemoryInfo

    init() {
        self.skSystem = SKSystem()

        self.cpu = CpuInfo(skSystem: self.skSystem)
        self.gpu = GpuInfo()
        self.disk = DiskInfo()
        self.battery = BatteryInfo()
        self.memory = MemoryInfo()

        // open the connection to the SMC
        do {
            try SMCKit.open()
        } catch SMCKit.SMCError.driverNotFound {
            DDLogError("Could not find the SMC driver.")
        } catch {
            DDLogError("Failed to open a connection to the SMC")
        }
    }

    deinit {
        // close the connection to the SMC
        if !SMCKit.close() {
            DDLogError("Failed to close the connection to the SMC")
        }
    }

    // MARK: -
    // MARK: Static Functions
    /**
     * Returns uptime of the system since the last boot.
     */
    func getSystemUptime() -> TimeDuration {
        // taken from https://stackoverflow.com/a/45068046/9717671

        var uptime = timespec()

        if clock_gettime(CLOCK_MONOTONIC_RAW, &uptime) != 0 {
            DDLogError("Could not retrieve system uptime")
            return TimeDuration(days: 0, hours: 0, minutes: 0, seconds: 0)
        }

        DDLogInfo("Raw uptime value: \(uptime)")

        let seconds = uptime.tv_sec % 60
        let minutes = (uptime.tv_sec / 60) % 60
        let hours = (uptime.tv_sec / 3600) % 24
        let days = uptime.tv_sec / (60 * 60 * 24)

        let uptimeDuration = TimeDuration(days: days, hours: hours, minutes: minutes, seconds: seconds)
        DDLogInfo("Got the system uptime: \(uptimeDuration)")

        return uptimeDuration
    }

    /**
     * Returns the size of the RAM in GB.
     */
    func getRamSize() -> Int {
        let ramSize = Int(ProcessInfo.processInfo.physicalMemory / 1_073_741_824)
        DDLogInfo("Got the ram size: \(ramSize)")

        return ramSize
    }
}
