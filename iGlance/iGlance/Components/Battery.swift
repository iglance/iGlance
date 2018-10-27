//
//  Battery.swift
//  iGlance
//
//  Created by Dominik on 12.06.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//
import Foundation
import IOKit.ps

class Battery {

    /**
     * Battery variables
     */
    var currentCapacity: Double = 0.0
    private var previousChargeValue: Double = 0.0
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
        currentCapacity = getBatteryCapacity()
        previousChargeValue = currentCapacity
        alreadyNotified = false
    }

    /**
     *  Notifies the user if the Battery is higher or lower than the upper and lower bounds.
     */
    @objc func notifyUser() {
        currentCapacity = getBatteryCapacity()
        let lower = Double(AppDelegate.UserSettings.lowerBatteryNotificationValue)
        let upper = Double(AppDelegate.UserSettings.upperBatteryNotificationValue)

        if previousChargeValue < upper && currentCapacity >= upper && alreadyNotified == false {
            deliverBatteryNotification(message: "Battery is almost fully charged")
        } else if previousChargeValue > lower && currentCapacity <= lower && alreadyNotified == false {
            deliverBatteryNotification(message: "Battery is low")
        } else if currentCapacity < upper && currentCapacity > lower {
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
            let timeInMinutes = remainingSeconds/60
            let hours = Int(floor(timeInMinutes/60))
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
                if name != nil && name == "InternalBattery-0" && currentCapacity != nil {
                    return Double(currentCapacity!)
                }
            }
        }
        return -1.0
    }
}
