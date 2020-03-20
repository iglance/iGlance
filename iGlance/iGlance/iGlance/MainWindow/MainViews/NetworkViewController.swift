//
//  NetworkViewController.swift
//  iGlance
//
//  Created by Dominik on 09.03.20.
//  Copyright © 2020 D0miH. All rights reserved.
//

import Cocoa
import CocoaLumberjack

class NetworkViewController: MainViewViewController {
    // MARK: -
    // MARK: Outlets
    @IBOutlet private var networkUsageCheckbox: NSButton!

    // MARK: -
    // MARK: Actions
    @IBAction private func networkUsageCheckboxChanged(_ sender: NSButton) {
        // get the boolean value of the checkbox
        let activated = sender.state == NSButton.StateValue.on

        // set the user setting
        AppDelegate.userSettings.settings.network.showBandwidth = activated

        if activated {
            AppDelegate.menuBarItemManager.network.show()
        } else {
            AppDelegate.menuBarItemManager.network.hide()
        }

        DDLogInfo("Did set network checkbox value to (\(activated))")
    }
}
