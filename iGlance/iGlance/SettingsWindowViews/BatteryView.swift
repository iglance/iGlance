//
//  BatteryView.swift
//  iGlance
//
//  Created by Dominik on 27.10.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

import Cocoa

class BatteryView: NSViewController {
    // define the outlet and the action of the checkbox to display the battery icon
    @IBOutlet var cbBatteryUtil: NSButton! {
        didSet {
            cbBatteryUtil.state = AppDelegate.UserSettings.userWantsBatteryUtil ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbBatteryUtil_clicked(_: NSButton) {
        let checked = (cbBatteryUtil.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsBatteryUtil = checked
        UserDefaults.standard.set(checked, forKey: "userWantsBatteryUtil")
        BatteryComponent.sItemBattery.isVisible = checked
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.battery) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.battery)
    }

    // define the outlet and the action of the checkbox to enable and disable the battery notifications
    @IBOutlet var cbBatteryNotification: NSButton! {
        didSet {
            cbBatteryNotification.state = AppDelegate.UserSettings.userWantsBatteryNotification ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbBatterNotification_clicked(_: NSButton) {
        let checked = (cbBatteryNotification.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsBatteryNotification = checked
        UserDefaults.standard.set(checked, forKey: "userWantsBatteryNotification")
    }

    // define the outlet and the action of the textfield which sets the lower battery notification value
    @IBOutlet var tfLowerBatteryValue: NSTextField! {
        didSet {
            tfLowerBatteryValue.intValue = Int32(AppDelegate.UserSettings.lowerBatteryNotificationValue)
        }
    }

    @IBAction func tfLowerBatteryValue_changed(_: NSTextField) {
        let value: Int = Int(tfLowerBatteryValue.intValue)
        AppDelegate.UserSettings.lowerBatteryNotificationValue = value
        UserDefaults.standard.set(value, forKey: "lowerBatteryNotificationValue")
    }

    // define the outlet and the action of the textfield which sets the upper battery notification value
    @IBOutlet var tfUpperBatteryValue: NSTextField! {
        didSet {
            tfUpperBatteryValue.intValue = Int32(AppDelegate.UserSettings.upperBatteryNotificationValue)
        }
    }

    @IBAction func tfUpperBatteryValue_changed(_: NSTextField) {
        let value: Int = Int(tfUpperBatteryValue.intValue)
        AppDelegate.UserSettings.upperBatteryNotificationValue = value
        UserDefaults.standard.set(value, forKey: "upperBatteryNotificationValue")
    }
}
