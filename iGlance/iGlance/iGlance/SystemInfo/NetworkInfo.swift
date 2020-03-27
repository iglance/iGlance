//
//  NetworkInfo.swift
//  iGlance
//
//  Created by Dominik on 17.03.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class NetworkInfo {
    // MARK: -
    // MARK: Private Variables
    /// The total uploaded and downloaded bytes that were read during the last update interval of the app.
    /// This variable is used to calculate the network bandwidth using [getNetworkBandwidth()](x-source-tag://getNetworkBandwidth())
    private var totalTransmittedBytes: (up: UInt64, down: UInt64) = (up: 0, down: 0)

    // MARK: -
    // MARK: Instance Functions
    /**
     * Returns the current bandwidth of the given interface in bytes.
     *
     *  - Parameter interface: The name of the interface.
     *
     *  - Tag: getNetworkBandwidth()
     */
    func getNetworkBandwidth(interface: String) -> (up: UInt64, down: UInt64) {
        // get the total transmitted bytes of the interfafe
        let transmittedBytes = getTotalTransmittedBytesOf(interface: interface)

        // get the transmitted byte since the last update
        let upBytes = transmittedBytes.up - self.totalTransmittedBytes.up
        let downBytes = transmittedBytes.down - self.totalTransmittedBytes.down

        // divide the bandwidth by the update interval to get the average of one update duration
        let upBandwidth = upBytes / UInt64(AppDelegate.userSettings.settings.updateInterval)
        let downBandwidth = downBytes / UInt64(AppDelegate.userSettings.settings.updateInterval)

        // update the total transmitted bytes
        self.totalTransmittedBytes = transmittedBytes

        return (up: upBandwidth, down: downBandwidth)
    }

    /**
     * Returns the total transmitted bytes of an interface since booting the machine.
     */
    func getTotalTransmittedBytesOf(interface: String) -> (up: UInt64, down: UInt64) {
        // create the process to call the netstat commandline tool
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["netstat", "-bdnI", interface]

        // create a pipe to get the output of the command
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        // get the output as a string
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let commandOutput = String(data: data, encoding: String.Encoding.utf8) else {
            DDLogError("An error occurred while casting the command output to a string")
            return (up: 0, down: 0)
        }

        DDLogInfo("Output of network bandwidth command: \(commandOutput)")

        // split the lines of the output
        let lowerCaseOutput = commandOutput.lowercased()
        let lines = lowerCaseOutput.split(separator: "\n")

        // check that there are more than one lines. If not the network interface is unknown or something else went wrong
        if lines.count <= 1 {
            DDLogError("Something went wrong while parsing the network bandwidth command output")
            return (up: 0, down: 0)
        }

        // create a regex to replace multiple spaces with just one space
        guard let regex = try? NSRegularExpression(pattern: "/ +/g") else {
            DDLogError("Failed to create the regex")
            return (up: 0, down: 0)
        }
        // take the second line since the first line are just the column names of the table
        let firstLine = String(lines[1])
        // replace all whitespaces to just one whitespace
        let cleanedFirstLine = regex.stringByReplacingMatches(in: firstLine, options: [], range: NSRange(location: 0, length: firstLine.count), withTemplate: " ")
        // split the line at the spaces to get the columns of the table
        let columns = cleanedFirstLine.split(separator: " ")

        // get the total down- and uploaded bytes
        guard let totalDownBytes = UInt64(String(columns[6])), let totalUpBytes = UInt64(String(columns[9])) else {
            DDLogError("Something went wrong while retrieving the down- and uploaded bytes")
            return (up: 0, down: 0)
        }

        return (up: totalUpBytes, down: totalDownBytes)
    }

    /**
     * Returns the name of the currently used network interface as a string. If something went wrong the default network interface "en0" is returned.
     */
    func getCurrentlyUsedInterface() -> String {
        // create the process for the command
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", "route get 0.0.0.0 2>/dev/null | grep interface: | awk '{print $2}'"]

        // create the pipe for the output
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()

        // get the command output
        let commandOutput = pipe.fileHandleForReading.readDataToEndOfFile()

        // get the currently used interface
        guard let commandString = String(data: commandOutput, encoding: String.Encoding.utf8) else {
            DDLogError("Something went wrong while casting the command output to a string")
            return "en0"
        }

        // get the interface name
        let interfaceName = commandString.trimmingCharacters(in: .whitespacesAndNewlines)

        return interfaceName.isEmpty ? "en0" : interfaceName
    }
}
