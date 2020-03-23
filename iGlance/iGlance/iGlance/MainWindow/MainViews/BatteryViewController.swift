//
//  BatteryViewController.swift
//  iGlance
//
//  Created by Dominik on 22.03.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class BatteryViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var batteryCheckbox: NSButton! {
        didSet {
            batteryCheckbox.state = AppDelegate.userSettings.settings.battery.showBattery ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var batterySelector: NSPopUpButton! {
        didSet {
            if AppDelegate.userSettings.settings.battery.showPercentage {
                // showing percentage is the second option
                batterySelector.selectItem(at: 1)
            } else {
                // showing the remaining time is the first option
                batterySelector.selectItem(at: 0)
            }
        }
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func batteryCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.battery.showBattery = activated

        if activated {
            AppDelegate.menuBarItemManager.battery.show()
        } else {
            AppDelegate.menuBarItemManager.battery.hide()
        }

        DDLogInfo("Did set battery checkbox value to (\(activated))")
    }

    @IBAction private func batterySelectorChanged(_ sender: NSPopUpButton) {
        if batterySelector.indexOfSelectedItem == 0 {
            // the first item is to display the remaining time
            AppDelegate.userSettings.settings.battery.showPercentage = false
        } else {
            // the second item is to display the percentage
            AppDelegate.userSettings.settings.battery.showPercentage = true
        }

        // update the menu bar items to make the change visible immediately
        AppDelegate.menuBarItemManager.updateMenuBarItems()

        DDLogInfo("Selected option to display battery percentage: \(AppDelegate.userSettings.settings.battery.showPercentage)")
    }
}
