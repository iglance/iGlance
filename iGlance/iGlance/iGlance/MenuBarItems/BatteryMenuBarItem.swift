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
import IOKit.ps

class BatteryMenuBarItem: MenuBarItem {
    override init() {
        // initialize the last battery charge value
        let charge = AppDelegate.systemInfo.battery.getCharge()
        self.lastBatteryCharge = charge

        super.init()

        // update the title of the menu entries
        chargeMenuEntry.title = "Charge: \(charge)%"
        let batteryState = AppDelegate.systemInfo.battery.getInternalBatteryState()
        let remainingTime = getRemainingTimeString(batteryState: batteryState)
        remainingTimeMenuEntry.title = "Remaining: \(remainingTime.string)"

        // add them to the menu
        menuItems.append(contentsOf: [chargeMenuEntry, remainingTimeMenuEntry, NSMenuItem.separator()])
    }

    // MARK: -
    // MARK: Private Variables
    private let chargeMenuEntry = NSMenuItem(title: "Charge: N/A%", action: nil, keyEquivalent: "")
    private let remainingTimeMenuEntry = NSMenuItem(title: "Remaining: N/A", action: nil, keyEquivalent: "")

    /// The charge of the battery that was read during the last update
    private var lastBatteryCharge: Int

    // MARK: -
    // MARK: Protocol Implementations

    func update() {
        self.statusItem.isVisible = AppDelegate.userSettings.settings.battery.showBatteryMenuBarItem
        if !self.statusItem.isVisible {
            return
        }

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

        // update the menu bar icon and the menu of the menu bar item
        updateMenuBarIcon(currentCharge: currentCharge, isOnAC: isOnAC, isCharging: isCharging, isCharged: isCharged, batteryState: batteryState)
        updateMenuBarMenu(currentCharge: currentCharge, batteryState: batteryState)

        // notify the user about the capacity of the battery if necessary
        if AppDelegate.userSettings.settings.battery.lowBatteryNotification.notifyUser {
            deliverLowBatteryNotification(currentCharge: currentCharge)
        }
        if AppDelegate.userSettings.settings.battery.highBatteryNotification.notifyUser {
            deliverHighBatteryNotification(currentCharge: currentCharge)
        }

        self.lastBatteryCharge = currentCharge
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

        var batteryIcon: NSImage?
        if AppDelegate.userSettings.settings.battery.showBatteryIcon {
            // get the battery icon
            batteryIcon = getBatteryIcon(currentCharge: currentCharge, isOnAC: isOnAC, isCharging: isCharging, isCharged: isCharged, batteryState: batteryState)
        }
        let batteryIconSize: CGSize = batteryIcon?.size ?? .zero

        // create the menu bar image
        let marginBetweenIconAndString = CGFloat(5)
        var iconWidth: CGFloat = buttonString.size().width
        if batteryIconSize.width > .ulpOfOne {
            iconWidth += batteryIconSize.width + marginBetweenIconAndString
        }

        let iconSize = NSSize(width: iconWidth, height: self.menuBarHeight)
        let image = NSImage(size: iconSize)

        // lock the image to render the string
        image.lockFocus()

        // render the string
        buttonString.draw(at: NSPoint(x: iconSize.width - buttonString.size().width,
                                      y: iconSize.height / 2 - buttonString.size().height / 2))

        // tint the battery icon to match it to the theme of the os
        if let tintedBatteryIcon = batteryIcon?.tint(color: ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black) {
            // render the battery icon
            tintedBatteryIcon.draw(
                at: NSPoint(x: 0, y: (iconSize.height - tintedBatteryIcon.size.height) / 2),
                from: NSRect.zero,
                operation: .sourceOver,
                fraction: 1.0)
        }

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
            guard var iconTemplate = NSImage(named: "BatteryIcon")?.copy() as? NSImage else {
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
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13),
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
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13),
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
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13),
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
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 13),
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

        // the battery icon has a height of 18 and a width of 16 while the nob at the top is 1 pixel high.
        // The borders of the battery icon are 1 pixel thick
        let borderWidth = 1.0
        // the margin of the charge indicator to the battery icon border
        let chargeBarMargin = 1.5
        // the width of the battery in pixel (including the border)
        let batteryWidth = 8.0
        // the height of the knob in pixel
        let knobHeight = 1.0
        // the height of the main part of the battery in pixel
        let batteryHeight = 18.0 - knobHeight

        // calculate the width and the max height of the charge indicator
        let chargeBarWidth = batteryWidth - (2 * borderWidth) - (2 * chargeBarMargin)
        let chargeBarMaxHeight = batteryHeight - (2 * borderWidth) - (2 * chargeBarMargin)

        // calculate the current height of the charge indicator
        let chargeBarCurrentHeight = (chargeBarMaxHeight / 100) * Double(currentCharge)

        // create and draw the charge indicator rectangle as a rounded rectangle
        let chargeBar = NSRect(x: borderWidth + chargeBarMargin, y: borderWidth + chargeBarMargin, width: chargeBarWidth, height: chargeBarCurrentHeight)
        let roundedRect = NSBezierPath(roundedRect: chargeBar, xRadius: 1.5, yRadius: 1.5)
        (ThemeManager.isDarkTheme() ? NSColor.white : NSColor.black).set()
        roundedRect.fill()

        // unlock the focus
        batteryIcon.unlockFocus()

        return batteryIcon
    }

    /**
     * Delivers the low battery charge notification if the threshold is reached.
     *
     *  - Parameter currentCharge: The current charge of the battery.
     */
    private func deliverLowBatteryNotification(currentCharge: Int) {
        let lowThreshold = AppDelegate.userSettings.settings.battery.lowBatteryNotification.value

        if self.lastBatteryCharge > lowThreshold && currentCharge <= lowThreshold {
            deliverNotification(title: "Battery Info", message: "Battery is low", identifier: BATTERY_NOTIFICATION_IDENTIFIER)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                DDLogInfo("Removing all delivered notifications")
                NSUserNotificationCenter.default.removeAllDeliveredNotifications()
            }
        }
    }

    /**
     * Delivers the high battery charge notification if the threshold is reached.
     *
     *  - Parameter currentCharge: The current charge of the battery.
     */
    private func deliverHighBatteryNotification(currentCharge: Int) {
        let highThreshold = AppDelegate.userSettings.settings.battery.highBatteryNotification.value

        if self.lastBatteryCharge < highThreshold &&  currentCharge >= highThreshold {
            deliverNotification(title: "Battery Info", message: "Battery is almost fully charged", identifier: BATTERY_NOTIFICATION_IDENTIFIER)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                DDLogInfo("Removing all delivered notifications")
                NSUserNotificationCenter.default.removeAllDeliveredNotifications()
            }
        }
    }

    /**
     * Notifies the user with a notification with the given title and message.
     */
    private func deliverNotification(title: String, message: String, identifier: String) {
        // create the notification and set its properties
        let notification = NSUserNotification()
        notification.identifier = identifier
        notification.title = title
        notification.subtitle = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
