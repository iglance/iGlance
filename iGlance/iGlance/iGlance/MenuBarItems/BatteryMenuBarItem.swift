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

        // get the remaining time
        let timeToEmptyMinutes = AppDelegate.systemInfo.battery.timeToEmpty()
        let timeToFullMinutes = AppDelegate.systemInfo.battery.timeToFullCharge()
        // get whether the battery is on ac
        let onAC = AppDelegate.systemInfo.battery.isOnAC()
        // get whether the battery is fully charged
        let fullyCharged = AppDelegate.systemInfo.battery.isFullyCharged()

        // TODO: depending on the state of the battery display a plugged in symbol

        if !onAC && (timeToEmptyMinutes == -1 || timeToFullMinutes == -1) {
            // if the machine is not charging and no time is available, the time is calculated
            button.title = "Calc."
        } else if onAC && fullyCharged {
            // if the machine is charging and the battery is fully charged
            button.title = "Charged"
        } else if onAC && timeToFullMinutes != -1 {
            let timeToFull = convertMinutesToHours(minutes: timeToFullMinutes)
            button.title = "\(timeToFull.hours):\(timeToFull.minutes)"
        } else if !onAC && timeToEmptyMinutes != -1 {
            let timeToEmpty = convertMinutesToHours(minutes: timeToEmptyMinutes)
            button.title = "\(timeToEmpty.hours):\(timeToEmpty.minutes)"
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
}
