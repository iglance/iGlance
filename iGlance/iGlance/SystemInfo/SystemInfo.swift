//
//  SystemInfo.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

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
    // MARK: Static Variables
    static let cpu = CpuInfo()
    static let gpu = GpuInfo()
    static let disk = DiskInfo()
    static let battery = Battery()

    // MARK: -
    // MARK: Static Functions
    /**
     * Returns uptime of the system since the last boot.
     */
    static func getSystemUptime() -> TimeDuration {
        // taken from https://stackoverflow.com/a/45068046/9717671

        var uptime = timespec()

        if clock_gettime(CLOCK_MONOTONIC_RAW, &uptime) != 0 {
            DDLogError("Could not retrieve system uptime")
            return TimeDuration(days: 0, hours: 0, minutes: 0, seconds: 0)
        }

        let seconds = uptime.tv_sec % 60
        let minutes = (uptime.tv_sec / 60) % 60
        let hours = (uptime.tv_sec / 3600) % 24
        let days = uptime.tv_sec / (60 * 60 * 24)

        return TimeDuration(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }

    /**
     * Returns the size of the RAM in GB.
     */
    static func getRamSize() -> Int {
        Int(ProcessInfo.processInfo.physicalMemory / 1_073_741_824)
    }
}
