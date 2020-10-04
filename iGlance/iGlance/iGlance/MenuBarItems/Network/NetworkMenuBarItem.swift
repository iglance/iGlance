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

    /// The minimum width of the network menu bar item
    private var minMenuBarItemWidth = CGFloat(55)

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
        self.statusItem.isVisible = AppDelegate.userSettings.settings.network.showBandwidth
        if !self.statusItem.isVisible {
            return
        }
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
        let networkBandwidthUp = convertToCorrectUnit(bytes: Int(bandwidth.up))
        let networkBandwidthDown = convertToCorrectUnit(bytes: Int(bandwidth.down))

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
        let convertedUp = convertToCorrectUnit(bytes: Int(totalBytesUploaded))
        let convertedDown = convertToCorrectUnit(bytes: Int(totalBytesDownloaded))
        let convertedTotal = convertToCorrectUnit(bytes: Int(totalBytesUploaded + totalBytesDownloaded))

        // update the menu view
        let upValueString = convertedUp.unit >= .Gigabyte ? String(format: "%.1f", convertedUp.value) : String(format: "%.2f", convertedUp.value)
        let downValueString = convertedDown.unit >= .Gigabyte ? String(format: "%.1f", convertedDown.value) : String(format: "%.2f", convertedDown.value)
        let totalValueString = convertedTotal.unit >= .Gigabyte ? String(format: "%.1f", convertedTotal.value) : String(format: "%.2f", convertedTotal.value)
        networkStatsMenuView.setUploadLabel("\(upValueString) \(convertedUp.unit.rawValue)")
        networkStatsMenuView.setDownloadLabel("\(downValueString) \(convertedDown.unit.rawValue)")
        networkStatsMenuView.setTotalLabel("\(totalValueString) \(convertedTotal.unit.rawValue)")
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
     * Returns the image that can be rendered on the menu bar.
     */
    private func createMenuBarImage(up: (value: Double, unit: SystemInfo.ByteUnit), down: (value: Double, unit: SystemInfo.ByteUnit)) -> NSImage? {
        let valueStringUp = up.unit < .Megabyte ? String(Int(up.value)) : String(format: "%.2f", up.value)
        let valueStringDown = down.unit < .Megabyte ? String(Int(down.value)) : String(format: "%.2f", down.value)

        // create the attributed strings for the upload and download
        let uploadString = self.createAttributedBandwidthString(value: valueStringUp, unit: up.unit.rawValue + "/s")
        let downloadString = self.createAttributedBandwidthString(value: valueStringDown, unit: down.unit.rawValue + "/s")

        // get the bandwidth icon
        guard let bandwidthIcon = NSImage(named: "NetworkBandwidthIcon") else {
            DDLogError("An error occurred while loading the bandwidth menu bar icon")
            return nil
        }

        // create the menu bar image for the bandwidth.
        let bandwidthTextWidth = max(self.minMenuBarItemWidth, max(uploadString.size().width, downloadString.size().width))
        let bandwidthIconWidth = bandwidthIcon.size.width
        let marginToIcons = CGFloat(5)
        let menuBarImage = NSImage(
            size: NSSize(
                width: bandwidthTextWidth + bandwidthIconWidth + marginToIcons,
                height: CGFloat(self.menuBarHeight)
            )
        )

        // focus the image to render the bandwidth values
        menuBarImage.lockFocus()

        // draw the upload string
        let uploadStringSize = uploadString.size()
        uploadString.draw(
            at: NSPoint(
                x: bandwidthIconWidth + marginToIcons + bandwidthTextWidth - uploadStringSize.width,
                y: menuBarImage.size.height - 11 // this value was found by trail and error
            )
        )

        // draw the download string
        let downloadStringsize = downloadString.size()
        // y value was found by trail and error
        downloadString.draw(at: NSPoint(x: bandwidthIconWidth + marginToIcons + bandwidthTextWidth - downloadStringsize.width, y: -2))

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
