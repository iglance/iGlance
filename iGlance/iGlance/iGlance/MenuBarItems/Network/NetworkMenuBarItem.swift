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

class NetworkMenuBarItem: MenuBarItem {
    // MARK: -
    // MARK: Private Variables
    /// The menu entry to reset the network stats that are displayed in the menu
    private let resetMenuEntry = NSMenuItem(title: "Reset statistic", action: #selector(resetNetworkStats), keyEquivalent: "r")
    /// The network statistics view that is displayed in the menu bar item menu
    let networkStatsMenuView = NetworkStatisticsMenuView(frame: NSRect(x: 0, y: 0, width: 250, height: 50))

    /// The total transmitted bytes that were read on the last reset
    private var totalBytesOnLastReset: [String: (up: UInt64, down: UInt64)] = [:]
    /// The transmitted bytes since the last reset of every interface
    private var transmittedBytesPerInterface: [String: (up: UInt64, down: UInt64)] = [:]

    // MARK: -
    // MARK: Overridden Functions
    override init() {
        // before showing the network bandwidth menu bar icon get the bandwidth
        // once to prevent random values in the menu bar because of wrong last up- and downloaded total bytes
        let interface = AppDelegate.systemInfo.network.getCurrentlyUsedInterface()
        _ = AppDelegate.systemInfo.network.getNetworkBandwidth(interface: interface)

        super.init()

        // add the menu entrys

        let networkStatsMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        networkStatsMenuItem.view = networkStatsMenuView

        resetMenuEntry.target = self
        menuItems.append(contentsOf: [networkStatsMenuItem, resetMenuEntry, NSMenuItem.separator()])

        // get the bandwidth once to initialize the values internally. The effect of this call is that the bandwidth value on startup is 0
        _ = AppDelegate.systemInfo.network.getNetworkBandwidth(interface: interface)

        // set the total down and up loaded bytes once on start
        let totalTransmittedBytes = AppDelegate.systemInfo.network.getTotalTransmittedBytesOf(interface: interface)
        self.totalBytesOnLastReset[interface] = totalTransmittedBytes
    }

    func update() {
        // get the currently used network interface
        let interfaceName = AppDelegate.systemInfo.network.getCurrentlyUsedInterface()

        updateMenuBarMenu(currentInterface: interfaceName)
        updateMenuBarIcon(currentInterface: interfaceName)
    }

    /**
     * Updates the icon of the menu bar item. This function is called during every update interval.
     *
     * - Parameter currentInterface: The name of the currently used interface.
     */
    func updateMenuBarIcon(currentInterface: String) {
        // get the button of the menu bar item
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'NetworkMenuBarItem'")
            return
        }

        // get the bandwidth
        let bandwidth = AppDelegate.systemInfo.network.getNetworkBandwidth(interface: currentInterface)
        let networkBandwidthUp = convertToCorrectUnit(bytes: bandwidth.up, perSecond: true)
        let networkBandwidthDown = convertToCorrectUnit(bytes: bandwidth.down, perSecond: true)

        let menuBarImage = createMenuBarImage(up: networkBandwidthUp, down: networkBandwidthDown)

        // set the menu bar item image
        button.image = menuBarImage
    }

