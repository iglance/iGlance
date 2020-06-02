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

/**
 * Executes the program that is located at the given launch path with the given arguments.
 *
 * - Returns: The output of the command as a string.
 */
func executeCommand(launchPath: String, arguments: [String]) -> String? {
    let task = Process()
    let outputPipe = Pipe()

    // execute the command
    task.launchPath = launchPath
    task.arguments = arguments
    task.standardOutput = outputPipe
    task.launch()
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = String(data: outputData, encoding: String.Encoding.utf8) else {
        DDLogError("An error occurred while casting the command output to a string")
        return nil
    }

    task.waitUntilExit()

    return output
}

/**
 *  Takes the amount of space in bytes and returns the correct value according to the unit as a string and the correct unit (KB, MB, GB, TB).
 *
 *  - Parameter bytes: The given number of bytes
 *
 *  # Examples:
 *
 *      512 Bytes -> (value: "512", unit: "B")
 *      5_000 Bytes -> (value: "5", unit: "KB")
 *      5_000_000 Bytes -> (value: "5", unit: "MB")
 *      5_000_000_000 Bytes -> (value: "5", unit: "GB")
 */
func convertToCorrectUnit(bytes: Int) -> (value: Double, unit: SystemInfo.ByteUnit) {
    if bytes < 1000 {
        return (value: Double(bytes), unit: SystemInfo.ByteUnit.Byte)
    }
    let exp = Int(log2(Double(bytes)) / log2(1000.0))
    let unitString = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
    let unit = SystemInfo.ByteUnit(rawValue: unitString) ?? SystemInfo.ByteUnit.Gigabyte
    let number = Double(bytes) / pow(1000, Double(exp))

    return (value: number, unit: unit)
}
