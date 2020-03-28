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
            batteryCheckbox.state = AppDelegate.userSettings.settings.battery.showBatteryMenuBarItem ? .on : .off
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

    @IBOutlet private var displayedInfoStackView: NSStackView! {
        didSet {
            // if the usage is not displayed hide it
            if !AppDelegate.userSettings.settings.battery.showBatteryMenuBarItem {
                displayedInfoStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var lowBatteryNotificationCheckbox: NSButton! {
        didSet {
            lowBatteryNotificationCheckbox.state = AppDelegate.userSettings.settings.battery.lowBatteryNotification.notifyUser ? .on : .off
        }
    }

    @IBOutlet private var highBatteryNotificationCheckbox: NSButton! {
        didSet {
            highBatteryNotificationCheckbox.state = AppDelegate.userSettings.settings.battery.highBatteryNotification.notifyUser ? .on : .off
        }
    }

    @IBOutlet private var lowBatteryNotificationTextField: NSTextField! {
        didSet {
            lowBatteryNotificationTextField.intValue = Int32(AppDelegate.userSettings.settings.battery.lowBatteryNotification.value)

            // set the action that is called when the user finished editing
            lowBatteryNotificationTextField.target = self
            lowBatteryNotificationTextField.action = #selector(lowBatteryNotificationTextFieldChanged(_:))
        }
    }

    @IBOutlet private var lowBatteryNotificationStackView: NSStackView! {
        didSet {
            if !AppDelegate.userSettings.settings.battery.lowBatteryNotification.notifyUser {
                lowBatteryNotificationStackView.isHidden = true
            }
        }
    }

    @IBOutlet private var highBatteryNotificationTextField: NSTextField! {
        didSet {
            highBatteryNotificationTextField.intValue = Int32(AppDelegate.userSettings.settings.battery.highBatteryNotification.value)

            // set the action that is called when the user finished editing
            highBatteryNotificationTextField.target = self
            highBatteryNotificationTextField.action = #selector(highBatteryNotificationTextFieldChanged(_:))
        }
    }

    @IBOutlet private var highBatteryNotificationStackView: NSStackView! {
        didSet {
            if !AppDelegate.userSettings.settings.battery.highBatteryNotification.notifyUser {
                highBatteryNotificationStackView.isHidden = true
            }
        }
    }

    // MARK: -
    // MARK: Actions

    @IBAction private func batteryCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == .on

        // set the user settings
        AppDelegate.userSettings.settings.battery.showBatteryMenuBarItem = activated

        if activated {
            AppDelegate.menuBarItemManager.battery.show()
        } else {
            AppDelegate.menuBarItemManager.battery.hide()
        }

        // hide the other settings
        displayedInfoStackView.isHidden = !activated

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

    @IBAction private func lowBatteryNotificationCheckboxChanged(_ sender: NSButton) {
        // get the status of the checkbox
        let activated = sender.state == .on

        // update the user settings
        AppDelegate.userSettings.settings.battery.lowBatteryNotification.notifyUser = activated

        //  hide the value text field stack view if necessary
        lowBatteryNotificationStackView.isHidden = !activated
    }

    @IBAction private func highBatteryNotificationCheckboxChanged(_ sender: NSButton) {
        // get the status of the checkbox
        let activated = sender.state == .on

        // update the user settings
        AppDelegate.userSettings.settings.battery.highBatteryNotification.notifyUser = activated

        //  hide the value text field stack view if necessary
        highBatteryNotificationStackView.isHidden = !activated
    }

    @objc
    private func lowBatteryNotificationTextFieldChanged(_ sender: NSTextField) {
        // get the value
        let value = Int(sender.intValue)

        // update the user settings
        AppDelegate.userSettings.settings.battery.lowBatteryNotification.value = value

        // set the first responder to nil in order to loose focus
        lowBatteryNotificationTextField.window?.makeFirstResponder(lowBatteryNotificationTextField.window?.contentView)
    }

    @objc
    private func highBatteryNotificationTextFieldChanged(_ sender: NSTextField) {
        // get the value
        let value = Int(sender.intValue)

        // update the user settings
        AppDelegate.userSettings.settings.battery.highBatteryNotification.value = value

        // set the first responder to nil in order to loose focus
        highBatteryNotificationTextField.window?.makeFirstResponder(highBatteryNotificationTextField.window?.contentView)
    }
}
