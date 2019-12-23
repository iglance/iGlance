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

    struct GpuInfo {
        let name: String
        let bus: String
    }

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

    /**
     * Returns the brand name of the cpu.
     */
    static func getCpuName() -> String {
        // taken from https://stackoverflow.com/a/18099669/9717671

        // get the length of the cpu name
        var stringSize = 0
        if sysctlbyname("machdep.cpu.brand_string", nil, &stringSize, nil, 0) != 0 {
            fatalError("Could not get the length of the cpu name")
        }

        var cpuName = [CChar](repeating: 0, count: Int(stringSize))
        if sysctlbyname("machdep.cpu.brand_string", &cpuName, &stringSize, nil, 0) != 0 {
            fatalError("Could not get the name of the cpu")
        }

        return String(cString: cpuName)
    }

    /**
     * Returns the name of the GPU. If there is no dedicated GPU the name of the internal GPU will be returned.
     */
    static func getGpuName() -> String {
        // taken from https://stackoverflow.com/a/32869978/9717671 and https://github.com/sebhildebrandt/systeminformation/blob/master/lib/graphics.js
        let task = Process()
        let outputPipe = Pipe()

        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPDisplaysDataType"]
        task.standardOutput = outputPipe
        task.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

        let output = NSString(data: outputData, encoding: String.Encoding.utf8.rawValue)! as String

        // seperate the lines
        let lines = output.split(separator: "\n")

        // create an array for the gpu info
        var gpuInfo: [GpuInfo] = []

        var lineIndex = 0
        while lineIndex < lines.count {
            // the first device infos starts with 6 spaces
            if lines[lineIndex].starts(with: "      ") {

                var deviceName = ""
                var bus = ""

                // iterate the infos of this device until the next line has less than 6 spaces
                while lineIndex < lines.count && lines[lineIndex].starts(with: "      ") {
                    let trimmedLine = lines[lineIndex].trimmingCharacters(in: .whitespacesAndNewlines)

                    if trimmedLine.starts(with: "Chipset Model: ") {
                        deviceName = trimmedLine.replacingOccurrences(of: "Chipset Model: ", with: "")
                    } else if trimmedLine.starts(with: "Bus: ") {
                        bus = trimmedLine.replacingOccurrences(of: "Bus: ", with: "")
                    }
                    lineIndex += 1
                }

                // add the gpu info to the array
                gpuInfo.append(GpuInfo(name: deviceName, bus: bus))

                continue
            }

            lineIndex += 1
        }

        // return the first built in gpu if there is any
        var gpuName = "No GPU found"
        for gpu in gpuInfo {
            if gpu.bus != "Built-In" {
                gpuName = gpu.name
            } else if gpuName == "No GPU found" && gpu.bus == "Built-In" {
                // if there was no other gpu found and the bus is built in, return the built in gpu
                gpuName = gpu.name
            }
        }

        return gpuName
    }

    /**
     * Returns the size of the internal disk in GB.
     */
    static func getDiskSize() -> Int {
        let task = Process()
        let outputPipe = Pipe()

        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPSerialATADataType", "SPNVMeDataType"]
        task.standardOutput = outputPipe
        task.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()

        let output = NSString(data: outputData, encoding: String.Encoding.utf8.rawValue)! as String

        let lines = output.split(separator: "\n")

        var lineIndex = 0
        while lineIndex < lines.count {
            if lines[lineIndex].starts(with: "      ") {

                print(lines[lineIndex])
            }

            lineIndex += 1
        }

        return 0
    }
}
