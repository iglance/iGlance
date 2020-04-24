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

class DiskInfo {
    /**
     * Returns a tuple with the first element beeing the size of the
     * disk and the second element beeing the unit (e.g. MB, GB, TB...).
     */
//    func getInternalDiskSize() -> (Int, String) {
//        guard let output = executeCommand(launchPath: "/usr/sbin/system_profiler", arguments: ["SPNVMeDataType", "SPSerialATADataType"]) else {
//            DDLogError("An error occurred while executing the system_profiler command")
//
//            return (0, "")
//        }
//
//        DDLogInfo("Output of internal disk size command: \n\(output)")
//
//        // get all the devices
//        var devices = output.components(separatedBy: "\n\n          Capacity:")
//        if devices.isEmpty {
//            DDLogError("Could not find the keyword 'Capacity' in the command output")
//            return (0, "")
//        }
//
//        // remove the name of the disk
//        devices.removeFirst()
//
//        for device in devices {
//            let deviceLines = device.split(separator: "\n")
//
//            // the capacity is the first line the second part of the line
//            let lineParts = deviceLines[0].components(separatedBy: " ")
//            let size = Int(Float(lineParts[1].replacingOccurrences(of: ",", with: "."))!)
//            // unit is the third part of the line
//            let unit = String(lineParts[2])
//
//            for deviceLine in deviceLines {
//                if deviceLine.contains("Detachable Drive: No") {
//                    // if the current device is not detachable return the size of this device
//                    return (size, unit)
//                }
//            }
//        }
//
//        // if no capacity was found return a default value
//        return (0, "")
//    }

    /**
    *  Takes the amount of space in bytes and returns the correct value according to the unit as a string and the correct unit (KB, MB, GB, TB) as a string.
    *  If the given value of bytes is smaller than 1000 the function will return a value as is and unit of "B".
    *
    *  - Parameter bytes: The given number of bytes
    *
    *      Examples:
    *          512 Bytes -> (value: "512", unit: "B")
    *          5_000 Bytes -> (value: "5", unit: "KB")
    *          5_000_000 Bytes -> (value: "5", unit: "MB")
    *          5_000_000_000 Bytes -> (value: "5", unit: "GB")
    *
    */
    static func convertToCorrectUnit(bytes: Int) -> (value: String, unit: String) {
        if bytes < 1000 {
            return (value: "\(bytes)", unit: "B")
        }
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))

        return (value: String(format: "%.1f", number), unit: unit)
    }

    /**
     *  Returns the named tuple of used disk space and free disk space in bytes
     */
    static func getFreeDiskUsageInfo() -> (usedSpace: Int, freeSpace: Int) {
        let fileURL = URL(fileURLWithPath: "/")
        do {
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            let totalSpace = values.volumeTotalCapacity
            let freeSpace = values.volumeAvailableCapacity
            return (totalSpace! - freeSpace!, freeSpace!)
        } catch {
            DDLogError("Error retrieving capacity: \(error.localizedDescription)")
        }
        return (0, 0)
    }
}
