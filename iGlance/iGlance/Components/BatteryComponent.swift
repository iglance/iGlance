//
//  Battery.swift
//  iGlance
//
//  MIT License
//
//  Copyright (c) 2018 Cemal K <https://github.com/Moneypulation>, Dominik H <https://github.com/D0miH>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Cocoa
import IOKit.ps

class BatteryComponent {
    /// The status item of the battery.
    static let sItemBattery = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    /// The button of the battery in the status bar.
    var btnBattery: NSStatusBarButton?
    /// The menu of the status item.
    var menuBattery: NSMenu?

    /// The current capacity of the battery.
    var currentCapacity: Double = 0.0
    /// The charge value before the last update.
    private var previousChargeValue: Double = 0.0
    /// Indicates whether the user was already notified.
    private var alreadyNotified: Bool = false

    /**
     *  - timeInSeconds > 0:    means a valid time is given
     *  - timeInSeconds = -1:   means the reamaining time is calculated
     *  - timeInSeconds = -2:   means AC power is being used
     */
    struct RemainingBatteryTime {
        var timeInSeconds: Double
        var hours: Int
        var minutes: Int
    }

    init() {
        // initialize the values of the battery
        currentCapacity = getBatteryCapacity()
        previousChargeValue = currentCapacity
        alreadyNotified = false

        // initialize the menu of the status item
        menuBattery = NSMenu()
        menuBattery?.addItem(NSMenuItem(title: "Capacity: ", action: nil, keyEquivalent: ""))
        menuBattery?.addItem(NSMenuItem(title: "Remaining time: ", action: nil, keyEquivalent: ""))
        menuBattery?.addItem(NSMenuItem.separator())
        menuBattery?.addItem(NSMenuItem(title: "Settings", action: #selector(AppDelegate.settings_clicked), keyEquivalent: "s"))
        menuBattery?.addItem(NSMenuItem.separator())
        menuBattery?.addItem(NSMenuItem(title: "Quit iGlance", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        BatteryComponent.sItemBattery.menu = menuBattery
    }

    /**
     *  Initializes the status item button of the battery. This function has to be called after the application did finished launching
     */
    func initialize() {
        btnBattery = BatteryComponent.sItemBattery.button
    }

    /**
     *  Notifies the user if the Battery is higher or lower than the upper and lower bounds.
     */
    @objc func notifyUser() {
        currentCapacity = getBatteryCapacity()
        let lower = Double(AppDelegate.UserSettings.lowerBatteryNotificationValue)
        let upper = Double(AppDelegate.UserSettings.upperBatteryNotificationValue)

        if previousChargeValue < upper, currentCapacity >= upper, alreadyNotified == false {
            deliverBatteryNotification(message: "Battery is almost fully charged")
        } else if previousChargeValue > lower, currentCapacity <= lower, alreadyNotified == false {
            deliverBatteryNotification(message: "Battery is low")
        } else if currentCapacity < upper, currentCapacity > lower {
            alreadyNotified = false
            NSUserNotificationCenter.default.removeAllDeliveredNotifications()
        }

        previousChargeValue = currentCapacity
    }

    /**
     *  Triggers a notification with the given message.
     *
     *  - Parameters:
     *      - message:  The message which is displayed in the notification.
     */
    func deliverBatteryNotification(message: String) {
        let notification = NSUserNotification()
        notification.identifier = "batteryFullNotification"
        notification.title = "Battery Info"
        notification.subtitle = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
        alreadyNotified = true
    }

    /**
     *  Returns the remaining time of the battery.
     *
     *  - Returns:  The remaining time as a RemainingBatterTime structure.
     */
    func getRemainingBatteryTime() -> RemainingBatteryTime {
        let remainingSeconds: CFTimeInterval = IOPSGetTimeRemainingEstimate()
        if remainingSeconds > 0.0 {
            let timeInMinutes = remainingSeconds / 60
            let hours = Int(floor(timeInMinutes / 60))
            let minutes = Int(timeInMinutes) % 60
            return RemainingBatteryTime(timeInSeconds: remainingSeconds, hours: hours, minutes: minutes)
        } else if remainingSeconds == -1.0 {
            return RemainingBatteryTime(timeInSeconds: remainingSeconds, hours: 0, minutes: 0)
        } else {
            return RemainingBatteryTime(timeInSeconds: remainingSeconds, hours: 0, minutes: 0)
        }
    }

    /**
     *  Returns the remaining capacity of the battery.
     *
     *  - Returns:
     *      - Capacity: The remaining capacity in percentage.
     */
    func getBatteryCapacity() -> Double {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sources = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array
        for powerSource in sources {
            if let info = IOPSGetPowerSourceDescription(snapshot, powerSource).takeUnretainedValue() as? [String: AnyObject] {
                let name = info[kIOPSNameKey] as? String
                let currentCapacity = info[kIOPSCurrentCapacityKey] as? Int
                if name != nil, name == "InternalBattery-0", currentCapacity != nil {
                    return Double(currentCapacity!)
                }
            }
        }
        return -1.0
    }

    /**
     *  This function updates the displayed time in the status item and the menu entries of the battery status item. The update is called every update interval.
     */
    func updateBatteryItem() {
        // determine the color scheme and set the font color accordingly
        var batteryIconString: String?
        var fontColor: NSColor?
        if InterfaceStyle() == InterfaceStyle.Dark {
            batteryIconString = "battery-icon-white"
            fontColor = NSColor.white
        } else {
            batteryIconString = "battery-icon-black"
            fontColor = NSColor.black
        }

        // get the remaining capacity of the battery
        let batteryCapacity = AppDelegate.myBattery.getBatteryCapacity()
        // get the remaining time
        let remainingTime = AppDelegate.myBattery.getRemainingBatteryTime()

        // update the button to display the remaining time
        let imageFinal = NSImage(size: NSSize(width: 32, height: 32))
        imageFinal.lockFocus()
        // get the battery icon and draw the image
        let batteryIcon = NSImage(named: batteryIconString!)
        batteryIcon?.draw(at: NSPoint(x: 0, y: 0), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)

        // display the current status of the remaining time.
        var timeValue: String?
        let batteryTime: BatteryComponent.RemainingBatteryTime = remainingTime
        if batteryTime.timeInSeconds > 0.0 {
            // if th remaining time is greater than zero display the time
            timeValue = String(batteryTime.hours) + ":" + String(format: "%02d", batteryTime.minutes)
        } else if batteryTime.timeInSeconds == -1.0 {
            // if the remaining time is -1 the time is calculated
            timeValue = "calc."
        } else if batteryTime.timeInSeconds == -2.0 {
            // if the remaining time is -2 the laptop is plugged into a power source
            timeValue = "AC"
        }

        // draw th remaining time in front of the icon
        let font = NSFont(name: "Apple SD Gothic Neo Bold", size: 9.0)
        let attrString = NSMutableAttributedString(string: timeValue!)
        attrString.addAttribute(.font, value: font as Any, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(.foregroundColor, value: fontColor as Any, range: NSMakeRange(0, attrString.length))
        let size = attrString.size()
        attrString.draw(at: NSPoint(x: 16 - size.width / 2, y: 16 - size.height / 2))

        // unlock the focus and update the image of the button
        imageFinal.unlockFocus()
        btnBattery?.image = imageFinal

        // update the menu entry with the current remaining time
        let timeEntry = menuBattery?.item(at: 1)
        timeEntry?.title = "Remaining time: " + timeValue!

        // update the menu entry with the current capacity
        let capacityEntry = menuBattery?.item(at: 0)
        capacityEntry?.title = "Capacity: " + String(format: "%02d", Int(batteryCapacity)) + "%"
    }
}
