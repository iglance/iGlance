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
    // MARK: -
    // MARK: Private Variables
    private var chargeMenuEntry = NSMenuItem(title: "Charge: N/A%", action: nil, keyEquivalent: "")
    private var remainingTimeMenuEntry = NSMenuItem(title: "Remaining: N/A", action: nil, keyEquivalent: "")

    override init() {
        super.init()

        // update the title of the menu entries
        let charge = AppDelegate.systemInfo.battery.getCharge()
        chargeMenuEntry.title = "Charge: \(charge)%"
        let batteryState = AppDelegate.systemInfo.battery.getInternalBatteryState()
        let remainingTime = getRemainingTimeString(batteryState: batteryState)
        remainingTimeMenuEntry.title = "Remaining: \(remainingTime.string)"

        // add them to the menu
        menuItems.append(contentsOf: [chargeMenuEntry, remainingTimeMenuEntry, NSMenuItem.separator()])
    }

    // MARK: -
    // MARK: Protocol Implementations

    func update() {
        // get the current charge
        let currentCharge = AppDelegate.systemInfo.battery.getCharge()
        // get the state of the internal battery
        let batteryState = AppDelegate.systemInfo.battery.getInternalBatteryState()
        // get whether the battery is on AC
        let isOnAC = AppDelegate.systemInfo.battery.isOnAC()
        // get whether the battery is charging
        let isCharging = AppDelegate.systemInfo.battery.isCharging()
        // get whether the battery is charged
        let isCharged = AppDelegate.systemInfo.battery.isFullyCharged()

        updateMenuBarIcon(currentCharge: currentCharge, isOnAC: isOnAC, isCharging: isCharging, isCharged: isCharged, batteryState: batteryState)
        updateMenuBarMenu(currentCharge: currentCharge, batteryState: batteryState)
    }

    // MARK: -
    // MARK: Private Functions

    /**
     * Updates the icon of the menu bar item. This function is called during every update interval.
     *
     * - Parameter currentCharge: The current charg of the battery in percentage
     * - Parameter isOnAC: Indicates whether the battery is currently on AC
     * - Parameter isCharging: Indicates whether the battery is currently charging.
     * - Parameter batteryState: The internal state object of the battery.
     */
    private func updateMenuBarIcon(currentCharge: Int, isOnAC: Bool, isCharging: Bool, isCharged: Bool, batteryState: InternalBatteryState) {
        // get the button of the menu bar item
        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'BatteryMenuBarItem'")
            return
        }

        // get the string for the button
        var buttonString: NSAttributedString
        if AppDelegate.userSettings.settings.battery.showPercentage {
            buttonString = getPercentageString(currentCharge: currentCharge)
        } else {
            buttonString = getRemainingTimeString(batteryState: batteryState)
        }

        // get the battery icon
        let batteryIcon = getBatteryIcon(currentCharge: currentCharge, isOnAC: isOnAC, isCharging: isCharging, isCharged: isCharged, batteryState: batteryState)
        // the battery icon is nil loading the icon failed
        if batteryIcon == nil {
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
     * Updates the menu of the menu bar item. This function is called during every update interval.
     *
     * - Parameter batteryState: The internal state of the battery.
     */
    private func updateMenuBarMenu(currentCharge: Int, batteryState: InternalBatteryState) {
        // update the title of the menu entries
        chargeMenuEntry.title = "Charge: \(currentCharge)%"
        let remainingTime = getRemainingTimeString(batteryState: batteryState)
        remainingTimeMenuEntry.title = "Remaining: \(remainingTime.string)"
    }

    /**
     * Returns the battery icon depending on the state of the battery.
     *
     * - Parameter isOnAC: Indicates whether the battery is on AC.
     * - Parameter isCharging: Indicates whether the battery is currently charging.
     * - Parameter isCharged: Indicates whether the battery is fully charged.
     * - Parameter batteryState: The internal state of the battery.
     */
    private func getBatteryIcon(currentCharge: Int, isOnAC: Bool, isCharging: Bool, isCharged: Bool, batteryState: InternalBatteryState) -> NSImage? {
        var batteryIcon: NSImage?
        if isOnAC && !isCharging || isCharged {
            batteryIcon = NSImage(named: "BatteryIconPlugged")
        } else if isOnAC && isCharging {
            batteryIcon = NSImage(named: "BatteryIconCharging")
        } else if !isCharging && !isOnAC || !isOnAC && isCharging {
            // the case !isOnAC && isCharging occurs when the machine is unplugged from AC and the remaining time is still calculated
            guard var iconTemplate = NSImage(named: "BatteryIcon") else {
                DDLogError("Failed to load the battery template icon (battery state: \(batteryState)")
                return nil
            }
            batteryIcon = getChargeBatteryIcon(batteryIcon: &iconTemplate, currentCharge: currentCharge)
        }

        if batteryIcon == nil {
            DDLogError("Failed to load the battery icon (battery state: \(batteryState)")
            return nil
        }

        return batteryIcon
    }

    /**
     * Returns the string which indicates the remaining time to charge or discharge.
     *
     * - Possible Values:
     *      * `Calculating`
     *      * The remaining time until full (hh:mm)
     *      * The remaining time until empty (hh:mm)
     *      * `Charged`
     *      * `Not Charging`
     *      * `Error`
     */
    private func getRemainingTimeString(batteryState: InternalBatteryState) -> NSAttributedString {
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

        return buttonString
    }

    /**
     * Returns the string of the remaining time until the battery is fully charged.
     */
    private func getTimeToFullString() -> NSAttributedString {
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
    private func getTimeToEmptyString() -> NSAttributedString {
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
    private func convertMinutesToHours(minutes: Int) -> (hours: Int, minutes: Int) {
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
    private func getPercentageString(currentCharge: Int) -> NSAttributedString {
        // define the attributes
        let attributes = [
            NSAttributedString.Key.font: NSFont(name: "Apple SD Gothic Neo", size: 14)!,
            NSAttributedString.Key.foregroundColor: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black
        ]

        return NSAttributedString(string: "\(currentCharge)%", attributes: attributes)
    }

    /**
     * Returns an image which indicates the charge of the battery.
     *
     * - Parameter batteryIcon: The given image on which the charge indication is drawn.
     * - Parameter currentCharge: The current charge in percentage.
     */
    private func getChargeBatteryIcon(batteryIcon: inout NSImage, currentCharge: Int) -> NSImage {
        // lock the focus
        batteryIcon.lockFocus()

        // the battery icon in x2 resolution has a height of 36 and a width of 18 while the nob at the top is 3 pixels high
        // the borders of the battery icon are 1.5 pixels thick
        let borderWidth = 1.5 / 2
        let chargeBarMargin = 1.5
        let batteryWidth = (18 / 2.0)
        let batteryHeight = ((36 - 3) / 2.0)

        // calculate the width and the max height of the bar
        let chargeBarWidth = batteryWidth - (2 * borderWidth) - (2 * chargeBarMargin) // chargeBar has a margin of 0.5 pixels to the outline of the battery
        let chargeBarMaxHeight = batteryHeight - (2 * borderWidth) - (2 * chargeBarMargin)

        // calculate the current height of the charge bar
        let chargeBarCurrentHeight = (chargeBarMaxHeight / 100) * Double(currentCharge)

        // create and draw the charge bar
        let chargeBar = NSRect(x: borderWidth + chargeBarMargin, y: borderWidth + chargeBarMargin, width: chargeBarWidth, height: chargeBarCurrentHeight)
        (ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black).set()
        chargeBar.fill()

        // unlock the focus
        batteryIcon.unlockFocus()

        return batteryIcon
    }
}
