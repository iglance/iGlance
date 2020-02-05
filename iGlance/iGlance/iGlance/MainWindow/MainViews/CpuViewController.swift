//
//  CpuViewController.swift
//  iGlance
//
//  Created by Dominik on 31.01.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class CpuViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets

    @IBOutlet private var cpuTempCheckbox: NSButton! {
        didSet {
            cpuTempCheckbox.state = AppDelegate.userSettings.settings.cpu.showTemperature ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    @IBOutlet private var cpuUsageCheckbox: NSButton! {
        didSet {
            cpuUsageCheckbox.state = AppDelegate.userSettings.settings.cpu.showUsage ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet private var usageColorWell: NSColorWell! {
        didSet {
            usageColorWell.color = AppDelegate.userSettings.settings.cpu.usageBarColor.nsColor
        }
    }

    // MARK: -
    // MARK: Actions

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

        DDLogInfo("Did set cpu temp checkbox value to (\(activated))")
    }

    @IBAction private func cpuUsageCheckboxChanged(_ sender: NSButton) {
        // get the boolean to the current state of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user settings
        AppDelegate.userSettings.settings.cpu.showTemperature = activated

        // show or hide the menu bar item
        if activated {
            AppDelegate.menuBarItemManager.cpuUsage.show()
        } else {
            AppDelegate.menuBarItemManager.cpuUsage.hide()
        }

        DDLogInfo("Did set cpu usage checkbox value to (\(activated))")
    }

    @IBAction private func usageColorWellChanged(_ sender: NSColorWell) {
        // set the color of the usage bar
        AppDelegate.userSettings.settings.cpu.usageBarColor = CodableColor(nsColor: sender.color)

        DDLogInfo("Changed usage bar color to (\(sender.color))")
    }
}
