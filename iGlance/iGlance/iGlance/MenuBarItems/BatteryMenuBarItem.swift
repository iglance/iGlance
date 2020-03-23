//
//  BatterymenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 22.03.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack
import IOKit.ps

class BatteryMenuBarItem: MenuBarItem {
    func update() {
        // get the button of the menu bar item
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'BatteryMenuBarItem'")
            return
        }

        // get the state of the internal battery
        let batteryState = AppDelegate.systemInfo.battery.getInternalBatteryState()

        var buttonString: NSAttributedString

        // define the attributes
        let attributes = [
            NSAttributedString.Key.font: NSFont(name: "Apple SD Gothic Neo", size: 14)!,
            NSAttributedString.Key.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        ]

        switch batteryState {
        case .calculatingRemainingTime:
            buttonString = NSAttributedString(string: "Calculating", attributes: attributes)
        case .charging:
            buttonString = getTimeToFullString()
        case .discharging:
            buttonString = getTimeToEmptyString()
        case .fullyCharged:
            buttonString = NSAttributedString(string: "Charged", attributes: attributes)
        case .notCharging:
            buttonString = NSAttributedString(string: "Not Charging", attributes: attributes)
        default:
            buttonString = NSAttributedString(string: "Error", attributes: attributes)
        }

        // get info about the battery to determin which icon to use
        let isOnAC = AppDelegate.systemInfo.battery.isOnAC()
        let isCharging = AppDelegate.systemInfo.battery.isCharging()

        var batteryIcon: NSImage?
        if isOnAC && isCharging {
            batteryIcon = NSImage(named: "BatteryIconCharging")
        } else if isOnAC && !isCharging {
            batteryIcon = NSImage(named: "BatteryIconPlugged")
        } else if !isCharging && !isOnAC || !isOnAC && isCharging {
            // the case !isOnAC && isCharging occurs when the machine is unplugged from AC and the remaining time is still calculated
            batteryIcon = NSImage(named: "BatteryIcon")
        }

        // the battery icon is nil loading the icon failed
        if batteryIcon == nil {
            DDLogError("Failed to load the battery icon (battery state: \(batteryState)")
            return
        }

        // create the menu bar image
        let marginBetweenIconAndString = CGFloat(5)
        let image = NSImage(size: NSSize(width: buttonString.size().width + batteryIcon!.size.width + marginBetweenIconAndString, height: 18))

        // lock the image to render the string
        image.lockFocus()

        // render the string
        buttonString.draw(at: NSPoint(x: image.size.width - buttonString.size().width, y: image.size.height / 2 - buttonString.size().height / 2))

        // tint the battery icon to match it to the theme of the os
        let tintedBatteryIcon = batteryIcon!.tint(color: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black)
        // render the battery icon
        tintedBatteryIcon.draw(at: NSPoint(x: 0, y: 18 / 2 - tintedBatteryIcon.size.height / 2), from: NSRect.zero, operation: .sourceOver, fraction: 1.0)

        // unlock the focus of the image
        image.unlockFocus()

        button.image = image
    }

    /**
     * Returns the string of the remaining time until the battery is fully charged.
     */
    func getTimeToFullString() -> NSAttributedString {
        // get the time until fully charged
        let timeToFullMinutes = AppDelegate.systemInfo.battery.timeToFullCharge()
        let timeToFull = convertMinutesToHours(minutes: timeToFullMinutes)
        let timeToFullString = "\(timeToFull.hours):\(String(format: "%02d", timeToFull.minutes))"

        // define the attributes
        let attributes = [
            NSAttributedString.Key.font: NSFont(name: "Apple SD Gothic Neo", size: 14)!,
            NSAttributedString.Key.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        ]

        return NSAttributedString(string: timeToFullString, attributes: attributes)
    }

    /**
     * Returns the string of the remaining time until the battery is empty.
     */
    func getTimeToEmptyString() -> NSAttributedString {
        // get the time until fully charged
        let timeToEmptyMinutes = AppDelegate.systemInfo.battery.timeToEmpty()
        let timeToEmpty = convertMinutesToHours(minutes: timeToEmptyMinutes)
        let timeToEmptyString = "\(timeToEmpty.hours):\(String(format: "%02d", timeToEmpty.minutes))"

        // define the attributes
        let attributes = [
            NSAttributedString.Key.font: NSFont(name: "Apple SD Gothic Neo", size: 14)!,
            NSAttributedString.Key.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        ]

        return NSAttributedString(string: timeToEmptyString, attributes: attributes)
    }

    /**
     * Converts the given number of minutes into hours and minutes. If a value below zero is provided the function will return (hours: 0, minutes: 0).
     */
    func convertMinutesToHours(minutes: Int) -> (hours: Int, minutes: Int) {
        if minutes <= 0 {
            return (hours: 0, minutes: 0)
        }

        let hours = Int(floor(Double(minutes) / 60))
        let minutes = minutes % 60

        return (hours: hours, minutes: minutes)
    }

    /**
     * Returns the string that is displaying the current charge of the battery in percentage.
     */
    func getPercentageString() -> String {
        let charge = AppDelegate.systemInfo.battery.getCharge()

        return "\(charge)%"
    }
}
