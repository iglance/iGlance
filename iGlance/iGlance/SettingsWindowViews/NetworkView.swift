//
//  NetworkView.swift
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

class NetworkView: NSViewController {
    // define the outlet and the action of the checkbox which is enabling the network statistic icon
    @IBOutlet var cbNetUsage: NSButton! {
        didSet {
            cbNetUsage.state = AppDelegate.UserSettings.userWantsBandwidth ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }

    @IBAction func cbNetUsage_clicked(_: NSButton) {
        let checked = (cbNetUsage.state == NSButton.StateValue.on)
        AppDelegate.UserSettings.userWantsBandwidth = checked
        NetUsageComponent.sItemBandwidth.isVisible = checked
        UserDefaults.standard.set(checked, forKey: "userWantsBandwidth")
        checked ? MyStatusItems.insertItem(item: MyStatusItems.StatusItems.bandwidth) : MyStatusItems.removeItem(item: MyStatusItems.StatusItems.bandwidth)
    }
}
