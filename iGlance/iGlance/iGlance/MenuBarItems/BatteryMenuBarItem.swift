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

        // TODO: display a battery icon and depending on the state of the battery display a plugged in symbol on the battery

        if AppDelegate.userSettings.settings.battery.showPercentage {
            button.title = getPercentageString()
        } else {
            button.title = getRemainingTimeString()
        }
    }

    /**
     * Converts the given number of minutes into hours and minutes.
     */
    func convertMinutesToHours(minutes: Int) -> (hours: Int, minutes: Int) {
        let hours = Int(floor(Double(minutes) / 60))
        let minutes = minutes % 60

        return (hours: hours, minutes: minutes)
    }

    /**
     * Returns the string that is displaying the remaining time until the battery is fully charged or empty.
     */
    func getRemainingTimeString() -> String {
        // get the remaining time
        let timeToEmptyMinutes = AppDelegate.systemInfo.battery.timeToEmpty()
        let timeToFullMinutes = AppDelegate.systemInfo.battery.timeToFullCharge()
        // get whether the battery is on ac
        let onAC = AppDelegate.systemInfo.battery.isOnAC()
        //  get whether the battery is charging
        let charging = AppDelegate.systemInfo.battery.isCharging()
        // get whether the battery is fully charged
        let fullyCharged = AppDelegate.systemInfo.battery.isFullyCharged()

        if !onAC && timeToEmptyMinutes == -1 || onAC && timeToFullMinutes == -1 {
            // if the machine is not charging and no time is available, the time is calculated
            return "Calculating"
        } else if onAC &&  !charging {
            // if the machine is on ac but the battery is not charging
            return "Not Charging"
        } else if onAC && fullyCharged {
            // if the machine is charging and the battery is fully charged
            return "Charged"
        } else if onAC && timeToFullMinutes != -1 {
            let timeToFull = convertMinutesToHours(minutes: timeToFullMinutes)
            return "\(timeToFull.hours):\(String(format: "%02d", timeToFull.minutes))"
        } else if !onAC && timeToEmptyMinutes != -1 {
            let timeToEmpty = convertMinutesToHours(minutes: timeToEmptyMinutes)
            return "\(timeToEmpty.hours):\(String(format: "%02d", timeToEmpty.minutes))"
        }

        return "Err"
    }

    /**
     * Returns the string that is displaying the current charge of the battery in percentage.
     */
    func getPercentageString() -> String {
        let charge = AppDelegate.systemInfo.battery.getCharge()

        return "\(charge)%"
    }
}
