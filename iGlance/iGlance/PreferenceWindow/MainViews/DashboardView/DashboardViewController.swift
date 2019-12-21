//
//  DashboardViewController.swift
//  iGlance
//
//  Created by Dominik on 19.12.19.
//  Copyright © 2019 D0miH. All rights reserved.
//

import Cocoa

class DashboardViewController: MainViewViewController {

    @IBOutlet weak var uptimeLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateUptimeLabel()
    }

    private func updateUptimeLabel() {
        // get the system uptime in seconds
        let uptime = SystemInfo.getSystemUptime()

        uptimeLabel.stringValue = "\(uptime.days) days\n\(uptime.hours) hours\n\(uptime.minutes) min"
    }
}
