//
//  FanMenuBarItem.swift
//  iGlance
//
//  Created by Dominik on 18.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Foundation
import CocoaLumberjack

class FanMenuBarItem: MenuBarItem {
    private let fanCount: Int

    override init() {
        fanCount = AppDelegate.systemInfo.fan.getNumberOfFans()

        super.init()
    }

    // MARK: -
    // MARK: Protocol Implementations
    func update() {
        var curMaxFanSpeed = 0
        for id in 0..<fanCount {
            // get the fan speed for the current fan
            let fanSpeed = AppDelegate.systemInfo.fan.getCurrentFanSpeed(id: id)

            // if the rpm of the current fan is higher than the saved fan speed update it
            if curMaxFanSpeed < fanSpeed {
                curMaxFanSpeed = fanSpeed
            }
        }

        guard let button = self.statusItem.button else {
            DDLogError("Could not retrieve the button of the 'FanMenuBarItem'")
            return
        }

        // add the unit if the user wants it to be displayed
        var unitString = ""
        if AppDelegate.userSettings.settings.fan.showFanSpeedUnit {
            unitString = "RPM"
        }

        button.title = String(Int(curMaxFanSpeed)) + " " + unitString
    }
}