    /**
     * Updates the menu of the menu bar item. This function is called during every update interval.
     *
     * - Parameter currentInterface: The name of the currently used interface
     */
    func updateMenuBarMenu(currentInterface: String) {
        // update the values of the current interface
        if let currentInterfaceLastResetValue = self.totalBytesOnLastReset[currentInterface] {
            // get the total transmitted bytes of that interface
            let transmittedBytes = AppDelegate.systemInfo.network.getTotalTransmittedBytesOf(interface: currentInterface)

            // get the difference of the currently total transmitted bytes and the total transmitted bytes on the last reset
            var bytesUploaded = transmittedBytes.up
            var bytesDownloaded = transmittedBytes.down
            if transmittedBytes.up > currentInterfaceLastResetValue.up {
                bytesUploaded = transmittedBytes.up - currentInterfaceLastResetValue.up
            }
            if transmittedBytes.down > currentInterfaceLastResetValue.down {
                bytesDownloaded = transmittedBytes.down - currentInterfaceLastResetValue.down
            }

            // update the dictionary
            self.transmittedBytesPerInterface[currentInterface] = (up: bytesUploaded, down: bytesDownloaded)
        } else {
            // if the last reset value of the current interface is not available set it
            let transmittedBytes = AppDelegate.systemInfo.network.getTotalTransmittedBytesOf(interface: currentInterface)
            self.totalBytesOnLastReset[currentInterface] = transmittedBytes
        }

        // add the transmitted bytes of every interface together
        var totalBytesUploaded: UInt64 = 0
        var totalBytesDownloaded: UInt64 = 0
        for interface in self.transmittedBytesPerInterface.keys {
            // get the transmitted bytes of the current interface
            let currentTransmittedBytes = self.transmittedBytesPerInterface[interface]!
            totalBytesUploaded += currentTransmittedBytes.up
            totalBytesDownloaded += currentTransmittedBytes.down
        }

        // convert the total and up/down-loaded bytes to the correct unit
        let convertedUp = convertToCorrectUnit(bytes: totalBytesUploaded, perSecond: false)
        let convertedDown = convertToCorrectUnit(bytes: totalBytesDownloaded, perSecond: false)
        let convertedTotal = convertToCorrectUnit(bytes: totalBytesUploaded + totalBytesDownloaded, perSecond: false)

        // update the menu view
        networkStatsMenuView.setUploadLabel("\(convertedUp.value) \(convertedUp.unit)")
        networkStatsMenuView.setDownloadLabel("\(convertedDown.value) \(convertedDown.unit)")
        networkStatsMenuView.setTotalLabel("\(convertedTotal.value) \(convertedTotal.unit)")
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Resets the total bytes downloaded and the total bytes uploaded.
     */
    @objc
    private func resetNetworkStats() {
        // get the currently used interface
        let interfaceName = AppDelegate.systemInfo.network.getCurrentlyUsedInterface()

        // remove all interfaces from the dictionaries
        for interface in self.totalBytesOnLastReset.keys {
            self.totalBytesOnLastReset.removeValue(forKey: interface)
        }

        for interface in self.transmittedBytesPerInterface.keys {
            self.transmittedBytesPerInterface.removeValue(forKey: interface)
        }

        // reset the total transmitted bytes for the currently used interface
        self.totalBytesOnLastReset[interfaceName] = AppDelegate.systemInfo.network.getTotalTransmittedBytesOf(interface: interfaceName)
    }

    /**
     *  Takes the bandwidth in bytes and returns the correct value according to the unit as a string and the correct unit (KB/s, MB/s, GB/s) as a string.
     *  If the given value of bytes is smaller than 1000 the function will return a value of zero and as unit "KB/s".
     *  The biggest unit that can be used to display the bandwidth with a value greater than 1 is used:
     *
     *  - Parameter bytes: The given number of bytes
     *  - Parameter perSecond: Whether the returned unit should be per second
     *
     *      Examples:
     *          512 Bytes -> (value: "0", unit: "KB/s")
     *          5_000 Bytes -> (value: "5", unit: "KB/s")
     *          5_000_000 Bytes -> (value: "5", unit: "MB/s")
     *          5_000_000_000 Bytes -> (value: "5", unit: "GB/s")
     *
     */
    private func convertToCorrectUnit(bytes: UInt64, perSecond: Bool) -> (value: String, unit: String) {
        let perSecondString = perSecond ? "/s" : ""

        // set the default values for the variables
        var value = "0"
        var unit = "KB" + perSecondString

        // get the value and the unit
        if bytes > 1_000_000_000 {
            // Gigabyte per second
            let gigabyteValue = Double(bytes) / 1_000_000_000
            // if the value is greater than 100 don't display the decimal places
            value = gigabyteValue >= 100 ? String(Int(gigabyteValue)) : String(format: "%.2f", gigabyteValue)
            unit = "GB" + perSecondString
        } else if bytes > 1_000_000 {
            // Megabytes per second
            let megabyteValue = Double(bytes) / 1_000_000
            // if the value is greater than 100 don't display the decimal places
            value = megabyteValue >= 100 ? String(Int(megabyteValue)) : String(format: "%.2f", megabyteValue)
            unit = "MB" + perSecondString
        } else if bytes > 1000 {
            // Kilobyte per second
            value = String(Int(bytes / 1000))
            unit = "KB" + perSecondString
        }

        return (value: value, unit: unit)
    }

    /**
     * Returns the image that can be rendered on the menu bar.
     */
    private func createMenuBarImage(up: (value: String, unit: String), down: (value: String, unit: String)) -> NSImage? {
        // create the attributed strings for the upload and download
        let uploadString = self.createAttributedBandwidthString(value: up.value, unit: up.unit)
        let downloadString = self.createAttributedBandwidthString(value: down.value, unit: down.unit)

        // get the bandwidth icon
        guard let bandwidthIcon = NSImage(named: "NetworkBandwidthIcon") else {
            DDLogError("An error occurred while loading the bandwidth menu bar icon")
            return nil
        }

        // create the menu bar image for the bandwidth.
        let bandwidthTextWidth = CGFloat(55)
        let bandwidthIconWidth = bandwidthIcon.size.width
        let menuBarImage = NSImage(size: NSSize(width: bandwidthTextWidth + bandwidthIconWidth, height: 18))

        // focus the image to render the bandwidth values
        menuBarImage.lockFocus()

        // draw the upload string
        let uploadStringSize = uploadString.size()
        uploadString.draw(at: NSPoint(x: bandwidthIconWidth + bandwidthTextWidth - uploadStringSize.width, y: 6))

        // draw the download string
        let downloadStringsize = downloadString.size()
        downloadString.draw(at: NSPoint(x: bandwidthIconWidth + bandwidthTextWidth - downloadStringsize.width, y: -3))

        // tint the icon to have the correct color depending on the current theme
        let tintedBandwidthIcon = bandwidthIcon.tint(color: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black)

        // draw the bandwidth icon in front of the upload and download string
        tintedBandwidthIcon.draw(at: NSPoint(x: 0, y: 18 / 2 - tintedBandwidthIcon.size.height / 2), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

        // unlock the focous of drawing
        menuBarImage.unlockFocus()

        return menuBarImage
    }

    /**
     * Creates an attributed string that can be drawn on the menu bar image.
     */
    private func createAttributedBandwidthString(value: String, unit: String) -> NSAttributedString {
        // create the attributed string
        let attrString = NSMutableAttributedString(string: value + " " + unit)

        // define the font for the number value and the unit
        let font = NSFont.systemFont(ofSize: 9)

        // add the attributes
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attrString.length - 1 - unit.count))
        attrString.addAttribute(.kern, value: 1.2, range: NSRange(location: 0, length: attrString.length - 1 - unit.count))
        attrString.addAttribute(.font, value: font, range: NSRange(location: attrString.length - unit.count, length: unit.count))
        let fontColor = ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        attrString.addAttribute(.foregroundColor, value: fontColor, range: NSRange(location: 0, length: attrString.length))

        return attrString
    }
}
