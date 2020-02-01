//
//  CpuViewController.swift
//  iGlance
//
//  Created by Dominik on 31.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa

class CpuViewController: MainViewViewController {
    @IBOutlet private var cpuTempCheckbox: NSButton! {
        didSet {
            cpuTempCheckbox.state = AppDelegate.userSettings.settings.cpu.showTemperature ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction private func cpuTempCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.cpu.showTemperature = activated

        // show or hide the menu bar item
        if activated {
            AppDelegate.menuBarItemManager.cpuTemp.show()
        } else {
            AppDelegate.menuBarItemManager.cpuTemp.hide()
        }
    }
}
