//
//  FanView.swift
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

class FanView: NSViewController {
    // define the outlet and the action to enable and disable the fan speed icon
    @IBOutlet var cbFanSpeed: NSButton! {
        didSet {
            cbFanSpeed.state = AppDelegate.UserSettings.userWantsFanSpeed ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBOutlet var cbUnitFanSpeed: NSButton! {
        didSet {
            cbUnitFanSpeed.state = AppDelegate.UserSettings.userWantsUnitFanSpeed ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbFanSpeed_clicked(_: NSButton) {
        let checked = (cbFanSpeed.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsFanSpeed = checked
        FanComponent.sItemFanSpeed.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsFanSpeed")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.fanSpeed) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.fanSpeed)
    }

    @IBAction func cbUnitFanSpeed_clicked(_: NSButton) {
        let checked = (cbUnitFanSpeed.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsUnitFanSpeed = checked
        UserDefaults.standard.set(checked, forKey: "userWantsUnitFanSpeed")
    }
}
