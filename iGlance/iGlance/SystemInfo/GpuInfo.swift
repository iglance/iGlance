//
//  GpuInfo.swift
//  iGlance
//
//  Created by Dominik on 24.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Foundation
import os.log

class GpuInfo {
    struct GpuInfo {
        let name: String
        let bus: String
    }

    /**
     * Returns the name of the GPU. If there is no dedicated GPU the name of the internal GPU will be returned.
     *
     * - Returns: The name of the GPU (e.g. Radeon Pro 560X)
     */
    func getGpuName() -> String {
        // taken from https://stackoverflow.com/a/32869978/9717671
        // and https://github.com/sebhildebrandt/systeminformation/blob/master/lib/graphics.js
        let task = Process()
        let outputPipe = Pipe()

        // execute the system_profiler command
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPDisplaysDataType"]
        task.standardOutput = outputPipe
        task.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: outputData, encoding: String.Encoding.utf8.rawValue)! as String

        // seperate the lines
        let lines = output.split(separator: "\n")

        // check that the command was successful by checking the first line
        if !lines[0].contains("Graphics/Displays:") {
            os_log("Command to retrieve the GPU name failed.", type: .error)
            return ""
        }

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

        // return the first dedicated gpu if there is any
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
}
