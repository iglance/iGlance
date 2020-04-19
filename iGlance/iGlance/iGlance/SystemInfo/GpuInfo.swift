//  Copyright (C) 2020  D0miH <https://github.com/D0miH> & Contributors <https://github.com/iglance/iGlance/graphs/contributors>
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import Foundation
import CocoaLumberjack

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
        // pretty similar to https://github.com/sebhildebrandt/systeminformation/blob/master/lib/graphics.js
        guard let output = executeCommand(launchPath: "/usr/sbin/system_profiler", arguments: ["SPDisplaysDataType"]) else {
            DDLogError("An error occurred while executing the system_profiler command")
            return ""
        }

        DDLogInfo("Output of gpu name command: \n\(output)")

        // seperate the lines
        let lines = output.split(separator: "\n")

        // check that the command was successful by checking the first line
        if !lines[0].contains("Graphics/Displays:") {
            DDLogError("Command to retrieve the GPU name failed")
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
                DDLogInfo("Set the gpu name to \(gpuName)")
            } else if gpuName == "No GPU found" && gpu.bus == "Built-In" {
                // if there was no other gpu found and the bus is built in, return the built in gpu
                gpuName = gpu.name
                DDLogInfo("Set the gpu name to \(gpuName)")
            }
        }

        return gpuName
    }
}
