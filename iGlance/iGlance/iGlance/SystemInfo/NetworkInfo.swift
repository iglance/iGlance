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

class NetworkInfo {
    // MARK: -
    // MARK: Private Variables
    /// The total uploaded and downloaded bytes that were read during the last update interval of the app.
    /// This variable is used to calculate the network bandwidth using [getNetworkBandwidth()](x-source-tag://getNetworkBandwidth())
    private var lastTotalTransmittedBytes: (up: UInt64, down: UInt64) = (up: 0, down: 0)

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
        var upBytes: UInt64 = 0
        var downBytes: UInt64 = 0
        // if the lastTotalTransmittedBytes is greater than the current transmitted bytes, the currently used interface was changed
        if transmittedBytes.up >= self.lastTotalTransmittedBytes.up {
            upBytes = transmittedBytes.up - self.lastTotalTransmittedBytes.up
        }
        if transmittedBytes.down >= self.lastTotalTransmittedBytes.down {
            downBytes = transmittedBytes.down - self.lastTotalTransmittedBytes.down
        }

        // divide the bandwidth by the update interval to get the average of one update duration
        let upBandwidth = upBytes / UInt64(AppDelegate.userSettings.settings.updateInterval)
        let downBandwidth = downBytes / UInt64(AppDelegate.userSettings.settings.updateInterval)

        // update the total transmitted bytes
        self.lastTotalTransmittedBytes = transmittedBytes

        return (up: upBandwidth, down: downBandwidth)
    }

    /**
     * Returns the total transmitted bytes of an interface since booting the machine.
     */
    func getTotalTransmittedBytesOf(interface: String) -> (up: UInt64, down: UInt64) {
        // create the process to call the netstat commandline tool
        guard let commandOutput = executeCommand(launchPath: "/usr/bin/env", arguments: ["netstat", "-bdnI", interface]) else {
            DDLogError("An error occurred while executing the netstat command")
            return (up: 0, down: 0)
        }

        DDLogInfo("Output of network bandwidth command: \n\(commandOutput)")

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
        // idea is from https://apple.stackexchange.com/a/223446
        // get the srvice list
        let arguments = ["networksetup", "-listallhardwareports"]
        guard let netCmdOutput = executeCommand(launchPath: "/usr/bin/env", arguments: arguments) else {
            DDLogError("Something went wrong while executing the networksetup command")
            return "en0"
        }
        let interfaceList = netCmdOutput.split(separator: "\n")
            .filter { $0.contains("Device:") }
            .map { $0.replacingOccurrences(of: "Device: ", with: "") }

        // the default interface is en0
        var activeInterfaces = ["en0"]

        // get all the network interfaces of ifconfig
        guard let ifconfigInterfacesCommand = executeCommand(launchPath: "/usr/bin/env", arguments: ["ifconfig", "-lu"]) else {
            DDLogError("Something went wrong while executing the ifconfig command to retrieve all interfaces")
            return activeInterfaces[0]
        }
        let ifconfigInterfacesList = ifconfigInterfacesCommand
            .replacingOccurrences(of: "\n", with: "")
            .split(separator: " ")
            .map { String($0) }

        // iterate the list from top to bottom
        for interfaceName in interfaceList where ifconfigInterfacesList.contains(interfaceName) {
            // get more info about the current network interface
            guard let ifconfOutput = executeCommand(launchPath: "/usr/bin/env", arguments: ["ifconfig", interfaceName]) else {
                DDLogError("Something went wrong while executing the ifconfig command for interface \(interfaceName)")
                continue
            }

            // get the status line
            let statusString = ifconfOutput.split(separator: "\n")
                .filter { $0.contains("status:") }
                .map { $0.replacingOccurrences(of: "\tstatus: ", with: "") }

            // check if the string array is empty
            if statusString.isEmpty {
                DDLogInfo("Could not find a status string for interface \(interfaceName)")
                continue
            }

            // if we got more values log it, but proceed and check if one of them is active
            if statusString.count > 1 {
                DDLogError("Read more than one status string for interface \(interfaceName)")
            }

            if statusString.contains("active") && !activeInterfaces.contains(interfaceName) {
                // add the active interface to the list
                activeInterfaces.insert(interfaceName, at: 0)
            }
        }

        // return the first interface in the list
        return activeInterfaces[0]
    }
}
