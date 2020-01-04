//
//  SystemInfo.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import IOKit

class SystemInfo {

    struct TimeDuration {
        let days: Int
        let hours: Int
        let minutes: Int
        let seconds: Int
    }

    static let cpu: CpuInfo = CpuInfo()
    static let gpu: GpuInfo = GpuInfo()
    static let disk: DiskInfo = DiskInfo()

    /**
     * Returns the time the system has been awake since the last time it was started.
     */
    static func getSystemUptime() -> TimeDuration {
        // taken from https://stackoverflow.com/a/45068046/9717671

        var uptime = timespec()

        if clock_gettime(CLOCK_MONOTONIC_RAW, &uptime) != 0 {
            fatalError("Could not retrieve system uptime")
        }

        let seconds = uptime.tv_sec % 60
        let minutes = (uptime.tv_sec / 60) % 60
        let hours = (uptime.tv_sec / 3600) % 24
        let days = uptime.tv_sec / (60 * 60 * 24)

        return TimeDuration(days: days, hours: hours, minutes: minutes, seconds: seconds)
    }

    /**
     * Returns the boot time.
     */
    static func getBootTime() -> Date {
        // taken from https://stackoverflow.com/a/45068046/9717671

        // define the commands
        var mib = [ CTL_KERN, KERN_BOOTTIME ]
        // create the variables
        var bootTime = timeval()
        var bootTimeSize = MemoryLayout<timeval>.size

        // call sysctl to get the boot time
        if sysctl(&mib, UInt32(mib.count), &bootTime, &bootTimeSize, nil, 0) != 0 {
            fatalError("Could not retrieve boot time")
        }

        // create the time interval object
        let timeInterval = TimeInterval(bootTime.tv_sec)

        return Date(timeIntervalSince1970: timeInterval)
    }

    /**
     * Returns the size of the RAM in GB.
     */
    static func getRamSize() -> Int {
        return Int(ProcessInfo.processInfo.physicalMemory / 10_73_741_824)
    }
}
