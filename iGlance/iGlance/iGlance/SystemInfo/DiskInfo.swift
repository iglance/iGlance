//
//  DiskInfo.swift
//  iGlance
//
//  Created by Dominik on 04.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class DiskInfo {
    /**
     * Returns a tuple with the first element beeing the size of the
     * disk and the second element beeing the unit (e.g. MB, GB, TB...).
     */
    func getInternalDiskSize() -> (Int, String) {
        let task = Process()
        let outputPipe = Pipe()

        // execute the system_profiler command
        task.launchPath = "/usr/sbin/system_profiler"
        task.arguments = ["SPNVMeDataType"]
        task.standardOutput = outputPipe
        task.launch()
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: outputData, encoding: String.Encoding.utf8) else {
            DDLogError("An error occurred while casting the command output to a string")
            return (0, "")
        }

        DDLogInfo("Output of internal disk size command: \(output)")

        // check that the command was successful by checking the first line
        if !output.split(separator: "\n")[0].contains("NVMExpress:") {
            DDLogError("Command to retrieve the disk size failed.")
            return (0, "")
        }

        // get all the devices
        var devices = output.components(separatedBy: "\n\n          Capacity:")
        // remove the name of the disk
        devices.removeFirst()

        for device in devices {
            let deviceLines = device.split(separator: "\n")

            // the capacity is the first line the second part of the line
            let lineParts = deviceLines[0].components(separatedBy: " ")
            let size = Int(Float(lineParts[1].replacingOccurrences(of: ",", with: "."))!)
            // unit is the third part of the line
            let unit = String(lineParts[2])

            for deviceLine in deviceLines {
                if deviceLine.contains("Detachable Drive: No") {
                    // if the current device is not detachable return the size of this device
                    return (size, unit)
                }
            }
        }

        // if no capacity was found return a default value
        return (0, "")
    }
}
