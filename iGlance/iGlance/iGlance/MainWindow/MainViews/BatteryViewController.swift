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
}
