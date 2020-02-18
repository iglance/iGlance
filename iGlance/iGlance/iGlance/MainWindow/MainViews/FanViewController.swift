//
//  FanViewController.swift
//  iGlance
//
//  Created by Dominik on 18.02.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class FanViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var fanSpeedCheckbox: NSButton! {
        didSet {
            fanSpeedCheckbox.state = AppDelegate.userSettings.settings.fan.showFanSpeed ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var fanSpeedUnitCheckbox: NSButton! {
        didSet {
            fanSpeedUnitCheckbox.state = AppDelegate.userSettings.settings.fan.showFanSpeedUnit ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func fanSpeedCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.fan.showFanSpeed = activated

        if activated {
            AppDelegate.menuBarItemManager.fan.show()
        } else {
            AppDelegate.menuBarItemManager.fan.hide()
        }

        DDLogInfo("Did set fan speed checkbox value to (\(activated))")
    }

    @IBAction private func fanSpeedUnitCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.fan.showFanSpeedUnit = activated

        // update the menu bar items to visualize the change
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Did set fan speed unit checkbox value to (\(activated))")
    }
}
