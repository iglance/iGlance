//
//  BatteryView.swift
//  iGlance
//
//  MIT License
//
//  Copyright (c) 2018 Cemal K <https://github.com/Moneypulation>, Dominik H <https://github.com/D0miH>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
