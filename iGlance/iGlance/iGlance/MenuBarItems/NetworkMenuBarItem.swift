//
//  NetworkMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 09.03.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class NetworkMenuBarItem: MenuBarItem {
    override init() {
        // before showing the network bandwidth menu bar icon get the bandwidth
        // once to prevent random values in the menu bar because of wrong last up- and downloaded total bytes
        let interface = AppDelegate.systemInfo.network.getCurrentlyUsedInterface()
        AppDelegate.systemInfo.network.getNetworkBandwidth(interface: interface)

        super.init()
    }

    func update() {
        // get the button of the menu bar item
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'NetworkMenuBarItem'")
            return
        }

        // get the currently used network interface
        let interfaceName = AppDelegate.systemInfo.network.getCurrentlyUsedInterface()

        // get the bandwidth
        let bandwidth = AppDelegate.systemInfo.network.getNetworkBandwidth(interface: interfaceName)
        let networkBandwidthUp = convertToCorrectUnit(bytes: bandwidth.up)
        let networkBandwidthDown = convertToCorrectUnit(bytes: bandwidth.down)

        let menuBarImage = createMenuBarImage(up: networkBandwidthUp, down: networkBandwidthDown)

        // set the menu bar item image
        button.image = menuBarImage
    }

    /**
     *  Takes the bandwidth in bytes and returns the correct value according to the unit as a string and the correct unit (KB/s, MB/s, GB/s) as a string.
     *  If the given value of bytes is smaller than 1000 the function will return a value of zero and as unit "KB/s".
     *  The biggest unit that can be used to display the bandwidth with a value greater than 1 is used:
     *
     *      Examples:
     *          512 Bytes -> (value: "0", unit: "KB/s")
     *          5_000 Bytes -> (value: "5", unit: "KB/s")
     *          5_000_000 Bytes -> (value: "5", unit: "MB/s")
     *          5_000_000_000 Bytes -> (value: "5", unit: "GB/s")
     *
     */
    private func convertToCorrectUnit(bytes: UInt64) -> (value: String, unit: String) {
        // set the default values for the variables
        var value = "0"
        var unit = "KB/s"

        // get the value and the unit
        if bytes > 1_000_000_000 {
            // Gigabyte per second
            let gigabyteValue = Double(bytes) / 1_000_000_000.0
            // if the value is greater than 100 don't display the decimal places
            value = gigabyteValue >= 100 ? String(Int(gigabyteValue)) : String(format: "%.2f", gigabyteValue)
            unit = "GB/s"
        } else if bytes > 1_000_000 {
            // Megabytes per second
            let megabyteValue = Double(bytes) / 1_000_000
            // if the value is greater than 100 don't display the decimal places
            value = megabyteValue >= 100 ? String(Int(megabyteValue)) : String(format: "%.2f", megabyteValue)
            unit = "MB/s"
        } else if bytes > 1000 {
            // Kilobyte per second
            value = String(Int(bytes / 1000))
            unit = "KB/s"
        }

        return (value: value, unit: unit)
    }

    /**
     * Returns the image that can be rendered on the menu bar.
     */
    private func createMenuBarImage(up: (value: String, unit: String), down: (value: String, unit: String)) -> NSImage? {
        // create the attributed strings for the upload and download
        let uploadString = self.createAttributedBandwidthString(value: up.value, unit: up.unit)
        let downloadString = self.createAttributedBandwidthString(value: down.value, unit: up.unit)

        // get the bandwidth icon
        guard let bandwidthIcon = NSImage(named: "NetworkBandwidthIcon@2") else {
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
        let font = NSFont(name: "Apple SD Gothic Neo Light", size: 10)!

        // add the attributes
        attrString.addAttribute(.font, value: font, range: NSRange(location: 0, length: attrString.length - 1 - unit.count))
        //attrString.addAttribute(.kern, value: 1.2, range: NSRange(location: 0, length: attrString.length - 1 - unit.count))
        attrString.addAttribute(.font, value: font, range: NSRange(location: attrString.length - unit.count, length: unit.count))
        let fontColor = ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        attrString.addAttribute(.foregroundColor, value: fontColor, range: NSRange(location: 0, length: attrString.length))

        return attrString
    }
}
