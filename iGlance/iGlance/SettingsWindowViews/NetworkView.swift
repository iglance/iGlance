//
//  NetworkView.swift
//  iGlance
//
//  Created by Dominik on 27.10.18.
//  Copyright © 2018 iGlance Corp. All rights reserved.
//

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
